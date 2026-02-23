---
layout: default
title: Signals
parent: Advanced Testing
nav_order: 5
---

# Testing for Signals

With GdUnit, you can test signals in your Godot projects. GdUnit provides two tools specifically for working with signals:
`assert_signal()` and `monitor_signals()`.<br>
By using these tools, you can test the emission of signals in your Godot projects and ensure that the correct signals are being sent and received.

## Verify Signals

The `assert_signal()` an Assertion Tool to verify for emitted signals until a certain time. When the timeout is reached,
the assertion fails with a timeout error.<br>
For more details show [assert_signal]({{site.baseurl}}/testing/assert-signal/#signal-assertions)

Since **v6.1**, `is_emitted()` and `is_not_emitted()` accept signal arguments as **variadic parameters**
instead of an array, and `signal_name` accepts either a **`Signal` reference** (type-safe, recommended)
or a **`String`**.

Here's an example of using `assert_signal()`:

{% tabs assert_signal %}
{% tab assert_signal GdScript %}
```gd
extends GdUnitTestSuite

class TestEmitter extends Node:
    signal test_signal_counted(value)
    signal test_signal()
    signal test_signal_unused()

    var _trigger_count :int
    var _count := 0

    func _init(trigger_count := 10):
        _trigger_count = trigger_count

    func _process(_delta):
        if _count >= _trigger_count:
            test_signal_counted.emit(_count)

        if _count == 20:
            test_signal.emit()
        _count += 1


var signal_emitter :TestEmitter


func before_test():
    signal_emitter = auto_free(TestEmitter.new())
    add_child(signal_emitter)


func test_signal_emitted() -> void:
    # wait until signal 'test_signal' is emitted — using a Signal reference (type-safe, recommended)
    await assert_signal(signal_emitter).is_emitted(signal_emitter.test_signal)
    # or using a String name
    await assert_signal(signal_emitter).is_emitted("test_signal")


func test_signal_is_emitted_with_args() -> void:
    # wait until 'test_signal_counted' is emitted with value 20 (variadic args since v6.1)
    await assert_signal(signal_emitter).is_emitted(signal_emitter.test_signal_counted, 20)


func test_signal_is_not_emitted() -> void:
    # wait to verify signal 'test_signal_counted()' is not emitted until the first 50ms
    await assert_signal(signal_emitter).wait_until(50).is_not_emitted(signal_emitter.test_signal_counted)


func test_is_signal_exists() -> void:
    var node :Node2D = auto_free(Node2D.new())

    assert_signal(node).is_signal_exists("visibility_changed")\
        .is_signal_exists("draw")\
        .is_signal_exists("visibility_changed")\
        .is_signal_exists("tree_entered")\
        .is_signal_exists("tree_exiting")\
        .is_signal_exists("tree_exited")

```
{% endtab %}
{% tab assert_signal C# %}
```cs
using System.Threading.Tasks;

using GdUnit4.Asserts;
using GdUnit4.Core.Signals;

using static Assertions;

[TestSuite]
public partial class SignalAssertTest
{
    private sealed partial class TestEmitter : Godot.Node
    {
        [Godot.Signal]
        public delegate void SignalAEventHandler();

        [Godot.Signal]
        public delegate void SignalBEventHandler(string value);

        [Godot.Signal]
        public delegate void SignalCEventHandler(string value, int count);

        private int frame;

        public override void _Process(double delta)
        {
            switch (frame)
            {
                case 5:
                    EmitSignal(SignalName.SignalA);
                    break;
                case 10:
                    EmitSignal(SignalName.SignalB, "abc");
                    break;
                case 15:
                    EmitSignal(SignalName.SignalC, "abc", 100);
                    break;
            }
            frame++;
        }
    }

    [TestCase]
    public async Task IsEmitted()
    {
        var node = AutoFree(new TestEmitter())!;
        await AssertSignal(node).IsEmitted("SignalA").WithTimeout(200);
        await AssertSignal(node).IsEmitted("SignalB", "abc").WithTimeout(200);
        await AssertSignal(node).IsEmitted("SignalC", "abc", 100).WithTimeout(200);
    }

    [TestCase]
    public async Task IsNoEmitted()
    {
        var node = AddNode(new Godot.Node2D());
        await AssertSignal(node).IsNotEmitted("visibility_changed", 10).WithTimeout(100);
    }

    [TestCase]
    public void IsSignalExists()
    {
        var node = AutoFree(new Godot.Node2D())!;

        AssertSignal(node).IsSignalExists("visibility_changed")
            .IsSignalExists("draw")
            .IsSignalExists("visibility_changed")
            .IsSignalExists("tree_entered")
            .IsSignalExists("tree_exiting")
            .IsSignalExists("tree_exited");
    }
}
```
{% endtab %}
{% endtabs %}

## Monitor Signals

The `monitor_signals()` tool allows you to monitor the emission of signals from a specific object.
It sets up a signal monitoring system for the specified object, which enables you to capture and analyze the signals emitted during the execution of your test.

{% tabs monitor_signals-overview %}
{% tab monitor_signals-overview GdScript %}
```gd
    func monitor_signals(source :Object, _auto_free := true) -> Object:
```
{% endtab %}
{% tab monitor_signals-overview C# %}
In C#, the monitor is integrated into the AssertSignal and is generated implicitly the first time an assertion is used on an emitter.
To visualize this better, you can use StartMonitoring. From this point on, all emitted signals are recorded.
```cs
    /// <summary>
    /// Starts the monitoring of emitted signals during the test runtime.
    /// It should be called first if you want to collect all emitted signals after the emitter has been created.
    /// </summary>
    /// <returns></returns>
    public ISignalAssert StartMonitoring();
```
{% endtab %}
{% endtabs %}

Here's an example of using signal monitors.

{% tabs monitor_signals-example %}
{% tab monitor_signals-example GdScript %}
```gd
extends GdUnitTestSuite

class MyEmitter extends Node:

    signal my_signal_a
    signal my_signal_b(value :String)

    func do_emit_a() -> void:
        my_signal_a.emit()

    func do_emit_b() -> void:
        my_signal_b.emit("foo")


func test_monitor_signals() -> void:
    # start monitoring on the emitter to collect all emitted signals
    # use typed variables to enable Signal reference syntax (since v6.1)
    var emitter_a: MyEmitter = monitor_signals(MyEmitter.new())
    var emitter_b: MyEmitter = monitor_signals(MyEmitter.new())

    # verify the signals are not emitted initial
    await assert_signal(emitter_a).wait_until(50).is_not_emitted(emitter_a.my_signal_a)
    await assert_signal(emitter_a).wait_until(50).is_not_emitted(emitter_a.my_signal_b)
    await assert_signal(emitter_b).wait_until(50).is_not_emitted(emitter_b.my_signal_a)
    await assert_signal(emitter_b).wait_until(50).is_not_emitted(emitter_b.my_signal_b)

    # emit signal `my_signal_a` on emitter_a
    emitter_a.do_emit_a()
    await assert_signal(emitter_a).is_emitted(emitter_a.my_signal_a)

    # emit signal `my_signal_b` on emitter_a (variadic args since v6.1)
    emitter_a.do_emit_b()
    await assert_signal(emitter_a).is_emitted(emitter_a.my_signal_b, "foo")
    # verify emitter_b still has nothing emitted
    await assert_signal(emitter_b).wait_until(50).is_not_emitted(emitter_b.my_signal_a)
    await assert_signal(emitter_b).wait_until(50).is_not_emitted(emitter_b.my_signal_b)

    # now verify emitter b
    emitter_b.do_emit_a()
    await assert_signal(emitter_b).wait_until(50).is_emitted(emitter_b.my_signal_a)

```

{% endtab %}
{% tab monitor_signals-example C# %}
```cs
using System.Threading.Tasks;

using GdUnit4.Asserts;
using GdUnit4.Core.Signals;

using static Assertions;

[TestSuite]
public partial class SignalAssertTest
{
    public sealed partial class MyEmitter : Godot.Node {

        [Godot.Signal]
        public delegate void SignalAEventHandler();

        [Godot.Signal]
        public delegate void SignalBEventHandler(string value);

        public void DoEmitSignalA() => EmitSignal(SignalName.SignalA);

        public void DoEmitSignalB() => EmitSignal(SignalName.SignalB, "foo");
    }

    [TestCase(Timeout = 1000)]
    public async Task MonitorOnSignal()
    {
        var emitterA = AutoFree(new MyEmitter())!;
        var emitterB = AutoFree(new MyEmitter())!;

        // verify initial the emitters are not monitored
        AssertThat(GodotSignalCollector.Instance.IsSignalCollecting(emitterA, MyEmitter.SignalName.SignalA)).IsFalse();
        AssertThat(GodotSignalCollector.Instance.IsSignalCollecting(emitterA, MyEmitter.SignalName.SignalB)).IsFalse();
        AssertThat(GodotSignalCollector.Instance.IsSignalCollecting(emitterB, MyEmitter.SignalName.SignalA)).IsFalse();
        AssertThat(GodotSignalCollector.Instance.IsSignalCollecting(emitterB, MyEmitter.SignalName.SignalB)).IsFalse();

        // start monitoring on the emitter A
        AssertSignal(emitterA).StartMonitoring();
        // verify the emitters are now monitored
        AssertThat(GodotSignalCollector.Instance.IsSignalCollecting(emitterA, MyEmitter.SignalName.SignalA)).IsTrue();
        AssertThat(GodotSignalCollector.Instance.IsSignalCollecting(emitterA, MyEmitter.SignalName.SignalB)).IsTrue();
        AssertThat(GodotSignalCollector.Instance.IsSignalCollecting(emitterB, MyEmitter.SignalName.SignalA)).IsFalse();
        AssertThat(GodotSignalCollector.Instance.IsSignalCollecting(emitterB, MyEmitter.SignalName.SignalB)).IsFalse();

        // verify the signals are not emitted initial
        await AssertSignal(emitterA).IsNotEmitted(MyEmitter.SignalName.SignalA).WithTimeout(50);
        await AssertSignal(emitterA).IsNotEmitted(MyEmitter.SignalName.SignalB).WithTimeout(50);
        await AssertSignal(emitterB).IsNotEmitted(MyEmitter.SignalName.SignalA).WithTimeout(50);
        await AssertSignal(emitterB).IsNotEmitted(MyEmitter.SignalName.SignalB).WithTimeout(50);

        // emit signal `signal_a` on emitter_a
        emitterA.DoEmitSignalA();
        await AssertSignal(emitterA).IsEmitted(MyEmitter.SignalName.SignalA).WithTimeout(50);

        // emit signal `my_signal_b` on emitter_a
        emitterA.DoEmitSignalB();
        await AssertSignal(emitterA).IsEmitted(MyEmitter.SignalName.SignalB, "foo").WithTimeout(50);
        // verify emitter_b still has nothing emitted
        await AssertSignal(emitterB).IsNotEmitted(MyEmitter.SignalName.SignalA).WithTimeout(50);
        await AssertSignal(emitterB).IsNotEmitted(MyEmitter.SignalName.SignalB).WithTimeout(50);

        // now verify emitter b
        emitterB.DoEmitSignalA();
        await AssertSignal(emitterB).IsEmitted(MyEmitter.SignalName.SignalA).WithTimeout(50);
    }
}
```
{% endtab %}
{% endtabs %}
