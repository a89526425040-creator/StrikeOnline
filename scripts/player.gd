extends CharacterBody3D

const SPEED := 6.2
const MOUSE_SENSITIVITY := 0.0022
const FIRE_RATE := 0.105
const MAGAZINE_SIZE := 30

var gravity := 18.0
var pitch := 0.0
var fire_timer := 0.0
var ammo := MAGAZINE_SIZE
var health := 100
var camera: Camera3D
var weapon_root: Node3D
var ray: RayCast3D

func _ready() -> void:
	_setup_input()
	_add_collision()
	_add_camera_and_weapon()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _setup_input() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("jump", KEY_SPACE)

func _add_key_action(action_name: String, key: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action_name, event)

func _add_collision() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.8
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = 0.9
	add_child(collision)

func _add_camera_and_weapon() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.58, 0)
	camera.current = true
	add_child(camera)
	ray = RayCast3D.new()
	ray.target_position = Vector3(0, 0, -100)
	ray.enabled = true
	camera.add_child(ray)
	weapon_root = Node3D.new()
	weapon_root.position = Vector3(0.28, -0.25, -0.48)
	camera.add_child(weapon_root)
	_make_weapon_part(Vector3(0.0, 0.0, 0.0), Vector3(0.13, 0.16, 0.48), Color(0.12, 0.14, 0.14))
	_make_weapon_part(Vector3(0.0, 0.015, -0.34), Vector3(0.055, 0.055, 0.48), Color(0.075, 0.08, 0.08))
	_make_weapon_part(Vector3(0.0, -0.15, 0.08), Vector3(0.09, 0.22, 0.12), Color(0.18, 0.16, 0.13))
	_make_weapon_part(Vector3(0.0, -0.12, 0.22), Vector3(0.075, 0.25, 0.09), Color(0.12, 0.12, 0.11))

func _make_weapon_part(pos: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.55
	mat.roughness = 0.42
	part.material_override = mat
	weapon_root.add_child(part)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		pitch = clampf(pitch - event.relative.y * MOUSE_SENSITIVITY, -1.35, 1.35)
		camera.rotation.x = pitch
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				return
			_shoot()
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_R:
			ammo = MAGAZINE_SIZE

func _physics_process(delta: float) -> void:
	fire_timer = maxf(0.0, fire_timer - delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 5.2
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_shoot()
	move_and_slide()

func _shoot() -> void:
	if fire_timer > 0.0 or ammo <= 0:
		return
	fire_timer = FIRE_RATE
	ammo -= 1
	ray.force_raycast_update()
	if ray.is_colliding():
		var hit := ray.get_collider()
		if hit and hit.has_method("take_damage"):
			hit.take_damage(34)

func take_damage(amount: int) -> void:
	health = maxi(0, health - amount)
