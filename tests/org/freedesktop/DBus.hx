package org.freedesktop;

interface DBus {
	function listNames():Array<String>;
	function getConnectionUnixProcessID(connectionName:String):UInt;
}