# Benchmarking: technical design

Implementation of `api-specification.md`. Order of work: `implementation-plan.md`.

## Architecture

### Separation

1. Code in `src/benchmark/`, public `GdUnitBenchmarkSuite` in `src/`. Class prefix `GdUnitBenchmark`.
2. Discovery shared: discoverer, scanner walk, guard. A benchmark is a `GdUnitTestCase`.
3. Execution separate: no `GdUnitTestSuiteExecutor`, stages, `GdUnitExecutionContext`, `GdUnitTestCaseImpl`,
   `GdUnitEvent`, run signals of `GdUnitSignals`.
4. Every test execution entry drops benchmark cases. `GdUnitTestSuiteScanner.load_suite` rejects benchmark scripts as
   safety net.
5. Existing files change only at the touch points below. New touch points need user consent.

### Reused

| Component                                                      | Use                                                  |
| -------------------------------------------------------------- | ---------------------------------------------------- |
| `GdUnitTestDiscoverer`                                         | Scan lookup folders, restore GUIDs, emit cases       |
| `GdUnitTestDiscoverGuard`                                      | Moved, renamed, deleted, added cases on file changes |
| `GdUnitTestDiscoverSink`, discover signals                     | Cases to the inspector                               |
| `GdUnitTestSuiteScanner` (walk, load)                          | Find and load scripts                                |
| `GdUnitTestCase`                                               | One benchmark with one parameter combination         |
| `GdUnitRunnerConfig`                                           | Cases and server port to the runner, own file        |
| `GdScriptParser`, `GdFunctionDescriptor`, `GdFunctionArgument` | Functions, lines, default arguments                  |
| `GdUnitExpressionRunner`                                       | `do_skip`, inline `parameters`                       |
| `CmdOptions`, `CmdOption`, `CmdArgumentParser`                 | Command line options                                 |
| `GdUnitTcpClient`, `GdUnitTcpServer`, `RPC`                    | Runner to editor transport                           |
| `GdUnitFileAccess`, `GdUnit4Version`, `GdUnitResult`           | Files, version, results                              |

Not reused: test parameter resolvers (positional argument lists, benchmarks need member dictionaries),
`GdUnitScriptErrorCollector` (script errors only), `GodotGdErrorMonitor.GdUnitLogger` (builds test report entries).
Replaced by `GdUnitBenchmarkErrorLogger`.

### Touch points

| File                                            | Change                                                                                                                                  |
| ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `src/core/discovery/GdUnitTestDiscoverer.gd`    | `discover_tests`: branch for benchmark suites                                                                                           |
| `src/core/discovery/GdUnitTestDiscoverGuard.gd` | `discover`: accept benchmark suites                                                                                                     |
| `src/core/GdUnitTestSuiteScanner.gd`            | `_load_is_test_suite` keeps benchmark suites, `load_suite` rejects them, `load_with_disabled_warnings` also disables `unused_parameter` |
| `src/core/runners/GdUnitTestCIRunner.gd`        | `discover_tests` drops benchmark cases, `--benchmark` in help                                                                           |
| Editor test commands                            | Drop benchmark cases, disabled on benchmark items                                                                                       |
| `bin/GdUnitCmdTool.gd`                          | `GdUnitBenchmarkCIRunner` on `--benchmark`                                                                                              |
| `bin/GdUnitCopyLog.gd`                          | Log into the latest benchmark report on `--benchmark`                                                                                   |
| `src/network/GdUnitServer.gd`                   | `_receive_rpc_data`: branch for `RPCGdUnitBenchmarkEvent`, disconnects the client on its `SESSION_CLOSE` like for `GdUnitEvent`         |
| `plugin.gd`                                     | Register benchmark console and commands                                                                                                 |
| `src/ui/parts/GdUnitInspectorTreeMainPanel.gd`  | Benchmark item types, routing by item type                                                                                              |

`is_test_suite` stays unchanged, a benchmark suite has no `GdUnitTestSuite` in its base chain.

### Layout

```text
addons/gdUnit4/src/
├── GdUnitBenchmarkSuite.gd
└── benchmark/
    ├── GdUnitBenchmarkSignals.gd
    ├── discovery/
    │   ├── GdUnitBenchmarkScanner.gd        # is_benchmark_suite, is_benchmark_case, discover
    │   ├── GdUnitBenchmarkConfig.gd         # arguments of a function or setup(), call arguments
    │   └── GdUnitBenchmarkParameters.gd     # resolve, validate parameters
    ├── execution/
    │   ├── GdUnitBenchmarkExecutor.gd
    │   ├── GdUnitBenchmarkMeasurement.gd    # overhead, calibration, rounds
    │   ├── GdUnitBenchmarkClock.gd
    │   └── GdUnitBenchmarkErrorLogger.gd
    ├── result/
    │   ├── GdUnitBenchmarkResult.gd
    │   ├── GdUnitBenchmarkStatistics.gd
    │   ├── GdUnitBenchmarkEnvironment.gd
    │   └── GdUnitBenchmarkEvent.gd
    ├── report/
    │   ├── GdUnitBenchmarkTable.gd
    │   ├── GdUnitBenchmarkTextReport.gd
    │   ├── GdUnitBenchmarkMarkdownWriter.gd
    │   ├── GdUnitBenchmarkCsvWriter.gd
    │   ├── GdUnitBenchmarkHtmlWriter.gd
    │   └── GdUnitBenchmarkJsonWriter.gd
    ├── runners/
    │   ├── GdUnitBenchmarkCIRunner.gd
    │   ├── GdUnitBenchmarkRunner.gd         # editor runner process
    │   └── GdUnitBenchmarkRunner.tscn
    ├── network/
    │   └── RPCGdUnitBenchmarkEvent.gd
    └── ui/
        ├── GdUnitBenchmarkConsole.gd
        ├── GdUnitBenchmarkConsole.tscn
        ├── GdUnitBenchmarkInspectorTree.gd
        └── GdUnitCommandBenchmarkSession.gd
```

Tests: `addons/gdUnit4/test/benchmark/`, discovery fixtures in `test/benchmark/resources/`.

## GdUnitBenchmarkSuite

- Extends `Node`, internals prefixed `__`.
- `setup()`, `cleanup()` empty. The executor checks the script for overrides.
- `auto_free(obj)` appends to `__auto_free`. Freed after `cleanup()`: valid nodes with `free()`, `RefCounted` by
  dropping the reference.

## Discovery

### Walk

1. `GdUnitTestDiscoverer.run()` scans the lookup folders, the CI runners the paths of `-a`.
2. `_load_is_test_suite` returns the script on `is_test_suite` or `GdUnitBenchmarkScanner.is_benchmark_suite`.
3. `discover_tests` calls `GdUnitBenchmarkScanner.discover(script)` for benchmark suites.
4. GUID restore, `GdUnitTestDiscoverSink`, guard change detection: unchanged.

`is_benchmark_suite` walks the base chain like `is_test_suite`, looking for `GdUnitBenchmarkSuite`.
`load_with_disabled_warnings` disables `unused_parameter` next to `unsafe_method_access`.

### Cases

`discover(script)` reads `bench_*` with `GdScriptParser.get_function_descriptors`. Per function:

1. `GdUnitBenchmarkConfig` from the default arguments, names trimmed of `_`.
2. `GdUnitBenchmarkConfig` of `setup()` for suite `do_skip` / `skip_reason`.
3. `GdUnitBenchmarkParameters` resolves and validates.
4. One `GdUnitTestCase` per combination via `GdUnitTestCase.from`.

| Field             | Content                                           |
| ----------------- | ------------------------------------------------- |
| `test_name`       | `bench_find`                                      |
| `display_name`    | `bench_find [size=10]`                            |
| `attribute_index` | Combination index                                 |
| `line_number`     | Function line                                     |
| `metadata`        | `{"benchmark": true}`                             |

- `metadata` holds the marker only. `GdUnitRunnerConfig` stores it via `inst_to_dict` and JSON, object values would
  not survive. `GdUnitTestCase.to_dict` (C# API) and copies by `GdUnitTestCase.from` drop it.
- `is_benchmark_case(test_case)` reads the marker, used by all filters of discovered cases. Inspector items use their
  `GdUnitType`.
- The executor reads the configuration and resolves the parameters from the script again, the combination by
  `attribute_index`. A different combination count than the discovery fails the case.
- Validation errors fail the case in the executor without running it. The discovery only builds the display name.

### Parameters

Source from the default value text, rule of `GdParameterSetResolverFactory`:

| Default value | Source                           |
| ------------- | -------------------------------- |
| `{...}`       | Inline, `GdUnitExpressionRunner` |
| contains `(`  | Function on a suite instance     |
| otherwise     | Property of a suite instance     |

The discovery instance is freed after reading, `setup()` is not called.

Validation with `script.get_script_property_list()`, entries with `PROPERTY_USAGE_SCRIPT_VARIABLE`: key exists, `type`
not `TYPE_NIL`, values match by `typeof`, `int` also for `float` members, objects also by class or script. Required
before every `set()`: a `String` set on an `int` member gives `0` without error (Godot 4.7.2).

Shared by discovery and executor, same resolution code.

## Execution

### Executor

`GdUnitBenchmarkExecutor.execute(script, cases)`, per case:

1. Read configuration, resolve and validate parameters. Error: failed. Suite or function skipped: skipped.
2. Create instance, set the parameter values on members, add to tree.
3. `OS.add_logger(GdUnitBenchmarkErrorLogger)`.
4. `await setup()` if overridden.
5. `GdUnitBenchmarkMeasurement`.
6. `await cleanup()` if overridden, also after errors in 4 or 5.
7. Remove logger, free `auto_free()` objects, remove and free instance.
8. Emit `BENCHMARK_AFTER` with the `GdUnitBenchmarkResult`.

`await process_frame` between rounds and benchmarks keeps the runner responsive and flushes TCP, outside every round.

### Modes

Arguments prepared once (an array per call costs ~60 ns): one value per declared argument in declaration order,
configuration values as read by `GdUnitBenchmarkConfig` (`input` as `Callable` on the instance, `parameters` as the
resolved dictionary). GDScript evaluates a default expression on every call without the argument.

Without `input`:

```gdscript
var arguments := _config.call_arguments(suite)
var start := _clock.now_usec()
for i in n:
    suite.callv(function_name, arguments)
var round_usec := _clock.now_usec() - start
```

With `input`, slot 0 holds the value:

```gdscript
var arguments := _config.call_arguments(suite)
var round_usec := 0
for i in n:
    arguments[0] = input.call()
    var start := _clock.now_usec()
    suite.callv(function_name, arguments)
    round_usec += _clock.now_usec() - start
    _release(arguments[0])
    arguments[0] = null
```

`_release(value)` after every call, outside the measurement: `Node` removed from its parent and freed, other
`Object` freed, `RefCounted` released by clearing the argument. Async: after the awaited call.

Async: `callv` returns `GDScriptFunctionState` when the body awaits (verified Godot 4.7.2). Detected on the first awaiting call, then
`await suite.callv(...)` at the same place and calibration restarts. Sync benchmarks never `await`.

Time per call: `max(0.0, round_usec * 1000.0 / n - overhead_ns)` ns.

Probe results, Godot 4.7.2:

| Call                                 | ns/call |
| ------------------------------------ | ------- |
| Plain `for` body                     | 31      |
| `callv`, prepared array, 1 argument  | 86      |
| `callv`, prepared array, 2 arguments | 97      |

Default arguments, `callv` on a `Node`, best of 7 rounds of 200 000 calls, Godot 4.7.2 without `-d` (with `-d`
about 25 ns more per call):

| Function                                         | ns/call                               |
| ------------------------------------------------ | ------------------------------------- |
| No arguments                                     | 112                                   |
| 3 defaults `int`, `int`, `bool` not passed       | 120                                   |
| Default `{"size": [10, 10000]}` not passed       | 493                                   |
| Default `_shuffled` (`Callable`) not passed      | 192                                   |
| Default `_sizes()` not passed                    | 627, `_sizes()` runs on every call    |
| 4 arguments passed, dictionary included          | 144                                   |
| Variadic `(...args)`, 0 / 1 / 4 arguments passed | 174 / 233 / 245, unfit as a reference |

| `sort()` size | Inputs ahead     | Clock around call | Total minus setup |
| ------------- | ---------------- | ----------------- | ----------------- |
| 10            | 0.422 µs ± 0.013 | 0.388 µs ± 0.011  | 0.343 µs ± 0.015  |
| 100           | 5.362 µs ± 0.155 | 5.181 µs ± 0.090  | 5.197 µs ± 0.115  |
| 10 000        | 969.7 µs ± 28.6  | 964.0 µs ± 18.0   | 958.5 µs ± 21.2   |

Clock around the call: smallest spread. Inputs ahead lose the CPU cache. 0/1 µs readings average out.

### Overhead

Per benchmark, a copy of the function without body on a temporary script:

```gdscript
extends "res://test/benchmarks/ArrayBenchmark.gd"


func _init() -> void:
    pass


func __overhead(_values: Array, _parameters: Dictionary, _input: Callable) -> void:
    pass
```

- Built by `GdUnitBenchmarkMeasurement` from the `GdFunctionDescriptor`: same argument names and types, no defaults,
  inferred types written out (`rounds := 10` gives `int`, `input := _shuffled` gives `Callable`).
- `extends` the suite script, so inner classes, `class_name` and `preload` constants of the suite resolve.
- `_init()` without `super()` skips the `_init()` of the suite. Member initializers of the suite still run (Godot
  4.7.2), `@onready` does not, the instance never enters the tree.
- One instance, not added to the tree, called with the same argument array, 3 rounds with the calibrated N, median.
  Freed after the measurement.
- Async uses the sync overhead. Mean below 2 × overhead: hint "close to the call overhead".

Probe, Godot 4.7.2, 5 arguments:

| Reference                                          | ns/call     |
| -------------------------------------------------- | ----------- |
| Empty function in the suite, typed arguments       | 194         |
| Empty function in the suite, untyped arguments     | 172         |
| Standalone script (`extends Node`), untyped        | 166         |
| Standalone script (`extends Node`), typed          | 202         |
| Temporary script extending the suite, typed copy   | 194         |
| Standalone script with an inner class of the suite | parse error |

### Calibration

N = 1, ×10 until a round reaches 50 ms, then scaled to 50 ms. A single call above 50 ms: N = 1. Clock resolution then
below 0.01 % of a round. The first round with N = 1 is the probe call, errors are checked right after it.

### Errors

`GdUnitBenchmarkErrorLogger extends Logger`, Godot 4.7.2:

| Source               | Callback                               |
| -------------------- | -------------------------------------- |
| `push_error`         | `_log_error`, `ERROR_TYPE_ERROR`       |
| Script runtime error | `_log_error`, `ERROR_TYPE_SCRIPT`      |
| `push_warning`       | `_log_error`, `ERROR_TYPE_WARNING`     |
| `printerr`           | `_log_message` with `error == true`    |

- Collects `ERROR_TYPE_ERROR` and `ERROR_TYPE_SCRIPT`, ignores the rest. Mutex, callbacks may come from any thread.
- Function and line from the first frame of the script backtraces via `GdUnitStackTrace.from_script_backtraces`.
  The `function` and `line` arguments of `push_error` point into the engine.
- A script error ends the current call with `null`, the loop goes on. Checked after the probe call, every round and
  every executor step: at most one round runs with errors.
- An error fails the benchmark and drops its samples. `OS.add_logger` since Godot 4.5.

### Clock

`GdUnitBenchmarkClock.now_usec() -> int` = `Time.get_ticks_usec()`. Injected, tests use a fake clock.

## Statistics

`GdUnitBenchmarkStatistics` on the times per call:

1. Quartiles with linear interpolation, fences at 1.5 × IQR. Above the upper fence: removed, kept as outliers. Below
   the lower fence: kept.
2. Mean.
3. StdDev with n - 1.
4. Error = `t(0.9995, n - 1) * StdDev / sqrt(n)`. t table for 1 to 30 degrees of freedom, above 3.291.
5. Median, Min, Max.
6. Ratio = `Mean / Mean of the baseline` with equal parameter values.
7. RatioSD = `Ratio * sqrt((StdDev / Mean)² + (StdDev_baseline / Mean_baseline)²)`.

Fewer than 2 values after 1: StdDev, Error, RatioSD `NA`.

## Result model

`GdUnitBenchmarkResult.serialize()`, used by transport and `results.json`:

```json
{
    "suite": "res://test/benchmarks/ArrayBenchmark.gd",
    "benchmark": "bench_sort",
    "display_name": "bench_sort [size=10]",
    "parameters": { "size": 10 },
    "baseline": false,
    "async": false,
    "state": "measured",
    "error": "",
    "n": 120000,
    "rounds": 10,
    "warmup": 3,
    "overhead_ns": 86.0,
    "samples_ns": [388.1, 387.9, 389.4, 388.0, 391.2, 388.5, 387.7, 388.3, 552.0, 388.9],
    "outliers_ns": [552.0],
    "mean_ns": 388.67,
    "error_ns": 1.37,
    "stddev_ns": 1.05,
    "median_ns": 388.3,
    "min_ns": 387.7,
    "max_ns": 391.2,
    "ratio": 3.23,
    "ratio_sd": 0.1,
    "hints": []
}
```

`state`: `measured`, `failed`, `skipped`. `results.json`: `schema_version`, environment, results.

`GdUnitBenchmarkEnvironment`, once per run:

| Value    | Source                                                |
| -------- | ----------------------------------------------------- |
| GdUnit4  | `GdUnit4Version.current()`                            |
| Godot    | `Engine.get_version_info()`                           |
| Build    | `OS.has_feature("editor")`, `OS.is_debug_build()`     |
| OS       | `OS.get_name()`, `OS.get_version()`                   |
| CPU      | `OS.get_processor_name()`, `OS.get_processor_count()` |
| Headless | `DisplayServer.get_name() == "headless"`              |
| Time     | `Time.get_datetime_string_from_system(true)`          |

## Events and transport

`GdUnitBenchmarkEvent`: `SESSION_START` (environment), `SUITE_BEFORE`, `BENCHMARK_BEFORE`, `BENCHMARK_AFTER`
(result), `SUITE_AFTER`, `SESSION_CLOSE`. Emitted by `GdUnitBenchmarkSignals.benchmark_event(event)`.

Editor runner: every event as `RPCGdUnitBenchmarkEvent` over the editor TCP connection, re-emitted on
`GdUnitBenchmarkSignals` by the branch in `GdUnitServer._receive_rpc_data`.

## Runners

Command line:

- `GdUnitCmdTool._initialize`: `--benchmark` in `OS.get_cmdline_args()` adds `GdUnitBenchmarkCIRunner` instead of
  `GdUnitTestCIRunner`. `runtest.sh` unchanged.
- `GdUnitBenchmarkCIRunner`: options via `CmdArgumentParser`, shared walk keeping benchmark cases, executor per suite,
  text report, files.
- Exit codes: `RETURN_SUCCESS`, `RETURN_ERROR` of the test runner.

Editor:

- `GdUnitCommandBenchmarkSession`: cases and port via `GdUnitRunnerConfig` to `GdUnitBenchmarkRunner.cfg`, then
  `OS.create_process` with `--no-window --path <project> res://addons/gdUnit4/src/benchmark/runners/GdUnitBenchmarkRunner.tscn`.
- `GdUnitBenchmarkRunner`: loads the config, connects via `GdUnitTcpClient`, runs like the CI runner, sends events.
- "Run Benchmarks", "Run all Benchmarks" collect benchmark cases of the selection or the discovery.
- One running flag for both session kinds disables the other kind.

## Report

- `GdUnitBenchmarkTable`: table of a suite per specification (columns, unit, decimals, right aligned, `NA`,
  `skipped`, `?`).
- `GdUnitBenchmarkTextReport`: header, tables, hints, legend. Used by console, CI, editor console.
- Writers: `report.md`, `report.html`, `report.csv`, `results.json`. `GdUnitFileAccess` creates
  `reports/benchmark_<n>/`, removes folders above `-rc`.
- `GdUnitBenchmarkConsole`: bottom panel tab, `RichTextLabel` with monospace font, rebuilt on `BENCHMARK_AFTER`, hints
  and legend on `SESSION_CLOSE`.

Inspector:

- `GdUnitType` gets `BENCHMARK_SUITE`, `BENCHMARK`. The discover handler creates them for marked cases, same folders
  and view modes as tests.
- `GdUnitBenchmarkInspectorTree`: icon, text `Mean ± Error`, state from `BENCHMARK_AFTER`, report panel content.
- The main panel routes selection, report panel and run action by type. Test result functions skip benchmark items,
  benchmarks don't count in progress bar and counters.

## Godot compatibility

Godot 4.7, 4.7.1, 4.8 (`master` row of `README.md`). APIs: `Time.get_ticks_usec`, `Object.callv`,
`GDScriptFunctionState`, `Script.get_script_property_list`, `OS.add_logger`, `Logger._log_error`, `ScriptBacktrace`
(4.5+), `OS.get_processor_name`, `Engine.get_version_info`, `DisplayServer.get_name`.

## Risks

- Mixed discovery results: a test entry without the filter runs benchmarks as tests. Safety net: `load_suite`.
- CI noise: spread varies between runs. Reporting only.
- `GdUnitInspectorTreeMainPanel.gd` (1236 lines, length already suppressed) gets routing only, benchmark logic lives
  in `GdUnitBenchmarkInspectorTree`.
- A parameter function with different results in editor and runner changes the combinations. Count check in the
  executor, values may still differ.
- The overhead instance runs the member initializers of the suite a second time, outside the measurement.
- `--benchmark` is unknown to older GdUnit4 versions.
