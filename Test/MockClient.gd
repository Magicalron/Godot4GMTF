extends Node
class_name MockClient

var mock_client = ENetMultiplayerPeer.new()
var multiplayer_api : MultiplayerAPI

func _ready():
	# Create the mock client instance
	mock_client.create_client( Network.LOCAL_HOST, Network.DEFAULT_PORT, Network.MAX_CHANNELS )

	# Create a new MultiplayerAPI, this is different to the default one used by the scene tree
	multiplayer_api = MultiplayerAPI.create_default_interface()

	# Set the APIs path to where this was added in the tree
	multiplayer_api.set_root_path( self.get_path() )

	# Set the root trees multiplayer_api path to this
	get_tree().set_multiplayer( multiplayer_api, self.get_path() )

	# Set the APIs peer to use the mock server
	multiplayer_api.multiplayer_peer = mock_client

	# Use mock signals for connection
	multiplayer_api.connected_to_server.connect( server_connection_established )
	multiplayer_api.server_disconnected.connect( server_disconnection )
	multiplayer_api.connection_failed.connect( terminate_connection )

# The API must be polled, the scene tree does this by default
# Since we aren't using the scene tree we must do this
func _process(_delta: float) -> void:
	if multiplayer_api.has_multiplayer_peer():
		multiplayer_api.poll()

# Mock incoming connection, add what you want done here
func server_connection_established() -> void:
	pass

# Mock disconnection from server, add what you want done here
func server_disconnection() ->void:
	pass

# Mock connection termination, add what you want done here
func terminate_connection() -> void:
	pass

func _exit_tree():
	mock_client.close()
