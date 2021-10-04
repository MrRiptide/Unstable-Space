extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !get_node("HBoxContainer").visible:
		# slowly changing to the same orientation as the main game scene
		get_node("Background").position.y = max(304, get_node("Background").position.y - (400-304)/3*delta)
		if get_node("Background").position.y == 304:
			get_tree().change_scene("res://Viewspace.tscn")


func _on_Start_Game_pressed():
	get_node("HBoxContainer").visible = false
