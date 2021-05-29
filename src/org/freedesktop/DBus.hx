package org.freedesktop;

import why.dbus.*;

using tink.CoreApi;

interface DBus {
	final nameLost:Signal<String>;
	final nameAcquired:Signal<String>;
	@:readonly final features:Array<String>;
	@:readonly final interfaces:Array<String>;
	function listNames():Array<String>;
	function requestName(name:String, flags:UInt):UInt;
	function getConnectionUnixProcessID(connectionName:String):UInt;
}

interface Properties {
	function get(iface:String, name:String):Variant;
	function getAll(interfaceName:String):Map<String, Variant>;
	function set(iface:String, name:String, value:Variant):Void;
}