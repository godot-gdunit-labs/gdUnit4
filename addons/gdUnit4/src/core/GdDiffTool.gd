# Character based diff, built on Myers' diff algorithm as implemented by git (xdiff)
# Based on "An O(ND) Difference Algorithm and Its Variations" by Eugene W. Myers
#
# The diff is not returned as an edit script, it is described as a list of changed regions (hunks).
# Text outside of the hunks is common to both values. This keeps the memory linear and the diff cheap
# to visualize, see GdAssertMessages.colored_diff().
class_name GdDiffTool
extends RefCounted


## Lower bound for the edit cost a single search accepts before it settles for the furthest reaching path (xdiff XDL_MAX_COST_MIN).
## The diff is minimal as long as the cost stays below this limit, otherwise it is only a good approximation.
const MIN_COST_LIMIT := 256
## Limits the work (visited diagonals and compared characters) spent on a whole diff.
## Once exhausted, the remaining regions are reported as completely changed instead of refining them further.
const MAX_WORK := 4_000_000

const _LINE_MAX := 1 << 30


## A changed region. The characters of `current` in [current_start, current_start + current_len) are replaced
## by the characters of `expected` in [expected_start, expected_start + expected_len).
## A hunk is a pure removal (`expected_len == 0`), a pure insertion (`current_len == 0`) or a replacement.
class Hunk:
	var current_start: int
	var current_len: int
	var expected_start: int
	var expected_len: int

	func _init(cur_start: int, cur_len: int, exp_start: int, exp_len: int) -> void:
		current_start = cur_start
		current_len = cur_len
		expected_start = exp_start
		expected_len = exp_len

	func _to_string() -> String:
		return "Hunk(current: %d+%d, expected: %d+%d)" % [current_start, current_len, expected_start, expected_len]


## Marks the characters of two sequences which are not part of the longest common subsequence.
## Port of the xdiff split/recursion (xdl_split, xdl_recs_cmp) without the snake heuristic and the discard of unmatched records.
class MyersSearch:
	var changed_a: PackedByteArray = PackedByteArray()
	var changed_b: PackedByteArray = PackedByteArray()
	var _a: PackedInt32Array
	var _b: PackedInt32Array
	var _kv_forward: PackedInt32Array = PackedInt32Array()
	var _kv_backward: PackedInt32Array = PackedInt32Array()
	var _kv_offset: int
	var _cost_limit: int
	var _work_left: int = MAX_WORK

	@warning_ignore_start("return_value_discarded")
	func _init(a: PackedInt32Array, b: PackedInt32Array) -> void:
		_a = a
		_b = b
		changed_a.resize(a.size())
		changed_b.resize(b.size())
		# one slot per diagonal (-b.size() .. a.size()) plus the two border slots of the search
		var diagonals: int = a.size() + b.size() + 3
		_kv_forward.resize(diagonals)
		_kv_backward.resize(diagonals)
		_kv_offset = b.size() + 1
		_cost_limit = maxi(MIN_COST_LIMIT, _bogo_sqrt(diagonals))
	@warning_ignore_restore("return_value_discarded")

	func run() -> void:
		# explicit stack instead of recursion, the first half is processed first
		var boxes: Array[Vector4i] = [Vector4i(0, _a.size(), 0, _b.size())]
		while not boxes.is_empty():
			var box: Vector4i = boxes.pop_back()
			var off1: int = box.x
			var lim1: int = box.y
			var off2: int = box.z
			var lim2: int = box.w
			# shrink the box by the common leading and trailing characters
			while off1 < lim1 and off2 < lim2 and _a[off1] == _b[off2]:
				off1 += 1
				off2 += 1
			while off1 < lim1 and off2 < lim2 and _a[lim1 - 1] == _b[lim2 - 1]:
				lim1 -= 1
				lim2 -= 1

			if off1 == lim1:
				_mark(changed_b, off2, lim2)
			elif off2 == lim2:
				_mark(changed_a, off1, lim1)
			else:
				var split: Vector2i = _split(off1, lim1, off2, lim2)
				var no_progress: bool = (split.x == off1 and split.y == off2) or (split.x == lim1 and split.y == lim2)
				if split.x < 0 or no_progress:
					# work budget exhausted, do not refine this region any further
					_mark(changed_a, off1, lim1)
					_mark(changed_b, off2, lim2)
				else:
					boxes.push_back(Vector4i(split.x, lim1, split.y, lim2))
					boxes.push_back(Vector4i(off1, split.x, off2, split.y))

	# Finds a point on the optimal path by searching from both ends of the box at the same time (middle snake).
	# Returns (-1, -1) when the work budget is exhausted.
	func _split(off1: int, lim1: int, off2: int, lim2: int) -> Vector2i:
		var a: PackedInt32Array = _a
		var b: PackedInt32Array = _b
		var kvf: PackedInt32Array = _kv_forward
		var kvb: PackedInt32Array = _kv_backward
		var o: int = _kv_offset
		var dmin: int = off1 - lim2
		var dmax: int = lim1 - off2
		var fmid: int = off1 - off2
		var bmid: int = lim1 - lim2
		var odd: bool = ((fmid - bmid) & 1) == 1
		var fmin: int = fmid
		var fmax: int = fmid
		var bmin: int = bmid
		var bmax: int = bmid
		kvf[fmid + o] = off1
		kvb[bmid + o] = lim1

		var cost: int = 1
		while true:
			# extend the forward diagonal domain by one
			if fmin > dmin:
				fmin -= 1
				kvf[fmin - 1 + o] = -1
			else:
				fmin += 1
			if fmax < dmax:
				fmax += 1
				kvf[fmax + 1 + o] = -1
			else:
				fmax -= 1

			var d: int = fmax
			while d >= fmin:
				var i1: int
				if kvf[d - 1 + o] >= kvf[d + 1 + o]:
					i1 = kvf[d - 1 + o] + 1
				else:
					i1 = kvf[d + 1 + o]
				var snake_start: int = i1
				var i2: int = i1 - d
				while i1 < lim1 and i2 < lim2 and a[i1] == b[i2]:
					i1 += 1
					i2 += 1
				_work_left -= i1 - snake_start
				kvf[d + o] = i1
				if odd and bmin <= d and d <= bmax and kvb[d + o] <= i1:
					return Vector2i(i1, i2)
				d -= 2

			# extend the backward diagonal domain by one
			if bmin > dmin:
				bmin -= 1
				kvb[bmin - 1 + o] = _LINE_MAX
			else:
				bmin += 1
			if bmax < dmax:
				bmax += 1
				kvb[bmax + 1 + o] = _LINE_MAX
			else:
				bmax -= 1

			d = bmax
			while d >= bmin:
				var i1: int
				if kvb[d - 1 + o] < kvb[d + 1 + o]:
					i1 = kvb[d - 1 + o]
				else:
					i1 = kvb[d + 1 + o] - 1
				var snake_start: int = i1
				var i2: int = i1 - d
				while i1 > off1 and i2 > off2 and a[i1 - 1] == b[i2 - 1]:
					i1 -= 1
					i2 -= 1
				_work_left -= snake_start - i1
				kvb[d + o] = i1
				if not odd and fmin <= d and d <= fmax and i1 <= kvf[d + o]:
					return Vector2i(i1, i2)
				d -= 2

			_work_left -= ((fmax - fmin) >> 1) + ((bmax - bmin) >> 1) + 2
			if _work_left < 0:
				return Vector2i(-1, -1)
			if cost >= _cost_limit:
				return _furthest_reaching(off1, lim1, off2, lim2, fmin, fmax, bmin, bmax)
			cost += 1
		return Vector2i(-1, -1)

	# The edit cost limit is reached, settle for the furthest reaching forward or backward path.
	func _furthest_reaching(off1: int, lim1: int, off2: int, lim2: int, fmin: int, fmax: int, bmin: int, bmax: int) -> Vector2i:
		var o: int = _kv_offset
		var forward_best: int = -1
		var forward_best_i1: int = -1
		var d: int = fmax
		while d >= fmin:
			var i1: int = mini(_kv_forward[d + o], lim1)
			var i2: int = i1 - d
			if lim2 < i2:
				i1 = lim2 + d
				i2 = lim2
			if forward_best < i1 + i2:
				forward_best = i1 + i2
				forward_best_i1 = i1
			d -= 2

		var backward_best: int = _LINE_MAX
		var backward_best_i1: int = _LINE_MAX
		d = bmax
		while d >= bmin:
			var i1: int = maxi(off1, _kv_backward[d + o])
			var i2: int = i1 - d
			if i2 < off2:
				i1 = off2 + d
				i2 = off2
			if i1 + i2 < backward_best:
				backward_best = i1 + i2
				backward_best_i1 = i1
			d -= 2

		if (lim1 + lim2) - backward_best < forward_best - (off1 + off2):
			return Vector2i(forward_best_i1, forward_best - forward_best_i1)
		return Vector2i(backward_best_i1, backward_best - backward_best_i1)

	func _mark(changed: PackedByteArray, from: int, to: int) -> void:
		for index in range(from, to):
			changed[index] = 1

	func _bogo_sqrt(value: int) -> int:
		var result: int = 1
		while value > 0:
			value >>= 2
			result <<= 1
		return result


## Compares both values and returns the changed regions in ascending order.
## Text between the hunks is equal. Returns an empty array when both values are equal.
static func diff(current: String, expected: String) -> Array[Hunk]:
	var cur_chars: PackedInt32Array = current.to_utf32_buffer().to_int32_array()
	var exp_chars: PackedInt32Array = expected.to_utf32_buffer().to_int32_array()
	var hunks: Array[Hunk] = []

	# cut off the common prefix and suffix, the search only needs to look at the characters in between
	var min_size: int = mini(cur_chars.size(), exp_chars.size())
	var prefix: int = 0
	while prefix < min_size and cur_chars[prefix] == exp_chars[prefix]:
		prefix += 1
	var suffix: int = 0
	while suffix < min_size - prefix and cur_chars[cur_chars.size() - 1 - suffix] == exp_chars[exp_chars.size() - 1 - suffix]:
		suffix += 1
	var cur_len: int = cur_chars.size() - prefix - suffix
	var exp_len: int = exp_chars.size() - prefix - suffix
	if cur_len == 0 and exp_len == 0:
		return hunks
	if cur_len == 0 or exp_len == 0:
		hunks.append(Hunk.new(prefix, cur_len, prefix, exp_len))
		return hunks

	var search := MyersSearch.new(cur_chars.slice(prefix, prefix + cur_len), exp_chars.slice(prefix, prefix + exp_len))
	search.run()
	var changed_cur: PackedByteArray = search.changed_a
	var changed_exp: PackedByteArray = search.changed_b
	# group the marked characters to hunks, the unchanged characters of both values are paired in sequence
	var i1: int = 0
	var i2: int = 0
	while i1 < cur_len or i2 < exp_len:
		var start1: int = i1
		var start2: int = i2
		while i1 < cur_len and changed_cur[i1] == 1:
			i1 += 1
		while i2 < exp_len and changed_exp[i2] == 1:
			i2 += 1
		if i1 > start1 or i2 > start2:
			hunks.append(Hunk.new(prefix + start1, i1 - start1, prefix + start2, i2 - start2))
		elif i1 < cur_len and i2 < exp_len:
			i1 += 1
			i2 += 1
		else:
			break
	return hunks



# prototype
static func longestCommonSubsequence(text1 :String, text2 :String) -> PackedStringArray:
	var text1Words := text1.split(" ")
	var text2Words := text2.split(" ")
	var text1WordCount := text1Words.size()
	var text2WordCount := text2Words.size()
	var solutionMatrix := Array()
	for i in text1WordCount+1:
		var ar := Array()
		for n in text2WordCount+1:
			ar.append(0)
		solutionMatrix.append(ar)

	for i in range(text1WordCount-1, 0, -1):
		for j in range(text2WordCount-1, 0, -1):
			if text1Words[i] == text2Words[j]:
				solutionMatrix[i][j] = solutionMatrix[i + 1][j + 1] + 1;
			else:
				solutionMatrix[i][j] = max(solutionMatrix[i + 1][j], solutionMatrix[i][j + 1]);

	var i := 0
	var j := 0
	var lcsResultList := PackedStringArray();
	while (i < text1WordCount && j < text2WordCount):
		if text1Words[i] == text2Words[j]:
			@warning_ignore("return_value_discarded")
			lcsResultList.append(text2Words[j])
			i += 1
			j += 1
		else: if (solutionMatrix[i + 1][j] >= solutionMatrix[i][j + 1]):
			i += 1
		else:
			j += 1
	return lcsResultList


static func markTextDifferences(text1 :String, text2 :String, lcsList :PackedStringArray, insertColor :Color, deleteColor:Color) -> String:
	var stringBuffer := ""
	if text1 == null and lcsList == null:
		return stringBuffer

	var text1Words := text1.split(" ")
	var text2Words := text2.split(" ")
	var i := 0
	var j := 0
	var word1LastIndex := 0
	var word2LastIndex := 0
	for k in lcsList.size():
		while i < text1Words.size() and j < text2Words.size():
			if text1Words[i] == lcsList[k] and text2Words[j] == lcsList[k]:
				stringBuffer += "<SPAN>" + lcsList[k] + " </SPAN>"
				word1LastIndex = i + 1
				word2LastIndex = j + 1
				i = text1Words.size()
				j = text2Words.size()

			else: if text1Words[i] != lcsList[k]:
				while i < text1Words.size() and text1Words[i] != lcsList[k]:
					stringBuffer += "<SPAN style='BACKGROUND-COLOR:" + deleteColor.to_html() + "'>" + text1Words[i] + " </SPAN>"
					i += 1
			else: if text2Words[j] != lcsList[k]:
				while j < text2Words.size() and text2Words[j] != lcsList[k]:
					stringBuffer += "<SPAN style='BACKGROUND-COLOR:" + insertColor.to_html() + "'>" + text2Words[j] + " </SPAN>"
					j += 1
			i = word1LastIndex
			j = word2LastIndex

			while word1LastIndex < text1Words.size():
				stringBuffer += "<SPAN style='BACKGROUND-COLOR:" + deleteColor.to_html() + "'>" + text1Words[word1LastIndex] + " </SPAN>"
				word1LastIndex += 1
			while word2LastIndex < text2Words.size():
				stringBuffer += "<SPAN style='BACKGROUND-COLOR:" + insertColor.to_html() + "'>" + text2Words[word2LastIndex] + " </SPAN>"
				word2LastIndex += 1
	return stringBuffer
