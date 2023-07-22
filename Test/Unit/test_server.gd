extends GutTest

class TestServerStandalone:
	extends GutTest
	var serverObj = load( "res://Network.gd" )
	var clientObj = load( "res://Test/MockClient.gd")

	var server = null
	var client = null

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
