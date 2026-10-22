---
layout: default
title: Configure Your IDE
nav_order: 2
---

## How GdUnit4Net Achieves IDE Support

GdUnit4Net leverages the industry-standard ([VSTest](https://github.com/microsoft/vstest?tab=readme-ov-file#vstest){:target="_blank"})
API to provide comprehensive IDE integration.
By implementing the VSTest adapter interface, GdUnit4Net allows IDEs that support the Visual Studio Test Platform to:

- **Discover tests** automatically in your Godot C# projects
- **Execute tests** with real-time feedback and reporting
- **Debug tests** with full breakpoint and variable inspection support
- **Filter and organize** test runs based on various criteria
- **Generate detailed reports** in multiple formats

This approach ensures a consistent testing experience across different IDEs while maintaining full compatibility with existing .NET testing workflows.

The project repository can be found here [gdunit4.test.adapter](https://github.com/godot-gdunit-labs/gdUnit4Net/blob/master/TestAdapter/README.md){:target="_blank"}.

## Preconditions

Before configuring your IDE, ensure you have completed the following setup requirements:

### Supported IDE's

|IDE               |Test Discovery|Test Run|Test Debug|Jump to Failure|Solution test config file|Test Filter|Parallel Test Execution|
|---|---|---|---|---|---|---|---|
|Visual Studio     |✅|✅|✅|✅|✅|✅|❌|
|Visual Studio Code|✅|✅|✅|✅|✅|✅|❌|
|JetBrains Rider version 2024.2 |✅|✅|✅|✅|✅|✅|❌|

> ✅ - supported<br>
> ☑️ - supported by a workaround (link)<br>
> ❌ - not supported<br>
> 🔜 - not yet implemented<br>

### 1. Project Configuration

Your Godot C# project must be properly configured with GdUnit4Net dependencies as described in the
[Setup Documentation]({{site.baseurl}}/csharp_project_setup/csharp-setup/). This includes:

- Correct .NET framework targeting (a framework supported by GdUnit4Net)
- Required NuGet package references (gdUnit4.api, gdUnit4.test.adapter, etc.)
- Proper project file structure

### 2. Environment Variable Setup

You must configure the `GODOT_BIN` environment variable pointing to your Godot executable.

|Platform|Environment Variable|Example Path|
|---|---|---|
|Windows|**%GODOT_BIN%**|`d:\development\Godot_v4.7-stable_mono_win64\Godot_v4.7-stable_mono_win64.exe`|
|Linux/Unix/Mac|**$GODOT_BIN**|`/Users/MisterX/Documents/develop/GodotMono.app/Contents/MacOS/Godot`|

Or define it in the **.runsettings** under `EnvironmentVariables` see below.

### 3. RunSettings Configuration

Create a `.runsettings` file in your project to configure test execution.
The full guide to configure the settings [can be found here](https://github.com/godot-gdunit-labs/gdUnit4Net/blob/master/TestAdapter/README.md#configuration-with-runsettings){:target="_blank"}.

Below is an example:

```xml
<?xml version="1.0" encoding="utf-8"?>
<RunSettings>
    <RunConfiguration>
        <MaxCpuCount>1</MaxCpuCount>
        <ResultsDirectory>./TestResults</ResultsDirectory>
        <TargetFrameworks>net8.0</TargetFrameworks>
        <TestSessionTimeout>180000</TestSessionTimeout>
        <TreatNoTestsAsError>true</TreatNoTestsAsError>
        <EnvironmentVariables>
            <GODOT_BIN>d:\development\Godot_v4.7-stable_mono_win64\Godot_v4.7-stable_mono_win64.exe</GODOT_BIN>
        </EnvironmentVariables>
    </RunConfiguration>

    <LoggerRunSettings>
        <Loggers>
            <Logger friendlyName="console" enabled="True">
                <Configuration>
                    <Verbosity>detailed</Verbosity>
                </Configuration>
            </Logger>
            <Logger friendlyName="html" enabled="True">
                <Configuration>
                    <LogFileName>test-result.html</LogFileName>
                </Configuration>
            </Logger>
            <Logger friendlyName="trx" enabled="True">
                <Configuration>
                    <LogFileName>test-result.trx</LogFileName>
                </Configuration>
            </Logger>
        </Loggers>
    </LoggerRunSettings>

    <GdUnit4>
        <!-- Additional Godot runtime parameters. These are passed to the Godot executable when running tests.-->
        <Parameters>"--verbose"</Parameters>
  
        <!-- Controls the display name format of test cases in the test results.
                 Allowed values:
                 - SimpleName: Uses only the method name (e.g., "TestMethod")
                 - FullyQualifiedName: Uses the full path including class and method name (e.g., "MyNamespace.MyClass.TestMethod")
                 Default: SimpleName -->
        <DisplayName>FullyQualifiedName</DisplayName>
  
        <!-- When set to true, standard output (stdout) from test cases is captured
                 and included in the test result. This can be useful for debugging. -->
        <CaptureStdOut>true</CaptureStdOut>
  
        <!-- The maximum duration allowed for a Godot project compilation process in milliseconds.
                         After this timeout period expires, the compilation process is forcefully terminated.
                         For large or complex Godot projects, you may need to increase this value.
                         Default: 120000 (2 minutes) -->
        <CompileProcessTimeout>120000</CompileProcessTimeout>

        <!-- The maximum duration allowed to connect to the Godot runtime host in milliseconds.
                         Increase this value for environments where the Godot host needs more time to start.
                         Default: 10000 (10 seconds) -->
        <GodotConnectTimeout>10000</GodotConnectTimeout>

        <!-- When set to true, a failing exit of the Godot runtime host after all test results are reported,
                         for example a crash with SIGSEGV or SIGABRT during the engine shutdown, is reported as a warning
                         and does not fail the test run. A failing exit before all test results are reported always fails the run.
                         Default: false -->
        <TolerateExitCodeAfterCompletion>false</TolerateExitCodeAfterCompletion>
    </GdUnit4>
</RunSettings>
```

---

### Visual Studio

![test-adapter]({{site.baseurl}}/assets/images/faq/visualstudio/test-explorer.png)

**Do follow this steps to activate the test explorer:**

- Activate the test explorer
  ![explorer]({{site.baseurl}}/assets/images/faq/visualstudio/setup-test-1.png)
- Configure the path to your `.runsettings`
  ![explorer]({{site.baseurl}}/assets/images/faq/visualstudio/setup-test-2.png)
- Restart Visual Studio

---

### Visual Studio Code

![test-adapter]({{site.baseurl}}/assets/images/faq/visualstudio-code/test-explorer.png)

**Do follow this steps to activate the test explorer:**

- Install the C# Dev Kit (v1.5.12 (pre-release) recommended).
- Detailed instructions [can be found here](https://code.visualstudio.com/docs/csharp/testing){:target="_blank"}.
  ![devkit]({{site.baseurl}}/assets/images/faq/visualstudio-code/test-setup-1.png)
- Open your `.vscode/settings.json` and add the following property to your project settings:
  It is important to use the correct C# Dev Kit version, which is currently a PreRelease.
  The property is newly introduced by this [issue](https://github.com/microsoft/vscode-dotnettools/issues/156){:target="_blank"}.

    ```json
    "dotnet.unitTests.runSettingsPath": "./test/.runsettings"
    ```
- Restart Visual Studio Code

---

### JetBrains Rider

![enable vstest]({{site.baseurl}}/assets/images/faq/jetbrains/test-explorer.png)

**Do follow these steps to activate the test explorer:**

{% include advice.html
content="We recommend to use Rider <b>2024.2</b> or higher to enable test debugging!
<a href='https://plugins.jetbrains.com/plugin/13882-godot-support'> Checkout for the latest version</a><br>"
%}

- Install the Godot Support plugin
  ![godot-support]({{site.baseurl}}/assets/images/faq/jetbrains/plugin-godot-support.png)
- Configure the path to your `.runsettings`
  ![runsettings]({{site.baseurl}}/assets/images/faq/jetbrains/setup-test-1.png)
- Enable the
  [VSTest adapters](https://www.jetbrains.com/help/rider/Reference__Options__Tools__Unit_Testing__VSTest.html#projects-with-unit-tests){:target="_blank"}
  in the Rider settings
  ![enable vstest]({{site.baseurl}}/assets/images/faq/jetbrains/setup-test-2.png)
- Restart JetBrains Rider

---

### Issues and Workarounds

|Issue| Solution                                                                                |
|-|-----------------------------------------------------------------------------------------|
|The test discovery is aborted and not all tests are found| Increase the `<TestSessionTimeout>` in your [RunSettings](#3-runsettings-configuration) |
