# GdUnit generated TestSuite
class_name GdUnitDiscoverCacheTest
extends GdUnitTestSuite


const __source = "res://addons/gdUnit4/src/core/discovery/GdUnitDiscoverCache.gd"


var _cache_file: String


func before_test() -> void:
	_cache_file = "user://gdunit_discover_cache_test_%d.json" % Time.get_ticks_usec()


func after_test() -> void:
	if FileAccess.file_exists(_cache_file):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(_cache_file))


func _test_case(source_file := "res://test/FooTest.gd", test_name := "test_bar") -> GdUnitTestCase:
	return GdUnitTestCase.from(source_file, source_file, 10, test_name)


#region cache lookup
func test_is_valid_false_when_absent() -> void:
	var cache := GdUnitDiscoverCache.new(_cache_file)
	assert_bool(cache.is_valid("res://test/FooTest.gd", 100)).is_false()


func test_is_valid_false_on_mtime_change() -> void:
	var cache := GdUnitDiscoverCache.new(_cache_file)
	cache.put("res://test/FooTest.gd", 100, [_test_case()])
	assert_bool(cache.is_valid("res://test/FooTest.gd", 100)).is_true()
	assert_bool(cache.is_valid("res://test/FooTest.gd", 101)).is_false()
#endregion


#region persistence
func test_put_and_get_round_trip() -> void:
	var cache := GdUnitDiscoverCache.new(_cache_file)
	cache.put("res://test/FooTest.gd", 100, [_test_case("res://test/FooTest.gd", "test_bar")])
	cache.save_cache()

	var reloaded := GdUnitDiscoverCache.new(_cache_file)
	reloaded.load_cache()
	assert_bool(reloaded.is_valid("res://test/FooTest.gd", 100)).is_true()
	var tests := reloaded.get_tests("res://test/FooTest.gd")
	assert_int(tests.size()).is_equal(1)
	assert_str(tests[0].test_name).is_equal("test_bar")
	assert_str(tests[0].source_file).is_equal("res://test/FooTest.gd")


func test_empty_entry_is_cached_and_valid() -> void:
	# A file that is not a test suite must be cached as empty so it is not re-loaded.
	var cache := GdUnitDiscoverCache.new(_cache_file)
	cache.put("res://test/helper.gd", 100, [])
	cache.save_cache()

	var reloaded := GdUnitDiscoverCache.new(_cache_file)
	reloaded.load_cache()
	assert_bool(reloaded.is_valid("res://test/helper.gd", 100)).is_true()
	assert_int(reloaded.get_tests("res://test/helper.gd").size()).is_equal(0)
#endregion


#region invalidation
func test_version_guard_discards_foreign_cache() -> void:
	var file := FileAccess.open(_cache_file, FileAccess.WRITE)
	file.store_string(JSON.stringify({
		"version": GdUnitDiscoverCache.CACHE_VERSION + 1,
		"entries": { "res://test/FooTest.gd": { "mtime": 100, "tests": [] } }
	}))
	file.close()

	var cache := GdUnitDiscoverCache.new(_cache_file)
	cache.load_cache()
	assert_bool(cache.is_valid("res://test/FooTest.gd", 100)).is_false()


func test_corrupt_cache_is_ignored() -> void:
	# A partially written / malformed cache must be ignored, not crash or spam errors.
	var file := FileAccess.open(_cache_file, FileAccess.WRITE)
	file.store_string('{"version": 1, "entries": {"res://a.gd": {"mtime": 1')
	file.close()

	var cache := GdUnitDiscoverCache.new(_cache_file)
	cache.load_cache()
	assert_bool(cache.is_valid("res://a.gd", 1)).is_false()


func test_prune_removes_absent_files() -> void:
	var cache := GdUnitDiscoverCache.new(_cache_file)
	cache.put("res://test/FooTest.gd", 100, [_test_case("res://test/FooTest.gd")])
	cache.put("res://test/BarTest.gd", 200, [_test_case("res://test/BarTest.gd")])

	cache.prune(["res://test/FooTest.gd"])
	assert_bool(cache.is_valid("res://test/FooTest.gd", 100)).is_true()
	assert_bool(cache.is_valid("res://test/BarTest.gd", 200)).is_false()
#endregion
