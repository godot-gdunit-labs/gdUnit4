#

<p align="center">
  <img src="https://github.com/godot-gdunit-labs/gdUnit4/blob/master/icon.png?branch=master" alt=""></br>
  <h1 align="center">GdUnit4 <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/MikeSchulze/gdunit4" width="14%"> </h1>
</p>
<h2 align="center">A Godot Embedded Unit Testing Framework</h2>

<h1 align="center">Supported Godot Versions</h1>
<p align="center">
  <img src="https://img.shields.io/badge/Godot-v4.3-%23478cbf?logo=godot-engine&logoColor=cyian&color=green" alt="">
  <img src="https://img.shields.io/badge/Godot-v4.4-%23478cbf?logo=godot-engine&logoColor=cyian&color=green" alt="">
  <img src="https://img.shields.io/badge/Godot-v4.4.1-%23478cbf?logo=godot-engine&logoColor=cyian&color=green" alt="">
  <img src="https://img.shields.io/badge/Godot-v4.5-%23478cbf?logo=godot-engine&logoColor=cyian&color=yellow" alt="">
</p>

<h1 align="center">Compatibility Overview</h1>
<p align="center">The latest version of GdUnit4 (master branch) is working with Godot <strong>v4.4.stable.mono.official [4c311cbee]</strong></p>
<table align="center">
  <thead>
 <tr>
   <th>GdUnit4 Version</th>
   <th>Godot minimal required/compatible Version</th>
 </tr>
  </thead>
  <tbody>
    <tr>
      <td>v6.x+</td><td>v4.5, v4.5.1</td>
    </tr>
    <tr>
      <td>v5.x+</td><td>v4.3, v4.4, v4.4.1</td>
    </tr>
    <tr>
      <td>v4.4.0+</td><td>v4.2.0, v4.3, v4.4.dev2</td>
    </tr>
    <tr>
      <td>v4.3.2+</td><td>v4.2.0, v4.3</td>
    </tr>
    <tr>
      <td>v4.3.0, v4.3.1</td><td>v4.2.0</td>
    </tr>
    <tr>
      <td>v4.2.1-v4.2.5</td><td>v4.1.0</td>
    </tr>
    <tr>
      <td>v4.2.0 and older</td><td>v4.0</td>
    </tr>
  </tbody>
</table>

<p align="center">
  <a target="_blank" href="https://www.youtube.com/watch?v=-iqxs3KPvLQ">
    <img src="https://github.com/godot-gdunit-labs/gdUnit4/blob/master/assets/gdUnit4-animated.gif" width="100%" alt=""/>
  </a>
</p>

<p align="center">
  <img alt="GitHub branch checks state" src="https://img.shields.io/github/checks-status/MikeSchulze/gdunit4/master"></br>
  <img alt="" src="https://github.com/godot-gdunit-labs/gdUnit4/actions/workflows/ci-dev.yml/badge.svg?branch=master"></br>
</p>

## What is GdUnit4?

**Gd**(*Godot*)**Unit**(*Unit Testing*)**4**(*Godot 4.x*)

GdUnit4 is an embedded unit testing framework designed for testing Gd scripts, C# scripts, and scenes in the Godot editor.
With GdUnit4, you can easily create and run unit tests to verify the functionality and performance of your code, ensuring
that it meets your requirements and specifications.<br>
GdUnit4 is a powerful tool that supports Test-Driven Development ([TDD](https://en.wikipedia.org/wiki/Test-driven_development)), a popular software development
approach that emphasizes creating automated tests before writing any code. By using GdUnit4 for TDD, you can
ensure that your code is thoroughly tested and free of bugs, which can save you time and effort in the long run.

---

## Features

### Core Testing Features

* **Support for GDScript and C#**  
  Write and execute tests in both GDScript and C#
* **Embedded Test Inspector**  
  Navigate your test suites directly within the Godot editor
* **Test Discovery**  
  Automatically searches for tests at runtime and adds them to the inspector
* **Convenient Interface**  
  Run test-suites directly from Godot using the context menu (FileSystem panel, ScriptEditor, or GdUnit Inspector)
* **Create Tests from Editor**  
  Right-click on any function in the ScriptEditor and select "Create TestCase" to generate tests automatically

### Test Writing & Assertions

* **Fluent Syntax**  
  Write test cases with an easy-to-read, fluent interface
* **Wide Range of Assertions**  
  Comprehensive assertion methods for verifying behavior and output
* **Argument Matchers**  
  Verify function calls with expected arguments
* **Unicode Text Support**  
  Full support for unicode characters in test strings and assertions
* **Variadic Arguments Support**  
  Test functions that accept variable numbers of arguments

### Advanced Testing Capabilities

* **Test Fuzzing**  
  Generate random inputs to test edge cases and boundary conditions
* **Parameterized Tests**  
  Test functions with multiple sets of inputs and expected outputs
* **Test Session Hooks**  
  Set up and tear down test resources at the session level for efficient test management
* **Mocking & Spying**
  * Mock classes to simulate behavior and define output for specific functions
  * Spy on functions to verify they were called with expected parameters
  * Mock or spy on scenes to simulate behavior and verify function calls
* **Scene Runner**  
  Simulate different kinds of inputs and actions:
  * Mouse clicks and movements
  * Keyboard inputs
  * Touch screen interactions
  * Custom input actions
  * Wait for specific signals or function return values
* **Flaky Test Handling**  
  Detect and handle flaky tests by rerunning failed tests  
  Configure retry count and mark non-deterministic failures in test results
* **Configurable Templates**  
  Customize templates for generating new test-suites

### Continuous Integration Support

* **Command Line Tool**  
  Run tests outside the Godot editor for CI/CD pipelines
* **HTML Report Generation**  
  Generate comprehensive HTML test reports
* **JUnit XML Report**  
  Export test results in JUnit XML format for CI integration
* **GitHub Action Integration**  
  Public marketplace action for integrating GdUnit4 into your CI workflow  
  [gdunit4-action](https://github.com/marketplace/actions/gdunit4-test-runner-action)

### GdUnit4Net - C# Support

* **C# API** - [gdUnit4.api](https://github.com/godot-gdunit-labs/gdUnit4Net/blob/master/README.md)  
  Full support for writing tests in C#
* **VSTest Integration** - [gdunit4.test.adapter](https://github.com/godot-gdunit-labs/gdUnit4Net/blob/master/TestAdapter/README.md)  
  Run and debug tests in:
  * Visual Studio
  * Visual Studio Code
  * JetBrains Rider

---

## Basic Test Example

 ```gdscript
class_name GdUnitExampleTest
extends GdUnitTestSuite

func test_example():
  assert_str("This is an example message")\
    .has_length(26)\
    .starts_with("This is an ex")
 ```

 ---

## Advanced Example: Automated Testing in Godot

[![Watch the video](https://i.ytimg.com/an_webp/CreugthdgJ0/mqdefault_6s.webp?du=3000&sqp=CPzPoMYG&rs=AOn4CLCnb4LpbgbUEjAExFj1NAdZ5lnqKA)](https://www.youtube.com/watch?v=CreugthdgJ0)

This excellent example is provided by [Godotneers](https://www.youtube.com/@godotneers) and demonstrates how to effectively test your game scenes using GDUnit4.
The video walks through practical automated testing techniques that can help improve your Godot project's reliability and maintainability.

## Documentation

<p align="left" style="font-family: Bedrock; font-size:21pt; color:#7253ed; font-style:bold">
  <a href="https://godot-gdunit-labs.github.io/gdUnit4/latest/first_steps/install/">How to Install the GdUnit4 plugin</a>
</p>
<p align="left" style="font-family: Bedrock; font-size:21pt; color:#7253ed; font-style:bold">
  <a href="https://godot-gdunit-labs.github.io/gdUnit4/latest/csharp_project_setup/csharp-setup/">How to setup GdUnit4 for C#</a>
</p>

<p align="left" style="font-family: Bedrock; font-size:21pt; color:#7253ed; font-style:bold">
  <a href="https://godot-gdunit-labs.github.io/gdUnit4/latest/">API Documentation</a>
</p>

---

### You Are Welcome To

<!-- markdownlint-capture -->
<!-- markdownlint-disable -->

* [Give Feedback](https://github.com/godot-gdunit-labs/gdUnit4/discussions) on the gdUnit GitHub Discussions page.
* [Suggest Improvements](https://github.com/godot-gdunit-labs/gdUnit4/issues/new?assignees=MikeSchulze&labels=enhancement&template=feature_request.md&title=) by creating a new feature
  request issue on the gdUnit GitHub Issues page.
* [Report Bugs](https://github.com/godot-gdunit-labs/gdUnit4/issues/new?assignees=MikeSchulze&labels=bug&projects=projects%2F5&template=bug_report.yml&title=GD-XXX%3A+Describe+the+issue+briefly)
  by creating a new bug report issue on the gdUnit GitHub Issues page.

<!-- markdownlint-enable -->
<!-- markdownlint-restore -->

---

## GdUnit Test Coverage and Code Quality

### Test Coverage

GdUnit is comprehensively tested to ensure robust functionality.<br>
Continuous Integration (CI) is in place for every pull request to prevent any potential functionality issues.

### Code Formatting

🙏 Special Thanks to @Scony for creating [gdlint](https://github.com/Scony/godot-gdscript-toolkit), a valuable tool contributing to code quality.

---

### Contribution Guidelines

**Thank you for your interest in contributing to GdUnit4!**<br>
To ensure a smooth and collaborative contribution process, please review our
[contribution guidelines](https://github.com/godot-gdunit-labs/gdUnit4/blob/master/CONTRIBUTING.md) before getting started.
These guidelines outline the standards and expectations we uphold in this project.

**Code of Conduct:**<br>
We strictly adhere to the Godot code of conduct in this project.
As a contributor, it is important to respect and follow this code to maintain a positive and inclusive community.

**Using GitHub Issues:**<br>
We utilize GitHub issues for tracking feature requests and bug reports.
If you have a general question or wish to engage in discussions, we recommend joining the [GdUnit Discord Server](https://discord.gg/rdq36JwuaJ) for specific inquiries.

We value your input and appreciate your contributions to make GdUnit4 even better!

---

<p align="left" style="font-family: Bedrock; font-size:21pt; color:#7253ed; font-style:bold">
  <img alt="GitHub issues" src="https://img.shields.io/github/issues/MikeSchulze/gdunit4">
  <img alt="GitHub closed issues" src="https://img.shields.io/github/issues-closed-raw/MikeSchulze/gdunit4"></br>
  <img alt="" src="https://img.shields.io/packagecontrol/dm/SwitchDictionary.svg">
  <img alt="" src="https://img.shields.io/packagecontrol/dt/SwitchDictionary.svg">

  <img alt="GitHub top language" src="https://img.shields.io/github/languages/top/MikeSchulze/gdunit4">
  <img alt="GitHub code size in bytes" src="https://img.shields.io/github/languages/code-size/MikeSchulze/gdunit4">
  <img alt="" src="https://img.shields.io/badge/License-MIT-blue.svg">
</p>

<p align="left">
  <a href="https://discord.gg/rdq36JwuaJ">
    <img src="https://discordapp.com/api/guilds/885149082119733269/widget.png?style=banner4" alt="Join GdUnit Server"/>
  </a>
</p>

### Thank you for supporting my project

---

## Sponsors

[<img src="https://avatars.githubusercontent.com/u/822035?v=4)" alt="bitbrain" width="125"/>](https://github.com/bitbrain) miguel a.k. bitbrain
[<img src="https://avatars.githubusercontent.com/u/2313134?v=4" alt="sebastianhutter" width="125"/>](https://github.com/sebastianhutter) Sebastian Hutter
[<img src="https://avatars.githubusercontent.com/u/836370?v=4" alt="rafaelGuerreiro" width="125"/>](https://github.com/rafaelGuerreiro) Rafael Guerreiro
[<img src="https://avatars.githubusercontent.com/u/58704291?v=4" alt="greenpixels" width="125"/>](https://github.com/greenpixels) Sven Teigler
