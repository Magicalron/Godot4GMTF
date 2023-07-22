extends Node
class_name MockServer

var mock_server = ENetMultiplayerPeer.new()
var multiplayer_api : MultiplayerAPI

func _ready():
	# Create the mock server instance
	mock_server.create_server( Network.DEFAULT_PORT, Network.MAX_CONNECTIONS, Network.MAX_CHANNELS )

	# Create a new MultiplayerAPI, this is different to the default one used by the scene tree
	multiplayer_api = MultiplayerAPI.create_default_interface()

	# Set the APIs path to where this was added in the tree
	multiplayer_api.set_root_path( self.get_path() )

	# Set the root trees multiplayer_api path to this
	get_tree().set_multiplayer( multiplayer_api, self.get_path() )

	# Set the APIs peer to use the mock server
	multiplayer_api.multiplayer_peer = mock_server

	# Use mock signals for connection
	multiplayer_api.peer_connected.connect( incoming_connection )
	multiplayer_api.peer_disconnected.connect( outgoing_connection )

# The API must be polled, the scene tree does this by default
# Since we aren't using the scene tree we must do this
func _process(_delta: float) -> void:
	if multiplayer_api.has_multiplayer_peer():
		multiplayer_api.poll()

# Mock incoming connection, add what you want done here
func incoming_connection( _id: int ) ->void:
	pass

# Mock outgoing connection, add what you want done here
func outgoing_connection( _id: int )->void:
	pass

# Exit the tree gracefully
func _exit_tree():
	mock_server.close()
