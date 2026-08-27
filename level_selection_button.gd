extends TextureButton

func _ready() -> void:
	var bm := BitMap.new()
	bm.create_from_image_alpha(texture_normal.get_image())
	texture_click_mask = bm
