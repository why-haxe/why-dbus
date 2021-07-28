package ;

import tink.testrunner.*;
import tink.unit.*;

@:asserts
class RunTests {
	static function main() {
		#if spawn_daemon
		Sys.putEnv('DBUS_SESSION_BUS_ADDRESS', js.node.ChildProcess.execSync('dbus-daemon --fork --config-file=/usr/share/dbus-1/session.conf --print-address'));
		#end
		
		// new why.dbus.Router<org.freedesktop.DBus>(null);
		
		// trace(js.Lib.require('dbus-next').systemBus() == js.Lib.require('dbus-next').systemBus());
		
		Runner.run(TestBatch.make([
			new SignatureTest(),
			new ObjectTest(),
			new ServerTest(),
		])).handle(Runner.exit);
	}
}