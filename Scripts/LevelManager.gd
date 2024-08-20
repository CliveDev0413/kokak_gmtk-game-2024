extends Node2D

@export var scene_switcher: StaticBody2D;

func _process(delta: float) -> void:
	var edible_objects = get_tree().get_nodes_in_group("edible_objects");
	
	if edible_objects.size() <= 0:
		scene_switcher.is_enabled = true;
	else:
		scene_switcher.is_enabled = false;
