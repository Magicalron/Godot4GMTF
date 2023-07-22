extends Node

@export var DEFAULT_PORT    = 8001
@export var MAX_CONNECTIONS = 2
@export var MAX_CHANNELS    = 1

const LOCAL_HOST = "127.0.0.1"

@export  var ip   = LOCAL_HOST
@onready var peer = ENetMultiplayerPeer.new()

var multiplayer_id = 0

signal PlayerConnected( id )
signal PlayerDisconnected( id )

func establish_server()->bool:
	if peer == null:
		return false
	# Check multiplayer peer is not already set to this
	if multiplayer.multiplayer_peer == peer:
		return false

	var err = peer.create_server( DEFAULT_PORT, MAX_CONNECTIONS, MAX_CHANNELS )
	if err == OK:
		establish_signals()
		return true
	else:
		return false

func establish_client()->bool:
	if peer == null:
		return false
	# Check multiplayer peer is not already set to this
	if multiplayer.multiplayer_peer == peer:
		return false

	var err = peer.create_client( ip, DEFAULT_PORT, MAX_CHANNELS )
	if err == OK:
		establish_signals()
		return true
	else:
		return false

func establish_signals():
	multiplayer.multiplayer_peer = peer
	if multiplayer.is_server():
		# Connect the signals used by the server
		multiplayer.peer_connected.connect( incoming_connection )
		multiplayer.peer_disconnected.connect( outgoing_connection )
		multiplayer_id = multiplayer.get_unique_id()
	else:
		# Connect the signals used by the client
		multiplayer.connected_to_server.connect( server_connection_established )
		multiplayer.server_disconnected.connect( server_disconnection )
		multiplayer.connection_failed.connect( terminate_connection )

# Server Signals
func incoming_connection( id: int )->void:
	emit_signal("PlayerConnected", id )

func outgoing_connection( id: int )->void:
	emit_signal("PlayerDisconnected", id )

# Client Signals
func server_connection_established()-> void:
	multiplayer_id = multiplayer.get_unique_id()
	emit_signal("PlayerConnected", multiplayer_id )

func server_disconnection():
	emit_signal("PlayerDisconnected", multiplayer_id )

func terminate_connection():
	emit_signal("PlayerDisconnected", multiplayer_id )
	if peer != null:
		peer.close()

# On termination of this node, exit gracefully by disconnecting
func _notification( what : int )-> void:
	match what:
		NOTIFICATION_PREDELETE:
			if peer != null:
				peer.close()
