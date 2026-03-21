# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

GdUnit4 is a Godot 4 embedded unit testing framework (Godot plugin) supporting GDScript and C#.
The plugin lives entirely under `addons/gdUnit4/` and is self-tested — the framework uses itself to run its own test suite.

Supported Godot versions: 4.3–4.6. C# targets net9.0 with .NET SDK 9.0.308 (pinned in `global.json`).

## Commands

### Running Tests

Tests require a Godot binary. Set `GODOT_BIN` or pass `--godot_binary`:

```bash
# GDScript tests
export GODOT_BIN=/path/to/godot
./addons/gdUnit4/runtest.sh

# With explicit binary
./addons/gdUnit4/runtest.sh --godot_binary /path/to/godot

# Run a specific test path
./addons/gdUnit4/runtest.sh --godot_binary /path/to/godot -a res://addons/gdUnit4/test/asserts/
```

For .NET projects, `runtest.sh` also runs `dotnet build --debug` automatically.

### C# Build and Format

```bash
# Build
dotnet build --debug

# Verify formatting (CI-style check, no changes applied)
dotnet format gdUnit4.csproj --verify-no-changes --verbosity diagnostic
```

### GDScript Linting

Requires `gdlint` (gdscript-toolkit 4.5.0):

```bash
gdlint addons/gdUnit4/bin/
gdlint addons/gdUnit4/src/cmd/
gdlint addons/gdUnit4/src/reporters/
gdlint addons/gdUnit4/src/network
gdlint addons/gdUnit4/src/asserts
```

### Markdown Linting

Run markdownlint-cli2 locally before pushing to catch formatting issues early:

```bash
markdownlint-cli2 --config .github/actions/formatting_checks/.markdownlint.jsonc "**/*.md"
```

## Architecture

### Plugin Structure

```text
addons/gdUnit4/
├── plugin.cfg          # Plugin metadata and version
├── plugin.gd           # Plugin entry point (EditorPlugin)
├── bin/                # CLI tools (GdUnitCmdTool.gd, GdUnitCopyLog.gd)
├── src/                # All framework source code
└── test/               # Self-tests (mirrors src/ structure)
```

### Source Modules (`addons/gdUnit4/src/`)

| Directory | Purpose |
| --------- | ------- |
| `asserts/` | Fluent assertion implementations (one file per type: Array, String, Signal, etc.) |
| `core/` | Test case execution, discovery, events, attributes, versioning |
| `doubler/` | Test double (mock/stub) code generation |
| `mocking/` | Mock framework logic |
| `spy/` | Spy/verification implementation |
| `matchers/` | Argument matchers used in mock assertions |
| `fuzzers/` | Fuzzy/parameterized test support |
| `extractors/` | Value extraction utilities for assertions |
| `monitor/` | Error and signal monitoring during test execution |
| `network/` | Client/server for distributed test reporting |
| `reporters/` | HTML and JUnit XML report generation |
| `ui/` | Godot editor UI — Test Inspector panel |
| `cmd/` | Command-line argument parsing (CmdArgumentParser, CmdCommandHandler) |
| `dotnet/` | C#-specific integration layer |

### Test Organization

Tests in `addons/gdUnit4/test/` mirror the `src/` structure. For example:

- `src/asserts/GdUnitArrayAssertImpl.gd` → `test/asserts/GdUnitArrayAssertImplTest.gd`
- `src/cmd/CmdArgumentParser.gd` → `test/cmd/CmdArgumentParserTest.gd`

C#-specific tests live under `test/dotnet/`.

### Key Core Files

- `src/core/_TestCase.gd` — Base test case class
- `src/core/GdObjects.gd` — Core object utilities
- `src/core/execution/` — Test execution pipeline
- `src/core/discovery/` — Test discovery logic
- `src/core/event/` — Test event system

## Coding Style

**GDScript:** Follow [Godot's GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
Enforced by gdlint with these key limits (`.gdlintrc`):

- Max line length: 140
- Max file lines: 1000
- Max public methods: 40
- Function argument count: 11

**C#:** StyleCop.Analyzers enforced. `TreatWarningsAsErrors = true`. Nullable reference types enabled. C# language version 13.0.

## Documentation

The `documentation/` folder is a Jekyll site built with the [just-the-docs](https://just-the-docs.com/) theme (Ruby 3.4.7, Jekyll ~4.4.1).
It is published to GitHub Pages via `.github/workflows/deploy-gh-pages.yml`, triggered on release events or manual dispatch.

### Structure

Markdown source files live under `documentation/doc/` in Jekyll collections:

| Collection | Path | Content |
| ---------- | ---- | ------- |
| `first_steps` | `doc/_first_steps/` | Installation, running tests, settings |
| `csharp_project_setup` | `doc/_csharp_project_setup/` | C# setup, VSTest adapter |
| `testing` | `doc/_testing/` | Test suites, test cases, all assert types |
| `advanced_testing` | `doc/_advanced_testing/` | Mocking, spying, scene runner, signals, fuzzing, etc. |
| `tutorials` | `doc/_tutorials/` | TDD and scene runner examples |
| `faq` | `doc/_faq/` | CI setup, common solutions |

### Building Locally

```bash
cd documentation
bundle install
bundle exec jekyll serve
```

The site is served at `http://localhost:4000/gdUnit4`.

### Deployment

The workflow deploys docs to the `gh-pages` branch under versioned paths (e.g., `/gdUnit4/v6.1.x/`)
and `/gdUnit4/latest/` for the latest overall release.
Only the newest patch in a major.minor series is deployed (e.g., v6.1.2 won't be overwritten by v6.1.1).
The `current_version` in `documentation/_config.yml` should be updated when releasing a new minor version.

## Branch and PR Conventions

- Main branch: `master`
- Feature branches should be named after the issue number (e.g., `GD-111`)
- PRs must link to an issue and pass all CI checks before merging
- CI runs format checks, gdlint, and tests against Godot 4.5, 4.5.1, and 4.6

### Before Pushing

Run all linting locally before pushing to avoid CI failures:

```bash
# GDScript lint (mirrors .github/workflows/gdlint.yml)
gdlint addons/gdUnit4/bin/
gdlint addons/gdUnit4/src/cmd/
gdlint addons/gdUnit4/src/reporters/
gdlint addons/gdUnit4/src/network
gdlint addons/gdUnit4/src/asserts

# Markdown lint
markdownlint-cli2 --config .github/actions/formatting_checks/.markdownlint.jsonc "**/*.md"

# C# format check (if C# files changed)
dotnet format gdUnit4.csproj --verify-no-changes --verbosity diagnostic
```

### PR Description

PR descriptions must include these two sections:

```markdown
# Why
<explain the motivation or problem being solved>

# What
<describe the changes made>
```
