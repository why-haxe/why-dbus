package why.dbus;

import why.dbus.Message;

typedef MatchRuleObject = {
	final ?type:MessageType;
	final ?sender:String;
	final ?iface:String;
	final ?member:String;
	final ?path:String;
	final ?pathNamespace:String;
	final ?destination:String;
	final ?args:Array<String>;
	final ?argPaths:Array<String>;
	final ?arg0Namespace:String;
	final ?eavesdrop:Bool;
}

abstract MatchRule(MatchRuleObject) from MatchRuleObject to MatchRuleObject {
	public inline function new(v) {
		this = v;
	}
	
	@:to public function toString():String {
		final buf = [];
		
		if(this.type != null)
			buf.push('type=\'${this.type.toString()}\'');
		if(this.sender != null)
			buf.push('sender=\'${this.sender}\'');
		if(this.iface != null)
			buf.push('interface=\'${this.iface}\'');
		if(this.member != null)
			buf.push('member=\'${this.member}\'');
		if(this.path != null)
			buf.push('path=\'${this.path}\'');
		if(this.pathNamespace != null)
			buf.push('path_namespace=\'${this.pathNamespace}\'');
		if(this.destination != null)
			buf.push('destination=\'${this.destination}\'');
		if(this.args != null)
			for(i => v in this.args) buf.push('arg${i}=\'${v}\'');
		if(this.argPaths != null)
			for(i => v in this.argPaths) buf.push('arg${i}path=\'${v}\'');
		if(this.arg0Namespace != null)
			buf.push('arg0namespace=\'${this.arg0Namespace}\'');
		if(this.eavesdrop != null)
			buf.push('eavesdrop=\'${this.eavesdrop}\'');
		
		return buf.join(',');
	}
}