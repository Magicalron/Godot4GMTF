extends GutTest

class TestClientStandalone:
	extends GutTest
	var clientObj = load( "res://Network.gd" )
	var client = null

	func before_each():
		client = autofree( clientObj.new() )
		self.add_child( client )

	func test_establish_client_success():
		assert_true( client.establish_client(), "Failed to create client")
		assert_false( multiplayer.is_server(), "Multiplayer should be client")
		assert_ne( multiplayer.get_unique_id(), 1, "client Network ID shouldn't be 1" )
		assert_not_connected( multiplayer, client, "peer_connected")
		assert_not_connected( multiplayer, client, "peer_disconnected")
		assert_connected( multiplayer, client, "connected_to_server")
		assert_connected( multiplayer, client, "server_disconnected")
		assert_connected( multiplayer, client, "connection_failed")

	func test_second_establish_client():
		assert_true( client.establish_client(), "Failed to create client")
		assert_false( client.establish_client(), "Second establish should return false")

	func test_establish_client_after_client():
		assert_true( client.establish_client(), "Failed to create client")
		assert_false( client.establish_server(), "establish_server() should return false")

	func test_establish_client_on_null_peer():
		client.peer = null
		assert_false( client.establish_client(), "Establish client with null peer should be false")


class TestClientConnections:
	extends GutTest
	var clientObj = load( "res://Network.gd" )
	var serverObj = load( "res://Test/MockServer.gd")
	var client = null
	var server = null

	const TIMEOUT = 1

	func before_each():
		client = autofree( clientObj.new() )
		self.add_child( client )
		# Move the scene tree multiplayer default root to the server instance
		get_tree().set_multiplayer( get_tree().get_multiplayer(), client.get_path() )
		assert_true( client.establish_client(), "server_establish() return false in init" )
		# Watch signals emitted from client & multiplayer
		watch_signals( client )
		watch_signals( multiplayer )

	func test_client_connection():
		server = autofree( serverObj.new() )
		self.add_child( server )
		await yield_to( client, "PlayerConnected", TIMEOUT, "Timed out waiting for client connection" )
		assert_signal_emitted( client, "PlayerConnected", [ client.multiplayer_id ] )

		client.peer.close()
		await yield_to( client, "PlayerDisconnected", TIMEOUT, "Timed out waiting for client disconnection" )
		assert_signal_emitted_with_parameters( client, "PlayerDisconnected", [ client.multiplayer_id ] )
