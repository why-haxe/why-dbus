package why.dbus;

using tink.CoreApi;

interface Transport {
	final signals:Signal<Message>;
	function call(message:Message, ?pos:haxe.PosInfos):Promise<Message>;
	// function send(message:Message):Void;
}