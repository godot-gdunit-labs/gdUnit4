---
layout: default
title: Continuous Integration Testing
nav_order: 10
---

# Continuous Integration Testing (CI)

## Definition

Continuous Integration (CI) is a method for automating the integration of code changes made by multiple contributors to a single software project.
It is a primary DevOps best practice that allows developers to frequently merge code changes into a central repository where builds and tests are executed.
Automated tools are used to confirm the new code is bug-free before integration.

[Wiki - Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration){:target="_blank"}

## Command Line Tool

GdUnit4 provides a command line tool that allows you to automate your testing workflow, including CI.

For more details please show at [Command Line Tool]({{site.baseurl}}/advanced_testing/cmd){:target="_blank"}

## Separate Tests That Need a Display

Most tests run in [headless mode]({{site.baseurl}}/advanced_testing/cmd/#headless-mode), including scene runner tests that simulate input.
Tests that depend on rendered output, like screenshots, shader output or `VisibleOnScreenNotifier2D`/`VisibleOnScreenNotifier3D`, need a display.
Keep these end-to-end tests in their own folder and run each folder in its own CI job.

```text
res://test/
├── unit/   # runs headless
└── e2e/    # needs a display
```

When you start Godot yourself, the headless job runs fast and needs no graphics setup:

```bash
godot --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -c -a res://test/unit
```

The end-to-end job runs Godot with a display. On a Linux CI server without a display, `xvfb-run` provides a virtual one,
and the OpenGL renderer of Mesa renders without a GPU:

```bash
xvfb-run --auto-servernum godot --rendering-driver opengl3 --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -c -a res://test/e2e
```

With the [gdUnit4-action](https://github.com/marketplace/actions/gdunit4-test-runner-action){:target="_blank"} you use one job per folder.
The action runs Godot with a virtual display, the argument `--headless` switches the unit test job to headless mode.
Example workflow, adapt the Godot version and paths to your project:
{% raw %}
```yaml
name: tests

on: [push, pull_request]

jobs:
  unit-tests:
    name: "Unit tests"
    runs-on: ubuntu-latest
    permissions:
      actions: write
      checks: write
      contents: write
      pull-requests: write
      statuses: write
    steps:
      - uses: actions/checkout@v4
      - uses: godot-gdunit-labs/gdUnit4-action@v1
        with:
          godot-version: '4.7'
          paths: 'res://test/unit'
          arguments: '--headless'
          report-name: unit-tests.xml

  e2e-tests:
    name: "End-to-end tests"
    runs-on: ubuntu-latest
    permissions:
      actions: write
      checks: write
      contents: write
      pull-requests: write
      statuses: write
    steps:
      - uses: actions/checkout@v4
      - uses: godot-gdunit-labs/gdUnit4-action@v1
        with:
          godot-version: '4.7'
          paths: 'res://test/e2e'
          report-name: e2e-tests.xml
```
{% endraw %}

## Howto deploy with GitHub Action

To deploy with GitHub Actions, you need to create a new workflow file in the *\.github/workflows/* directory and name it *ci\.yml*.
Please visit [GitHub Workflows Page](https://docs.github.com/en/actions/using-workflows){:target="_blank"}

### Using the gdUnit4-action

This GitHub Action automates the execution of GdUnit4 unit tests within the Godot Engine 4.x environment.
It provides flexibility in configuring the Godot version, GdUnit4 version, test paths, and other parameters to suit your testing needs.<br>
Find here on GitHub Marketplace [gdUnit4-action](https://github.com/marketplace/actions/gdunit4-test-runner-action){:target="_blank"}

Example workflow: (Please note that this is just an example and needs to be adapted to your project environment.)
{% raw %}
```yaml
name: ci-pr-example
run-name: ${{ github.head_ref || github.ref_name }}-ci-pr-example

on:
  pull_request:
    paths-ignore:
      - '**.yml'
      - '**.md'
  workflow_dispatch:


concurrency:
  group: ci-pr-example${{ github.event.number }}
  cancel-in-progress: true


jobs:
  unit-test:
    name: "CI Unit Test"
    runs-on: 'ubuntu-22.04'
    timeout-minutes: 10 # The overall timeout
    permissions:
      actions: write
      checks: write
      contents: write
      pull-requests: write
      statuses: write

    steps:
      # checkout your repository
      - uses: actions/checkout@v4
        with:
          lfs: true
      # run tests by using the gdUnit4-action with Godot version 4.2.1 and the latest GdUnit4 release 
      - uses: MikeSchulze/gdUnit4-action@v1.0.2
        with:
          godot-version: '4.2.1'
          paths: |
            res://project/tests/
          timeout: 5
          report-name: test_report.xml      
```
{% endraw %}

## Howto deploy with GitLab CI

You have to create a new workflow file on GitLab and named it *\.gitlab-ci\.yml*.
Please visit [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/yaml/gitlab_ci_yaml.html){:target="_blank"} for more detaild instructions

Thanks to [mzoeller](https://github.com/mzoeller){:target="_blank"} to providing this example workflow.
{% raw %}
```yaml
image: barichello/godot-ci:4.0.0

cache:
  key: import-assets
  paths:
    - .import/

stages:
  - export
  - tests
  - deploy

variables:
  EXPORT_NAME: $CI_PROJECT_NAME
  GIT_SUBMODULE_STRATEGY: recursive

linux:
  stage: export
  script:
    - mkdir -v -p build/linux
    - godot -v --export "Linux/X11" build/linux/$EXPORT_NAME.x86_64
  artifacts:
    name: $EXPORT_NAME-$CI_JOB_NAME
    paths:
      - build/linux

gdunit4:
  stage: tests
  dependencies:
    - linux
  script:
    - export GODOT_BIN=/usr/local/bin/godot
    - ./runtest.sh -a ./test || if [ $? -eq 101 ]; then echo "warnings"; elif [ $? -eq 0 ]; then echo "success"; else exit 1; fi
  artifacts:
    when: always
    reports:
      junit: ./reports/report_1/results.xml
```
{% endraw %}
