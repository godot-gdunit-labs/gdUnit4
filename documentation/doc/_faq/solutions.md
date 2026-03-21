---
layout: default
title: Problems & Solutions
nav_order: 10
---

# Problems & Solutions

This section lists known problems and possible solutions/workarounds.

## Problems

- [Script/Resource Errors after the plugin is installed]({{site.baseurl}}/faq/solutions/#scriptresource-errors-after-the-plugin-is-installed)
- [Modifying the Game Engine State 'mainLoop.Paused = true' during Tests]({{site.baseurl}}/faq/solutions/#modifying-the-game-engine-state-mainlooppaused--true-during-tests)
- [Export Failures with GdUnit4 Plugin Installed]({{site.baseurl}}/faq/solutions/#export-failures-with-gdunit4-plugin-installed)
- [How to Exclude Directories from Test Discovery]({{site.baseurl}}/faq/solutions/#how-to-exclude-directories-from-test-discovery)

---

### Script/Resource Errors after the plugin is installed

When installing the GdUnit4 plugin and activating it, you may encounter a lot of script and resource loading errors.
These errors occur due to a cache problem in the Godot Engine.

<h4> Solution </h4>

To solve the errors, you need to restart the Godot Editor. If this does not help, you may need to manually delete
the Godot cache folder:

1. Close the Godot Editor.
2. Delete the `.godot` folder from your working directory.
3. Start the Godot Editor (you may still see loading errors).
4. Close and restart the Godot Editor. The loading errors should no longer occur.

---

### Modifying the Game Engine State 'mainLoop.Paused = true' during Tests

When a test modifies the game engine state `Paused` on the `SceneTree`, it can affect the test execution.
Setting the main loop to paused will stop the engine running, including the test execution running in the main loop,
causing the GdUnit4 test window to remain open even after tests are complete.

<h4> Solution </h4>

When you modify engine states during tests, ensure you restore them to their previous values when the test is finished.
You can achieve this by adding an "after test" stage to your test suite.

{% tabs mainloop_paused %}
{% tab mainloop_paused GDScript %}

```ruby
# Reset the paused mode back to false after each test
func after_test() -> void:
    Engine.get_main_loop().paused = false

# Simple example test to modify the game state
func test_game_paused() -> void:
    var mainLoop :SceneTree = Engine.get_main_loop()

    assert_that(mainLoop.paused).is_false()
    # The following lines cause the GdUnit4 test window to remain open even after tests are complete
    mainLoop.paused = true
    assert_that(mainLoop.paused).is_true()
```

{% endtab %}
{% tab mainloop_paused C# %}

```cs
// Reset the paused mode back to false after each test
[AfterTest]
public void TearDown() =>
    ((SceneTree)Engine.GetMainLoop()).Paused = false;


[TestCase]
public void GamePaused()
{
    var mainLoop = (SceneTree)Engine.GetMainLoop();

    AssertThat(mainLoop.Paused).IsFalse();

    // The following lines cause the GdUnit4 test window to remain open even after tests are complete
    mainLoop.Paused = true;
    AssertThat(mainLoop.Paused).IsTrue();
}
```

{% endtab %}
{% endtabs %}

---

### Export Failures with GdUnit4 Plugin Installed

When exporting games with the GdUnit4 plugin installed, you may encounter crashes during the export process,
particularly in CI/CD environments.
The crash typically shows a "Program crashed with signal 11" error and occurs because Godot has issues when exporting
projects that include editor-only plugins like GdUnit4.

<h4> Solution </h4>

The recommended solution is to **exclude the GdUnit4 addon from the export** rather than disabling the plugin entirely.
This allows you to keep the plugin active for development while ensuring clean exports.

<b>Exclude GdUnit4 from Export Settings</b>

1. Open your project in the Godot Editor
2. Go to **Project > Export...**
3. Select your export preset (e.g., "Windows Desktop", "macOS", etc.)
4. In the **Resources** tab, locate the **Filters to exclude files/folders from project** section
5. Add the following filter to exclude the GdUnit4 addon:
   ```shell
   addons/gdunit4/*
   ```
   ![export-excludes]({{site.baseurl}}/assets/images/faq/export-excludes.png)
6. Export your game - the crash should no longer occur

**Important Notes:**

- The export exclusion method is preferred over disabling the plugin because it keeps GdUnit4 functional
  during development
- The GdUnit4 addon is designed for development and testing environments and should not be included in production builds
- After applying the exclusion filters, test your export to ensure it works correctly

---

### How to Exclude Directories from Test Discovery

When your project contains directories that should not be scanned for tests — such as third-party plugins,
subprojects, or generated content — you can prevent GdUnit4 from scanning them by placing a `.gdignore` file
in those directories.

GdUnit4's test discovery scanner respects `.gdignore` files the same way Godot does: any directory containing
a `.gdignore` file is skipped entirely during the scan.

<h4> Solution </h4>

Create an empty `.gdignore` file in any directory you want to exclude from test discovery:

```shell
touch addons/some_other_plugin/.gdignore
```

GdUnit4 will no longer scan that directory or any of its subdirectories for test suites.
