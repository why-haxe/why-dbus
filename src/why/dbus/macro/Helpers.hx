package why.dbus.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using Lambda;
using StringTools;
using tink.MacroApi;
using tink.CoreApi;

class Helpers {
	public static function asynchronize(type:Type):ComplexType {
		return switch type.getID() {
			case 'Void':
				macro:tink.core.Promise<tink.core.Noise>;
			case _:
				final ct = type.toComplex();
				macro:tink.core.Promise<$ct>;
		}
	}

	public static function getSignal(type:Type):Option<Array<Type>> {
		return switch type {
			case TAbstract(_.get() => {name: _.startsWith('Signal') => true, pack: ['why', 'dbus'], type: TType(_, types)}, _):
				Some(types);
			case _:
				None;
		}
	}
	
	
	public static function unwrap(type:Type):Type {
		final ct = type.toComplex();
		
		return
			if(type.getID() == 'Void')
				Context.getType('tink.core.Noise');
			else Context.typeof(macro {
				function get<A>(p:tink.core.Promise<A>):A throw null;
				get((null:$ct));
			});
	}
}