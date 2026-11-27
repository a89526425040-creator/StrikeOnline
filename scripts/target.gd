extends StaticBody3D

var health := 100
var visual: MeshInstance3D

func _ready() -> void:
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.38
	capsule.height = 1.8
	visual = MeshInstance3D.new()
	visual.mesh = capsule
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.68, 0.23, 0.16)
	mat.roughness = 0.8
	visual.material_override = mat
	add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.8
	collision.shape = shape
	add_child(collision)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
	else:
		var mat := visual.material_override as StandardMaterial3D
		mat.albedo_color = Color(0.95, 0.65, 0.12)
