# AtlasTextureHelper.gd - Helper script to create AtlasTextures from sprite sheets
class_name AtlasTextureHelper
extends RefCounted

# Create an AtlasTexture from a sprite sheet
static func create_atlas_texture(source_texture: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = region
	return atlas

# Helper to create tool UI icons from a single sprite sheet
static func create_tool_ui_icons(ui_sprite_sheet: Texture2D, icon_size: Vector2 = Vector2(16, 16)) -> Dictionary:
	var icons = {}
	
	# Your UI sprite sheet layout (16x16 each): hoe, shovel, watering_can (horizontally)
	icons["hoe"] = create_atlas_texture(ui_sprite_sheet, Rect2(0, 0, icon_size.x, icon_size.y))
	icons["shovel"] = create_atlas_texture(ui_sprite_sheet, Rect2(icon_size.x, 0, icon_size.x, icon_size.y))
	icons["watering_can"] = create_atlas_texture(ui_sprite_sheet, Rect2(icon_size.x * 2, 0, icon_size.x, icon_size.y))
	
	return icons

# Helper to create tool rack sprites from a single sprite sheet
static func create_tool_rack_sprites(rack_sprite_sheet: Texture2D, sprite_size: Vector2 = Vector2(16, 16)) -> Array[Texture2D]:
	var sprites: Array[Texture2D] = []
	
	# Your rack sprite sheet: top row has 3 tools, bottom row has unused objects
	# We need: empty, hoe, shovel, watering_can
	# Assuming empty rack is at position (3,0) or create a blank texture
	# Top row: hoe(0,0), shovel(1,0), watering_can(2,0)
	
	# You might need to create an empty rack sprite or use a different position
	# For now, I'll assume there's an empty version somewhere, adjust as needed
	sprites.append(create_atlas_texture(rack_sprite_sheet, Rect2(0, sprite_size.y, sprite_size.x, sprite_size.y))) # Bottom row first sprite as empty
	sprites.append(create_atlas_texture(rack_sprite_sheet, Rect2(0, 0, sprite_size.x, sprite_size.y))) # hoe
	sprites.append(create_atlas_texture(rack_sprite_sheet, Rect2(sprite_size.x, 0, sprite_size.x, sprite_size.y))) # shovel  
	sprites.append(create_atlas_texture(rack_sprite_sheet, Rect2(sprite_size.x * 2, 0, sprite_size.x, sprite_size.y))) # watering_can
	
	return sprites
