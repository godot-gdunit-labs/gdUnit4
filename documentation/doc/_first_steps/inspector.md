---
layout: default
title: Test Inspector
nav_order: 3
---

# The GdUnit Test Inspector

The GdUnit Test Inspector is your entry point for running tests and reviewing their results. This page explains what each part of the inspector shows;
for the different ways to trigger a test run, see [How to Run Tests]({{site.baseurl}}/first_steps/how-to-run-tests/).

## Overview

The GdUnit inspector provides an overview of the currently executed tests and allows you to navigate them.
It allows you to select individual tests and view possible test failures, including the full call stack. The integrated status bar gives you a quick overview
of the last test run, including elapsed time and orphan nodes.

![GdUnit inspector overview]({{site.baseurl}}/assets/images/inspector/inspector.png){:.centered}

- (1) [Button Bar](#button-bar)
- (2) [Status Bar](#status-bar)
- (3) [Test Run Overview](#test-run-overview-tree)
- (4) [Failure Report](#failure-report)

---

## Button Bar

The button bar contains several buttons that allow you to perform different actions in GdUnit:
![button-bar]({{site.baseurl}}/assets/images/inspector/button-bar.png){:.centered}

| Preview | Description |
| ------- | ----------- |
| ![doc button]({{site.baseurl}}/assets/images/inspector/icons/btn-doc.png) | Opens the GdUnit documentation page in your browser |
| ![settings button]({{site.baseurl}}/assets/images/inspector/icons/btn-settings.png) | Opens the GdUnit settings window |
| ![run overall button]({{site.baseurl}}/assets/images/inspector/icons/btn-run-overall.png) | Run Overall tests |
| ![run button]({{site.baseurl}}/assets/images/inspector/icons/btn-run.png) | (Re)Run the tests in runtime mode |
| ![debug button]({{site.baseurl}}/assets/images/inspector/icons/btn-debug.png) | (Re)Run the tests in debug mode |
| ![stop button]({{site.baseurl}}/assets/images/inspector/icons/btn-stop.png) | Stops the current test run |
|  | Displays the version of GdUnit |

Note that the keyboard shortcuts for these buttons may vary depending on your specific GdUnit configuration.

### The Run Overall Button

The **Run Overall** button provides a convenient way to execute all the tests in your project at once, instead of running them one by one or selecting
a custom set of tests. By clicking the "Run Overall" button, you can initiate the execution of all the tests in your project, saving you time and effort.
![overall-button]({{site.baseurl}}/assets/images/inspector/overall-button.png){:.centered}
To enable the **Run Overall** button in GdUnit4, you need to adjust the [UI settings]({{site.baseurl}}/first_steps/settings/#ui-settings).<br>
Once you have enabled the **Run Overall** button, it should be visible in the inspector.

---

## Status Bar

This area gives you information about the current/last test execution, such as the progress, the elapsed time, and errors/failures/orphans found.<br>
With the arrow buttons, you can navigate back and forth over found failures, errors, flaky tests, skipped tests, and orphan nodes.<br>
![status-bar]({{site.baseurl}}/assets/images/inspector/status-bar.png){:.centered}

- **Indicators**

    | Preview | Description |
    | ------- | ----------- |
    | ![progress indicator]({{site.baseurl}}/assets/images/inspector/icons/count-progress.png) | Test execution progress (indicator of test run) |
    | ![error count]({{site.baseurl}}/assets/images/inspector/icons/count-error.png)   | Number of errors (parse/runtime errors) |
    | ![failure count]({{site.baseurl}}/assets/images/inspector/icons/count-failed.png)  | Number of failures                      |
    | ![flaky count]({{site.baseurl}}/assets/images/inspector/icons/count-flaky.png)   | Number of flaky tests                   |
    | ![skipped count]({{site.baseurl}}/assets/images/inspector/icons/count-skipped.png) | Number of skipped tests                 |
    | ![orphan count]({{site.baseurl}}/assets/images/inspector/icons/count-orphan.png)  | Number of detected orphan nodes         |

- **Controls**

    | Preview | Description |
    | ------- | ----------- |
    | ![rediscover tests]({{site.baseurl}}/assets/images/inspector/icons/action-refresh.png) | Rediscover tests (rescans the project for testsuites without running them) |
    | ![sort mode]({{site.baseurl}}/assets/images/inspector/icons/action-sort.png)    | Change sort tree mode (asc/desc/time)                                      |
    | ![tree presentation]({{site.baseurl}}/assets/images/inspector/icons/action-tree.png)    | Change the test tree presentation (tree/flat)                              |

- **Sorting Options**

    The sorting option controls how the test results are displayed in the inspector tree. You can sort the results by:

  - **Unsorted**: The natural order.
  - **Name Ascending**: Sorts the test cases alphabetically from A to Z.
  - **Name Descending**: Sorts the test cases alphabetically from Z to A.
  - **Test Execution Time**: Sorts the test cases based on the time they took to execute, from longest to shortest.

- **Tree Presentation**

    The tree presentation setting allows you to switch between two views:

  - **Flat View**: Displays all test cases in a single, flat list without any hierarchical structure.
  - **Tree View**: Displays test cases in a hierarchical structure, reflecting the path of your test files and suites.

---

## Test Run Overview Tree

This area provides an overview of all executed/executing tests and their execution status in real-time. Each entry shows its execution time and, when a
test was retried (for example a flaky test or a test run with
[**Run Tests Until Fail**]({{site.baseurl}}/first_steps/how-to-run-tests/#using-the-inspector-context-menu)),
the number of retries. Here, you can navigate through the tests and view the report for each individual test by selecting it. You can also run the
currently selected test or test suite again by right-clicking to open a context menu.
![test-overview]({{site.baseurl}}/assets/images/inspector/test-overview.png){:.centered}

Each test is prefixed with an icon showing its outcome:

| Icon | Meaning |
| ---- | ------- |
| ![passed icon]({{site.baseurl}}/assets/images/inspector/icons/state-success.png) | Passed |
| ![failed icon]({{site.baseurl}}/assets/images/inspector/icons/state-failed.png) | Failed (a used assert reported a mismatch) |
| ![error icon]({{site.baseurl}}/assets/images/inspector/icons/state-error.png) | Error (an unhandled runtime error or script error) |
| ![flaky icon]({{site.baseurl}}/assets/images/inspector/icons/state-flaky.png) | Flaky (failed at least once but passed on retry) |
| ![skipped icon]({{site.baseurl}}/assets/images/inspector/icons/state-skipped.png) | Skipped |
| ![orphan icon]({{site.baseurl}}/assets/images/inspector/icons/state-orphan.png) | Orphan nodes detected — shown instead of the pass/fail icon, even if the test itself passed |

{% include advice.html
content="Whats the difference between errors and failures?<br>
GdUnit distinguishes between errors and failures. An error is a hard failure such as a test abort or timeout, while a failure is a test error caused
by a failed assertion."
%}

{% include advice.html
content="Double-clicking on a test in the test run overview jumps directly to the test, or to the failing line if a failure was reported."
%}

---

## Failure Report

This area displays the failure report of the currently selected failed test.<br>
GdUnit generates the failure report based on the used assert, according to the scheme **expected** vs **current** value, followed by the full call stack
that led to the failure. Every stack frame is clickable and jumps straight to the corresponding source line.
![report]({{site.baseurl}}/assets/images/inspector/report.png){:.centered}

For tests with detected orphan nodes, this area reports differently — see
[Orphan Nodes or Leaking Memory]({{site.baseurl}}/advanced_testing/orphan/) for details.
