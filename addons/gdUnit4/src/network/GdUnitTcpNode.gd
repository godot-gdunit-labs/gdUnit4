class_name GdUnitTcpNode
extends Node

const FRAME_MAGIC := 0xDEADBEEF
const FRAME_HEADER_SIZE := 8
const MAX_FRAME_PAYLOAD_SIZE := 64 * 1024 * 1024

# Bytes received but not yet forming a complete frame, kept between calls so a message split
# across multiple TCP reads is reassembled instead of parsed in pieces.
var _receive_buffer := PackedByteArray()
# Reused across sends so a frame header is not allocated per message.
var _send_header := PackedByteArray()


func rpc_send(stream: StreamPeerTCP, data: RPC) -> void:
	var payload := data.serialize().to_utf16_buffer()
	@warning_ignore_start("return_value_discarded")
	if _send_header.is_empty():
		_send_header.resize(FRAME_HEADER_SIZE)
	_send_header.encode_u32(0, FRAME_MAGIC)
	_send_header.encode_u32(4, payload.size())
	@warning_ignore_restore("return_value_discarded")
	var status_code := stream.put_data(_send_header)
	if status_code == OK:
		status_code = stream.put_data(payload)
	if status_code != OK:
		push_error("'rpc_send:' Can't put_data(), error: %s" % error_string(status_code))


func receive_packages(stream: StreamPeerTCP, rpc_cb: Callable = noop) -> Array[RPC]:
	var received_packages: Array[RPC] = []
	if stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		_receive_buffer.clear()
		return received_packages

	var available := stream.get_available_bytes()
	if available > 0:
		var chunk := stream.get_data(available)
		if chunk[0] != OK:
			push_error("'receive_packages:' Can't get_data(%d), error: %s" % [available, error_string(chunk[0] as int)])
			return received_packages
		_receive_buffer.append_array(chunk[1])

	var consumed := extract_payload(_receive_buffer, func(payload: PackedByteArray) -> void:
		var json := payload.get_string_from_utf16()
		if json.is_empty():
			push_warning("json is empty, can't process data")
			return
		var data := RPC.deserialize(json)
		if data == null:
			return
		received_packages.append(data)
		rpc_cb.call(data))

	if consumed >= _receive_buffer.size():
		_receive_buffer.clear()
	elif consumed > 0:
		_receive_buffer = _receive_buffer.slice(consumed)
	return received_packages


## Dispatches every complete frame in [param buffer] to [param on_payload] and returns the number of
## bytes consumed; the caller keeps [code]buffer[/code] from that offset on as the remainder for the
## next read. Resyncs to the next magic marker when the buffer is not aligned to a frame header.
static func extract_payload(buffer: PackedByteArray, on_payload: Callable) -> int:
	var size := buffer.size()
	var offset := 0
	while size - offset >= FRAME_HEADER_SIZE:
		if buffer.decode_u32(offset) != FRAME_MAGIC:
			var next := _find_magic(buffer, offset + 1)
			if next == -1:
				# No further marker; keep only a possibly split marker in the last 3 bytes.
				return maxi(offset, size - 3)
			offset = next
			continue
		var payload_size := buffer.decode_u32(offset + 4)
		if payload_size > MAX_FRAME_PAYLOAD_SIZE:
			# Implausible size: this magic was a false positive, resync to the next marker.
			var next := _find_magic(buffer, offset + 1)
			if next == -1:
				return maxi(offset, size - 3)
			offset = next
			continue
		if size - offset - FRAME_HEADER_SIZE < payload_size:
			return offset
		var start := offset + FRAME_HEADER_SIZE
		on_payload.call(buffer.slice(start, start + payload_size))
		offset = start + payload_size
	return offset


static func _find_magic(buffer: PackedByteArray, from: int) -> int:
	for index in range(from, buffer.size() - 3):
		if buffer.decode_u32(index) == FRAME_MAGIC:
			return index
	return -1


static func noop(_rpc_data: RPC) -> void:
	pass
