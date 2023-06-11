extends Sprite2D

# EVERYTHING IS A FILE!!!

var gateway = "0.0.0.0"; # default: 0.0.0.0 = zero conf
var ip_addr = "0.0.0.0"; # default: 0.0.0.0 = zero conf

var filepaths = {
	"/root": {}, # executables, system-files, etc.
	"/home": {}  # users default file storage
	
	}; # multi-dimensional array to store all file-paths

var nics = []; # network interfaces
var listenings = []; # hostnames, ports etc.
var routes = []; # known routes

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
