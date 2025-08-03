extends Node2D
class_name Bird

func set_flying(is_flying := true):
	$Sprite.frame = 1 if is_flying else 0
