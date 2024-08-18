extends Camera2D

@export var dead_zone: float = 250.0;

func _process(delta: float) -> void:
	var pos = get_local_mouse_position();
	if pos.x > -dead_zone and pos.y < dead_zone:
		set_position(pos);
	pass;
