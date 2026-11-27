extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const TARGET_SCRIPT = preload("res://scripts/target.gd")

func _ready() -> void:
	_build_environment()
	_build_arena()
	_spawn_targets()
	var player = CharacterBody3D.new()
	player.set_script(PLAYER_SCRIPT)
	player.name = "Player"
	player.position = Vector3(0, 0.1, 8)
	add_child(player)
	_build_hud()

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.sky.sky_material = ProceduralSkyMaterial.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.62, 0.7)
	env.ambient_light_energy = 0.65
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

func _build_arena() -> void:
	_make_box("Ground", Vector3(0, -0.5, 0), Vector3(34, 1, 34), Color(0.22, 0.25, 0.26))
	_make_box("BackWall", Vector3(0, 2, -17), Vector3(34, 4, 0.7), Color(0.31, 0.34, 0.35))
	_make_box("LeftWall", Vector3(-17, 2, 0), Vector3(0.7, 4, 34), Color(0.28, 0.31, 0.32))
	_make_box("RightWall", Vector3(17, 2, 0), Vector3(0.7, 4, 34), Color(0.28, 0.31, 0.32))
	_make_box("FrontWall", Vector3(0, 2, 17), Vector3(34, 4, 0.7), Color(0.31, 0.34, 0.35))
	_make_box("ContainerA", Vector3(-6, 1.2, -4), Vector3(5, 2.4, 3), Color(0.38, 0.25, 0.16))
	_make_box("ContainerB", Vector3(6, 1.2, -8), Vector3(4, 2.4, 3), Color(0.17, 0.29, 0.31))
	_make_box("BarrierA", Vector3(1, 0.65, 1), Vector3(4, 1.3, 1.1), Color(0.42, 0.43, 0.39))
	_make_box("BarrierB", Vector3(-8, 0.65, 6), Vector3(3, 1.3, 1.1), Color(0.42, 0.43, 0.39))

func _make_box(label: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.88
	visual.material_override = mat
	body.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _spawn_targets() -> void:
	for p in [Vector3(-5, 0.95, -12), Vector3(0, 0.95, -13), Vector3(5, 0.95, -11), Vector3(10, 0.95, -3)]:
		var target := StaticBody3D.new()
		target.set_script(TARGET_SCRIPT)
		target.position = p
		add_child(target)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "STRIKE ONLINE  |  ПРОТОТИП\nWASD — движение   Мышь — обзор   ЛКМ — огонь   R — перезарядка   Esc — меню"
	label.position = Vector2(18, 16)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.93, 0.95, 0.96))
	layer.add_child(label)
	var cross := Label.new()
	cross.text = "+"
	cross.set_anchors_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-10, -22)
	cross.add_theme_font_size_override("font_size", 32)
	cross.add_theme_color_override("font_color", Color.WHITE)
	layer.add_child(cross)
