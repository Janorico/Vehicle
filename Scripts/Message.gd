extends Control

onready var to_option_button = $SendMessageDialog/GridContainer/ToOptionButton
onready var message_text_edit = $SendMessageDialog/GridContainer/MessageTextEdit

func _send():
	to_option_button.clear()
	to_option_button.add_item("ALL_KEY", 0)
	for player in Net.player_info:
		to_option_button.add_item("%s (ID: %s)" % [Net.player_info[player]["name"], str(player)], player)
	$SendMessageDialog/GridContainer/MessageTextEdit.text = ""
	get_node("../../Vehicles").get_vehicle().enabled = false
	$SendMessageDialog.popup_centered()

func _dialog_confirmed():
	var to = to_option_button.get_selected_id()
	var text = message_text_edit.text
	if to == 0:
		rpc("get_message", Net.net_id, "ALL_KEY", text)
	else:
		rpc_id(to, "get_message", Net.net_id, Net.player_info[to]["name"], text)

remote func get_message(from, to, message):
	$GetMessagePanel/GridContainer/FromTextLabel.text = "%s (ID: %s)" % [Net.player_info[from]["name"], str(from)]
	$GetMessagePanel/GridContainer/ToTextLabel.text = to
	$GetMessagePanel/GridContainer/MessageTextEdit.text = message
	var viewport_size = get_viewport().size
	var panel_size = $GetMessagePanel.rect_size
	$GetMessagePanel.rect_position = Vector2(((viewport_size.x - panel_size.x) / 2), (viewport_size.y - panel_size.y))
	$GetMessagePanel.show()
	$GetMessagePanel/Timer.start()

func _dialog_closed():
	get_node("../../Vehicles").get_vehicle().enabled = true
