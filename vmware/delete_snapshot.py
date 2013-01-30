#!/usr/bin/python

#####################################
# delete all snapshots
# jlacroix
#
# required: http://code.google.com/p/pysphere/
#
#####################################

snapshot_name="base"

host="vcenter.example.com"
login="user"
password="password"
pre_name="VDS"

#####################################

import datetime
import sys
from pysphere import VIServer


server = VIServer()
print "connect"
server.connect(host, login, password)
print "get vm"

vmlist = server.get_registered_vms()

for vmpath in vmlist:
	vm = server.get_vm_by_path(vmpath)
	name = vm.get_property('name')
	if name.find(pre_name) != -1 and name.find("-"+pre_name) == -1:
		snapshot_list = vm.get_snapshots()
		for snapshot in snapshot_list:
			if snapshot.get_name() == snapshot_name:
				print "delete snapshot " + snapshot_name  + " for " + vm.get_property('name') + ": " + str(datetime.datetime.now())[0:19]
				vm.delete_named_snapshot(snapshot_name, sync_run=False)

print "end " + str(datetime.datetime.now())[0:19]
server.disconnect()
