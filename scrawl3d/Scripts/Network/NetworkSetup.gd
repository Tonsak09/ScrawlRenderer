extends Node

#@onready var mainMenu = $CanvasLayer/MultiplayerMenu
@export var spawnParent : Node3D 
@onready var addressEntry = $MultiplayerMenu/MarginContainer/VBoxContainer/AddressEntry

const Player = preload("res://Prefabs/Player.tscn")
#TODO: Figure out a better way to choose a port 
const PORT = 9999
var enetPeer = ENetMultiplayerPeer.new()

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("quit"):
		#get_tree().quit()

func _on_host_button_pressed() -> void:
	#mainMenu.hide()
	
	enetPeer.create_server(PORT)
	multiplayer.multiplayer_peer = enetPeer
	multiplayer.peer_connected.connect(AddPlayer)
	multiplayer.peer_disconnected.connect(RemovePlayer)
	
	AddPlayer(multiplayer.get_unique_id())
	upnpSetup()

func _on_join_button_pressed() -> void:
	#mainMenu.hide()
	
	enetPeer.create_client(addressEntry.text, PORT)
	multiplayer.multiplayer_peer = enetPeer
	
	AddPlayer(multiplayer.get_unique_id())

func AddPlayer(peerID):
	var player = Player.instantiate()
	player.name = str(peerID)
	spawnParent.add_child(player)

func RemovePlayer(peerID):
	var player = get_node_or_null(str(peerID))
	if player:
		player.queue_free()

func upnpSetup():
	var upnp = UPNP.new()
	
	var discoverResult = upnp.discover()
	assert(discoverResult == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discoverResult)
		
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
		
	var mapResult = upnp.add_port_mapping(PORT)
	assert("UPNP Port Mapping Faileed! Error %s" % mapResult)
	
	var tempAddress = "xxx.xxx.xx.xxx"
	print("Success! Join Address: %s" % tempAddress) #upnp.query_external_address())
