extends Node3D


#----------------------VARIABLES----------------------
var target
var spawnObject


#----------------------SETUP FUNCTIONS----------------------
# [ ? ] Sets the target for this node and propagates it to all child nodes
func setupTarget(target):
	self.target = target
	setTargetOfChildren(target)


#----------------------PROPERTY FUNCTIONS----------------------
# [ ? ] Sets the spawn object and propagates it to all child nodes that support it
func setSpawnObject(object):
	self.spawnObject = object
	# [ ? ] For each child node that has the setSpawnObject method, this method is called to propagate the spawn object
	for child in get_children():
		if (child.has_method("setSpawnObject")):
			child.setSpawnObject(object)


#----------------------UTILITY FUNCTIONS----------------------
# [ ? ] Sets the target for all child nodes that support the setupTarget method
func setTargetOfChildren(target):
	# [ ? ] Iterates over all children and calls setupTarget on those that support it
	for child in get_children():
		if (child.has_method("setupTarget")):
			child.setupTarget(target)


func playDeathOfChildren():
	for child in get_children():
		if (child.has_method("playDeath")):
			child.playDeath()
