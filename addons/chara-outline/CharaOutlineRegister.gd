extends Node

#
# キャラクタアウトライン by あるる（きのもと 結衣） @arlez80
# Character Outline by Yui Kinomoto @arlez80
#
# MIT License
#

class_name CharaOutlineRegister

export(bool) var hide:bool = false
export(int, 0, 255) var object_id:int = 0
export(float, 0.0, 1.0) var line_width:float = 0.0
export(float, 0.0, 1.0) var priority:float = 0.25
export(NodePath) var target_path:NodePath = ".."
