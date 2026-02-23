---
layout: default
title: Run Tests
nav_order: 3
---

# How to Run Test

Running tests in GdUnit is a straightforward process, and you have several options to choose from:

## Using the GdUnit Inspector

The GdUnit Inspector provides various options to run single unit tests or sets of testsuites:

- **Using the Button Bar**: You can use the buttons available in the GdUnit Inspector's to run tests.<br>
Refer to the [Using the Button Bar](#button-bar) section for more details.

- **Using the Inspector Tree**: The Inspector Tree allows you to run tests from a hierarchical view.<br>
Explore the [Using the Inspector Tree](#test-run-overview-tree) section for instructions on running tests using this approach.

- **Using the Run Overall Button**: The **Run Overall** button enables you to run all tests at once.<br>
Find more information in the [Using the Run Overall Button](#the-run-overall-button) section.

## Using the Editor Context Menu

The Editor Context Menu provides options to run or debug individual test cases or entire testsuites:

- **Using the Context Menu**: You can right-click on a specific test case or testsuite in the editor and select the appropriate option from the context menu.

For detailed steps, refer to the [Using the Context Menu]({{site.baseurl}}/first_steps/getting-started/#execute-your-test) section.

## Using the FileSystem Context Menu

The FileSystem Context Menu allows you to run or debug individual testsuites or sets of testsuites by selecting the desired testsuite or folder:

![FileSystem Context Menu]({{site.baseurl}}/assets/images/inspector/run-test-filesystem.png){:.centered}

These options provide flexibility in running tests based on your preferences and requirements.

## Using the Inspector Context Menu

The Inspector Context Menu provides options to run, debug, or manage the selected test or test suite directly from the Test Run Overview Tree.
Right-click any item in the tree to open the context menu.

![inspector-context-menu]({{site.baseurl}}/assets/images/inspector/inspector-context-menu.png){:.centered}

| Command | Description |
| ------- | ----------- |
| **Run Tests** | Runs the selected test or test suite in runtime mode. |
| **Debug Tests** | Runs the selected test or test suite in debug mode. |
| **Run Tests Until Fail** | Repeatedly runs the selected test or test suite until a failure occurs. Useful for investigating flaky tests. The number of retries is configured via [Rerun Until Failure Retries]({{site.baseurl}}/first_steps/settings/#test-settings) in settings. |
| **Expand All** | Expands all nodes in the test run overview tree. |
| **Collapse All** | Collapses all nodes in the test run overview tree. |

## The GdUnit Test Inspector/Explorer

### Definition

The GdUnit inspector provides an overview of the currently executed tests and allows you to navigate them.
It allows you to select individual tests and view possible test failures. The integrated status and info bar gives you a quick overview of the last test run.

![]({{site.baseurl}}/assets/images/inspector/inspector.png){:.centered}

- [(1) Button Bar](#button-bar)
- [(2) Status Bar](#status-bar)
- [(3) Test Run Overview](#test-run-overview-tree)
- [(4) Failure Report](#failure-report)
- [(5) Info Bar](#info-bar)

---

### Button Bar

The button bar contains several buttons that allow you to perform different actions in GdUnit:
![]({{site.baseurl}}/assets/images/inspector/button-bar.png){:.centered}

|Button|Description|
|--- | --- |
|(1)| Opens the GdUnit documentation page in your browser |
|(2)| Opens the GdUnit settings window |
|(3)| Run Overall tests |
|(4)| (Re)Run the tests in runtime mode |
|(5)| (Re)Run the tests in debug mode |
|(6)| Stops the current test run |
|(7)| Displays the version of GdUnit |

Note that the keyboard shortcuts for these buttons may vary depending on your specific GdUnit configuration.

{% include advice.html
content="When running tests in GdUnit, it is recommended to first run them in debug mode (4) in order to get the line number where the failure occurred
in the test report. This is because Godot does not provide stack trace information when running in runtime mode (3),
which can result in the failure line not being displayed in the report."
%}

#### The Run Overall Button

The **Run Overall** button provides a convenient way to execute all the tests in your project at once, instead of running them one by one or selecting
a custom set of tests. By clicking the "Run Overall" button, you can initiate the execution of all the tests in your project, saving you time and effort.
![overall-button]({{site.baseurl}}/assets/images/inspector/overall-button.png){:.centered}
To enable the **Run Overall** button in GdUnit4, you need to adjust the [UI settings]({{site.baseurl}}/first_steps/settings/#ui-settings).<br>
Once you have enabled the **Run Overall** button, it should be visible in the inspector.

---

### Status Bar

This area gives you information about the current/last test execution, such as the progress and errors/failures found.<br>
With the arrow buttons, you can navigate back and forth over found failures.<br>
![status-bar]({{site.baseurl}}/assets/images/inspector/status-bar.png){:.centered}

| Marker | Description                                     |
|--------|-------------------------------------------------|
| (0)    | Test execution progress (indicator of test run) |
| (1)    | Number of errors (parse/runtime errors)         |
| (2)    | Number of failures                              |
| (3)    | Number of flaky tests                           |
| (4)    | Number of skipped tests                         |
| (5)    | Discover and run all tests                      |
| (6)    | Change sort tree mode (asc/desc/time)           |
| (7)    | Change the test tree presentation  (tree/flat)  |

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

{% include advice.html
content="Whats the difference between errors and failures?<br>
GdUnit distinguishes between errors and failures. An error is a hard failure such as a test abort or timeout, while a failure is a test error caused
by a failed assertion."
%}

---

### Test Run Overview Tree

This area provides an overview of all executed/executing tests and their execution status in real-time. Here, you can navigate through the tests and view
the report for each individual test by selecting it. You can also run the currently selected test or test suite again by right-clicking to open a context menu.
![test-overview]({{site.baseurl}}/assets/images/inspector/test-overview.png){:.centered}

{% include advice.html
content="Double-clicking on a test in the test run overview allows you to jump directly to the test or test error if a failure line was reported
in Debug Mode (4)."
%}

---

### Failure Report

This area displays the failure report of the currently selected failed test.<br>
GdUnit generates the failure report based on the used assert, according to the scheme **expected** vs **current** value.
![report]({{site.baseurl}}/assets/images/inspector/report.png){:.centered}

---

### Info Bar

This section provides you with information about the total duration of the test execution and any orphaned nodes found.<br>
![info-bar]({{site.baseurl}}/assets/images/inspector/info-bar.png){:.centered}

- **Time**<br>
    The time taken to execute all tests.
- **Orphans**<br>
     The number of nodes that were not cleaned up after the execution of the tests. Orphaned nodes can cause memory leaks, and it's essential to clean them
- up after the execution of the tests.
{% include advice.html
content="It's recommended to always check for orphaned nodes after the execution of tests to ensure there are no memory leaks in your game/application."
%}
