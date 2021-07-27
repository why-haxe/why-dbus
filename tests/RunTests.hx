package ;

import tink.testrunner.*;
import tink.unit.*;

@:asserts
class RunTests {
	static function main() {
		#if spawn_daemon
		Sys.putEnv('DBUS_SESSION_BUS_ADDRESS', js.node.ChildProcess.execSync('dbus-daemon --fork --config-file=/usr/share/dbus-1/session.conf --print-address'));
		#end
		
		Runner.run(TestBatch.make([
			new SignatureTest(),
			new ObjectTest(),
		])).handle(Runner.exit);
	}
}