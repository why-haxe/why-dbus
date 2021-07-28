package why.dbus.server;

import why.dbus.Message;

using tink.CoreApi;

@:genericBuild(why.dbus.server.Router.build())
class Router<T> {}

abstract class RouterBase<T> {
	public final path:String;
	public final iface:String;
	public final target:T;
	public final signals:Signal<OutgoingSignalMessage>;
	
	public function new(path, iface, target) {
		this.path = path;
		this.iface = iface;
		this.target = target;
		signals = new Signal(collect);
	}
	
	public abstract function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage>;
	public abstract function collect(fire:OutgoingSignalMessage->Void):CallbackLink;
}