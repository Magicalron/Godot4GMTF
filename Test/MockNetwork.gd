extends GutTest
class_name MockNetwork

# This class is used to test networking objects from the servers perspective
class Server:
	extends GutTest
	const 	NETWORK_PATH = "res://Network.gd"
	const 	TIMEOUT 	 = 1

	var server		= null
	var mockClient  = null

	func before_all():
		server = load( NETWORK_PATH ).new()
		self.add_child( server )

		# Change the scene_tree default multiplayer root
		get_tree().get_multiplayer().set_root_path( server.get_path() )
		assert_true( server.establish_server() )

		watch_signals( server )
		mockClient 	= MockClient.new()
		self.add_child( mockClient )
		await yield_to( server, "PlayerConnected", TIMEOUT )
		assert_signal_emitted( server, "PlayerConnected", "MockClient never connected to server")

	func after_all():
		if mockClient != null:
			mockClient.free()
		if server != null:
			server.free()

	# To test your node on the network it needs to be located at the same relative path on the client
	# and the server
	func add_test_node( node, node_name ):
		# Create the nodes, and give them the same Node name
		var serverNode = autofree( node.new() )
		serverNode.name = node_name
		var clientNode = autofree( node.new() )
		clientNode.name = node_name

		# Add each node to its respective multiplayer path
		server.add_child( serverNode )
		mockClient.add_child( clientNode )
		return [serverNode, clientNode]
