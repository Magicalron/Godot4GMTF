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
