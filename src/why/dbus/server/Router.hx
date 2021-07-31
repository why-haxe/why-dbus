package why.dbus.server;

import why.dbus.Signature;
import why.dbus.Message;

using tink.CoreApi;

@:genericBuild(why.dbus.server.Router.build())
class Router<T> {}

interface RouterObject {
	final signals:Signal<SignalPayload>;
	function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage>;
}

abstract class RouterBase<T> implements RouterObject {
	public final target:T;
	public final signals:Signal<SignalPayload>;
	
	public function new(target) {
		this.target = target;
		this.signals = new Signal(collect);
	}
	
	public abstract function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage>;
	public abstract function collect(fire:SignalPayload->Void):CallbackLink;
}

typedef SignalPayload = {
	final member:String;
	final signature:SignatureCode;
	final body:Array<Any>;
}