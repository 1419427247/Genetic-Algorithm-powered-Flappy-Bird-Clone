extends Node2D

const BEAN := preload("res://scene/pacman/bean.tscn")
const MAN := preload("res://scene/pacman/man.tscn")

@onready var natural_stage = $NaturalStage

@onready var spawn_mark = $SpawnMark

var mans : Array[Man] = []

var neural_networks : Array[NeuralNetwork] = []

func _ready() -> void:
	Engine.time_scale = 10
	restart()

var round_count : int = 0
var life_time : float = 0

func restart() -> void:
	round_count += 1
	life_time = 0
	
	var max_score : float = 0
	for man in mans:
		var chromosome : NaturalStage.Chromosome = man.get_meta("chromosome")
		chromosome.fitness += man.score
		natural_stage.return_chromosome(chromosome)
		max_score = max(max_score,man.score)
		man.queue_free()
	print("最高得分:",max_score)
	mans.clear()
	natural_stage.generation()

	#print(natural_stage._chromosomes.size())

	for child in get_children():
		if child is Bean:
			child.queue_free()

	for i in range(48):
		var man : Man = MAN.instantiate()
		man.position = spawn_mark.position
		mans.push_back(man)
		add_child(man)
		
		var chromosome : NaturalStage.Chromosome = natural_stage.get_chromosome()
		man.set_meta("chromosome",chromosome)

		var neural_network : NeuralNetwork = NeuralNetwork.new()
		man.set_meta("neural_network",neural_network)
		neural_network.input_count = 9
		neural_network.output_count = 2
		neural_network.hidden_layer = [16,8]
		man.add_child(neural_network)

		neural_network.deserialize(chromosome.genes)
		
	$Timer.start()

func _physics_process(delta: float) -> void:
	var is_all_dead : bool = true
	var sur_count : int = 0

	for man : Man in mans:
		if man.is_dead:
			continue
		is_all_dead = false
		var neural_network : NeuralNetwork = man.get_meta("neural_network")
		
		var arg_0 : float = 0
		if man.ray_cast_2d_1.is_colliding():
			var k := man.ray_cast_2d_1.get_collider()
			if k is Bean:
				arg_0 = 0.5
			else:
				arg_0 = 1
		var arg_1 : float = 0
		if man.ray_cast_2d_2.is_colliding():
			var k := man.ray_cast_2d_2.get_collider()
			if k is Bean:
				arg_1 = 0.5
			else:
				arg_1 = 1
		var arg_2 : float = 0
		if man.ray_cast_2d_3.is_colliding():
			var k := man.ray_cast_2d_3.get_collider()
			if k is Bean:
				arg_2 = 0.5
			else:
				arg_2 = 1

		var arg_3 : float = (man.ray_cast_2d_1.get_collision_point() - man.position).length() / 600
		var arg_4 : float = (man.ray_cast_2d_2.get_collision_point() - man.position).length() / 600
		var arg_5 : float = (man.ray_cast_2d_3.get_collision_point() - man.position).length() / 600

		var arg_6 : float = man.direction.x + 0.5
		var arg_7 : float = man.direction.y + 0.5
		var arg_8 : float = man.rotation / PI
		var result : Matrix =  neural_network.feed_forward(Matrix.instance_from([
			[arg_0,arg_1,arg_2,arg_3,arg_4,arg_5,arg_6,arg_7,arg_8]
		]))
		man.direction = Vector2(result.get_value(0,0) - 0.5,result.get_value(0,1) - 0.5)
	if is_all_dead:
		restart()

func _on_timer_timeout():
	var bean : Bean = BEAN.instantiate()
	bean.position = Vector2(randf_range(0,1200),randf_range(0,600))
	add_child(bean)
