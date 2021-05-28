package why.dbus.macro;

import haxe.macro.Expr;
import haxe.macro.Type;

using tink.MacroApi;

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

	
}