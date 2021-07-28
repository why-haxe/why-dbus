package why.dbus;

import why.dbus.Message;

using tink.CoreApi;

@:genericBuild(why.dbus.Router.build())
class Router<T> {}

abstract class RouterBase<T> {
	final target:T;
				
	public function new(target) {
		this.target = target;
	}
	
	public abstract function route(message:IncomingCallMessage):Promise<OutgoingReturnMessage>;
}