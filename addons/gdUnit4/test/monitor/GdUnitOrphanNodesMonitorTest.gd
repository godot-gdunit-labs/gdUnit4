# GdUnit generated TestSuite
class_name GdUnitOrphanNodesMonitorTest
extends GdUnitTestSuite

const __source = 'res://addons/gdUnit4/src/monitor/GdUnitOrphanNodesMonitor.gd'


func before_test() -> void:
	# the monitor only collects counts when orphan reporting is enabled
	ProjectSettings.set_setting(GdUnitSettings.REPORT_ORPHANS, true)


func test_leaked_node_is_counted_as_orphan() -> void:
	var monitor := GdUnitOrphanNodesMonitor.new("test")
	monitor.start()
	var leaked := Node.new()
	monitor.stop()

	assert_int(monitor.orphans_count()).is_equal(1)
	leaked.free()


func test_node_queued_for_deletion_is_not_counted() -> void:
	# a node that is already queued for deletion will be freed by the engine
	# and must not be reported as an orphan
	var monitor := GdUnitOrphanNodesMonitor.new("test")
	monitor.start()
	var node := Node.new()
	node.queue_free()
	monitor.stop()

	assert_int(monitor.orphans_count()).is_equal(0)


func test_children_of_node_queued_for_deletion_are_not_counted() -> void:
	# the children are freed together with their queued parent
	var monitor := GdUnitOrphanNodesMonitor.new("test")
	monitor.start()
	var node := Node.new()
	var child := Node.new()
	node.add_child(child)
	child.add_child(Node.new())
	node.queue_free()
	monitor.stop()

	assert_int(monitor.orphans_count()).is_equal(0)


func test_leaked_node_with_children_is_counted() -> void:
	var monitor := GdUnitOrphanNodesMonitor.new("test")
	monitor.start()
	var leaked := Node.new()
	leaked.add_child(Node.new())
	monitor.stop()

	assert_int(monitor.orphans_count()).is_equal(2)
	leaked.free()


func test_node_queued_inside_leaked_subtree_is_counted_once() -> void:
	# only the leaked parent is counted, the queued child and its own child are freed
	var monitor := GdUnitOrphanNodesMonitor.new("test")
	monitor.start()
	var leaked := Node.new()
	var queued := Node.new()
	leaked.add_child(queued)
	queued.add_child(Node.new())
	queued.queue_free()
	monitor.stop()

	assert_int(monitor.orphans_count()).is_equal(1)
	leaked.free()
