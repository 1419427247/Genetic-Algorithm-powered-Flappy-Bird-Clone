class_name Bird extends Area2D

const GRAVITY : Vector2 = Vector2(0, 980)

var velocity : Vector2 = Vector2.ZERO

var is_dead : bool = false

var life_time : float = 0

@onready var animated_sprite_2d = $AnimatedSprite2D

func _process(delta: float) -> void:
	animated_sprite_2d.look_at(global_position + (velocity + Vector2(980,0)).normalized())
	if not is_dead:
		life_time += delta

func _physics_process(delta : float) -> void:
	var acceleration : Vector2 = GRAVITY
	velocity += acceleration * delta
	position += velocity * delta
func _on_area_entered(area: Area2D) -> void:
	is_dead = true

func jump() -> void:
	if not is_dead:
		velocity = Vector2(0, -980 / 2.8)
		


func _on_body_entered(body):
	is_dead = true
