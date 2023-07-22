extends GutTest

class TestServerStandalone:
	extends GutTest
	var serverObj = load( "res://Network.gd" )
	var server = null

	func before_each():
		server = autofree( serverObj.new() )
		self.add_child( server )

	func test_establish_server_success():
		assert_true( server.establish_server(), "Failed to create server")
		assert_true( multiplayer.is_server(), "Multiplayer should be server")
		assert_eq( multiplayer.get_unique_id(), 1, "Server Network ID should be 1" )
		assert_connected( multiplayer, server, "peer_connected")
		assert_connected( multiplayer, server, "peer_disconnected")
		assert_not_connected( multiplayer, server, "connected_to_server")
		assert_not_connected( multiplayer, server, "server_disconnected")
		assert_not_connected( multiplayer, server, "connection_failed")

	func test_second_establish_server():
		assert_true( server.establish_server(), "Failed to create server")
		assert_false( server.establish_server(), "Second establish should return false")

	func test_establish_client_after_server():
		assert_true( server.establish_server(), "Failed to create server")
		assert_false( server.establish_client(), "establish_client() should return false")

	func test_establish_server_on_null_peer():
		server.peer = null
		assert_false( server.establish_server(), "Establish server with null peer should be false")

class TestServerConnections:
	extends GutTest
	var serverObj = load( "res://Network.gd" )
	var clientObj = load( "res://Test/MockClient.gd")
	var server = null
	var client = null

	const TIMEOUT = 1

	func before_each():
		server = autofree( serverObj.new() )
		self.add_child( server )
		# Move the scene tree multiplayer default root to the server instance
		get_tree().set_multiplayer( get_tree().get_multiplayer(), server.get_path() )
		assert_true( server.establish_server(), "server_establish() return false in init" )
		# Watch signals emitted from server & multiplayer
		watch_signals( server )
		watch_signals( multiplayer )

	func test_client_connection():
		client = autofree( clientObj.new() )
		self.add_child( client )
		var client_id = client.mock_client.get_unique_id()
		await yield_to( server, "PlayerConnected", TIMEOUT, "Timed out waiting for client connection" )
		assert_signal_emitted_with_parameters( server, "PlayerConnected", [ client_id ] )

		self.remove_child( client )
		await yield_to( server, "PlayerDisconnected", TIMEOUT, "Timed out waiting for client disconnection" )
		assert_signal_emitted_with_parameters( server, "PlayerDisconnected", [ client_id ] )
