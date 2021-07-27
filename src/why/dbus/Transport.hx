package why.dbus;

import why.dbus.Message;

using tink.CoreApi;

interface Transport {
	final signals:Signal<IncomingSignalMessage>;
	function call(message:OutgoingCallMessage, ?pos:haxe.PosInfos):Promise<IncomingReturnMessage>;
	// function send(message:Message):Void;
}