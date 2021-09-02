package why.dbus.server;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import tink.macro.BuildCache;
import why.dbus.Signature;
import why.dbus.macro.Helpers.*;

using why.dbus.util.Tools;
using tink.MacroApi;

class Properties {
	public static function build() {
		return BuildCache.getTypeN('why.dbus.server.Properties', (ctx:BuildContextN) -> {
			final name = ctx.name;
			final types = ctx.types;
			final cts = types.map(t -> t.toComplex());
			
			final def = macro class $name extends why.dbus.server.Properties.PropertiesBase {}
			
			def.fields.push({
				access: [APublic],
				name: 'new',
				pos: ctx.pos,
				kind: FFun({
					args: [for(i => ct in cts) {name: 'v$i', type: macro:why.dbus.server.Interface<$ct>}],
					expr: {
						final entries = [for(i => type in types) {
							final ct = cts[i];
							macro $v{type.getInterfaceName()} => new why.dbus.server.Properties.InterfaceProperties<$ct>($i{'v$i'});
						}];
						macro super(${macro $a{entries}});
					}
				}),
			});
			
			def.pack = ['why', 'dbus', 'server'];
			def;
		});
	}
}

class InterfaceProperties {
	static final VARIANT = macro:why.dbus.types.Variant;
	
	public static function build() {
		return BuildCache.getType('why.dbus.server.InterfaceProperties', (ctx:BuildContext) -> {
			final name = ctx.name;
			final type = ctx.type;
			final ct = type.toComplex();
			
			final getCases:Array<Case> = [];
			final getAllCases:Array<Expr> = [];
			final setCases:Array<Case> = [];
			final listeners:Array<Expr> = [];
			
			final def = macro class $name implements why.dbus.server.Properties.InterfacePropertiesObject {
				public final changed:tink.core.Signal<tink.core.Named<why.dbus.types.Variant>>;
				public final target:why.dbus.server.Interface<$ct>;
				
				public function new(target) {
					this.target = target;
					this.changed = new tink.core.Signal(cb -> $a{listeners});
				}
				
				public function get(name:String):tink.core.Promise<$VARIANT> {
					return ${ESwitch(macro name, getCases, macro new tink.core.Error(NotFound, 'Property not found')).at()}
				}
				
				public function getAll():tink.core.Promise<Map<String, $VARIANT>> {
					final map = new Map<String, $VARIANT>();
					return tink.core.Promise.inParallel(${macro $a{getAllCases}}).swap(map);
				}
				
				public function set(name:String, value:$VARIANT):tink.core.Promise<tink.core.Noise> {
					return ${ESwitch(macro name, setCases, macro new tink.core.Error(NotFound, 'Property not found')).at()}
				}
			}
			
			switch type.getFields() {
				case Success(fields):
					for(f in fields) {
						final fname = f.name;
						final member = f.getMemberName();
						switch f.type.reduce() {
							case TFun(args, unwrap(_) => ret):
								// skip
							case getSignal(_) => Some(types): 
								// skip
							case _:
								var canRead = true, canWrite = true;
								switch [f.meta.has(':readonly'), f.meta.has(':writeonly')] {
									case [true, true]:
										f.pos.error('Either @:readonly or @:writeonly, but not both');
									case [true, false]:
										canWrite = false;
									case [false, true]:
										canRead = false;
									case [false, false]:
										// skip
								}
								
								getCases.push({
									values: [macro $v{member}],
									expr: 
										if(canRead)
											macro target.$fname.get().next(v -> new why.dbus.types.Variant(${(f.type:SignatureCode)}, v));
										else
											macro new tink.core.Error(NotFound, 'Member "' + $v{member} + '" not readable'),
								});
								getAllCases.push(
									if(canRead)
										macro target.$fname.get()
											.withSideEffect(v -> map[$v{member}] = new why.dbus.types.Variant(${(f.type:SignatureCode)}, v))
											.noise()
									else
										macro tink.core.Promise.NOISE
								);
								setCases.push({
									values: [macro $v{member}],
									expr:
										if(canWrite)
											macro target.$fname.set(value.value)
										else
											macro new tink.core.Error(NotFound, 'Member "' + $v{member} + '" not writable'),
								});
								if(canRead)
									listeners.push(macro target.$fname.changed.handle(v -> {
										cb(new tink.core.Named($v{member}, new why.dbus.types.Variant(${(f.type:SignatureCode)}, v)));
									}));
						}
					}
				case Failure(e):
					throw e;
			}
			
			def.pack = ['why', 'dbus', 'server'];
			def;
		});
	}
}