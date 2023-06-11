class_name Client
extends Node2D


var peerId = null;
var peerAddr = "0.0.0.0";


func toSimpleNetworkPacket():
	var obj = {};
	
	obj.id = get_instance_id();
	obj.username = name;
	obj.position = {"x":position.x, "y":position.y};
	obj.color = {"r":modulate.r, "g":modulate.g, "b": modulate.b, "a": modulate.a};
	
	
	
	return obj;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
