class_name GdUnitInspectorTreeConstants
extends RefCounted

# the inspector panel presantation
enum TreeViewMode {
	TREE,
	FLAT
}


# The inspector sort modes
enum SortMode {
	UNSORTED,
	NAME_ASCENDING,
	NAME_DESCENDING,
	EXECUTION_TIME
}


enum STATE {
	INITIAL,
	RUNNING,
	SKIPPED,
	SUCCESS,
	WARNING,
	FLAKY,
	FAILED,
	ERROR,
	ABORDED,
	ORPHAN
}
