class_name Matrix extends RefCounted

var _rows: int = 0
var _cols: int = 0
var _data: Array[PackedFloat64Array] = []

func _to_string() -> String:
	var result : PackedStringArray = ["["]
	for i in range(_rows):
		result.push_back("[")
		for j in range(_cols):
			result.push_back(str(_data[i][j]))
			if j < _cols - 1:
				result.push_back(", ")
		result.push_back("]")
		if i < _rows - 1:
			result.push_back(", ")
	result.push_back("]")
	return "".join(result)

func rows() -> int:
	return _rows

func cols() -> int:
	return _cols

func set_value(row: int, col: int, value: float) -> void:
	_data[row][col] = value

func get_value(row: int, col: int) -> float:
	return _data[row][col]

func get_row(row: int) -> PackedFloat64Array:
	return _data[row]

func set_row(row: int, value: PackedFloat64Array) -> void:
	_data[row] = value

func get_col(col: int) -> PackedFloat64Array:
	var result = PackedFloat64Array()
	result.resize(_rows)
	for i in range(_rows):
		result[i] = _data[i][col]
	return result

func set_col(col: int, value: PackedFloat64Array) -> void:
	for i in range(_rows):
		_data[i][col] = value[i]

func rand(min: float, max: float) -> void:
	for i in range(_rows):
		for j in range(_cols):
			_data[i][j] = randf_range(min, max)

func transpose() -> Matrix:
	var result = Matrix.instance(_cols, _rows)
	for i in range(_rows):
		for j in range(_cols):
			result._data[j][i] = _data[i][j]
	return result

func dot(other: Matrix) -> Matrix:
	assert(_cols == other._rows)
	var result = Matrix.instance(_rows, other._cols)
	for i in range(_rows):
		for j in range(other._cols):
			var sum = 0.0
			for k in range(_cols):
				sum += _data[i][k] * other._data[k][j]
			result._data[i][j] = sum
	return result

func add(other: Matrix) -> Matrix:
	var result = Matrix.instance(_rows, _cols)
	for i in range(_rows):
		for j in range(_cols):
			result._data[i][j] = _data[i][j] + other._data[i][j]
	return result

func sub(other: Matrix) -> Matrix:
	var result = Matrix.instance(_rows, _cols)
	for i in range(_rows):
		for j in range(_cols):
			result._data[i][j] = _data[i][j] - other._data[i][j]
	return result

func mul(other: Matrix) -> Matrix:
	var result = Matrix.instance(_rows, _cols)
	for i in range(_rows):
		for j in range(_cols):
			result._data[i][j] = _data[i][j] * other._data[i][j]
	return result

func div(other: Matrix) -> Matrix:
	var result = Matrix.instance(_rows, _cols)
	for i in range(_rows):
		for j in range(_cols):
			result._data[i][j] = _data[i][j] / other._data[i][j]
	return result

func map(callable: Callable) -> Matrix:
	var result = Matrix.instance(_rows, _cols)
	for i in range(_rows):
		for j in range(_cols):
			result._data[i][j] = callable.call(_data[i][j])
	return result

func add_assign(other: Matrix) -> void:
	for i in range(_rows):
		for j in range(_cols):
			_data[i][j] += other._data[i][j]

func sub_assign(other: Matrix) -> void:
	for i in range(_rows):
		for j in range(_cols):
			_data[i][j] -= other._data[i][j]

func mul_assign(other: Matrix) -> void:
	for i in range(_rows):
		for j in range(_cols):
			_data[i][j] *= other._data[i][j]

func div_assign(other: Matrix) -> void:
	for i in range(_rows):
		for j in range(_cols):
			_data[i][j] /= other._data[i][j]


func map_assign(callable: Callable) -> void:
	for i in range(_rows):
		for j in range(_cols):
			_data[i][j] = callable.call(_data[i][j])

func duplicate() -> Matrix:
	var result = Matrix.instance(_rows, _cols)
	for i in range(_rows):
		for j in range(_cols):
			result._data[i][j] = _data[i][j]
	return result

static func instance(rows: int, cols: int) -> Matrix:
	var result = Matrix.new()
	result._rows = rows
	result._cols = cols
	result._data.resize(rows)
	for i in range(rows):
		result._data[i].resize(cols)
	return result

static func instance_identity(size: int) -> Matrix:
	var result = Matrix.instance(size, size)
	for i in range(size):
		result._data[i][i] = 1.0
	return result

static func instance_from(array: Array[PackedFloat64Array]) -> Matrix:
	var result = Matrix.instance(array.size(), array[0].size())
	for i in range(array.size()):
		for j in range(array[0].size()):
			result._data[i][j] = array[i][j]
	return result
