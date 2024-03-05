@tool
class_name Chart extends Control

@export var background_color : Color = Color.WHITE:
	set(value):
		background_color = value
		queue_redraw()

@export var line_color : Color = Color.BLACK:
	set(value):
		line_color = value
		queue_redraw()

@export var point_color : Color = Color.BLACK:
	set(value):
		point_color = value
		queue_redraw()

@export var line_width : float = 1:
	set(value):
		line_width = value
		queue_redraw()

@export var point_size : float = 5:
	set(value):
		point_size = value
		queue_redraw()

@export var x_min : float = 0:
	set(value):
		x_min = value
		queue_redraw()

@export var x_max : float = 100:
	set(value):
		x_max = value
		queue_redraw()

@export var y_min : float = 0:
	set(value):
		y_min = value
		queue_redraw()

@export var y_max : float = 100:
	set(value):
		y_max = value
		queue_redraw()

@export var x_points : Array[float] = []:
	set(value):
		x_points = value
		queue_redraw()

@export var y_points : Array[float] = []:
	set(value):
		y_points = value
		queue_redraw()

@export var view_center : Vector2 = Vector2(0, 0):
	set(value):
		view_center = value
		queue_redraw()

@onready var natural_stage: NaturalStage = $NaturalStage

func _ready() -> void:
	for i in range(3):
		var chromosome := natural_stage.get_chromosome()
		chromosome.fitness = randi() % 100
		print(chromosome)
		natural_stage.return_chromosome(chromosome)

	natural_stage.generation()
	print("  ")
	print(natural_stage._chromosomes)

func add_point(x : float, y : float) -> void:
	x_points.append(x)
	y_points.append(y)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, size.x, size.y), background_color, true)
	
	## 根据view center绘制坐标轴
	if x_min <= view_center.x and view_center.x <= x_max:
		var x = (view_center.x - x_min) / (x_max - x_min) * size.x
		draw_line(Vector2(x, 0), Vector2(x, size.y), line_color, line_width)
	if y_min <= view_center.y and view_center.y <= y_max:
		var y = (view_center.y - y_min) / (y_max - y_min) * size.y
		draw_line(Vector2(0, y), Vector2(size.x, y), line_color, line_width)

	var x_scale : float = size.x / (x_max - x_min)
	var y_scale : float = size.y / (y_max - y_min)

	for i in range(x_points.size() - 1):
		var x1 = (x_points[i] - x_min) * x_scale
		var y1 = size.y - (y_points[i] - y_min) * y_scale
		var x2 = (x_points[i + 1] - x_min) * x_scale
		var y2 = size.y - (y_points[i + 1] - y_min) * y_scale
		draw_line(Vector2(x1, y1), Vector2(x2, y2), line_color, line_width)
		draw_circle(Vector2(x1, y1), point_size, point_color)
		draw_circle(Vector2(x2, y2), point_size, point_color)
