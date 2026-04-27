---
name: release-post
description: Generates a detailed Patreon release announcement post for a GdUnit4 version. Fetches the GitHub release notes, then pulls every linked issue and PR to extract the full problem/solution context, and writes a reader-friendly markdown post saved as patreon_vX.Y.Z.md in the project root.
---

# Release Post Agent

## Purpose

Generate a Patreon release announcement for a GdUnit4 version that goes beyond the raw changelog.
Each entry must explain **what the problem was** and **why the fix matters** — not just what changed.

## Steps

### 1. Fetch the release notes

```bash
gh release view vX.Y.Z --repo godot-gdunit-labs/gdUnit4
```

Parse out all issue numbers and PR numbers from the "What's Changed" section.

### 2. Fetch all issues and PRs in parallel

For every issue number referenced (e.g. GD-1085):

```bash
gh issue view <number> --repo godot-gdunit-labs/gdUnit4
```

For documentation-only PRs that have no backing issue:

```bash
gh pr view <number> --repo godot-gdunit-labs/gdUnit4
```

Fetch all of them in parallel to save time.

### 3. Write the post

#### Document structure

```markdown
# GdUnit4 vX.Y.Z is out!

<one-sentence intro: what kind of release this is and who benefits>

---

## Improvements

### <title> *(GD-XXXX)*

<problem paragraph: describe what was broken or missing, including concrete failure scenarios>

<fix paragraph: describe what was changed and what the user experience is now>

---

## Bug Fixes

### <title> *(GD-XXXX)*

<same structure as above>

---

## Community Contributions  (only if present)

<thank contributors by name, summarise what they did>

---

Full changelog and download: https://github.com/godot-gdunit-labs/gdUnit4/releases/tag/vX.Y.Z

<closing sentence thanking supporters>
```

#### Writing rules

- **Lead with the problem.** Readers should feel the pain before hearing the fix.
- **Plain language.** Avoid internal jargon; write for a developer who uses GdUnit4 but hasn't read the source.
- **Concrete scenarios.** Use real examples from the issue body (code snippets, error messages, reproduction steps) to make the impact tangible.
- **One section per issue.** Group by category (Improvements / Bug Fixes / Documentation / Other). Skip dependabot bumps entirely.
- **Reference the issue number** in italics at the end of each heading: `*(GD-XXXX)*`.
- **No filler.** Don't pad entries that are self-explanatory; a two-sentence entry is fine if the issue is simple.
- **Community contributions** get a dedicated section with a personal thank-you by name.

### 4. Save the output

Write the finished post to the project root:

```
patreon_vX.Y.Z.md
```

Use `vX.Y.Z` matching the release tag (e.g. `patreon_v6.1.3.md`).
