@tool
## 遗传算法是一种模拟自然选择和遗传机制的优化算法。它通过模拟进化过程中的遗传、交叉和变异等操作，来搜索问题的最优解。
class_name NaturalStage extends Node

class Chromosome extends RefCounted:
	## 基因
	var genes: PackedFloat64Array = PackedFloat64Array()
	## 适应度
	var fitness: float = 1
	func _to_string() -> String:
		return "fitness: " + str(fitness) + ", genes: " + str(genes)

## 选择算法
enum SelectionAlgorithm{
	## 轮盘赌
	ROULETTE,
	## 随机竞争
	RANDOM_COMPETITION,
	## 随机
	RANDOM,
}

## 交叉算法用于遗传算法中的个体交叉操作。它决定了如何将两个个体的基因组合成一个新的个体。
enum CrossAlgorithm{
	## 单点交叉算法
	## 在一个随机的交叉点将两个个体的基因进行切割，并产生一个新的个体
	ONE_POINT = 0,
	## 双点交叉算法
	## 在两个随机的交叉点将两个个体的基因进行切割，并产生一个新的个体
	TWO_POINT = 1,
	## 均匀交叉算法
	## 对两个个体的每一个基因位，选择一个随机数，如果小于交叉概率，则交换基因
	UNIFORM = 2,
	## 算数交叉算法
	## 对两个个体的每一个基因位，随机选择一个权重值，然后按照权重值对基因进行加权平均
	ARITHMETIC = 3,
}

## 突变算法
enum MutationAlgorithm{
	## 边界突变
	BOUNDARY,
	## 高斯突变
	## 对染色体上的每一个基因位，选择一个随机数，如果小于突变概率，则对该位置的基因值进行一定程度的变异。
	## 该变异值是一个随机生成的服从高斯分布的小数。
	GAUSSIAN,
	## 均匀突变
	## 对染色体上的每一个基因位，选择一个随机数，如果小于突变概率，则对该位置的基因值进行一定程度的变异。
	UNIFORM,
}

## 种子（seed）是一个用于生成随机数的起始值。种子的作用是确定随机数生成器的初始状态，从而使得每次运行遗传算法时生成的随机数序列是可重复的。
## 通过设置相同的种子，可以确保每次运行遗传算法时使用相同的随机数序列。这对于调试和复现实验结果非常有用。如果不设置种子，每次运行遗传算法时都会生成不同的随机数序列，导致结果的不确定性。因此，种子在遗传算法中用于控制随机性，使得实验结果可重复。可以根据需要设置不同的种子值来观察遗传算法的不同运行情况。
@export var seed : int = 0

## 基因染色体长度，即基因的个数
@export var gene_size : int = 32

## 使用Round函数将基因值转换为整数
@export var gene_force_int : bool = false

## 基因取值范围
@export var gene_range : Vector2 = Vector2(-1, 1)

## 这个参数表示在遗传算法中不参与突变而直接保留最优个体的比例。
## 默认值为0.1，表示直接保留不参与突变的最优个体的比例为10%。
@export_range(0,1,0.00001) var optimal_retention_rate : float = 0.1

@export_group("Selection Algorithm")
## 选择算法
@export var selection_algorithm : SelectionAlgorithm = SelectionAlgorithm.ROULETTE

@export_group("Cross Algorithm")
## 交叉算法
@export var cross_algorithm : CrossAlgorithm = CrossAlgorithm.UNIFORM

@export_group("Mutation Algorithm")
## 突变算法
@export var mutation_algorithm : MutationAlgorithm = MutationAlgorithm.UNIFORM:
	set(value):
		mutation_algorithm = value
		notify_property_list_changed()

## 这个参数表示基因突变的概率，它决定了在遗传算法中每个基因发生突变的可能性。
## 突变是指基因在遗传过程中发生的随机变化，有助于引入新的基因组合，从而增加遗传算法的多样性。
## 默认值为0.02，表示每个基因有0.2%的概率发生突变。
@export_range(0,1,0.00001) var mutation_rate : float = 0.02

## 高斯突变的标准差
@export_range(0,1,0.001) var gaussian_mutation_standard_deviation : float = 0.1

## 基因库
var _chromosomes : Array[Chromosome] = []

## 退回的基因库
var _return_chromosomes : Array[Chromosome] = []

var random_number_generator : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	random_number_generator.seed = seed

func _validate_property(property: Dictionary):
	if property.name == "gaussian_mutation_standard_deviation" and mutation_algorithm != MutationAlgorithm.GAUSSIAN:
		property.usage = PROPERTY_USAGE_NO_EDITOR

## 取一条染色体
func get_chromosome() -> Chromosome:
	var result : Chromosome = null
	if _chromosomes.size() == 0:
		result = Chromosome.new()
		for i in range(gene_size):
			var gene : float = random_number_generator.randf_range(gene_range.x, gene_range.y)
			if gene_force_int:
				gene = round(gene)
			result.genes.push_back(gene)
	else:
		result = _chromosomes.pop_back()
	return result

## 归还一个染色体
func return_chromosome(chromosome : Chromosome):
	_return_chromosomes.push_back(chromosome)

## 自然选择
func generation() -> void:
	if _return_chromosomes.size() == 0:
		return

	## 根据适应度将最优个体直接放入下一代
	var optimal_retention_count : int = int(_return_chromosomes.size() * optimal_retention_rate)
	var optimal_retention_chromosomes : Array[Chromosome] = []
	if optimal_retention_count > 0:
		_return_chromosomes.sort_custom(
			func(a : Chromosome, b : Chromosome) -> bool:
				return a.fitness > b.fitness
		)
		for i in range(optimal_retention_count):
			optimal_retention_chromosomes.push_back(_return_chromosomes[i])
	
	var selection_chromosomes : Array[Chromosome] = selection(_return_chromosomes)
	var cross_chromosomes : Array[Chromosome] = cross(selection_chromosomes)
	var mutation_chromosomes : Array[Chromosome] = mutation(cross_chromosomes)

	for i in range(optimal_retention_count):
		optimal_retention_chromosomes[i].fitness = 1
	mutation_chromosomes.append_array(optimal_retention_chromosomes)

	_chromosomes = mutation_chromosomes
	_return_chromosomes = []

## 选择
func selection(chromosomes : Array[Chromosome]) -> Array[Chromosome]:
	var result : Array[Chromosome] = []
	match selection_algorithm:
		SelectionAlgorithm.ROULETTE:
			var total_fitness : float = 0
			for chromosome in chromosomes:
				total_fitness += chromosome.fitness
			for i in range(chromosomes.size()):
				var random : float = random_number_generator.randf() * total_fitness
				var total : float = 0
				for chromosome in chromosomes:
					total += chromosome.fitness
					if total >= random:
						result.push_back(chromosome)
						break
		SelectionAlgorithm.RANDOM_COMPETITION:
			for i in range(chromosomes.size()):
				var chromosome_a : Chromosome = chromosomes[random_number_generator.randi() % chromosomes.size()]
				var chromosome_b : Chromosome = chromosomes[random_number_generator.randi() % chromosomes.size()]
				if chromosome_a.fitness > chromosome_b.fitness:
					result.push_back(chromosome_a)
				else:
					result.push_back(chromosome_b)
		SelectionAlgorithm.RANDOM:
			for i in range(chromosomes.size()):
				result.push_back(chromosomes[random_number_generator.randi() % chromosomes.size()])
	return result

## 交叉
func cross(chromosomes : Array[Chromosome]) -> Array[Chromosome]:
	var result : Array[Chromosome] = []
	for i in range(0, chromosomes.size(), 2):
		var chromosome_a : Chromosome = chromosomes[i]
		var chromosome_b : Chromosome = chromosomes[i + 1]

		var new_chromosome_a : Chromosome = Chromosome.new()
		var new_chromosome_b : Chromosome = Chromosome.new()

		match cross_algorithm:
			CrossAlgorithm.ONE_POINT:
				var cross_point : int = random_number_generator.randi() % gene_size
				for j in range(gene_size):
					if j < cross_point:
						new_chromosome_a.genes.push_back(chromosome_a.genes[j])
						new_chromosome_b.genes.push_back(chromosome_b.genes[j])
					else:
						new_chromosome_a.genes.push_back(chromosome_b.genes[j])
						new_chromosome_b.genes.push_back(chromosome_a.genes[j])
			CrossAlgorithm.TWO_POINT:
				var cross_point_a : int = random_number_generator.randi() % gene_size
				var cross_point_b : int = random_number_generator.randi() % gene_size
				if cross_point_a > cross_point_b:
					var temp : int = cross_point_a
					cross_point_a = cross_point_b
					cross_point_b = temp
				for j in range(gene_size):
					if j < cross_point_a:
						new_chromosome_a.genes.push_back(chromosome_a.genes[j])
						new_chromosome_b.genes.push_back(chromosome_b.genes[j])
					elif j < cross_point_b:
						new_chromosome_a.genes.push_back(chromosome_b.genes[j])
						new_chromosome_b.genes.push_back(chromosome_a.genes[j])
					else:
						new_chromosome_a.genes.push_back(chromosome_a.genes[j])
						new_chromosome_b.genes.push_back(chromosome_b.genes[j])
			CrossAlgorithm.UNIFORM:
				for j in range(gene_size):
					if random_number_generator.randi() % 2 == 0:
						new_chromosome_a.genes.push_back(chromosome_a.genes[j])
						new_chromosome_b.genes.push_back(chromosome_b.genes[j])
					else:
						new_chromosome_a.genes.push_back(chromosome_b.genes[j])
						new_chromosome_b.genes.push_back(chromosome_a.genes[j])
			CrossAlgorithm.ARITHMETIC:
				for j in range(gene_size):
					var alpha : float = random_number_generator.randf_range(0, 1)
					var new_gene : float = chromosome_a.genes[j] * alpha + chromosome_b.genes[j] * (1 - alpha)
					new_gene = clampf(new_gene, gene_range.x, gene_range.y)
					if gene_force_int:
						new_gene = round(new_gene)
					new_chromosome_a.genes.push_back(new_gene)
					new_gene = chromosome_a.genes[j] * (1 - alpha) + chromosome_b.genes[j] * alpha
					new_gene = clampf(new_gene, gene_range.x, gene_range.y)
					if gene_force_int:
						new_gene = round(new_gene)
					new_chromosome_b.genes.push_back(new_gene)
		result.push_back(new_chromosome_a)
		result.push_back(new_chromosome_b)
	return result

func mutation(chromosomes : Array[Chromosome]) -> Array[Chromosome]:
	var result : Array[Chromosome] = []
	match mutation_algorithm:
		MutationAlgorithm.BOUNDARY:
			for chromosome in chromosomes:
				for i in range(gene_size):
					if random_number_generator.randf() < mutation_rate:
						var new_gene : float = 0
						if random_number_generator.randi() % 2 == 0:
							new_gene = gene_range.x
						else:
							new_gene = gene_range.y
						if gene_force_int:
							new_gene = round(new_gene)
						chromosome.genes[i] = new_gene
				result.push_back(chromosome)
		MutationAlgorithm.GAUSSIAN:
			for chromosome in chromosomes:
				for i in range(gene_size):
					if random_number_generator.randf() < mutation_rate:
						var gaussian : float = random_number_generator.randfn(0, 1)
						var new_gene : float = chromosome.genes[i] + gaussian * gaussian_mutation_standard_deviation
						new_gene = clampf(new_gene, gene_range.x, gene_range.y)
						if gene_force_int:
							new_gene = round(new_gene)
						chromosome.genes[i] = new_gene
				result.push_back(chromosome)
		MutationAlgorithm.UNIFORM:
			for chromosome in chromosomes:
				for i in range(gene_size):
					if random_number_generator.randf() < mutation_rate:
						chromosome.genes[i] = random_number_generator.randf_range(gene_range.x, gene_range.y)
						if gene_force_int:
							chromosome.genes[i] = round(chromosome.genes[i])
				result.push_back(chromosome)
	return result
