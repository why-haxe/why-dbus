package why.dbus.server;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import tink.macro.BuildCache;
import why.dbus.Signature;
import why.dbus.util.Tools.*;
import why.dbus.macro.Helpers.*;

using tink.MacroApi;

class Properties {
	static final VARIANT = macro:why.dbus.types.Variant;
	
	public static function build() {
		return BuildCache.getType('why.dbus.server.Properties', (ctx:BuildContext) -> {
			final name = ctx.name;
			final type = ctx.type;
			final ct = type.toComplex();
			
			final getCases:Array<Case> = [];
			final getAllCases:Array<Expr> = [];
			final setCases:Array<Case> = [];
			
			final def = macro class $name extends why.dbus.server.Properties.PropertiesBase<why.dbus.server.Interface<$ct>> {
				function get(name:String):tink.core.Promise<$VARIANT> {
					return ${ESwitch(macro name, getCases, macro new tink.core.Error(NotFound, 'Property not found')).at()}
				}
				
				function getAll():tink.core.Promise<Map<String, $VARIANT>> {
					final map = new Map<String, $VARIANT>();
					return tink.core.Promise.inParallel(${macro $a{getAllCases}}).swap(map);
				}
				
				function set(name:String, value:$VARIANT):tink.core.Promise<tink.core.Noise> {
					return ${ESwitch(macro name, setCases, macro new tink.core.Error(NotFound, 'Property not found')).at()}
				}
			}
			
			switch type.getFields() {
				case Success(fields):
					for(f in fields) {
						final getter = 'get_' + f.name;
						final setter = 'set_' + f.name;
						switch f.type.reduce() {
							case TFun(args, unwrap(_) => ret):
								// skip
							case getSignal(_) => Some(types): 
								// skip
							case _:
								getCases.push({
									values: [macro $v{capitalize(f.name)}],
									expr: macro target.$getter().next(v -> new why.dbus.types.Variant(${(f.type:SignatureCode)}, v)),
								});
								getAllCases.push({
									macro target.$getter()
										.withSideEffect(v -> map[$v{capitalize(f.name)}] = new why.dbus.types.Variant(${(f.type:SignatureCode)}, v))
										.noise();
								});
								setCases.push({
									values: [macro $v{capitalize(f.name)}],
									expr: macro target.$setter(value.value),
								});
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