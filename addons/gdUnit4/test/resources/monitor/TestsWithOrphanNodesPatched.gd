extends GdUnitTestSuite

@warning_ignore_start("unused_private_class_variable")
var _member_node1 := T2.new() # produces an orphan Node2D


func test_one_orphans_nodes() -> void:
	var _func_ref2 := RefCounted.new() # is refcounted and never orphan
	var _func_obj2 := Object.new() # produces an orphan Object
	var _func_node2 := Node3D.new() # produces an orphan Node3D

	# Injected collect orphan details
	await get_tree().process_frame
	collect_orphan_node_details()


func test_one_orphans_nodes_skip_inject() -> void:
	var _func_ref2 := RefCounted.new() # is refcounted and never orphan
	var _func_obj2 := Object.new() # produces an orphan Object
	var _func_node2 := Node3D.new() # produces an orphan Node3D

	collect_orphan_node_details()


# Results in four orphan nodes related to local valze t2
func test_four_orphan_nodes() -> void:
	var _func_node3 := Node3D.new() # produces an orphan Node3D
	var t2 := T2.new()

	add_child(t2)

	# Injected collect orphan details
	await get_tree().process_frame
	collect_orphan_node_details()


## Loads a sceen via `scene_runner` (auto_free) but it contains orphan nodes
func test_with_scene_orphans() -> void:

	# run scene with orphan nodes
	var runner := scene_runner("res://addons/gdUnit4/test/core/execution/resources/OrphanScene.tscn")

	@warning_ignore("redundant_await")
	await runner.simulate_frames(10)

	# Injected collect orphan details
	await get_tree().process_frame
	collect_orphan_node_details()


## Loads a sceen and do not freeing
func test_load_scene_orphans() -> void:
	# run scene with orphan nodes
	var _scene: Node2D = preload("res://addons/gdUnit4/test/core/execution/resources/OrphanScene.tscn").instantiate()

	# Injected collect orphan details
	await get_tree().process_frame
	collect_orphan_node_details()


## Shold not detect any orphan becuase the node is auto freed
func test_no_orphans_auto_free() -> void:
	var func_node2: Node3D = auto_free(Node3D.new())

	assert_object(func_node2).is_not_null()

	# Injected collect orphan details
	await get_tree().process_frame
	collect_orphan_node_details()


## This test has no orphans
func test_no_orphans() -> void:
	assert_bool(true).is_true()

	# Injected collect orphan details
	await get_tree().process_frame
	collect_orphan_node_details()


## using parameterized test with orphans
@warning_ignore("unused_parameter")
func test_parameterized_with_orphans(index: int, obj: Object, test_parameters := [
	[0, RefCounted.new()],
	[1, Node2D.new()]]) -> void:
	assert_that(obj).is_not_null()

	# Injected collect orphan details
	await get_tree().process_frame
	collect_orphan_node_details()
