extends Node3D


func _on_area_3d_body_entered(body):
	if body == $Player:
		$Player.position = Vector3(0,0,0)
