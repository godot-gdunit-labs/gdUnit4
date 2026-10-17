---
layout: default
title: Session Hooks
parent: Advanced Testing
nav_order: 2
---

# Testing with Hooks

Test hooks provide powerful extension points in GdUnit4 that allow you to execute custom logic at specific moments during the test lifecycle. They enable sophisticated test environment management, custom reporting, and integration with external systems.

## What are Test Hooks?

Test hooks are classes that extend `GdUnitTestSessionHook` and implement methods that run at the beginning and end of test sessions. Unlike test fixtures (`before` and `after` methods) that run for individual tests, hooks operate at the session level, making them ideal for:

- Setting up and tearing down shared test environments
- Managing database connections or external services
- Generating custom test reports
- Implementing test metrics and monitoring
- Integrating with CI/CD pipelines

## Hook Lifecycle

Understanding when hooks execute is crucial for proper implementation:

![Execution Graph]({{site.baseurl}}/assets/images/hooks/hook-lifecycle-diagram.svg){:.centered}

## GdUnitTestSessionHook API

Every custom hook must extend `GdUnitTestSessionHook` and implement two key methods:

{% tabs basic-hook %}
{% tab basic-hook GdScript %}
```gdscript
class_name MyCustomHook
extends GdUnitTestSessionHook

func _init():
    super("MyCustomHook", "Description of what this hook does")

func startup(session: GdUnitTestSession) -> GdUnitResult:
    # Initialize resources before tests run
    ...
    
    # Send status messages through GdUnit messaging system
    session.send_message("Custom hook initialized")
    
    # Return success or error
    return GdUnitResult.success()

func shutdown(session: GdUnitTestSession) -> GdUnitResult:
    # Clean up resources after tests complete
    ...
    
    # Send cleanup status
    session.send_message("Custom hook cleanup completed")
    
    return GdUnitResult.success()
```
{% endtab %}
{% tab basic-hook C# %}

{% include advice.html
content="The GdUnitTestSessionHook is current not implemented and will be released with gdUnit4.api v5.1.0"
%}

```csharp
using GdUnit4;
using Godot;

public class MyCustomHook : GdUnitTestSessionHook
{
    public MyCustomHook() 
        : base("MyCustomHook", "Description of what this hook does")
    {
    }

    public override GdUnitResult Startup(GdUnitTestSession session)
    {
        // Initialize resources before tests run
        ...
        
        // Send status messages through GdUnit messaging system
        session.SendMessage("Custom hook initialized");
        
        // Return success or error
        return GdUnitResult.Success();
    }

    public override GdUnitResult Shutdown(GdUnitTestSession session)
    {
        // Clean up resources after tests complete
        ...
        
        // Send cleanup status
        session.SendMessage("Custom hook cleanup completed");
        
        return GdUnitResult.Success();
    }
}
```
{% endtab %}
{% endtabs %}


## GdUnitTestSession API

The `GdUnitTestSession` object passed to your hooks provides several useful properties and methods:

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `report_path` | `String` | File system path where test reports will be generated |

### Methods

| Method | Description |
|--------|-------------|
| `test_count()` | Returns the number of test cases to be executed |
| `send_message(message: String)` | Sends a message through the GdUnit messaging system |
| `find_test_by_id(id: GdUnitGUID)` | Finds a test case by its unique identifier |

### Signals

| Signal | Description |
|--------|-------------|
| `test_event(event: GdUnitEvent)` | Emitted when test execution events occur |



## Practical Examples

### Example 1: Database Test Hook

This example shows how to set up and tear down a test database for integration testing:

{% tabs database-example %}
{% tab database-example GdScript %}
```gdscript
class_name DatabaseTestHook
extends GdUnitTestSessionHook

var db_connection

func _init():
    super("DatabaseTestHook", "Manages test database lifecycle")

func startup(session: GdUnitTestSession) -> GdUnitResult:
    session.send_message("Creating test database: %s" % test_db_name)
    
    # Connect to database server
    db_connection = DatabaseManager.connect_to_server({
        "host": "localhost",
        "port": 5432,
        "user": "test_user",
        "password": "test_password"
    })
    
    if not db_connection:
        return GdUnitResult.error("Failed to connect to database server")
    
    # Create test database
    if not db_connection.create_database("test_db_name"):
        return GdUnitResult.error("Failed to create test database")
    
    
    session.send_message("Test database ready")
    return GdUnitResult.success()

func shutdown(session: GdUnitTestSession) -> GdUnitResult:
    session.send_message("Cleaning up test database")
    
    if db_connection:
        # Drop test database
        db_connection.drop_database("test_db_name")
        db_connection.disconnect()
        
    session.send_message("Database cleanup completed")
    return GdUnitResult.success()
```
{% endtab %}
{% endtabs %}

### Example 2: Performance Monitoring Hook

This example tracks test execution performance and generates a report:

{% tabs performance-example %}
{% tab performance-example GdScript %}
```gdscript
class_name PerformanceMonitorHook
extends GdUnitTestSessionHook

var start_time: int
var test_metrics: Dictionary = {}
var current_suite: String = ""

func _init():
    super("PerformanceMonitor", "Tracks test execution metrics")

func startup(session: GdUnitTestSession) -> GdUnitResult:
    start_time = Time.get_ticks_msec()
    
    # Subscribe to test events
    session.test_event.connect(_on_test_event)
    
    session.send_message("Performance monitoring started for %d test cases" % session.test_count())
    return GdUnitResult.success()

func shutdown(session: GdUnitTestSession) -> GdUnitResult:
    var total_time = Time.get_ticks_msec() - start_time
    
    # Generate performance report
    var report = _generate_report(total_time)
    
    # Save report in the same directory as test reports
    var report_dir = session.report_path.get_base_dir()
    var perf_report_path = report_dir.path_join("performance_metrics.json")
    
    var file = FileAccess.open(perf_report_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(report))
        file.close()
        session.send_message("Performance report saved to: %s" % perf_report_path)
    
    return GdUnitResult.success()

func _on_test_event(event: GdUnitEvent) -> void:
    match event.type:
        GdUnitEvent.TESTSUITE_BEFORE:
            current_suite = event.suite_name
            test_metrics[current_suite] = {
                "start_time": Time.get_ticks_msec(),
                "tests": {}
            }
        
        GdUnitEvent.TESTCASE_AFTER:
            if current_suite in test_metrics:
                test_metrics[current_suite]["tests"][event.test_name] = {
                    "duration": event.elapsed_time,
                    "status": "passed" if event.is_success else "failed"
                }

func _generate_report(total_time: int) -> Dictionary:
    return {
        "total_duration_ms": total_time,
        "suites": test_metrics,
        "timestamp": Time.get_datetime_string_from_system()
    }
```
{% endtab %}
{% endtabs %}


## Registering Hooks

To use your custom hooks, you need to register them in the GdUnit4 settings:

1. Open the **GdUnit4 Settings** (Tools button in the GdUnit Inspector)
   ![inspector-settings]({{site.baseurl}}/assets/images/settings/inspector-settings.png){:.centered}
2. Navigate to the Hooks tab
![settings-hook]({{site.baseurl}}/assets/images/settings/settings-hooks.png){:.centered}
3. Click the **+ (Add)** button
4. Select your hook class file
5. Enable the hook using the checkbox
6. Adjust priority if needed using the arrow buttons

## Best Practices

### Error Handling

Always return appropriate `GdUnitResult` values to indicate success or failure:

```gdscript
func startup(session: GdUnitTestSession) -> GdUnitResult:
    if not initialize_resources():
        return GdUnitResult.error("Failed to initialize resources: %s" % get_last_error())
    
    if not validate_configuration():
        return GdUnitResult.error("Invalid configuration: missing required settings")
    
    session.send_message("All systems initialized successfully")
    return GdUnitResult.success()
```

### Resource Management

Ensure proper cleanup in the shutdown method, even if startup failed:

```gdscript
func shutdown(session: GdUnitTestSession) -> GdUnitResult:
    var errors = []
    
    # Always attempt cleanup, regardless of startup success
    if resource_a:
        if not resource_a.cleanup():
            errors.append("Failed to cleanup resource_a")
        resource_a = null
    
    
    if errors.is_empty():
        return GdUnitResult.success()
    else:
        return GdUnitResult.error(", ".join(errors))
```

### Session Communication

Use the session object effectively for communication and event handling:

```gdscript
func startup(session: GdUnitTestSession) -> GdUnitResult:
    # Send informational messages
    session.send_message("Initializing test environment...")
    
    # Access test configuration
    var test_count = session.test_count()
    session.send_message("Preparing to run %d test cases" % test_count)
    
    # Use report path for output files
    var report_dir = session.report_path.get_base_dir()
    session.send_message("Reports will be saved to: %s" % report_dir)
    
    # Subscribe to test events
    session.test_event.connect(_on_test_event)
    
    return GdUnitResult.success()

func _on_test_event(event: GdUnitEvent) -> void:
    # React to different event types
    match event.type:
        GdUnitEvent.INIT:
            print("Test runner initialized")
        GdUnitEvent.TESTSUITE_BEFORE:
            print("Starting suite: %s" % event.suite_name)
        GdUnitEvent.TESTCASE_BEFORE:
            print("Starting test: %s" % event.test_name)
        GdUnitEvent.TESTCASE_AFTER:
            print("Finished test: %s (success: %s)" % [event.test_name, event.is_success])
        GdUnitEvent.TESTSUITE_AFTER:
            print("Finished suite: %s" % event.suite_name)
        GdUnitEvent.STOP:
            print("Test execution stopped")
```

## System Hooks

GdUnit4 includes built-in system hooks that cannot be removed:

### GdUnitHtmlTestReporter
Extends `GdUnitBaseReporterTestSessionHook` to generate interactive HTML test reports with:
- Detailed test results and execution times
- Collapsible sections for easy navigation
- Visual charts and statistics
- Failure details with stack traces

### GdUnitXMLTestReporter
Extends `GdUnitBaseReporterTestSessionHook` to generate JUnit-compatible XML reports for:
- CI/CD pipeline integration
- Test result aggregation tools
- Automated build systems

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Hook not executing | Ensure the hook is enabled in settings and the class extends `GdUnitTestSessionHook` |
| Startup failures | Check console output for error messages; startup must return `GdUnitResult.success()` |
| Cleanup not running | Shutdown always runs; check for errors in your shutdown implementation |
| Priority conflicts | Adjust hook order in settings; hooks execute top-to-bottom |
| Missing test events | Ensure you're connected to `session.test_event` signal |
| Report path issues | Use `session.report_path.get_base_dir()` to get the directory |

### Debug Tips

- Use `session.send_message()` for logging hook activities
- Check the Godot console for detailed error messages
- Test hooks in isolation before combining multiple hooks
- Start with simple implementations and gradually add complexity
- Use `print()` statements during development, but prefer `session.send_message()` for production

## See Also

- [Settings - Hooks Configuration]({{site.baseurl}}/first_steps/settings/#hooks-settings) - Configure and manage hooks in the GdUnit4 settings
- [Test Setup/Teardown]({{site.baseurl}}/testing/hooks/#test-setupteardown) - Learn about test-level fixtures
