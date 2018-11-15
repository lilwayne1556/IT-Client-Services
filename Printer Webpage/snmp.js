function getSNMPInfo(){
    var snmp = require("net-snmp");
    var session = snmp.createSession("bar0017-dell5460.scc.uni.edu", "public");
    var oid = "43.11.1.1";

    function doneCb (error) {
    if (error)
        console.error(error.toString ());
	}

	function feedCb (varbinds) {
		for (var i = 0; i < varbinds.length; i++) {
			if (snmp.isVarbindError(varbinds[i]))
				console.error(snmp.varbindError (varbinds[i]));
			else
				console.log(varbinds[i].oid + "|" + varbinds[i].value);
		}
	}

	var maxRepetitions = 20;

	// The maxRepetitions argument is optional, and will be ignored unless using
	// SNMP verison 2c
	console.log((session.subtree(oid, maxRepetitions, feedCb, doneCb)));
}

getSNMPInfo();