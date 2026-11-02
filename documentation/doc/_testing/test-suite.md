---
layout: default
title: Test Suite
nav_order: 2
---

# GdUnit Test Suite

## TestSuite Definition

A TestSuite is a collection of tests that are aligned to a specific class or module that you want to test.
When writing tests, it is common to find that several tests require similar test data to be created before and cleaned up after the test run.
GdUnit TestSuites allow you to define pre-initialized test data and cleanup [(**hooks**)]({{site.baseurl}}/testing/hooks/#gdunit-hooks) that will be executed at
specific points during test execution.

In addition to containing multiple test cases, a TestSuite can also contain test setup and teardown hooks that are executed before and after each test case, as
well as before and after the entire TestSuite.
This allows you to control the test environment and ensure that tests are executed in a consistent and repeatable manner.

- [TestSuite Hooks]({{site.baseurl}}/testing/hooks/#testsuite-hooks)

## TestSuite Example

{% tabs faq-test-case-name %}
{% tab faq-test-case-name GdScript %}
Defines a TestSuite with two TestCases<br>

```gd
extends GdUnitTestSuite

func before() -> void:
    # Setup suite-level shared resources, expensive setup

func after() -> void:
    # Cleanup suite-level shared resources, expensive setup

func test_string_to_lower() -> void:
   assert_str("AbcD".to_lower()).is_equal("abcd")
   
func test_string_to_upper() -> void:
   assert_str("AbcD".to_upper()).is_equal("ABCD")   
   
```

{% endtab %}
{% tab faq-test-case-name C# %}
Use the **[TestSuite]** attribute to define TestSuite.

```cs
namespace Examples;

using GdUnit4;
using static GdUnit4.Assertions;

[TestSuite]
public class GdUnitExampleTest
{ 
    
   [Before] 
   public void Setup() {
     // Setup suite-level shared resources, expensive setup
   }

   [After] 
   public void Setup() {
     // Cleanup suite-level shared resources, expensive setup
   }
   
   [TestCase]
   public void StringToLower() {
      AssertString("AbcD".ToLower()).IsEqual("abcd");
   }
   
   [TestCase]
   public void StringToUpper() {
      AssertString("AbcD".ToUpper()).IsEqual("ABCD");
   }
}
```

{% endtab %}
{% endtabs %}

## The TestSuite Execution Graph

{% tabs faq-TestSuite-overview %}
{% tab faq-TestSuite-overview GdScript %}
![Execution Graph]({{site.baseurl}}/assets/images/hooks/suite-execution-graph-gdscript.svg){:.centered}
{% endtab %}
{% tab faq-TestSuite-overview C# %}
![Execution Graph]({{site.baseurl}}/assets/images/hooks/suite-execution-graph-csharp.svg){:.centered}
{% endtab %}
{% endtabs %}
