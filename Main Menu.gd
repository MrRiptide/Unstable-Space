extends Control


var changing = false


func _ready():
	changing = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if changing:
		# slowly changing to the same orientation as the main game scene
		get_node("HBoxContainer").modulate.a = max(0, get_node("HBoxContainer").modulate.a - 1.0/3*delta)
		get_node("Background").position.y = get_node("HBoxContainer").modulate.a * (400-304) + 304
		if get_node("HBoxContainer").modulate.a == 0:
			get_tree().change_scene("res://Viewspace.tscn")


func _on_Start_Game_pressed():
	changing = true
