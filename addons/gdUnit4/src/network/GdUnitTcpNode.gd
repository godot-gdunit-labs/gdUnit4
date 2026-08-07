class_name GdUnitTcpNode
extends Node

## Marks the start of a framed message on the wire.
const FRAME_MAGIC := 0xDEADBEEF
## Size in bytes of a frame header: the magic marker (u32) plus the payload length (u32).
const FRAME_HEADER_SIZE := 8

# Bytes received but not yet forming a complete frame are kept here between calls, so a
# message split across multiple TCP reads is reassembled instead of parsed in pieces.
var _receive_buffer := PackedByteArray()


## Encodes [param payload] as a length-prefixed frame: [magic][payload size][payload].
static func encode_frame(payload: PackedByteArray) -> PackedByteArray:
	var frame := PackedByteArray()
	@warning_ignore("return_value_discarded")
	frame.resize(FRAME_HEADER_SIZE)
	@warning_ignore("return_value_discarded")
	frame.encode_u32(0, FRAME_MAGIC)
	@warning_ignore("return_value_discarded")
	frame.encode_u32(4, payload.size())
	frame.append_array(payload)
	return frame


func rpc_send(stream: StreamPeerTCP, data: RPC) -> void:
	var payload := data.serialize().to_utf16_buffer()
	var status_code := stream.put_data(encode_frame(payload))
	if status_code != OK:
		push_error("'rpc_send:' Can't put_data(), error: %s" % error_string(status_code))


func receive_packages(stream: StreamPeerTCP, rpc_cb: Callable = noop) -> Array[RPC]:
	var received_packages: Array[RPC] = []
	if stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return received_packages

	# Drain everything currently available and append it to the reassembly buffer.
	var available := stream.get_available_bytes()
	if available > 0:
		var chunk := stream.get_data(available)
		if chunk[0] != OK:
			push_error("'receive_packages:' Can't get_data(%d), error: %s" % [available, error_string(chunk[0] as int)])
			return received_packages
		_receive_buffer.append_array(chunk[1])

	# Process only the frames that have fully arrived; keep the remainder for next time.
	var result := extract_frames(_receive_buffer)
	_receive_buffer = result["remainder"]
	for payload: PackedByteArray in result["payloads"]:
		var json := payload.get_string_from_utf16()
		if json.is_empty():
			push_warning("json is empty, can't process data")
			continue
		var data := RPC.deserialize(json)
		if data == null:
			continue
		received_packages.append(data)
		rpc_cb.call(data)
	return received_packages


## Extracts every complete frame from [param buffer] and returns[br]
## [code]{ "payloads": Array[PackedByteArray], "remainder": PackedByteArray }[/code].[br]
## Incomplete trailing data is returned as the remainder to be completed by later reads.[br]
## If the buffer is not aligned to a frame header the reader resyncs to the next magic marker.
static func extract_frames(buffer: PackedByteArray) -> Dictionary:
	var payloads: Array[PackedByteArray] = []
	var offset := 0
	while buffer.size() - offset >= FRAME_HEADER_SIZE:
		if buffer.decode_u32(offset) != FRAME_MAGIC:
			var next := _find_magic(buffer, offset + 1)
			if next == -1:
				# No further marker; keep only a possible split marker at the tail.
				offset = maxi(offset, buffer.size() - 3)
				break
			offset = next
			continue
		var size := buffer.decode_u32(offset + 4)
		if buffer.size() - offset - FRAME_HEADER_SIZE < size:
			# Header known but payload not fully arrived yet.
			break
		payloads.append(buffer.slice(offset + FRAME_HEADER_SIZE, offset + FRAME_HEADER_SIZE + size))
		offset += FRAME_HEADER_SIZE + size
	return { "payloads": payloads, "remainder": buffer.slice(offset) }


## Returns the byte offset of the next [constant FRAME_MAGIC] marker at or after [param from],
## or -1 when none is present.
static func _find_magic(buffer: PackedByteArray, from: int) -> int:
	for index in range(from, buffer.size() - 3):
		if buffer.decode_u32(index) == FRAME_MAGIC:
			return index
	return -1


static func noop(_rpc_data: RPC) -> void:
	pass
