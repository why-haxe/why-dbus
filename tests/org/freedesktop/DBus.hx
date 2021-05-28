package org.freedesktop;

import why.dbus.*;

interface DBus {
	@:read final features:Array<String>;
	@:read final interfaces:Array<String>;
	function listNames():Array<String>;
	function getConnectionUnixProcessID(connectionName:String):UInt;
}

interface Properties {
	function get(iface:String, name:String):Variant;
	function getAll(interfaceName:String):Map<String, Variant>;
	function set(iface:String, name:String, value:Variant):Void;
}