# Benchmarking: implementation plan

Steps to build `api-specification.md` per `technical-design.md`. Section names refer to the design.
Feature issue: #1532.

## Rules

- One sub issue and one PR per step, PR with `Part of #<id>`.
- Local runs: suites of the change, plus discovery, guard and scanner tests when touched.
- Every PR keeps `master` working. Users reach the feature from step 13.
- No work of a later step.

## Steps

| Step | Issue | Content                           | Needs      | PR    |
| ---- | ----- | --------------------------------- | ---------- | ----- |
| 0    | #1552 | Design documents                  | -          | #1553 |
| 1    | #1533 | Statistics                        | 0          |       |
| 2    | #1534 | Result model, environment, events | 1          |       |
| 3    | #1535 | `GdUnitBenchmarkSuite`            | 0          |       |
| 4    | #1536 | Benchmark configuration           | 3          |       |
| 5    | #1537 | Parameters                        | 4          |       |
| 6    | #1538 | Test execution filters            | 3          |       |
| 7    | #1539 | Discovery                         | 5, 6       |       |
| 8    | #1540 | Executor lifecycle                | 2, 7       |       |
| 9    | #1541 | Measurement                       | 8          |       |
| 10   | #1542 | Async benchmarks                  | 9          |       |
| 11   | #1543 | Text report                       | 2          |       |
| 12   | #1544 | Report files                      | 11         |       |
| 13   | #1545 | Command line runner               | 10, 12     |       |
| 14   | #1546 | Transport to the editor           | 2          |       |
| 15   | #1547 | Editor run                        | 13, 14     |       |
| 16   | #1548 | Benchmark console                 | 11, 15     |       |
| 17   | #1549 | Inspector                         | 7, 15      |       |
| 18   | #1550 | User documentation                | 13, 16, 17 |       |
| 19   | #1551 | Benchmarks of GdUnit4 itself      | 13         |       |

## Design sections and tests

| Step | Design                                                                                                 | Tests                                                                                   |
| ---- | ------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| 1    | "Statistics"                                                                                           | Reference values computed outside Godot, 0/1/2/equal values, only outliers, `NA`        |
| 2    | "Result model", `GdUnitBenchmarkEvent`                                                                 | Serialize round trip                                                                    |
| 3    | "GdUnitBenchmarkSuite"                                                                                 | Hooks overridable, `auto_free()`                                                        |
| 4    | "Cases" items 1, 2, call arguments in "Modes"                                                          | Every argument with and without `_`, every validation error, call argument order        |
| 5    | "Parameters"                                                                                           | All sources, every validation error, `int` for `float`, invalid value never set         |
| 6    | "Separation" item 4, touch points of test commands, CI runner, scanner                                 | Test run of a folder with benchmark suites runs tests only                              |
| 7    | "Walk", "Cases"                                                                                        | Extends by class name, path, two levels, guard, display names, existing tests unchanged |
| 8    | "Executor", "Errors", `GdUnitBenchmarkSignals`                                                         | Fake clock: lifecycle order, new instance, errors in every hook, no orphans, see below  |
| 9    | "Modes", "Overhead", "Calibration", "Clock"                                                            | Fake clock: both modes, `input` freed, see below. Real clock: positive values, N grows  |
| 10   | Async in "Modes"                                                                                       | Async measured with frames, sync never awaits                                           |
| 11   | "Report": table, text report                                                                           | Expected text, units, parameter columns, baseline, `NA`, `skipped`, `?`, hints, legend  |
| 12   | "Report": writers                                                                                      | Expected files, history                                                                 |
| 13   | "Runners" (command line), touch points `GdUnitCmdTool.gd`, `GdUnitCopyLog.gd`, `GdUnitTestCIRunner.gd` | Exit codes, files, test run unchanged. Manual: 4.7, 4.7.1, 4.8, gdUnit4-action          |
| 14   | "Events and transport", touch point `GdUnitServer.gd`                                                  | RPC round trip, client disconnected on `SESSION_CLOSE`                                  |
| 15   | "Runners" (editor), touch point `plugin.gd`                                                            | Manual editor run                                                                       |
| 16   | "Report": `GdUnitBenchmarkConsole`                                                                     | Console text from an event sequence                                                     |
| 17   | "Report": inspector, touch point main panel                                                            | Mixed folder in both view modes, commands per item type, test counters                  |
| 18   | -                                                                                                      | Examples as tests in `#region documented examples`                                      |
| 19   | -                                                                                                      | Run produces a report                                                                   |

Also tested:

- Step 4: `_init()`, `_ready()`, `_process()`, `_notification()` in the suite or a base script fail every benchmark of
  the suite with the line, helper functions with `_` prefix don't. No return type, `-> Variant`, `-> int` fail,
  `-> void` passes.
- Step 8: parameter values set before the instance enters the tree, combination count differs from the discovery,
  `push_error` and script errors fail, `printerr` and `push_warning` don't.
- Step 9: default expressions never run (call counter in `parameters := _sizes()`), overhead copy has the
  argument names and types (inferred types written out, inner class of the suite), an error in the probe call stops
  before calibration.
- Step 10: mode from `is_coroutine()` (coroutine called without `await`, `await` in a lambda), several and nested
  `await`, `await` behind a condition measured per call, `input` value released after the awaited call, a state on a
  sync benchmark in the probe call fails it, no pending state at `cleanup()`.

Probes: step 7 first checks that `unused_parameter` disabled before `ResourceLoader.load` suppresses the warning on
first load, also in the editor runner process. Step 10 first checks that `callv` on an awaiting body returns
`GDScriptFunctionState` on Godot 4.7, 4.7.1, 4.8 (4.7.2 verified, see "Async"). Results into the design.

Step 18: `documentation/doc/_advanced_testing/benchmarking.md` covering the specification, `--benchmark` on the
command line page. Point out explicitly: the `input` value is freed by the executor after every call, no
`auto_free()` for it (see "Input per call" of the specification).

Step 19: `addons/gdUnit4/test/benchmarks/` with the `GD-1248` scenarios of `analysis.md`. Optional: manual workflow
writing `report.md` to the job summary.
