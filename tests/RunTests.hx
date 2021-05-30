package ;

import tink.testrunner.*;
import tink.unit.*;

@:asserts
class RunTests {

	static function main() {
		Runner.run(TestBatch.make([
			new SignatureTest(),
			new ObjectTest(),
		])).handle(Runner.exit);
	}
	
}