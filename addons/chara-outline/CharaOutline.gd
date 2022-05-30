extends Node

#
# キャラクタアウトライン by あるる（きのもと 結衣） @arlez80
# Character Outline by Yui Kinomoto @arlez80
#
# MIT License
#

class_name CharaOutline

const group_name:String = "arlez80:charactor_outline"

onready var viewport:Viewport = $Viewport
onready var camera:Camera = $Viewport/Camera
onready var sobel_filter:ColorRect = $Viewport/SobelFilter
onready var outline_filter:ColorRect = $OutlineFilter

export(int, LAYERS_3D_RENDER) var layers_for_draw_target:int = 1 << 19
var max_objects:int = 64

func _ready( ):
	self.camera.cull_mask = self.layers_for_draw_target
	self._generate_nodes( )

func _clear_all_nodes( ) -> void:
	var start_node:Node = self.get_viewport( )
	for t in start_node.get_tree( ).get_nodes_in_group( self.group_name ):
		if start_node.is_a_parent_of( t ):
			t.queue_free( )

func _generate_nodes( ) -> void:
	self._clear_all_nodes( )
	self._check_registers( self.get_tree( ).get_root( ) )

func _check_registers( n:Node ):
	for t in n.get_children( ):
		if t is CharaOutlineRegister:
			var root:Node = t.get_node( t.target_path )
			self._copy_nodes( root, t )

		self._check_registers( t )

func _copy_nodes( n:Node, cor:CharaOutlineRegister ):
	if n is MeshInstance:
		self._copy_mesh_instance( n.get_parent( ), n, cor )

	for t in n.get_children( ):
		self._copy_nodes( t, cor )

func _copy_mesh_instance( parent:Node, mi:MeshInstance, cor:CharaOutlineRegister ):
	if mi.mesh == null or ( self.group_name in mi.get_groups( ) ):
		return

	var copyed: = MeshInstance.new( )
	parent.add_child( copyed )

	copyed.mesh = mi.mesh
	copyed.skeleton = mi.skeleton
	copyed.skin = mi.skin
	copyed.software_skinning_transform_normals = mi.software_skinning_transform_normals
	copyed.visible = mi.visible
	copyed.layers = self.layers_for_draw_target
	mi.layers = mi.layers & ( ~self.layers_for_draw_target )

	var factor:float = 1.0 / float( self.max_objects )
	var matr: = SpatialMaterial.new( )
	matr.flags_unshaded = true
	if cor.hide:
		matr.albedo_color = Color( 0.0, 0.0, cor.priority )
	else:
		matr.albedo_color = Color( ( cor.object_id + 1 ) * factor, cor.line_width, cor.priority )
	matr.params_cull_mode = SpatialMaterial.CULL_DISABLED
	copyed.material_override = matr

	copyed.add_to_group( self.group_name )

func _process( delta:float ):
	var screen_viewport: = self.get_viewport( )
	if screen_viewport == null:
		return
	self.viewport.size = screen_viewport.size
	self.sobel_filter.rect_size = screen_viewport.size
	self.outline_filter.rect_size = screen_viewport.size
	#$Debug.rect_size = screen_viewport.size

	var src_camera: = screen_viewport.get_camera( )
	if src_camera == null or self.camera == src_camera:
		return

	self.camera.cull_mask = self.layers_for_draw_target
	self.camera.global_transform = src_camera.global_transform
	self.camera.set_perspective(src_camera.fov, src_camera.near, src_camera.far)
