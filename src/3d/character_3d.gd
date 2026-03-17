extends CharacterBody3D

var is_dead: bool = false
@onready var health_component: HealthComponent = $HealthComponent
@onready var label:Label3D = $Label3D

var _base_speed: float = 5.0
var _label_msg:String = "%s / %s"

func _ready() -> void:
	if health_component:
		label.text = _label_msg % [str(health_component.current_health),str(health_component.get_max_health())]
		health_component.health_changed.connect(_on_health_changed)
		health_component.max_health_changed.connect(_on_max_health_changed)
		health_component.died.connect(_on_died)
		health_component.damage_received.connect(_on_damage_received)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_dead:
		velocity.x = 0
		velocity.y = 0
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = 4.5
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _base_speed
		velocity.z = direction.z * _base_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _base_speed)
		velocity.z = move_toward(velocity.z, 0, _base_speed)

	move_and_slide()

func _on_died() -> void:
	print("[Player] Died!")
	is_dead = true

func _on_health_changed(new_health: float, old_health: float) -> void:
	print("[Player] Health: %.1f -> %.1f" % [old_health, new_health])
	label.text = _label_msg % [str(new_health),str(health_component.get_max_health())]

func _on_max_health_changed(new_max: float, old_max: float):
	print("[Player] Max Health: %.1f -> %.1f" % [old_max, new_max])
	label.text = _label_msg % [str(health_component.current_health),str(new_max)]

func _on_damage_received(amount: float, final_damage: float, _source: Node) -> void:
	print("[Player] Took %.1f damage (original: %.1f)" % [final_damage, amount])
