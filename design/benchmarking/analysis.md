# Benchmarking: analysis

Verified facts, Godot 4.7.2 on Windows unless noted. Background for the profiler diagnoser and for step 9.

## Script profiler

| Run                             | Debugger                                       | Profiler `"scripts"`                              |
| ------------------------------- | ---------------------------------------------- | ------------------------------------------------- |
| `godot -d`                      | local                                          | yes, table on stdout                              |
| `runtest.sh` with `-d` appended | local, last debugger flag wins                 | yes                                               |
| `runtest.sh`, gdUnit4-action    | none, `--remote-debug tcp://127.0.0.1:0` fails | no                                                |
| Editor, normal run              | none, `OS.create_process` without `-d`         | no                                                |
| Editor, debug run               | remote to the editor                           | no, only `"servers"`, `"visual"`, `"performance"` |

- `runtest.sh` starts `-s -d --remote-debug tcp://127.0.0.1:0`, the connection fails, `EngineDebugger.is_active()` is
  false.
- `EngineDebugger.profiler_enable("scripts", true)` prints `BEGIN PROFILING` and resets all counters.
- `profiler_enable("scripts", false)` prints the table `ACCUMULATED` via `print_line` (stdout and every logger).
- The table lists every loaded function, also uncalled ones: ~1350 functions, 2702 lines, ~190 KB per table here.
- No API returns the data: `ScriptLanguage` has no methods, `EngineProfiler` only receives frames of an own profiler.

```text
ACCUMULATED: total: 0.016393
0:res://addons/gdUnit4/src/core/report/messaging/GdUnitValueText.gd::176::GdUnitValueText._snapshot_at
    total: 0.033811/206 %   self: 0.001567/9 % tcalls: 5050
```

- Line 1: `<rank>:<path>::<line>::<function>`. Line 2 (tab): seconds with 6 decimals, `tcalls` = calls.
- Header `total` = sum of all self times, percentages refer to it.
- `total` counts nested calls again: recursive functions exceed 100 %.
- Native work (`str()`, constructors) counts as self time of the caller.
- Self times don't sum to the real time: 16.4 ms self against 19.8 ms for `_work`.
- Total of the measured function matches the clock: 79141 µs table, 79146 µs `Time.get_ticks_usec()`.
- Overhead: 68932 µs without, 79146 µs and 79807 µs with the profiler (+15 %), many small calls.

Capture in the same process with a logger (`OS.add_logger` since 4.5), received both tables of two rounds:

```gdscript
class ProfileLogger extends Logger:
    var lines := PackedStringArray()
    var _mutex := Mutex.new()

    func _log_message(message: String, _error: bool) -> void:
        _mutex.lock()
        lines.append(message)
        _mutex.unlock()
```

`--quiet` also silences the logger. The table always goes to stdout too.

## Debugger flags

- `-d` alone loops endlessly in `debug>` on a script error (12137 prompts in 20 s), a CI run hangs.
- `-d --ignore-error-breaks`: errors are printed, the run continues, `breakpoint` doesn't stop. Listed by `--help` of
  4.7.0 and 4.8-beta3.
- gdUnit4-action passes `arguments` to `runtest.sh`, which appends them to the Godot call (read in code, not run).
- Editor normal run: `--no-window --path <project> res://addons/gdUnit4/src/core/runners/GdUnitTestRunner.tscn` in
  `GdUnitCommandTestSession.execute`.

## Profiler limits

- Whole process, all threads, global counter reset: no parallel benchmarks.
- Script time only, engine work of awaited frames is missing.
- Text format, may change between Godot versions.
- Not verified: editor normal run with the flags, Godot 4.7.0 and 4.8, a CI run with the flags, C# (profiling
  functions empty per Godot source), `OS.execute_with_pipe` instead of a logger.

## GD-1248 scenarios

Failing assert up to the rendered message, `Time.get_ticks_usec()`, 3 rounds, `master` against the branch in turns,
median of two runs, output to a file.

| Scenario            | Iterations | Assert                                                                 |
| ------------------- | ---------- | ---------------------------------------------------------------------- |
| `success`           | 2000       | `assert_int(1).is_equal(1)`                                            |
| `int`               | 500        | `assert_int(1).is_equal(2)`                                            |
| `string`            | 500        | `assert_str("abc").is_equal("abd")`                                    |
| `string_2000_lines` | 20         | `assert_str(big_text).is_equal(big_changed)`, one change in the middle |
| `array_1000`        | 50         | `assert_array(range(1000)).is_equal(changed)`, one element changed     |
| `dict_200`          | 50         | `assert_dict(dict).is_equal(dict_changed)`, one value changed          |
| `object`            | 500        | `assert_object(node).is_same(other)`                                   |
| `array_objects_100` | 100        | `assert_array(objects).contains([other])`, 100 `Resource` objects      |

Steps measured per scenario: create the report, encode the event, decode it, render with `GdUnitReport.message()`
twice. The md5 of the text proves equal output.

Result for 100 `Resource` objects: `master` 81 µs (`str(array)` once in C++), branch 313 µs (one `GdUnitValueText`
per object, 1.1 µs each). Editor path additionally `serialized` + `var_to_bytes` 169 µs, `bytes_to_var` + `restored`
279 µs. Per failing assert with 100 objects: +0.3 ms command line, +0.74 ms editor. Passing asserts cost nothing
extra. Full tables: `design/GD-1248-failure-message-templates.md` on branch `GD-1248`.

Adapters to run the same suite on `master` and the branch:

```gdscript
var _tcp_node_script: GDScript = load("res://addons/gdUnit4/src/network/GdUnitTcpNode.gd")
var _rpc_script: GDScript = load("res://addons/gdUnit4/src/network/rpc/RPC.gd")
var _has_frames := _tcp_node_script.get_script_method_list().any(
    func(method: Dictionary) -> bool: return method["name"] == "encode_frames")
var _tcp_node: Node
var _captured: Array = []


func _expect_failures(enabled: bool) -> void:
    var thread_context: Object = GdUnitThreadManager.get_current_context()
    if thread_context.has_method("capture_failures"):
        if enabled:
            thread_context.call("capture_failures")
        else:
            _captured = thread_context.call("stop_capture")
        return
    Engine.set_meta("expect_assert_report_failures", enabled)


func _last_report() -> GdUnitReport:
    if not _captured.is_empty():
        return _captured.back()
    var context: Object = GdUnitExecutionContext.current()
    if context.has_method("last_failure"):
        return context.call("last_failure")
    return GdUnitReport.new().call("from_error", GdUnitReport.FAILURE, context.call("last_error"))


func _encode(event: GdUnitEvent) -> Array:
    var rpc := RPCGdUnitEvent.of(event)
    if _has_frames:
        return _tcp_node_script.call("encode_frames", rpc)
    var serialized: Variant = rpc.serialize()
    var text: String = serialized
    return [text.to_utf16_buffer()]


func _decode(frames: Array) -> GdUnitReport:
    var received: RPC = null
    if _has_frames:
        for frame: PackedByteArray in frames:
            received = _tcp_node.call("decode_frame", frame)
    else:
        var frame: PackedByteArray = frames[0]
        received = _rpc_script.call("deserialize", frame.get_string_from_utf16())
    return (received as RPCGdUnitEvent).event().reports()[0]
```

`_tcp_node` is created in the setup and freed in the cleanup. Event for the transport:
`GdUnitEvent.new().test_after(GdUnitGUID.new(), "bench", {}, [report])`.

## Probes

Small `SceneTree` scripts, run from a temporary project or the project root, deleted afterwards:

| Fact                  | Command                                                                                     |
| --------------------- | ------------------------------------------------------------------------------------------- |
| Profilers of a run    | `godot --headless --path . -d -s res://probe.gd`, prints `EngineDebugger.has_profiler(...)` |
| Run like `runtest.sh` | `godot --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://probe.gd`           |
| Remote debugger       | TCP listener on a free port, `--remote-debug tcp://127.0.0.1:<port>`                        |
| Endless `debug>` loop | script error under `-d`, stdin from `/dev/null`, stopped by `timeout`                       |
| Capture and overhead  | `godot --headless --path . -d --ignore-error-breaks -s res://probe.gd` with the logger      |
| API for profiler data | `ClassDB.class_get_method_list("ScriptLanguage", true)`, same for `EngineDebugger`          |
