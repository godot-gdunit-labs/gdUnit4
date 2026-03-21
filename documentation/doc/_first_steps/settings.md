---
layout: default
title: Settings
nav_order: 2
---

# Settings

GdUnit4 provides several customizable settings to meet your testing needs.
To access these settings, simply press the 'tools' button located in the GdUnit inspector.
![inspector-settings]({{site.baseurl}}/assets/images/settings/inspector-settings.png){:.centered}

---

## Common Settings

![settings-common]({{site.baseurl}}/assets/images/settings/settings-common.png){:.centered}

* **Common**
  * **Server Connection Timeout**<br>
   The server connection timeout determines the maximum wait time in minutes for the test runner client when communication between the editor and
   runner is interrupted.

  * **Update Notification Enabled**<br>
   This option enables or disables the GdUnit update notification. If enabled, a notification will appear when starting Godot to inform you about
   new updates available for installation.

* **Test**
  * **Flaky Test**<br>
    With this setting, you can activate or deactivate the detection of faulty tests and automatically run the test again if it fails.
  
  * **Flaky Max Retries**<br>
    This setting is used to configure the number of retries that a test should perform if it fails.

  * **Rerun Until Failure Retries**<br>
    This setting configures the maximum number of times a test is rerun when using **Run Tests Until Fail** from the Inspector Context Menu.
    Once the limit is reached or a failure occurs, the run stops. The default value is **10**.

  * **Test Discovery**<br>
   This setting configures the auto-discovery of tests. If enabled, it will scan the configured Test Root Folder for available tests at startup.
   Directories containing a `.gdignore` file are excluded from test discovery,
   consistent with how Godot itself ignores those directories.

  * **Test Root Folder**<br>
   This setting defines the root folder where automated tests will be generated. By default, tests are usually located parallel to the source code in
   a folder named 'test'. However, you can customize this location by specifying a different folder path.
   The default root folder is **test**.

      ```python
      res://project/src/folder_a/folder_b/my_class.gd
      res://project/test/folder_a/folder_b/my_class_test.gd
      ```

  * **Test Suite Naming Nonvention**<br>
      Configures how to generate the test-suite file name.

      1. *AUTO_DETECT* - generates the file name by source file naming convention.
      2. *SNAKE_CASE*  - generates the file name in snake case convention.
      3. *PASCAL_CASE* - generates the file name in pascal case convention.

  * **Test Timeout Seconds**<br>
      This setting configures the default timeout for a test case in seconds. If a test case runs longer than the specified timeout, the test will be
      interrupted and fail. You can override the default timeout on a per-test-case basis by specifying a different timeout using the `timeout` argument.

{% tabs settings-timeout %}
{% tab settings-timeout GdScript %}

```gd
# Configures the test case to fail after a maximum of 2 seconds runtime
func test_foo(timeout = 2000) -> void:
...
```

{% endtab %}
{% tab settings-timeout C# %}

```cs
// Configures the test case to fail after a maximum of 2 seconds runtime
[TestCase(Timeout = 2000)]
public async Task foo() {
}
```

{% endtab %}
{% endtabs %}

---


## Hooks Settings

Configure test session hooks and reporting mechanisms for automated test lifecycle management.

![settings-hook]({{site.baseurl}}/assets/images/settings/settings-hooks.png){:.centered}

### Overview

Test session hooks execute custom logic at the beginning and end of test sessions, enabling:
- Automated test environment setup and teardown
- Custom test report generation in various formats
- Integration with external systems and CI/CD pipelines
- Resource management across multiple test suites

### Built-in System Hooks

GdUnit4 includes two pre-installed system hooks that provide essential reporting functionality:

* **GdUnitHtmlTestReporter** `SYSTEM`  
  Generates interactive HTML test reports with detailed results, execution times, and statistics. Reports include collapsible sections and visual charts for easy analysis.

* **GdUnitXMLTestReporter** `SYSTEM`  
  Produces JUnit-compatible XML reports for CI/CD integration. Compatible with Jenkins, GitLab CI, GitHub Actions, and other continuous integration tools.

### Hook Management Controls

| Control | Function | Description |
|---------|----------|-------------|
| ☑️ **Checkbox** | Enable/Disable | Toggle hook activation without removing it from the list |
| ⬆️ **Up Arrow** | Increase Priority | Move hook higher in execution order (executes earlier) |
| ⬇️ **Down Arrow** | Decrease Priority | Move hook lower in execution order (executes later) |
| ➕ **Add** | Register Hook | Add a new custom hook to the system |
| 🗑️ **Remove** | Delete Hook | Remove custom hooks (system hooks cannot be deleted) |

### Execution Order

Hooks execute in the priority order shown in the list:
1. **Startup Phase**: Hooks initialize in top-to-bottom order before tests begin
2. **Test Execution**: All test suites run if startup succeeds
3. **Shutdown Phase**: Hooks cleanup in reverse order after tests complete

### Configuration Notes

* **System hooks** are marked with a `SYSTEM` tag and cannot be removed
* **Custom hooks** can be added, removed, and reordered as needed
* **Disabled hooks** remain in the list but don't execute during test sessions
* **Hook failures** during startup prevent test execution and display errors in the console
* **Priority changes** take effect immediately for the next test session

### Status Information

The text field at the bottom displays contextual information about the selected hook, including its description and current configuration status. For system hooks, it shows "The Html test reporting hook" or "The XML test reporting hook" respectively.

---

## UI Settings

![settings-ui]({{site.baseurl}}/assets/images/settings/settings-ui.png){:.centered}

* **Inspector**
  * **Node Collapse**<br>
      By default, the testsuite node in the Inspector is collapsed after a successful test run. This option controls whether the testsuite node remains
      collapsed or expanded.
  * **Tree Sort Mode**<br>
      This setting controls the tree sorting by name in ascending or descending order, or by test execution time.
  * **Tree View Mode**<br>
      This setting controls whether the inspector tree is presented as a flat view or a tree view.

* **ToolBar**
  * **Run Overall**<br>
      This setting controls the visibility of the 'run overall' button in the inspector tool bar. By default, the button is hidden,
      but you can show or hide it as desired.

---

## Shortcuts Settings

![settings-shortcuts]({{site.baseurl}}/assets/images/settings/settings-shortcuts.png){:.centered}

* **Editor**<br>
  This section allows you to customize the keyboard shortcuts for the script editor in Godot. You can customize the shortcuts for various actions such
  as create test, run test, and debug test.

* **Filesystem**<br>
  In this section, you can customize the keyboard shortcuts for the filesystem inspector in Godot. You can customize shortcuts for various actions,
  such as running tests and debugging tests.

* **Inspector**<br>
  In this section, you can customize the keyboard shortcuts for the GdUnit inspector in Godot. You can customize shortcuts for various actions,
  such as running tests, debugging tests, running overall tests, stopping the current test run, and rerunning tests until failure.

---

## Report Settings

![settings-report]({{site.baseurl}}/assets/images/settings/settings-report.png){:.centered}

* **Asserts**
  * **Strict Number Type Compare**<br>
   This setting controls how numbers are compared in GdUnit. By default, GdUnit performs a type-safe comparison and will always fail if you compare an
   integer with a floating-point number, even if they have the same value. To allow equal values, such as `0` and `0.0`, you can turn off this configuration.

  * **Verbose Errors**<br>
   This setting suppresses internal error reporting for failed assert conditions in GdUnit. When an assert condition fails, GdUnit normally generates an
   error message to indicate the failure. By enabling this setting, you can suppress these error messages, which can be useful in certain testing
   scenarios where error reporting is not necessary or desired.

  * **Verbose Warnings**<br>
   This setting suppresses internal warning reporting for failed assert conditions in GdUnit. When an assert condition fails, GdUnit normally generates
   a warning message to indicate the failure. By enabling this setting, you can suppress these warning messages, which can be useful in certain testing
   scenarios where warning reporting is not necessary or desired.

* **Godot**
  * **Push Error**<br>
   This setting reports Godot push_error() notifications in GdUnit and causes the test to fail (by default, this setting is disabled).
   When Godot encounters an error condition, it can generate a push_error() notification to indicate the error.
   By enabling this setting, you can capture these notifications in GdUnit and cause the associated test to fail.
   This can be useful in certain testing scenarios where error reporting is critical.

  * **Script Error**<br>
   This setting reports Godot gdscript errors in GdUnit and causes the associated test to fail. When Godot encounters an error in a gdscript file,
   such as a syntax error or a runtime error, GdUnit can capture the error and cause the associated test to fail.
   By enabling this setting, you can ensure that errors in gdscript files are detected and reported in your tests.

* **Common**
  * **Verbose Orphans**<br>
   This setting enables or disables orphan node reporting in GdUnit. When this setting is enabled, GdUnit will report any nodes in your project that are
   not referenced by any other nodes or resources. These orphan nodes can indicate unused or unnecessary content in your project,
   which can be helpful in optimizing your project. By disabling this setting, you can suppress the reporting of orphan nodes,
   which can be useful in certain testing scenarios where orphan node reporting is not necessary or desired.

---

## Templates Settings

When creating a new test-case in GdUnit, you can use this template to generate your test-suite.
To do this, simply right-click on the desired function you want to test and select 'Create Test' from the context menu.
This will generate a new test-case using the default template, which you can customize to suit your testing needs.

![settings-template]({{site.baseurl}}/assets/images/settings/settings-template.png){:.centered}

To personalize your test-suite template in GdUnit, you can use the provided tags to modify it according to your needs.<br>
These tags allow you to add custom placeholders and data fields to your test-suite, making them more informative and easier to manage.
To view a list of all the supported tags, simply click on the **Supported Tags** button in the template page.
![settings-template-editor-tags]({{site.baseurl}}/assets/images/settings/settings-template-editor-tags.png){:.centered}

---

## Updates

The Updates section provides automatic update management for GdUnit4 by monitoring the GitHub repository for new releases.

![settings-update]({{site.baseurl}}/assets/images/settings/settings-update.png){:.centered}

* **Update Notification**<br>
  When a new version of GdUnit4 is available on GitHub, the Updates tab will display a yellow bell icon to notify you of the available update.
  This visual indicator makes it easy to spot when updates are ready for installation.
  The update notification is enabled by default but can be manually disabled in the Common settings section if you prefer not to receive update notifications.

* **Release Notes**<br>
  The Updates section displays the complete release notes for the new version, allowing you to review what changes, bug fixes, and new features are
  included before deciding to update. This helps you understand what improvements or potential breaking changes the update may introduce.

* **Update Installation**<br>
  To install the new version, simply click the **Update** button. The update process will:
    1. Download the latest version from the GitHub repository
    2. Replace the currently installed GdUnit4 plugin with the new version
    3. Automatically restart Godot after the installation is complete

* **Technical Details**<br>
  The update system works by checking the GitHub releases API for new versions during Godot startup.
  When a newer version is detected compared to your currently installed version, the notification system activates and the update becomes available for installation.
