class_name GdUnitBenchmarkSuiteTest
extends GdUnitTestSuite


#region hooks
func test_hooks_are_empty() -> void:
	var suite: GdUnitBenchmarkSuite = auto_free(GdUnitBenchmarkSuite.new())

	suite.setup()
	suite.cleanup()

	assert_array(suite.__auto_free).is_empty()


func test_hooks_overridable() -> void:
	var suite: HookBenchmark = auto_free(HookBenchmark.new())
	var base: GdUnitBenchmarkSuite = suite

	base.setup()
	base.cleanup()

	assert_array(suite.calls).contains_exactly(["setup", "cleanup"])


func test_setup_overridable_with_skip_arguments_and_await() -> void:
	var suite: AsyncHookBenchmark = auto_free(AsyncHookBenchmark.new())
	add_child(suite)

	await suite.setup(true, "no threads")

	assert_array(suite.calls).contains_exactly(["setup true 'no threads'"])


func test_overrides_no_godot_virtual_method() -> void:
	var script: GDScript = GdUnitBenchmarkSuite
	var virtual_methods: Array[String] = []
	for method in ClassDB.class_get_method_list(script.get_instance_base_type()):
		if method["flags"] & METHOD_FLAG_VIRTUAL:
			virtual_methods.append(method["name"])
	var overridden: Array[String] = []
	for method in script.get_script_method_list():
		if virtual_methods.has(method["name"]):
			overridden.append(method["name"])

	assert_array(overridden).is_empty()
#endregion


#region auto_free
func test_auto_free_returns_object() -> void:
	var suite: GdUnitBenchmarkSuite = auto_free(GdUnitBenchmarkSuite.new())
	var node := Node.new()
	var ref := RefCounted.new()

	assert_object(suite.auto_free(node)).is_same(node)
	assert_object(suite.auto_free(ref)).is_same(ref)
	assert_array(suite.__auto_free).contains_exactly([node, ref])

	node.free()


func test_auto_free_objects_freeable() -> void:
	var suite: GdUnitBenchmarkSuite = auto_free(GdUnitBenchmarkSuite.new())
	var node: Node = suite.auto_free(Node.new())
	var ref_weak: WeakRef = weakref(suite.auto_free(RefCounted.new()))

	_free_objects(suite.__auto_free)

	assert_bool(is_instance_valid(node)).is_false()
	assert_object(ref_weak.get_ref()).is_null()
#endregion


func _free_objects(objects: Array) -> void:
	for obj: Variant in objects:
		if obj is Node:
			@warning_ignore("unsafe_method_access")
			obj.free()
	objects.clear()


class HookBenchmark:
	extends GdUnitBenchmarkSuite

	var calls: Array[String] = []

	func setup() -> void:
		calls.append("setup")

	func cleanup() -> void:
		calls.append("cleanup")


class AsyncHookBenchmark:
	extends GdUnitBenchmarkSuite

	var calls: Array[String] = []

	func setup(do_skip := false, skip_reason := "") -> void:
		await get_tree().process_frame
		calls.append("setup %s '%s'" % [do_skip, skip_reason])
