extends Node

const MAX_RANGE = 150

@onready var timer = $Timer

@export var sword_ability : PackedScene

var damage = 5
var base_wait_time

# Called when the node enters the scene tree for the first time.
func _ready():
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if (player == null):
		return
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy:Node2D): 
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	
	if (enemies.size() == 0):
		return
		
	enemies.sort_custom(func(a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)

	var sword_instance = sword_ability.instantiate() as SwordAbility
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(sword_instance)
	sword_instance.hitbox_component.damage = damage
	sword_instance.global_position = enemies[0].global_position
	
	#angles the sword towards the target enemy by getting the vector angle between the player and the enemy
	var enemy_direction = enemies[0].global_position - player.global_position
	sword_instance.rotation = enemy_direction.angle()
	
	
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id != "sword_rate":
		return
		
	var percent_reduction = current_upgrades["sword_rate"]["quantity"] * 0.1
	timer.wait_time = base_wait_time * (1 - percent_reduction)
	timer.start()
	
	print(timer.wait_time)
