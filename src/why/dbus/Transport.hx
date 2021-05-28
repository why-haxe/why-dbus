package why.dbus;

using tink.CoreApi;

interface Transport {
	function call(message:Message):Promise<Message>;
	// function send(message:Message):Void;
}