package why.dbus.server;

import why.dbus.Message;

using tink.CoreApi;

@:genericBuild(why.dbus.server.Router.build())
class Router<T> {}

interface RouterObject {
	final signals:Signal<OutgoingSignalMessage>;
	function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage>;
}

abstract class RouterBase<T> implements RouterObject {
	public final path:String;
	public final iface:String;
	public final target:T;
	public final signals:Signal<OutgoingSignalMessage>;
	
	public function new(path, iface, target) {
		this.path = path;
		this.iface = iface;
		this.target = target;
		this.signals = new Signal(collect);
	}
	
	public abstract function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage>;
	public abstract function collect(fire:OutgoingSignalMessage->Void):CallbackLink;
}