package why.dbus.util;

import haxe.macro.Type;

using tink.MacroApi;

class Tools {
	public static function capitalize(v:String) {
		return v.charAt(0).toUpperCase() + v.substr(1);
	}
	
	public static function getInterfaceName(type:Type) {
		return switch type {
			case TInst(_.get() => {meta: meta}, _):
				switch meta.extract(':name') {
					case []: type.toComplex().toString();
					case [{params: [{expr: EConst(CString(v))}]}]: v;
					case m: m[0].pos.error('Invalid use of @:name');
				}
			case _:
				throw '[why-dbus] Expected interface';
		}
	}
	
	public static function getMemberName(field:ClassField) {
		return switch field.meta.extract(':name') {
			case []: capitalize(field.name);
			case [{params: [{expr: EConst(CString(v))}]}]: v;
			case m: m[0].pos.error('Invalid use of @:name');
		}
	}
}