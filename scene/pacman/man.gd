class_name Man extends CharacterBody2D

@onready var ray_cast_2d_1: RayCast2D = $RayCast2D1
@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2
@onready var ray_cast_2d_3: RayCast2D = $RayCast2D3

var speed : float = 120

var direction : Vector2 = Vector2.RIGHT

var score : float = 0

var hunger : float = 0:
	set(value):
		hunger = clamp(value, 0, 100)

var is_dead : bool = false

@onready var sprite_2d = $Sprite2D

func _physics_process(delta):
	if hunger >= 100:
		is_dead = true
		return
	if is_dead:
		return
	hunger += delta * 1
	score += delta * 1
	
	var mine_direction : Vector2 = Vector2.from_angle(sprite_2d.global_rotation + PI / 2)
	var angel_delta_max : float = absf(direction.angle_to(mine_direction))
	var angel_delta : float = clampf(mine_direction.cross(direction) * 5 * delta,-angel_delta_max,angel_delta_max)
	sprite_2d.rotation = sprite_2d.rotation + angel_delta
	
	velocity = speed * (Vector2.from_angle(sprite_2d.rotation)).normalized()
	move_and_slide()
	var kinematic_collision: KinematicCollision2D = get_last_slide_collision()
	if kinematic_collision:
		var collider: Node2D = kinematic_collision.get_collider()
		if collider is Bean:
			hunger = 0
			collider.queue_free()
		else:
			is_dead = true
