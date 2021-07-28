package org.freedesktop;

import why.dbus.*;
import why.dbus.types.*;

interface DBus {
	final nameLost:Signal<String>;
	final nameAcquired:Signal<String>;
	@:readonly final features:Array<String>;
	@:readonly final interfaces:Array<String>;
	function listNames():Array<String>;
	function requestName(name:String, flags:UInt):UInt;
	function getConnectionUnixProcessID(connectionName:String):UInt;
	function addMatch(rule:String):Void;
	function removeMatch(rule:String):Void;
}

interface Properties {
	final propertiesChanged:Signal<String, Map<String, Variant>, Array<String>>;
	
	function get(iface:String, name:String):Variant;
	function getAll(iface:String):Map<String, Variant>;
	function set(iface:String, name:String, value:Variant):Void;
}

interface ObjectManager {
	final interfacesAdded:Signal<ObjectPath, Map<String, Map<String, Variant>>>;
	final interfacesRemoved:Signal<ObjectPath, Array<String>>;
	
	function getManagedObjects():Map<ObjectPath, Map<String, Map<String, Variant>>>;
}

interface Introspectable {
	function introspect():String;
}