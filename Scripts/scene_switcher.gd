extends StaticBody2D

@export var next_scene_path: String;

var is_enabled: bool = true;

func _on_body_entered(body: Node2D) -> void:
	if is_enabled && body.is_in_group("player"):
		
