package why.dbus;

import why.dbus.Message.OutgoingErrorMessage;
import why.dbus.Message;

using tink.CoreApi;

interface Transport {
	final calls:Signal<Pair<IncomingCallMessage, Callback<Outcome<OutgoingReturnMessage, OutgoingErrorMessage>>>>;
	final signals:Signal<IncomingSignalMessage>;
	function call(message:OutgoingCallMessage, ?pos:haxe.PosInfos):Promise<IncomingReturnMessage>;
	function emit(message:OutgoingSignalMessage):Promise<Noise>;
}