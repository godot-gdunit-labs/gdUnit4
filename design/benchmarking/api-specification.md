# Benchmarking: API specification

User-visible behavior. Implementation: `technical-design.md`.

## Scope

Not in the first version: diagnosers (objects, memory, profiler breakdown), comparing runs, time limit, setting for
the round target, C# benchmarks, debug run in the editor.

## Example

```gdscript
class_name ArrayBenchmark
extends GdUnitBenchmarkSuite

var size := 10
var _values := []


func setup() -> void:
    _values = range(size)
    _values.shuffle()


func cleanup() -> void:
    _values.clear()


func bench_find(rounds := 10, warmup := 3, baseline := true, parameters := {"size": [10, 10000]}) -> void:
    _values.find(size - 1)


func bench_sort(values: Array, parameters := {"size": [10, 10000]}, input := _shuffled) -> void:
    values.sort()


func _shuffled() -> Array:
    return _values.duplicate()
```

## Benchmark

- Extends `GdUnitBenchmarkSuite` (extends `Node`). No test suite, no asserts, reports values only.
- Found like tests: folders of "Test Lookup Folder", on the command line the paths of `-a`.
- No `before()` / `after()`, state belongs to the single benchmark.

| Method                               | Behavior                                           |
| ------------------------------------ | -------------------------------------------------- |
| `setup() -> void`                    | Optional, before every benchmark, may `await`      |
| `cleanup() -> void`                  | Optional, after every benchmark, also after errors |
| `auto_free(obj: Variant) -> Variant` | Returns `obj`, frees it after `cleanup()`          |

## Benchmark functions

- Prefix `bench_`. The body is the measured unit, no loop.
- Called repeatedly on the same instance, member changes persist between calls.
- Configuration by default arguments, read by the discovery. The executor passes the read values on every call, a
  default expression never runs per call. A leading `_` is allowed. `UNUSED_PARAMETER` is not reported while loading.
- With `input`: exactly one argument without default, first. Without: none.

| Argument      | Default | Meaning                                      |
| ------------- | ------- | -------------------------------------------- |
| `rounds`      | `10`    | Measured rounds, one sample each             |
| `warmup`      | `3`     | Dropped rounds before                        |
| `baseline`    | `false` | Reference of `Ratio`, at most one per suite  |
| `input`       | none    | Suite function, called before every call     |
| `parameters`  | none    | Member values, one benchmark per combination |
| `do_skip`     | `false` | Expression, skips when `true`                |
| `skip_reason` | none    | Text for skipped benchmarks                  |

## Lifecycle

Per benchmark and parameter combination:

1. New suite instance.
2. Parameter values set on members.
3. Added to the tree, `_ready()` sees the parameter values.
4. `setup()`.
5. Calibrate N, `warmup` rounds dropped, `rounds` rounds measured.
6. `cleanup()`.
7. Free `auto_free()` objects, then the instance.

Sequential, never parallel, never in a test process.

## Input per call

`input := _func`: suite function without arguments, called before every call, its return value is the only
argument. Not measured. The executor frees the value after its call, outside the measurement: a `Node` is removed
from its parent and freed, another `Object` freed, a `RefCounted` released. Don't register it with `auto_free()`.

## Parameters

- Dictionary of member names to value lists: `{"size": [10, 100]}`. Set before the instance enters the tree.
- Several keys give the cartesian product in key order.
- Sources: inline, property (`parameters := _sizes`), function (`parameters := _sizes()`).
- Keys must be typed member variables (`var size := 10`, `var size: int`), values must fit the type.
- Inspector: one item per combination, `bench_find [size=10]`. Report: one column per key.

## Skipping

On a function: skips the benchmark with all combinations. On `setup()`: skips the suite.

```gdscript
func setup(do_skip := OS.get_name() == "Web", skip_reason := "No threads on the web") -> void:
    pass
```

## Async

The body may `await`. Measured time includes awaited frames. Usually N = 1, then `rounds` = measured calls. Marked by
a hint.

```gdscript
var _level_scene: PackedScene


func setup() -> void:
    _level_scene = load("res://level.tscn")


func bench_spawn_100_enemies(level: Level, rounds := 10, input := _new_level) -> void:
    for i in 100:
        level.spawn_enemy()
    await get_tree().process_frame


func _new_level() -> Level:
    var level: Level = _level_scene.instantiate()
    add_child(level)
    return level
```

## Measurement

- Clock `Time.get_ticks_usec()`, not the script profiler.
- N calibrated to rounds of at least 50 ms, N = 1 for longer calls.
- Call overhead measured per benchmark and subtracted, with a copy of the function without body on a second instance
  of the suite. Its member initializers run again, outside the measurement, `_init()` and `_ready()` don't.
- Reported: time per call. Upper outliers removed before `Mean` and `Error`.
- Editor binary runs GDScript as debug build, not comparable with exported games. Header shows the build.

## Errors

A benchmark fails, the others continue, on:

- unknown argument, second baseline, arguments without default not matching `input`,
- parameter key not a member, untyped member, value not matching the type,
- script error or `push_error` in `setup()`, `input`, body or `cleanup()`.

The error names function and line, for parameters key and value index. Report: `NA` plus error in hints. Command
line exit code `100`.

## Running

A run is either tests or benchmarks.

Editor:

- "Run Benchmarks": context menu of inspector, file system dock, script editor. On a folder: all its benchmark suites.
- "Run all Benchmarks": inspector toolbar.
- Test commands run tests only. Test commands disabled on benchmark items, benchmark commands on test items.
- Commands of the other kind disabled during a run. Stop ends the run.

Command line and CI:

```bash
./addons/gdUnit4/runtest.sh --godot_binary /path/to/godot --benchmark -a res://test/benchmarks
```

- With `--benchmark`: `-a`, `-i`, `-rd`, `-rc`, `-help` as for tests.
- Exit code `0` all measured or skipped, `100` one failed.
- gdUnit4-action: `arguments: --benchmark`.

## Report

```text
GdUnit4 v7.0.0, Windows 11 (10.0.26200)
AMD Ryzen 9 7950X, 32 logical cores
Godot v4.7.2.stable (editor, debug), headless

res://test/benchmarks/ArrayBenchmark.gd
| Benchmark | size  | Mean         | Error       | StdDev      | Ratio  | RatioSD | N      |
| --------- | ----- | -----------: | ----------: | ----------: | -----: | ------: | -----: |
| find      | 10    |     0.120 µs |   0.0021 µs |   0.0019 µs |   1.00 |    0.00 | 400000 |
| sort      | 10    |     0.389 µs |   0.0014 µs |   0.0011 µs |   3.24 |    0.06 | 120000 |
| find      | 10000 |    12.300 µs |   0.0900 µs |   0.0800 µs |   1.00 |    0.00 |   4100 |
| sort      | 10000 |   964.000 µs |   9.1000 µs |   8.5000 µs |  78.37 |    0.85 |     52 |

Hints
  Outliers
    ArrayBenchmark.sort: size=10 -> 1 outlier was removed (0.552 µs)
  Close to the call overhead
    ArrayBenchmark.find: size=10 -> mean below 2 × call overhead (0.086 µs)

Legend
  size    : Value of the 'size' parameter
  Mean    : Arithmetic mean of all measurements
  Error   : Half of 99.9% confidence interval
  StdDev  : Standard deviation of all measurements
  Ratio   : Mean divided by the baseline mean ([Current]/[Baseline])
  RatioSD : Standard deviation of Ratio, propagated from both StdDev values
  N       : Calibrated calls per round
  1 µs    : 1 Microsecond (0.000001 sec)
```

- Header: GdUnit4 version, OS, CPU, Godot version, build (editor/template, debug/release), headless.
- One table per suite. Columns: `Benchmark` (name without `bench_`), one per parameter key, `Mean`, `Error`,
  `StdDev`, `Ratio` and `RatioSD` with a baseline, `N`.
- One time unit per table from the smallest mean: ns, µs, ms, s.
- `Ratio` against the baseline with equal parameter values, `?` without one.
- Value columns: `NA` failed, `skipped` skipped.
- Hints: removed outliers, close to call overhead, async, errors. Legend: shown columns only.

| Output                   | Content                                                   |
| ------------------------ | --------------------------------------------------------- |
| Command line, CI         | Text report at the end of the run                         |
| Editor console           | New tab next to `gdUnitConsole`, rows as results arrive   |
| Inspector                | Item text `Mean ± Error`, report panel with row and hints |
| `reports/benchmark_<n>/` | `report.md`, `report.html`, `report.csv`, `results.json`  |

Report folders count up like `report_<n>`, `-rc` limits them.
