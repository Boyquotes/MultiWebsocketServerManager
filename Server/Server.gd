class_name Server
extends Window

var blockProxyConnections = false;

var _CLIENT: PackedScene = preload("res://Client/Client.tscn");
var websocket_server: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new();
#var host: String = "";
#var port: int = 0;
var prefix = str("[SERVER][" , get_instance_id() , "]");

# default methods:
func _ready():
	print(prefix,"[METHOD] SERVER._READY() ");
	print(prefix,"[DEBUG] Protocols: ", websocket_server.get_supported_protocols());
	# websocket_server.set_supported_protocols([]); # demo-chat, etc.
	
#	get_tree().set_multiplayer(multiplayer, self.get_path())
#	multiplayer.set_multiplayer_peer(websocket_server);
#	websocket_server.handshake_timeout = 1;

func _process(_delta):
	websocket_server.poll();
	var count = websocket_server.get_available_packet_count();
	if(count):
		print("PACKET FOUND:", count);
		var peerId = websocket_server.get_packet_peer();
		var messageRaw = websocket_server.get_packet().get_string_from_utf8();
		# var messageObj = JSON.parse_string(messageRaw);
		print("[CLIENT-MSG] new message from peerId: '",  peerId, "'\n -> messageRaw: ", messageRaw);


# basics server methods (start/stop/exit etc.):
func start(host, port, server_tls_options = null):
	print(prefix,"[METHOD] SERVER.START()");
	var error = websocket_server.create_server(int(port), host, server_tls_options);
	if error:
		print(prefix, "[DEBUG] Server can't start, error: ", error, " (queue_free)");
		delete();
		return error;
	print(prefix, "[DEBUG] Server is running and listening on: ws://", host, ":", port, " with Options: ", server_tls_options)
	
	# Connect the peer_connected signal to the _on_peer_connected method
	websocket_server.connect("peer_connected", Callable(self, "_on_peer_connected"));
	websocket_server.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"));
	
	
#	var client = websocket_server.create_client(str("ws://", host, ":", port));
#	print("TEST CLIENT: ", client)
	
	return Error.OK;
	
func stop():
	print("[Method] SERVER.STOP()");
	websocket_server.close();
	print("Server has stopped successfully.");

func delete():
	queue_free();



# helper methods
func getClientByPeerId(peerId):
	for user in %MiniMap.get_children():
		if(user.peerId == peerId):
			return user;
	return null;

func getClientByAddress(ipAddress):
	for user in %MiniMap.get_children():
		if(user.peerAddr == ipAddress):
			return user;
	return null;

func getSimplifiedClientList(): # ready to transfer over sockets to multiplayer instances. filter: no passwords etc. allowed.
	var clients = [];
	for client in %MiniMap.get_children():
		clients.push_back(client.toSimpleNetworkPacket());
	return clients;



# build network packets for the users:
func buildMessage(peerId, message: String):
	return {
		"action":"MESSAGE",
		"data": message
	};

func buildSimplifiedUserUpdate(peerId):
	var user = getClientByPeerId(peerId);
	return {
		"action":"UPDATE_USER",
		"data": getSimplifiedClientList()
	};

func emitObjectToPeer(obj, peer):
	var packet = JSON.stringify(obj);
	peer.send_text(packet);
	return;


# events
func _on_peer_connected(peerId: int): # peer connected
	var peer = websocket_server.get_peer(peerId);
	var peerAddr = websocket_server.get_peer_address(peerId);
	print("\nPeer connected: ", peerId, " with IP Address: ", peerAddr);
	
	# is multi-user or using same proxy:
	var client = getClientByAddress(peerAddr);
	if(client):
		var jsonObj = buildMessage(peerId, "ILLEGAL LOGIN!");
		emitObjectToPeer(jsonObj, peer);
		
		if(blockProxyConnections):
			peer.close()
			return;
		
		
	var new_client = _CLIENT.instantiate();
	new_client.position.x = randi() % 291;
	new_client.position.y = randi() % 291;
	new_client.peerId = peerId;
	new_client.peerAddr = peerAddr;
	%MiniMap.add_child(new_client);
	
	var jsonObj2 = buildSimplifiedUserUpdate(peerId);
	emitObjectToPeer(jsonObj2, peer);
	
	# testing here
	var client_peer = websocket_server.get_peer(peerId);
	var buffer: PackedByteArray = [];
	client_peer.put_packet(buffer);

func _on_peer_disconnected(peerId: int): # peer disconnected
	print("Client disconnected! ", peerId);
	var client:Client = getClientByPeerId(peerId);
	if(client):
		client.queue_free();
	
	return false;
