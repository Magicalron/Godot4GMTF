extends Node

@export var DEFAULT_PORT    = 8001
@export var MAX_CONNECTIONS = 2
@export var MAX_CHANNELS    = 1

const LOCAL_HOST = "127.0.0.1"
@export var ip = LOCAL_HOST

@onready var peer = ENetMultiplayerPeer.new()

func establish_server()->bool:
	if peer == null:
		return false
	# Check multiplayer peer is not already set to this
	if multiplayer.multiplayer_peer == peer:
		return false

	var err = peer.create_server( DEFAULT_PORT, MAX_CONNECTIONS, MAX_CHANNELS )
	if err == OK:
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
		return true
	else:
		return false

func _notification( what : int )-> void:
	match what:
		NOTIFICATION_PREDELETE:
			if peer != null:
				peer.close()
