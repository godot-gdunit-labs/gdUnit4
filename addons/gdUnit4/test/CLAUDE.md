# Testing Requirements

Every code change must be accompanied by new or updated tests. Tests live under `addons/gdUnit4/test/` and mirror
the `src/` structure (e.g. `src/core/Foo.gd` → `test/core/FooTest.gd`).

## GdUnit4 Fluent Syntax

All GDScript tests must use the GdUnit4 fluent assertion API. Do **not** use plain `assert()`.

**Test suite skeleton:**

```gdscript
class_name MyFeatureTest
extends GdUnitTestSuite


const __source = "res://addons/gdUnit4/src/path/to/MyFeature.gd"


# optional lifecycle hooks
func before_test() -> void:
    pass

func after_test() -> void:
    pass
```

**Test section grouping — use `#region` / `#endregion`:**

Group related test functions into named regions instead of comment dividers.
Every region must have a matching `#endregion`:

```gdscript
#region is_equal
func test_is_equal_same_value() -> void:
    assert_int(1).is_equal(1)

func test_is_equal_different_value_fails() -> void:
    assert_failure(func() -> void: assert_int(1).is_equal(2)) \
        .is_failed()
#endregion

#region has_size
func test_has_size() -> void:
    assert_array([1, 2, 3]).has_size(3)
#endregion
```

**Core assert functions and chaining:**

```gdscript
# Primitives
assert_bool(value).is_true()
assert_bool(value).is_false()

assert_int(value).is_equal(42)
assert_int(value).is_not_equal(0)
assert_int(value).is_greater(10).is_less(100)

assert_float(value).is_equal_approx(3.14, 0.001)

assert_str(value).is_equal("expected")
assert_str(value).is_not_null().has_length(5).starts_with("ab").ends_with("cd").contains("bc")
assert_str(value).is_empty()

# Objects / variants
assert_object(value).is_not_null()
assert_object(value).is_instanceof(MyClass)
assert_that(value).is_null()
assert_that(value).is_equal(expected)
assert_that(value).is_instanceof(Node)

# Arrays
assert_array(value).is_not_empty()
assert_array(value).has_size(3).contains(1, 2)
assert_array(value).contains_exactly(1, 2, 3)

# Dictionaries
assert_dict(value).is_not_empty()
assert_dict(value).contains_key("foo")
assert_dict(value).contains_key_value("foo", "bar")
assert_dict(value).has_size(3).contains_key_value("foo", "bar")
```

**Testing expected failures:**

```gdscript
assert_failure(func() -> void: assert_str("abc").is_equal("xyz")) \
    .is_failed() \
    .has_message("Expecting:\n 'xyz'\n but was\n 'abc'")

assert_failure(func() -> void: assert_str("abc").is_null()) \
    .is_failed() \
    .starts_with_message("Expecting: '<null>'")
```

**Mocking and spying:**

```gdscript
var mock :Variant = mock(MyClass)
when(mock.my_method(any_int())).thenReturn(42)
verify(mock).my_method(42)
verify(mock, times(2)).my_method(any_int())
```

**Scene runner:**

```gdscript
var runner := scene_runner("res://my_scene.tscn")
await runner.simulate_frames(10)
assert_signal(runner).is_emitted("my_signal")
runner.simulate_key_pressed(KEY_ENTER)
```

**Auto-free resources:**

```gdscript
var node := auto_free(MyNode.new())   # freed after test automatically
```
