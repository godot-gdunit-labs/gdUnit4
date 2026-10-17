---
layout: default
title: Migrating from v6 to v7
nav_order: 6
---

# Migrating from v6 to v7

GdUnit4 v7 requires at least **Godot 4.7** and removes the API deprecated in v6.
This page lists every change you have to apply to your project and your tests when upgrading from v6, each with a before and after example.

The C# API is provided by [gdUnit4Net](https://github.com/godot-gdunit-labs/gdUnit4Net){:target="_blank"}, please check its release notes for C# related changes.

## Godot 4.7 Is Required

GdUnit4 v7 requires at least **Godot 4.7**. Upgrade your project to Godot 4.7 or newer before you install GdUnit4 v7.
If you have to stay on an older Godot version, use GdUnit4 v6, see the
[Compatibility Overview](https://github.com/godot-gdunit-labs/gdUnit4#compatibility-overview){:target="_blank"}.

### The `inferred_declaration` Warning

When the GDScript warning `inferred_declaration` is set to `Warning` or `Error`, GdUnit4 requires that the plugin directory is excluded from the warnings.
GdUnit4 v7 only checks the Godot project setting `debug/gdscript/warnings/directory_rules`, the old setting `debug/gdscript/warnings/exclude_addons` is no longer
supported by Godot 4.7. Add a directory rule that excludes `res://addons/gdUnit4` to the project settings.

## Removed Key Modifier Arguments

The deprecated `shift_pressed` and `ctrl_pressed` arguments of the scene runner key functions are removed.
Simulate the modifier as its own key instead, it stays pressed until you release it.

```gd
# v6
runner.simulate_key_pressed(KEY_A, true)

# v7
runner.simulate_key_press(KEY_SHIFT)
await runner.simulate_key_pressed(KEY_A)
runner.simulate_key_release(KEY_SHIFT)
```

The change applies to `simulate_key_pressed`, `simulate_key_press` and `simulate_key_release`,
see [Keyboard Input]({{site.baseurl}}/advanced_testing/scene_runner/keys/) for more details.

## Removed `checked()` on Mocks

The deprecated `checked()` function to stub a mocked function is removed, use `on()` instead.

```gd
# v6
do_return(true).checked(mocked_node).is_inside_tree()

# v7
do_return(true).on(mocked_node).is_inside_tree()
```

## Renamed `any_quat()`

The argument matcher `any_quat()` is renamed to `any_quaternion()` to match the Godot 4 type `Quaternion`.

```gd
# v6
verify(mocked_node).set_quaternion(any_quat())

# v7
verify(mocked_node).set_quaternion(any_quaternion())
```

## Removed `error_as_string()`

The test suite function `error_as_string()` is removed, use the Godot function `error_string()` instead.

```gd
# v6
var message := error_as_string(ERR_FILE_NOT_FOUND)

# v7
var message := error_string(ERR_FILE_NOT_FOUND)
```

## Test Suite Template

New test suites created from the default GDScript template no longer contain the `const __source` declaration.
Your existing test suites are not affected, GdUnit4 does not use the declaration, so you can remove it.
