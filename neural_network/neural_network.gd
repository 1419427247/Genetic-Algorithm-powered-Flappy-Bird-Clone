@tool
class_name NeuralNetwork extends Node

enum NeuraActivationFunction{
	SIGMOID,
	TANH,
	RELU,
	LEAKY_RELU,
	SOFTMAX
}

static var ACTIVATION_FUNCTIONS : Dictionary = {
	NeuraActivationFunction.SIGMOID: func(x : float) -> float: return 1.0 / (1.0 + exp(-x)),
	NeuraActivationFunction.TANH: func(x : float) -> float: return tanh(x),
	NeuraActivationFunction.RELU: func(x : float) -> float: return max(0.0, x),
	NeuraActivationFunction.LEAKY_RELU: func(x : float) -> float: return max(0.01 * x, x),
	NeuraActivationFunction.SOFTMAX: func(x : float) -> float: return exp(x)
}

@export var activation_function : NeuraActivationFunction = NeuraActivationFunction.SIGMOID

@export var input_count : int = 1

@export var output_count : int = 1

@export var hidden_layer : Array[int] = [1]:
	set(value):
		for i : int in hidden_layer.size():
			hidden_layer[i] = max(0,hidden_layer[i])
		hidden_layer = value

var _weights : Array[Matrix] = []

var _biases : Array[Matrix] = []

func _ready():
	_weights.resize(hidden_layer.size() + 1)
	_biases.resize(hidden_layer.size() + 1)

	_weights[0] = Matrix.instance(input_count, hidden_layer[0])
	_biases[0] = Matrix.instance(1, hidden_layer[0])

	for i : int in range(1, hidden_layer.size()):
		_weights[i] = Matrix.instance(hidden_layer[i - 1], hidden_layer[i])
		_biases[i] = Matrix.instance(1, hidden_layer[i])

	_weights[hidden_layer.size()] = Matrix.instance(hidden_layer[hidden_layer.size() - 1], output_count)
	_biases[hidden_layer.size()] = Matrix.instance(1, output_count)

	#for i : int in range(0, hidden_layer.size() + 1):
		#_weights[i].rand(-1,1)
		#_biases[i].rand(-1,1)

func feed_forward(input : Matrix) -> Matrix:
	if input.cols() != input_count:
		printerr("Error: Input size does not match input count")
		return Matrix.instance(1,output_count)
	var output : Matrix = input;
	for i : int in range(0, hidden_layer.size() + 1):
		output = output.dot(_weights[i])
		output.add_assign(_biases[i])
		output.map_assign(ACTIVATION_FUNCTIONS[activation_function])
	return output

## 序列化
func serialize() -> PackedFloat64Array:
	var data : PackedFloat64Array = PackedFloat64Array()
	for i : int in range(0, hidden_layer.size() + 1):
		for j : int in range(0, _weights[i].rows()):
			for k : int in range(0, _weights[i].cols()):
				data.push_back(_weights[i].get_value(j,k))
		for j : int in range(0, _biases[i].rows()):
			for k : int in range(0, _biases[i].cols()):
				data.push_back(_biases[i].get_value(j,k))
	return data

## 反序列化
func deserialize(data : PackedFloat64Array):
	var index : int = 0
	for i : int in range(0, hidden_layer.size() + 1):
		for j : int in range(0, _weights[i].rows()):
			for k : int in range(0, _weights[i].cols()):
				_weights[i].set_value(j,k,data[index])
				index += 1
		for j : int in range(0, _biases[i].rows()):
			for k : int in range(0, _biases[i].cols()):
				_biases[i].set_value(j,k,data[index])
				index += 1
