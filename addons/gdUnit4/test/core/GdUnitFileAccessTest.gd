# GdUnit generated TestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


var file_to_save: String
var _test_paths: PackedStringArray = []


func after() -> void:
	# verify tmp files are deleted automatically
	assert_bool(FileAccess.file_exists(file_to_save)).is_false()


func after_test() -> void:
	for test_path in _test_paths:
		GdUnitFileAccess.delete_directory(test_path)
	_test_paths.clear()


func _create_file(p_path: String, p_name: String) -> void:
	var file := create_temp_file(p_path, p_name)
	file.store_string("some content")


func test_copy_directory() -> void:
	var temp_dir := create_temp_dir("test_copy_directory")
	assert_bool(GdUnitFileAccess.copy_directory("res://addons/gdUnit4/test/core/resources/copy_test/folder_a/", temp_dir)).is_true()
	assert_file("%s/file_a.txt" % temp_dir).exists()
	assert_file("%s/file_b.txt" % temp_dir).exists()


func test_copy_directory_recursive() -> void:
	var temp_dir := create_temp_dir("test_copy_directory_recursive")
	assert_bool(GdUnitFileAccess.copy_directory("res://addons/gdUnit4/test/core/resources/copy_test/", temp_dir, true)).is_true()
	assert_file("%s/folder_a/file_a.txt" % temp_dir).exists()
	assert_file("%s/folder_a/file_b.txt" % temp_dir).exists()
	assert_file("%s/folder_b/file_a.txt" % temp_dir).exists()
	assert_file("%s/folder_b/file_b.txt" % temp_dir).exists()
	assert_file("%s/folder_b/folder_ba/file_x.txt" % temp_dir).exists()
	assert_file("%s/folder_c/file_z.txt" % temp_dir).exists()


func test_create_temp_dir() -> void:
	var temp_dir := create_temp_dir("examples/game/save")
	file_to_save = temp_dir + "/save_game.dat"

	var data := {
		"user": "Hoschi",
		"level": 42
	}
	var file := FileAccess.open(file_to_save, FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	assert_bool(FileAccess.file_exists(file_to_save)).is_true()


func test_create_temp_file() -> void:
	# setup - stores a tmp file with "user://tmp/examples/game/game.sav" (auto closed)
	var file := create_temp_file("examples/game", "game.sav")
	assert_object(file).is_not_null()
	# write some example data
	file.store_line("some data")
	file.close()

	# verify
	var file_read := create_temp_file("examples/game", "game.sav", FileAccess.READ)
	assert_object(file_read).is_not_null()
	assert_str(file_read.get_as_text()).is_equal("some data\n")
	# not needs to be manually close, will be auto closed after test suite execution


func test_find_last_path_index() -> void:
	# not existing directory
	assert_int(GdUnitFileAccess.find_last_path_index("/foo", "report_")).is_equal(0)
	# empty directory
	var temp_dir := create_temp_dir("test_reports")
	assert_int(GdUnitFileAccess.find_last_path_index(temp_dir, "report_")).is_equal(0)
	# create some report directories
	create_temp_dir("test_reports/report_1")
	assert_int(GdUnitFileAccess.find_last_path_index(temp_dir, "report_")).is_equal(1)
	create_temp_dir("test_reports/report_2")
	assert_int(GdUnitFileAccess.find_last_path_index(temp_dir, "report_")).is_equal(2)
	create_temp_dir("test_reports/report_3")
	assert_int(GdUnitFileAccess.find_last_path_index(temp_dir, "report_")).is_equal(3)
	create_temp_dir("test_reports/report_5")
	assert_int(GdUnitFileAccess.find_last_path_index(temp_dir, "report_")).is_equal(5)
	# create some more
	for index in range(10, 42):
		create_temp_dir("test_reports/report_%d" % index)
	assert_int(GdUnitFileAccess.find_last_path_index(temp_dir, "report_")).is_equal(41)


func test_delete_path_index_lower_equals_than() -> void:
	var temp_dir := create_temp_dir("test_reports_delete")
	assert_array(GdUnitFileAccess.scan_dir(temp_dir)).is_empty()
	assert_int(GdUnitFileAccess.delete_path_index_lower_equals_than(temp_dir, "report_", 0)).is_equal(0)

	# create some directories
	for index in range(10, 42):
		create_temp_dir("test_reports_delete/report_%d" % index)
	assert_array(GdUnitFileAccess.scan_dir(temp_dir)).has_size(32)

	# try to delete directories with index lower than 0, shold delete nothing
	assert_int(GdUnitFileAccess.delete_path_index_lower_equals_than(temp_dir, "report_", 0)).is_equal(0)
	assert_array(GdUnitFileAccess.scan_dir(temp_dir)).has_size(32)

	# try to delete directories with index lower_equals than 30
	# shold delet directories report_10 to report_30 = 21
	assert_int(GdUnitFileAccess.delete_path_index_lower_equals_than(temp_dir, "report_", 30)).is_equal(21)
	# and 12 directories are left
	assert_array(GdUnitFileAccess.scan_dir(temp_dir))\
		.has_size(11)\
		.contains([
			"report_31",
			"report_32",
			"report_33",
			"report_34",
			"report_35",
			"report_36",
			"report_37",
			"report_38",
			"report_39",
			"report_40",
			"report_41",
		])


func test_scan_dir() -> void:
	var temp_dir := create_temp_dir("test_scan_dir")
	assert_array(GdUnitFileAccess.scan_dir(temp_dir)).is_empty()

	create_temp_dir("test_scan_dir/report_2")
	assert_array(GdUnitFileAccess.scan_dir(temp_dir)).contains_exactly(["report_2"])
	# create some more directories and files
	create_temp_dir("test_scan_dir/report_4")
	create_temp_dir("test_scan_dir/report_5")
	create_temp_dir("test_scan_dir/report_6")
	create_temp_file("test_scan_dir", "file_a")
	create_temp_file("test_scan_dir", "file_b")
	# this shoul not be counted it is a file in a subdirectory
	create_temp_file("test_scan_dir/report_6", "file_b")
	assert_array(GdUnitFileAccess.scan_dir(temp_dir))\
		.has_size(6)\
		.contains([
			"report_2",
			"report_4",
			"report_5",
			"report_6",
			"file_a",
			"file_b"])


func test_delete_directory() -> void:
	var tmp_dir := create_temp_dir("test_delete_dir")
	create_temp_dir("test_delete_dir/data1")
	create_temp_dir("test_delete_dir/data2")
	_create_file("test_delete_dir", "example_a.txt")
	_create_file("test_delete_dir", "example_b.txt")
	_create_file("test_delete_dir", ".hidden_file.txt")
	_create_file("test_delete_dir/data1", "example.txt")
	_create_file("test_delete_dir/data2", "example2.txt")

	assert_array(GdUnitFileAccess.scan_dir(tmp_dir)).contains_exactly_in_any_order([
		"data1",
		"data2",
		"example_a.txt",
		"example_b.txt",
		".hidden_file.txt"
	])

	# Delete the entire directory and its contents
	GdUnitFileAccess.delete_directory(tmp_dir)
	assert_bool(DirAccess.dir_exists_absolute(tmp_dir)).is_false()
	assert_array(GdUnitFileAccess.scan_dir(tmp_dir)).is_empty()


func test_delete_directory_content_only() -> void:
	var tmp_dir := create_temp_dir("test_delete_dir")
	create_temp_dir("test_delete_dir/data1")
	create_temp_dir("test_delete_dir/data2")
	_create_file("test_delete_dir", "example_a.txt")
	_create_file("test_delete_dir", "example_b.txt")
	_create_file("test_delete_dir/data1", "example.txt")
	_create_file("test_delete_dir/data2", "example2.txt")

	assert_array(GdUnitFileAccess.scan_dir(tmp_dir)).contains_exactly_in_any_order([
		"data1",
		"data2",
		"example_a.txt",
		"example_b.txt"
	])

	# Delete the entire directory and its contents
	GdUnitFileAccess.delete_directory(tmp_dir, true)
	assert_bool(DirAccess.dir_exists_absolute(tmp_dir)).is_true()
	assert_array(GdUnitFileAccess.scan_dir(tmp_dir)).is_empty()


func _relative_path(path: String) -> String:
	_test_paths.append(path.get_slice("/", 0))
	return path


func _absolute_path(path: String) -> String:
	var absolute_path := ProjectSettings.globalize_path(path)
	_test_paths.append(absolute_path)
	return absolute_path


func _create_file_at(file_path: String) -> void:
	DirAccess.make_dir_recursive_absolute(file_path.get_base_dir())
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string("some content")
	file.close()


func _create_report_dirs(test_dir: String, count: int) -> void:
	for index in range(1, count + 1):
		_create_file_at(test_dir.path_join("report_%d/index.html" % index))


func _file_uri_to_path(uri: String) -> String:
	var path := uri.trim_prefix("file://").uri_decode()
	if path.find(":") == 2:
		return path.substr(1)
	return path


#region relative paths
func test_delete_directory_by_relative_path() -> void:
	var test_dir := _relative_path(".gdunit_test_delete_dir")
	_create_file_at(test_dir.path_join("example_a.txt"))
	_create_file_at(test_dir.path_join("data1/example.txt"))
	assert_bool(DirAccess.dir_exists_absolute(test_dir.path_join("data1"))).is_true()
	assert_bool(FileAccess.file_exists(test_dir.path_join("example_a.txt"))).is_true()

	GdUnitFileAccess.delete_directory(test_dir)
	assert_bool(DirAccess.dir_exists_absolute(test_dir)).is_false()


func test_delete_directory_content_only_by_relative_path() -> void:
	var test_dir := _relative_path(".gdunit_test_delete_content")
	_create_file_at(test_dir.path_join("example_a.txt"))
	_create_file_at(test_dir.path_join("data1/example.txt"))

	GdUnitFileAccess.delete_directory(test_dir, true)
	assert_bool(DirAccess.dir_exists_absolute(test_dir)).is_true()
	assert_array(DirAccess.get_files_at(test_dir)).is_empty()
	assert_array(DirAccess.get_directories_at(test_dir)).is_empty()


func test_delete_path_index_lower_equals_than_by_relative_path() -> void:
	var test_dir := _relative_path(".gdunit_test_report_history")
	_create_report_dirs(test_dir, 5)
	assert_array(DirAccess.get_directories_at(test_dir)).has_size(5)

	assert_int(GdUnitFileAccess.delete_path_index_lower_equals_than(test_dir, "report_", 3)).is_equal(3)
	assert_array(DirAccess.get_directories_at(test_dir)).contains_exactly_in_any_order(["report_4", "report_5"])
#endregion


#region absolute paths
func test_delete_directory_by_absolute_path() -> void:
	var test_dir := _absolute_path("user://tmp/gdunit_test_delete_dir")
	_create_file_at(test_dir.path_join("example_a.txt"))
	_create_file_at(test_dir.path_join("data1/example.txt"))
	assert_bool(DirAccess.dir_exists_absolute(test_dir.path_join("data1"))).is_true()
	assert_bool(FileAccess.file_exists(test_dir.path_join("example_a.txt"))).is_true()

	GdUnitFileAccess.delete_directory(test_dir)
	assert_bool(DirAccess.dir_exists_absolute(test_dir)).is_false()


func test_delete_directory_by_path_with_space() -> void:
	var test_dir := _absolute_path("user://tmp/gdunit test delete dir")
	_create_file_at(test_dir.path_join("data 1/example.txt"))

	GdUnitFileAccess.delete_directory(test_dir)
	assert_bool(DirAccess.dir_exists_absolute(test_dir)).is_false()


func test_delete_directory_by_not_existing_path() -> void:
	GdUnitFileAccess.delete_directory("user://tmp/gdunit_test_not_existing_dir")
	assert_bool(DirAccess.dir_exists_absolute("user://tmp/gdunit_test_not_existing_dir")).is_false()


func test_delete_path_index_lower_equals_than_by_absolute_path() -> void:
	var test_dir := _absolute_path("user://tmp/gdunit_test_report_history")
	_create_report_dirs(test_dir, 5)
	assert_array(DirAccess.get_directories_at(test_dir)).has_size(5)

	assert_int(GdUnitFileAccess.delete_path_index_lower_equals_than(test_dir, "report_", 3)).is_equal(3)
	assert_array(DirAccess.get_directories_at(test_dir)).contains_exactly_in_any_order(["report_4", "report_5"])
#endregion


#region as_file_uri
func test_as_file_uri_by_relative_path() -> void:
	_create_file_at(_relative_path(".gdunit_test_file_uri").path_join("report_1/index.html"))

	var uri := GdUnitFileAccess.as_file_uri(".gdunit_test_file_uri/report_1/index.html")
	assert_str(uri) \
		.starts_with("file:///") \
		.ends_with("/.gdunit_test_file_uri/report_1/index.html")
	assert_bool(FileAccess.file_exists(_file_uri_to_path(uri))).is_true()


func test_as_file_uri_by_relative_path_with_dot_segments() -> void:
	_create_file_at(_relative_path(".gdunit_test_file_uri").path_join("report_1/index.html"))

	var uri := GdUnitFileAccess.as_file_uri("./.gdunit_test_file_uri/report_1/../report_1/index.html")
	assert_str(uri) \
		.starts_with("file:///") \
		.ends_with("/.gdunit_test_file_uri/report_1/index.html") \
		.not_contains("/./") \
		.not_contains("..")
	assert_bool(FileAccess.file_exists(_file_uri_to_path(uri))).is_true()


func test_as_file_uri_by_absolute_path() -> void:
	var file_path := _absolute_path("user://tmp/gdunit_test_file_uri").path_join("report_1/index.html")
	_create_file_at(file_path)

	var uri := GdUnitFileAccess.as_file_uri(file_path)
	assert_str(uri).starts_with("file:///")
	assert_str(_file_uri_to_path(uri)).is_equal(file_path)


func test_as_file_uri_by_resource_path() -> void:
	var uri := GdUnitFileAccess.as_file_uri("res://addons/gdUnit4/plugin.cfg")
	assert_str(uri) \
		.starts_with("file:///") \
		.ends_with("/addons/gdUnit4/plugin.cfg")
	assert_bool(FileAccess.file_exists(_file_uri_to_path(uri))).is_true()


func test_as_file_uri_by_user_path() -> void:
	_test_paths.append("user://tmp/gdunit_test_file_uri")
	_create_file_at("user://tmp/gdunit_test_file_uri/report_1/index.html")

	var uri := GdUnitFileAccess.as_file_uri("user://tmp/gdunit_test_file_uri/report_1/index.html")
	assert_str(uri) \
		.starts_with("file:///") \
		.not_contains("user:") \
		.ends_with("/tmp/gdunit_test_file_uri/report_1/index.html")
	assert_bool(FileAccess.file_exists(_file_uri_to_path(uri))).is_true()


func test_as_file_uri_by_empty_path() -> void:
	var uri := GdUnitFileAccess.as_file_uri("")
	assert_str(uri).starts_with("file:///")
	assert_bool(DirAccess.dir_exists_absolute(_file_uri_to_path(uri))).is_true()


func test_as_file_uri_by_unix_root_path() -> void:
	assert_str(GdUnitFileAccess.as_file_uri("/tmp/reports/report_1/index.html")).is_equal("file:///tmp/reports/report_1/index.html")


func test_as_file_uri_by_windows_drive_path() -> void:
	assert_str(GdUnitFileAccess.as_file_uri("C:/reports/report_1/index.html")).is_equal("file:///C:/reports/report_1/index.html")


func test_as_file_uri_by_windows_backslash_path() -> void:
	assert_str(GdUnitFileAccess.as_file_uri("C:\\reports\\report_1\\index.html")).is_equal("file:///C:/reports/report_1/index.html")


func test_as_file_uri_by_path_with_space() -> void:
	assert_str(GdUnitFileAccess.as_file_uri("C:/Users/John Doe/reports/index.html")) \
		.is_equal("file:///C:/Users/John%20Doe/reports/index.html")


func test_as_file_uri_by_path_with_non_ascii_characters() -> void:
	assert_str(GdUnitFileAccess.as_file_uri("/home/jürgen/reports/index.html")).is_equal("file:///home/j%C3%BCrgen/reports/index.html")


func test_as_file_uri_by_path_with_reserved_characters() -> void:
	assert_str(GdUnitFileAccess.as_file_uri("C:/Users/me/proj#1/100%/index.html")) \
		.is_equal("file:///C:/Users/me/proj%231/100%25/index.html")
#endregion


func test_extract_package() -> void:
	clean_temp_dir()
	var tmp_path := GdUnitFileAccess.create_temp_dir("test_update")
	var source := "res://addons/gdUnit4/test/update/resources/update.zip"

	# the temp should be inital empty
	assert_array(GdUnitFileAccess.scan_dir(tmp_path)).is_empty()
	# now extract to temp
	var result := GdUnitFileAccess.extract_zip(source, tmp_path)
	assert_result(result).is_success()
	assert_array(GdUnitFileAccess.scan_dir(tmp_path)).contains_exactly_in_any_order([
		"addons",
		"runtest.cmd",
		"runtest.sh",
	])


func test_extract_package_invalid_package() -> void:
	clean_temp_dir()
	var tmp_path := GdUnitFileAccess.create_temp_dir("test_update")
	var source := "res://addons/gdUnit4/test/update/resources/update_invalid.zip"

	# the temp should be inital empty
	assert_array(GdUnitFileAccess.scan_dir(tmp_path)).is_empty()
	# now extract to temp
	var result := GdUnitFileAccess.extract_zip(source, tmp_path)
	assert_result(result).is_error()\
		.contains_message("Extracting `%s` failed! Please collect the error log and report this. Error Code: 1" % source)
	assert_array(GdUnitFileAccess.scan_dir(tmp_path)).is_empty()
