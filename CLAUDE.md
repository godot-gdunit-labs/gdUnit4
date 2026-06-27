# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

GdUnit4 is a Godot 4 embedded unit testing framework (Godot plugin) supporting GDScript and C#.
The plugin lives entirely under `addons/gdUnit4/` and is self-tested — the framework uses itself to run its own test suite.

Supported Godot versions: (read the **Compatibility Overview** table in `README.md`
and find the row whose GdUnit4 version contains `master`). C# targets net9.0 with .NET SDK 9.0.308 (pinned in `global.json`).

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

After every GDScript change, lint the modified file with gdlint before considering the task done:

```bash
gdlint path/to/changed_file.gd
```

Before running gdlint, verify it is installed:

```bash
gdlint --version
```

If gdlint is not installed, **stop and tell the user** to install it:

```text
gdlint is not installed. Please install it with:
  pip install gdtoolkit==4.5.0
```

Do not skip linting or proceed without it.

**C#:** StyleCop.Analyzers enforced. `TreatWarningsAsErrors = true`. Nullable reference types enabled. C# language version 13.0.

## Godot API Compatibility

Before using any Godot API function, class, or feature, read the **Compatibility Overview** table in `README.md`
and find the row whose GdUnit4 version contains `master`. That row lists the exact Godot versions that must be supported.

All Godot API usage must be compatible with **every** version listed in that row. If an API is not available in
all of them, it cannot be used without a version guard. When uncertain, check the
[Godot class reference changelog](https://docs.godotengine.org/en/stable/classes/) or the Godot GitHub commit history.

## Testing Requirements

Every code change must be accompanied by new or updated tests. Tests live under `addons/gdUnit4/test/` and mirror
the `src/` structure (e.g. `src/core/Foo.gd` → `test/core/FooTest.gd`).

See `addons/gdUnit4/test/CLAUDE.md` for the full GdUnit4 fluent assertion syntax, test suite skeleton,
section grouping conventions, mocking, scene runner, and auto-free usage.

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

### Git Hooks

A pre-commit hook is provided in `.githooks/pre-commit`. It automatically strips `uid="uid://..."` attributes
from `[ext_resource]` lines in staged `.tscn` scene files before each commit. These UIDs are generated by
Godot from `.uid` sidecar files which are not committed to this repository; leaving them in the scene files
causes loading warnings on clean clones.

Activate the hook once after cloning:

```bash
git config core.hooksPath .githooks
```

When editing or creating `.tscn` files, do not manually remove uid attributes — the hook handles it automatically on commit.

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

### Commit Messages

The subject line must start with the issue/branch number (e.g. `GD-1234`) followed by a short
meaningful title describing what the commit is about. The body must include these two sections:

```markdown
GD-1234: Short meaningful title

# Why
<explain the motivation or problem being solved>

# What
<describe the changes made>
```

### PR Description

The PR title must start with the issue/branch number (e.g. `GD-1234`) followed by a short meaningful title. The description must include these two sections:

```markdown
# Why
<explain the motivation or problem being solved>

# What
<describe the changes made>
```

## GitHub Issue Creation and Updates

### Issue types and prefixes

Issue templates are defined in `.github/ISSUE_TEMPLATE/`. Before creating or updating an issue, read
the template files to determine the `name`, `title` prefix (`GD-`, `TASK-`, `DOC-`), required `labels`,
`type`, `assignees`, `projects`, and required body sections (`validations: required: true`).

If the issue type is **not obvious** from the request, ask the user and present the available template
names as selectable options before proceeding.

### Metadata — apply on both creation and update

When creating or reviewing an issue, read the chosen template file and apply every top-level field
(`assignees`, `labels`, `type`, `projects`, etc.) to the issue. Verify all fields are correctly set
and correct any that are missing or wrong.

`gh issue create` does **not** automatically apply the `projects:` field from YAML templates — that
field is a GitHub web UI hint only. Always add the issue to the project explicitly after creation.
Before doing so, check whether the `read:project` scope is available:
```bash
gh auth status 2>&1 | grep -q "read:project"
```

- If the scope **is present**, add the issue: `gh project item-add <number> --owner <owner> --url <issue-url>`
- If the scope **is missing**, do not run the command. Instead, inform the user:
  > Project assignment requires the `read:project` scope. Please run the following command in the
  > terminal where the Agent is running, complete the browser authorization, then ask me to update
  > the issue again:
  >
  > `gh auth refresh -s read:project`

`gh issue edit` does not support `--type`; correct an existing issue's type via GraphQL:
```bash
# 1. fetch type IDs
gh api graphql -f query='query { repository(owner:"godot-gdunit-labs", name:"gdUnit4") { issueTypes(first:10) { nodes { id name } } } }'
# 2. fetch issue node ID
gh api graphql -f query='query { repository(owner:"godot-gdunit-labs", name:"gdUnit4") { issue(number:NNN) { id } } }'
# 3. set the type
gh api graphql -f query='mutation { updateIssue(input:{ id:"ISSUE_ID" issueTypeId:"TYPE_ID" }) { issue { issueType { name } } } }'
```

### Body rules

- Read the chosen template file and fill every field marked `validations: required: true`.
- Write in plain, human-readable language — no file names, function names, or class names.
- Optional fields (`validations: required: false` or absent) can be omitted.
- For `dropdown` fields, write the selected option value as a plain line under the section heading.
- For the `feature-type` dropdown in Feature Request issues, infer the best-matching option from the
  problem description rather than defaulting to the first option.
- For version fields (e.g. `gdunit-version`), read the current version from `addons/gdUnit4/plugin.cfg`
  (`version` key) and select the closest matching option from the dropdown.
- For Godot version fields (e.g. `godot-version`), run `$GODOT_BIN --version` to get the exact version.
  If `GODOT_BIN` is not set, fall back to the feature version in `project.godot` (`config/features`).
- For environment/system fields (e.g. `system`), read the field's `placeholder` in the template to
  understand what information is expected, then collect each item from the actual system environment
  (OS version, relevant project settings, installed tools) and fill it in.
- **Feature Request exception:** when the feature is a new or changed API, the Proposed Solution field
  may include a short code snippet showing the suggested method signature or call-site usage only.
  This exception applies only to API/code features — not to process, tooling, or documentation
  improvements. No implementation details.
- **Bug Report exception:** the Bug Description field may include the function name or call that is
  misbehaving. The Steps to Reproduce field may include a full code snippet demonstrating the problem.

### Title: two-step workflow

The issue number is not known until after creation. Create the issue first, then immediately rename it
using the prefix from the template's `title` field (e.g. `GD-XXX` → prefix `GD`).

Class names, function names, and method names in the title must be wrapped in backticks (e.g. `is_valid()`).

```bash
ISSUE_URL=$(gh issue create \
    --title "Brief description (no prefix yet)" \
    --assignee MikeSchulze \
    --label "LABEL" \
    --type "TYPE" \
    --body "...")
ISSUE_NUM=$(basename "$ISSUE_URL")
PREFIX="GD"   # derived from the template's title prefix (GD, TASK, or DOC)
gh issue edit "$ISSUE_NUM" --title "${PREFIX}-${ISSUE_NUM}: Brief description"
```

## AI-Harness PR Creation

When you create a Pull Request as part of autonomous AI work (e.g. after fixing an issue or
implementing a feature end-to-end without the user running `/pr`), apply these two additions:

**Label:** always add `bot:ai-generated` via `--label "bot:ai-generated"` in the `gh pr create` call.

**Description prefix:** prepend the following callout block at the top of every AI-harness PR body,
before the `## Summary` section:

```markdown
> [!NOTE]
> 🤖 **This Pull Request was 100% generated by an AI Coding Harness.**
> Please review logic, edge cases, and unit test coverage carefully before merging.
```

Do **not** add the label or the note when the user explicitly runs `/pr` — that command is
user-triggered and the PR is not considered fully AI-generated.

## Task Progress Display

For any multi-step task (more than one distinct action), always start the response by
printing a numbered plan with checkboxes, then update each item to ✅ as it completes:

```text
- [ ] Step 1 — description
- [ ] Step 2 — description
- [ ] Step 3 — description
```

Reprint the list (with completed items marked ✅) before each major step so the
developer can see live progress. Keep step descriptions short (one line each).
