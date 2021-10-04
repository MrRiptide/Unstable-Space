extends Node2D


# Declare member variables here. Examples:
var direction = 0
var speed
var rotation_speed = 0.05
var distance = 1000
var health = 1
var scale_multi
var damage

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var x_range = Vector2(0, get_viewport().get_visible_rect().size[0])
	var y_range = Vector2(0, get_viewport().get_visible_rect().size[1])
	
	self.position = Vector2(x_range[1]/2, y_range[1])
	
	var version
	var size
	
	# if at certain stage and 30% chance spawn as large
	if get_node("../../Asteroid Timer").wait_time < 4 and rng.randf() < 0.3:
		version = rng.randi_range(1, 2) 
		speed = 100
		health = 5
		damage = 15
		scale_multi = 3
		size = "Large"
	# else spawn as medium
	else:
		version = rng.randi_range(1, 3) 
		speed = 150
		damage = 10
		scale_multi = 1
		size = "Medium"
	
	var asteroidSource = load("res://Asteroids/"+size+str(version)+".tscn")
	
	get_node(".").add_child(asteroidSource.instance())
	
	# set a random rotation
	
	get_node("Hitbox").set_rotation(rng.randi_range(-180, 180))
	
	# don't allow the asteroids to be spawned within a certain radius of the gun
	# this is mostly just to prevent having to deal with asteroids being hidden behind the gun
	while (self.position.distance_to(get_node("../../Gunner").position) < 200):
		var random_x = rng.randi() % int(x_range[1] - x_range[0]) + 1 + x_range[0]
		var random_y = rng.randi() % int(y_range[1] - y_range[0]) + 1 + y_range[0]
		self.position = Vector2(random_x, random_y)
	# print(self.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_node("Hitbox").set_rotation(get_node("Hitbox").get_rotation() + rotation_speed*delta)

	# show a warning with distance when within 500m of the ship
	if distance < 500:
		get_node("Distance").text = str(round(distance)) + "m"
		get_node("Distance").visible = true
	# asteroid has hit the ship, deal damage and destroy the asteroid
	# TODO: add animations for the ship being hit
	if distance < 0:
		get_node("../../").damage(damage)
		self.get_parent().remove_child(self)
	distance -= speed * delta
	
	var percent_size = 1-(distance / 1000)
	var max_scale = 1.5
	get_node(".").scale = Vector2(max_scale*percent_size, max_scale*percent_size)

func damage(score_manager, hit_reg):
	health -= 1
	
	var explosionSource = load("res://Asteroids/ExplosionParticles.tscn")
	var explosion = explosionSource.instance()
	explosion.global_position = hit_reg.global_position
	#explosion.scale = 100*get_node(".").scale
	explosion.source = self
	if health == 0:
		explosion.global_position = self.global_position
		explosion.destroy = true
		score_manager.add_score(100)
	else:
		explosion.global_position = hit_reg.global_position
	get_parent().add_child(explosion)
