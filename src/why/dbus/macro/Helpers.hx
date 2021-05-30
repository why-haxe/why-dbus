package why.dbus.macro;

import haxe.macro.Expr;
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
			case TAbstract(_.get() => {name: _.startsWith('Signal') => true, pack: ['why', 'dbus'], type: TAbstract(_.get() => {name: 'Signal', pack: ['tink', 'core']}, [TAbstract(_.get() => {type: TType(_, types)}, _)])}, _):
				Some(types);
			case _:
				None;
		}
	}
}