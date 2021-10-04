extends Node2D

onready var asteroidScene = preload("res://Asteroids/Asteroid.tscn")
var max_health = 100
var health = max_health
var score = 0


func _ready():
	randomize()
	var asteroid = asteroidScene.instance()
	
	get_node("Asteroids").add_child(asteroid)
	#get_node("Gunner/Hit Registration/Bullet Trace").set_as_toplevel(true)


func end_game():
	get_tree().paused = true
	get_node("Game End Screen/VBoxContainer/HBoxContainer/Final Score Label").text = "Final Score: " + str(score)
	get_node("Game End Screen").visible = true
	


func damage(amount):
	health -= amount
	get_node("HealthBar").value = health
	#get_node("Camera2D").shake(5)
	if health <= 0:
		end_game()

var y_offset = 0
var x_offset = 0
var fire_rate = 10
var shots_fired = 0
var max_shots_fired = 75
var barrel_speed = 0
var barrel_accel = 60
# might add overheating as another limitation, but want to do that later
var heat = 0
var max_heat = 750
var heating_rate = 5
var overheated = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# okay do the gentle shaking of the background here, then with damage increase shakiness
	# also on take damage have a period of extreme shake
	
	# reducing the recoil
	var recenter_rate = 50
	# functionality for shooting the gun
	#print(y_offset, " , ", x_offset)
	
	get_node("Gunner").self_modulate = Color(1.0, 1-((255.0-80)/255)*(float(heat) / max_heat), 1-(float(heat) / max_heat))

	
	if heat >= max_heat:
		overheated = true
	
	if Input.is_action_pressed("fire") and !overheated:
		if get_node("Gunner").frames.get_animation_speed("charging") < 40:
			get_node("Gunner").set_animation("charging")
			#print(barrel_speed)
			barrel_speed += barrel_accel*delta
			get_node("Gunner").frames.set_animation_speed("charging", int(barrel_speed))
		elif get_node("Gunner/Fire Rate").time_left == 0:
			get_node("Gunner").set_animation("firing")
			# TODO: add SFX of the gun firing & warming up
			
			# doing recoil of the gun
			
			var max_y_offset = 150
			var wiggle_coef = 15 + 60 * (1-health/max_health)
			# thinking to bound the recoil so that it doesnt end up off the screen
			y_offset = min(max_y_offset, y_offset + 10 + 5*(1-health/max_health))
			
			#print((1.2 - float(health)/max_health))
			x_offset = (1.2 - float(health)/max_health)*wiggle_coef * randf()
			
			var hit_reg = get_node("Gunner/Hit Registration")
			
			hit_reg.global_position = get_global_mouse_position() - (wiggle_coef*(min(max_shots_fired, shots_fired)/max_shots_fired))*Vector2(
				cos(shots_fired/3),
				sin(shots_fired/5)
			)
			
			# hit registration
			
			for area in hit_reg.get_overlapping_areas():
				#print(area.get_parent().name)
				if "Asteroid" in area.get_parent().name:
					area.get_parent().damage(self)
			
			# since the bullet trace is a child of hit registration it should mark the point that the bullet was fired at
			get_node("Gunner/Hit Registration/Bullet Trace").emitting = true
			
			heat += heating_rate
			shots_fired += 1
			get_node("Gunner/Fire Rate").start()
	else:
		get_node("Gunner/Hit Registration/Bullet Trace").emitting = false
		get_node("Gunner").set_animation("charging")
		if barrel_speed == 0:
			shots_fired = max(0, min(max_shots_fired, shots_fired) - fire_rate*delta)
			heat = max(0, heat - heating_rate * 20 * delta)
			if heat == 0:
				overheated = false
		barrel_speed = max(0, barrel_speed - barrel_accel*delta)
		get_node("Gunner").frames.set_animation_speed("charging", int(barrel_speed))
		

func add_score(amount):
	score += amount
	get_node("Score Label").text = str(score)


func _on_Asteroid_Timer_timeout():
	get_node("Asteroid Timer").wait_time = max(0.5, get_node("Asteroid Timer").wait_time*0.97)
	var asteroid = asteroidScene.instance()
	
	get_node("Asteroids").add_child(asteroid)


func _on_Play_Again_Button_pressed():
	get_tree().change_scene("res://Viewspace.tscn")
	get_tree().paused = false


func _on_Main_Menu_Button_pressed():
	get_tree().change_scene("res://Main Menu.tscn")
	get_tree().paused = false
