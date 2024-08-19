extends CharacterBody2D

@onready var collision_area = $CollisionArea
@onready var health_component = $HealthComponent
@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_bar = $HealthBar

const MAX_SPEED = 125
const ACCELERATION_SMOOTHING = 20

var number_colliding_bodies = 0


func _ready():
	collision_area.body_entered.connect(on_body_entered)
	collision_area.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	update_health_display()


func _process(delta):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED
	
	self.velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	
	move_and_slide()
	

func get_movement_vector() -> Vector2:
	
	# `velocity` will be a Vector2 between `Vector2(-1.0, -1.0)` and `Vector2(1.0, 1.0)`.
	# This handles deadzone in a correct way for most use cases.
	# The resulting deadzone will have a circular shape as it generally should.
	var vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return vec


func check_deal_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	
	health_component.damage(1)
	damage_interval_timer.start()
	
	print(health_component.current_health)
	
	
func update_health_display():
	health_bar.value = health_component.get_health_percent()


func on_body_entered(other_body: Node2D):
	number_colliding_bodies += 1
	check_deal_damage()


func on_body_exited(other_body: Node2D):
	number_colliding_bodies -= 1
	
	
func on_damage_interval_timer_timeout():
	check_deal_damage()
	
	
func on_health_changed():
	update_health_display()
