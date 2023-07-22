This example project is meant to illustrate how godot can handle a server and multiple clients all in one instance.
It depends on Gut. A godot asset that adds testing functionality to the godot editor.
GUT can be found here: https://github.com/bitwes/Gut

# Setup
	1. Open this project in godot v4.03 (stable) - untested for other versions of godot
	2. Install Gut into the addons directory
	3. Run the Gut Tests

# Breakdown
Network.gd:
The network controller used to handle connections

MockClient:
A script that sets up a connectable client. This client doesn't do anything
other than call all of the correct network setup for a functioning server to
connect to.

MockServer:
A script that sets up a connectable server. The server doesn't do anything other
than tell the client that it's connected to a server. This can be used to emulate
connecting to a remote server

MockNetwork:
This is used to allow testing to setup a functioning server with a mock client
connection or a functioning client with a mock server

Unit Tests:
test_client - demonstrates a functioning client
test_server - demonstrates a functioning server
test_example - how to test an object with network capability
