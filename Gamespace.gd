extends Node2D

onready var asteroidScene = preload("res://Asteroid.tscn")
var max_health = 100
var health = max_health
var score = 0


func _ready():
	randomize()
	var asteroid = asteroidScene.instance()
	
	get_node("Asteroids").add_child(asteroid)
	#get_node("Gunner/Hit Registration/Bullet Trace").set_as_toplevel(true)


func end_game():
	get_node("Game End Screen/HBoxContainer/Final Score Label").text = "Final Score: " + score
	get_node("Game End Screen").visible = true
	


func damage():
	health -= 10
	get_node("HealthBar").value = health
	if health <= 0:
		end_game()

var y_offset = 0
var x_offset = 0
var barrel_speed = 0
var barrel_accel = 60
# might add overheating as another limitation, but want to do that later
var heat = 0
var max_heat = 500
var heating_rate = 25

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# reducing the recoil
	var recenter_rate = 50
	y_offset = max(0, y_offset - recenter_rate * delta)
	x_offset = max(0, x_offset - recenter_rate * delta)
	# functionality for shooting the gun
	#print(y_offset, " , ", x_offset)
	if Input.is_action_pressed("fire"):
		if get_node("Gunner").frames.get_animation_speed("charging") < 40:
			get_node("Gunner").set_animation("charging")
			print(barrel_speed)
			barrel_speed += barrel_accel*delta
			get_node("Gunner").frames.set_animation_speed("charging", int(barrel_speed))
		elif get_node("Gunner/Fire Rate").time_left == 0:
			get_node("Gunner").set_animation("firing")
			# TODO: add animation of the gun firing
			# TODO: add SFX of the gun firing & warming up
			#print("pew")
			#print(get_global_mouse_position())
			#get_node("Gunner/Bullet Trace").global_position = get_global_mouse_position()
			
			# doing recoil of the gun
			
			var max_y_offset = 150
			var wiggle_coef = 50
			# thinking to bound the recoil so that it doesnt end up off the screen
			y_offset = min(max_y_offset, y_offset + 10 + 5*(1-health/max_health))
			
			print((1.2 - float(health)/max_health))
			x_offset = (1.2 - float(health)/max_health)*wiggle_coef * randf()
			
			var hit_reg = get_node("Gunner/Hit Registration")
			
			hit_reg.global_position = get_global_mouse_position() - Vector2(
				x_offset,
				min(y_offset + (1.2 - float(health)/max_health)*wiggle_coef * randf(), 100000)
			)
			
			# hit registration
			
			for area in hit_reg.get_overlapping_areas():
				if "Asteroid" in area.name:
					area.damage()
			
			# since the bullet trace is a child of hit registration it should mark the point that the bullet was fired at
			get_node("Gunner/Hit Registration/Bullet Trace").emitting = true
			
			get_node("Gunner/Fire Rate").start()
	else:
		get_node("Gunner/Hit Registration/Bullet Trace").emitting = false
		get_node("Gunner").set_animation("charging")
		barrel_speed = max(0, barrel_speed - barrel_accel*delta)
		get_node("Gunner").frames.set_animation_speed("charging", int(barrel_speed))
		


func _on_Asteroid_Timer_timeout():
	var asteroid = asteroidScene.instance()
	
	get_node("Asteroids").add_child(asteroid)
