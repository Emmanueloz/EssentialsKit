extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var is_dead: bool = false
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_dead:
		move_and_slide()
		return
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_died() -> void:
	print("Character3D died!")
	is_dead = true

func _on_health_changed(new_health: float) -> void:
	print("Character3D health changed: ", new_health)
