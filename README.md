# Macro-powered DBus Abstraction

According to Wiki (https://en.wikipedia.org/wiki/D-Bus):

> In computing, D-Bus (short for "Desktop Bus") is a Message-oriented middleware mechanism that allows communication between multiple processes running concurrently on the same machine.

This library can generate DBus client code by describing the DBus API via Haxe interfaces.
For example, the description of the official `org.freedestop.DBus` API can be found in `src/org/freedesktop/DBus.hx`.

A more real-world example can be found at https://github.com/why-haxe/why-bluez, which is a client of the BlueZ over DBus API.

> BlueZ is a Bluetooth stack for Linux kernel-based family of operating systems.

**TODO**

- Support server codes