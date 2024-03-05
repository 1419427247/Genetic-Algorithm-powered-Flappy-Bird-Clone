extends Node2D

const BIRD = preload("res://scene/flappy_bird/bird.tscn")
const PIPELINE = preload("res://scene/flappy_bird/pipeline.tscn")

@onready var stage: NaturalStage = $Stage

@onready var pipeline_spawn: Marker2D = $PipelineSpawn
@onready var bird_spawn: Marker2D = $BirdSpawn

var birds : Array[Bird] = []

var pipelines : Array[Node2D] = []

var neural_networks : Array[NeuralNetwork] = []

func _ready() -> void:
	Engine.time_scale = 3
	restart()

var round_count : int = 0
var life_time : float = 0

func restart() -> void:
	round_count += 1
	life_time = 0
	for i in range(pipelines.size()):
		pipelines[i].queue_free()
	pipelines = []

	var total_life_time : float = 0
	var max_life_time : float = 0
	for i in range(birds.size()):
		var chromosome : NaturalStage.Chromosome = birds[i].get_meta("chromosome")
		total_life_time += birds[i].life_time
		if birds[i].life_time > max_life_time:
			max_life_time = birds[i].life_time
		chromosome.fitness = birds[i].life_time
		stage.return_chromosome(chromosome)
		birds[i].queue_free()
		neural_networks[i].queue_free()
	stage.generation()
	birds.clear()
	neural_networks.clear()
	print("平均存活时间:",total_life_time / 16," 最大存活时间:",max_life_time)

	for i in range(16):
		var bird : Bird = BIRD.instantiate()
		bird.position = bird_spawn.position
		birds.push_back(bird)
		add_child(bird)
		
		var chromosome : NaturalStage.Chromosome = stage.get_chromosome()
		bird.set_meta("chromosome",chromosome)

		var neural_network : NeuralNetwork = NeuralNetwork.new()
		neural_network.input_count = 1
		neural_network.output_count = 1
		neural_network.hidden_layer = [2]
		neural_networks.push_back(neural_network)
		add_child(neural_network)

		neural_network.deserialize(chromosome.genes)
 	
	$Timer.start()
	_on_timer_timeout()

func _physics_process(delta: float) -> void:
	if pipelines.size() > 0:
		var first : Node2D = pipelines.front()
		if first.position.x < bird_spawn.position.x - 50:
			pipelines.pop_front()
			first.queue_free()
	
	var first : Node2D = pipelines.front()
	life_time +=  delta
	var all_dead : bool = true
	var sur_count : int = 0

	for i in range(birds.size()):
		var bird : Bird = birds[i]
		if not bird.is_dead:
			sur_count+=1
		else:
			continue
		var neural_network : NeuralNetwork = neural_networks[i]
		all_dead = all_dead and bird.is_dead

		var result : Matrix =  neural_network.feed_forward(Matrix.instance_from([
			[(bird.position.y - first.position.y)]
		]))
		if result.get_value(0,0) > 0.5:
			bird.jump()
	
	if all_dead:
		restart()

func _on_timer_timeout() -> void:
	var pipeline : Node2D = PIPELINE.instantiate()
	pipeline.position = pipeline_spawn.position + Vector2(0,randi_range(-125,125))
	pipelines.push_back(pipeline)
	add_child(pipeline)

func _on_button_button_down() -> void:
	restart()
