extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const MAP_SCENE = preload("res://sendstone_new (1).glb")

var player_spawn_height := 3.0

func _ready() -> void:
	_build_environment()
	_load_sandstone_map()
	_build_fallback_ground()
	var player := CharacterBody3D.new()
	player.set_script(PLAYER_SCRIPT)
	player.name = "Player"
	player.position = Vector3(0, player_spawn_height, 0)
	add_child(player)
	_build_hud()


func _place_player_on_ground(player: Character:= WorldEnvironment.new()
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

func _load_sandstone_map() -> void:
	var map_instance := MAP_SCENE.instantiate()
	map_instance.name = "SandstoneMap"
	add_child(map_instance)

	var bounds := _get_map_bounds(map_instance)
	if bounds.size.x <= 0.01 or bounds.size.z <= 0.01:
		push_error("Sandstone map has no measurable 3D geometry.")
		return

	var horizontal_size := maxf(bounds.size.x, bounds.size.z)
	var map_scale := 64.0 / horizontal_size
	# Start above the highest point of the imported level, then let gravity
	# place the player on the actual map collision instead of below the mesh.
	player_spawn_height = maxf(3.0, bounds.size.y * map_scale + 2.0)
	map_instance.scale = Vector3.ONE * map_scale
	map_instance.position = Vector3(
		-bounds.get_center().x * map_scale,
		-bounds.position.y * map_scale,
		-bounds.get_center().z * map_scale
	)

	_add_map_collisions(map_instance)
	print("Sandstone map loaded. Original bounds: ", bounds, " scale: ", map_scale)

func _get_map_bounds(root: Node) -> AABB:
	var result := AABB()
	var found := false
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D and node.mesh != null:
			var mesh_node := node as MeshInstance3D
			var mesh_bounds: AABB = mesh_node.get_aabb() * mesh_node.global_transform
			if found:
				result = result.merge(mesh_bounds)
			else:
				result = mesh_bounds
				found = true
		for child in node.get_children():
			stack.append(child)
	return result

func _add_map_collisions(root: Node) -> void:
	# Build collision as a sibling of each rendered mesh. This preserves the
	# imported mesh's local transform without applying it twice.
	var stack: Array[Node] = [root]
	var collision_count := 0
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is MeshInstance3D and node.mesh != null:
			var mesh_node := node as MeshInstance3D
			var trimesh_shape := mesh_node.mesh.create_trimesh_shape()
			if trimesh_shape != null:
				# Keep collision directly under the rendered mesh. It inherits
				# every GLB parent transform exactly once and uses mesh-local vertices.
				var body := StaticBody3D.new()
				body.name = mesh_node.name + "_Collision"
				body.collision_layer = 1
				body.collision_mask = 1
				body.position = Vector3.ZERO
				var shape_node := CollisionShape3D.new()
				shape_node.shape = trimesh_shape
				shape_node.position = Vector3.ZERO
				body.add_child(shape_node)
				mesh_node.add_child(body)
				collision_count += 1
		for child in node.get_children():
			stack.append(child)
	print("Sandstone collision bodies created: ", collision_count)

func _build_fallback_ground() -> void:
	# Safety floor guarantees the player cannot fall forever if part of the
	# imported GLB has missing or one-sided collision geometry.
	var ground := StaticBody3D.new()
	ground.name = "SafetyGround"
	ground.position.y = 0.0
	add_child(ground)

	var mesh_instance := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(120.0, 120.0)
	mesh_instance.mesh = floor_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.48, 0.40, 0.29)
	material.roughness = 1.0
	mesh_instance.material_override = material
	ground.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(120.0, 0.5, 120.0)
	collision.shape = shape
	collision.position.y = -0.25
	ground.add_child(collision)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var label := Label.new()
	label.text = "STRIKE ONLINE  |  SANDSTONE\nWASD — движение   Мышь — обзор   ЛКМ — огонь   R — перезарядка   Esc — меню"
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
