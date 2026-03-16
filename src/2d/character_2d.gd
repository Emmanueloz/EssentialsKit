extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

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
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_died() -> void:
	print("Character2D died!")
	is_dead = true

func _on_health_changed(new_health: float) -> void:
	print("Character2D health changed: ", new_health)
