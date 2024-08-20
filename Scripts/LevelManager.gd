extends Node2D

@export var next_scene_path: String;

var is_done = false;

func _process(delta: float) -> void:
	var edible_objects = get_tree().get_nodes_in_group("edible_objects");
	
	if edible_objects.size() <= 0 && !is_done:
		switch_scene();
		is_done = true;
		
func switch_scene() -> void:
	Transition.transition();
	await Transition.on_transition_finished;
	get_tree().change_scene_to_file(next_scene_path);
	pass;
