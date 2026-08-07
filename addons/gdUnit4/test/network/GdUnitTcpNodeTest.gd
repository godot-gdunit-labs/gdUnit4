# GdUnit generated TestSuite
class_name GdUnitTcpNodeTest
extends GdUnitTestSuite


const __source = "res://addons/gdUnit4/src/network/GdUnitTcpNode.gd"


func _frame(text: String) -> PackedByteArray:
	return GdUnitTcpNode.encode_frame(text.to_utf16_buffer())


func _payload_texts(result: Dictionary) -> Array:
	var texts: Array = []
	for payload: PackedByteArray in result["payloads"]:
		texts.append(payload.get_string_from_utf16())
	return texts


#region complete frames
func test_extract_single_complete_frame() -> void:
	var result := GdUnitTcpNode.extract_frames(_frame("hello"))
	assert_array(_payload_texts(result)).contains_exactly(["hello"])
	assert_int((result["remainder"] as PackedByteArray).size()).is_equal(0)


func test_extract_multiple_frames_in_one_buffer() -> void:
	var buffer := _frame("first")
	buffer.append_array(_frame("second"))
	buffer.append_array(_frame("third"))
	var result := GdUnitTcpNode.extract_frames(buffer)
	assert_array(_payload_texts(result)).contains_exactly(["first", "second", "third"])
	assert_int((result["remainder"] as PackedByteArray).size()).is_equal(0)


func test_empty_buffer_yields_nothing() -> void:
	var result := GdUnitTcpNode.extract_frames(PackedByteArray())
	assert_int((result["payloads"] as Array).size()).is_equal(0)
	assert_int((result["remainder"] as PackedByteArray).size()).is_equal(0)
#endregion


#region partial frames
func test_partial_header_is_kept_as_remainder() -> void:
	var partial := _frame("hello").slice(0, 4)  # only half the header arrived
	var result := GdUnitTcpNode.extract_frames(partial)
	assert_int((result["payloads"] as Array).size()).is_equal(0)
	assert_int((result["remainder"] as PackedByteArray).size()).is_equal(4)


func test_partial_payload_is_kept_as_remainder() -> void:
	var full := _frame("hello")
	var partial := full.slice(0, full.size() - 2)  # header complete, payload truncated
	var result := GdUnitTcpNode.extract_frames(partial)
	assert_int((result["payloads"] as Array).size()).is_equal(0)
	assert_int((result["remainder"] as PackedByteArray).size()).is_equal(partial.size())


func test_frame_split_across_two_reads_is_reassembled() -> void:
	var full := _frame("payload spanning reads")
	var split := full.size() - 5

	var first := GdUnitTcpNode.extract_frames(full.slice(0, split))
	assert_int((first["payloads"] as Array).size()).is_equal(0)

	var buffer: PackedByteArray = first["remainder"]
	buffer.append_array(full.slice(split))
	var second := GdUnitTcpNode.extract_frames(buffer)
	assert_array(_payload_texts(second)).contains_exactly(["payload spanning reads"])
	assert_int((second["remainder"] as PackedByteArray).size()).is_equal(0)
#endregion


#region resync
func test_resyncs_past_leading_garbage_to_next_frame() -> void:
	var buffer := PackedByteArray([1, 2, 3])  # not a frame header
	buffer.append_array(_frame("recovered"))
	var result := GdUnitTcpNode.extract_frames(buffer)
	assert_array(_payload_texts(result)).contains_exactly(["recovered"])
	assert_int((result["remainder"] as PackedByteArray).size()).is_equal(0)


func test_resyncs_past_implausible_frame_size() -> void:
	# A false-positive magic declaring a bogus huge size must not stall the reader.
	var buffer := PackedByteArray()
	@warning_ignore("return_value_discarded")
	buffer.resize(GdUnitTcpNode.FRAME_HEADER_SIZE)
	@warning_ignore("return_value_discarded")
	buffer.encode_u32(0, GdUnitTcpNode.FRAME_MAGIC)
	@warning_ignore("return_value_discarded")
	buffer.encode_u32(4, GdUnitTcpNode.MAX_FRAME_PAYLOAD_SIZE + 1)
	buffer.append_array(_frame("recovered"))
	var result := GdUnitTcpNode.extract_frames(buffer)
	assert_array(_payload_texts(result)).contains_exactly(["recovered"])
	assert_int((result["remainder"] as PackedByteArray).size()).is_equal(0)
#endregion
