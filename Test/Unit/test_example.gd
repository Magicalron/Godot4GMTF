extends GutTest

func test_init():
	assert_true( true, "Something went dramatically wrong" )

class MyObjectToTest:
	extends Node

	signal WasPinged

	@rpc( "any_peer" )
	func ping():
		print( "{0} was pinged from {1}".format(
			[multiplayer.get_unique_id(), multiplayer.get_remote_sender_id()]))
		emit_signal( "WasPinged" )

	@rpc( "authority")
	func authoritative_ping():
		print( "{0} was pinged from the server".format([multiplayer.get_unique_id()]))
		emit_signal( "WasPinged" )

class TestServerMyObjectToTest:
	extends MockNetwork.Server

	# This is the object that would appear in your servers scene tree
	var serverTestObject = null
	# This is the object that would appear in your clients scene tree
	var clientTestObject = null

	func before_each():
		var nodes = add_test_node( MyObjectToTest, "test_object" )
		serverTestObject = nodes[0]
		clientTestObject = nodes[1]
		watch_signals( serverTestObject )
		watch_signals( clientTestObject )

	func test_server_to_client_ping():
		serverTestObject.rpc("ping")
		await yield_to( clientTestObject, "WasPinged", TIMEOUT )
		assert_signal_emitted( clientTestObject, "WasPinged" )
		assert_signal_not_emitted( serverTestObject, "WasPinged" )

	func test_client_to_server_ping():
		clientTestObject.rpc("ping")
		await yield_to( serverTestObject, "WasPinged", TIMEOUT )
		assert_signal_emitted( serverTestObject, "WasPinged" )
		assert_signal_not_emitted( clientTestObject, "WasPinged" )

	func test_authority_ping():
		clientTestObject.rpc("authoritative_ping")
		await yield_to( serverTestObject, "WasPinged", TIMEOUT )
		assert_signal_not_emitted( serverTestObject, "WasPinged" )
		assert_signal_not_emitted( clientTestObject, "WasPinged" )

		serverTestObject.rpc("authoritative_ping")
		await yield_to( clientTestObject, "WasPinged", TIMEOUT )
		assert_signal_emitted( clientTestObject, "WasPinged" )
		assert_signal_not_emitted( serverTestObject, "WasPinged" )
