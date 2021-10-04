extends Area2D


# Declare member variables here. Examples:
var direction = 0
var speed = 50
var distance = 1000


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var x_range = Vector2(0, get_viewport().get_visible_rect().size[0])
	var y_range = Vector2(0, get_viewport().get_visible_rect().size[1])
	
	self.position = Vector2(x_range[1]/2, y_range[1])
	
	# don't allow the asteroids to be spawned within a certain radius of the gun
	# this is mostly just to prevent having to deal with asteroids being hidden behind the gun
	while (self.position.distance_to(get_node("../../Gunner").position) < 200):
		var random_x = randi() % int(x_range[1] - x_range[0]) + 1 + x_range[0]
		var random_y = randi() % int(y_range[1] - y_range[0]) + 1 + y_range[0]
		self.position = Vector2(random_x, random_y)
	# print(self.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# show a warning with distance when within 500m of the ship
	if distance < 500:
		get_node("Distance").text = str(round(distance)) + "m"
		get_node("Distance").visible = true
	# asteroid has hit the ship, deal damage and destroy the asteroid
	# TODO: add animations for the ship being hit
	if distance < 0:
		get_node("../../").damage()
		self.get_parent().remove_child(self)
	distance -= speed * delta
	
	var percent_size = (distance / 1000)
	get_node("CollisionShape2D").scale = Vector2(1-percent_size, 1-percent_size)

func damage(score_manager):
	get_parent().remove_child(self)
	score_manager.add_score(100)
