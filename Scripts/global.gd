extends Node

var is_frog_tongue_out: bool = false;
var frog: CharacterBody2D;

func _ready() -> void:
	frog = get_tree().get_first_node_in_group("player");
