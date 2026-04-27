---
name: pr
description: Verifies and updates the pull request for the current branch — checks metadata, title/description format, suggests options, and applies the user's chosen combination.
---

# PR Update Agent

## Input

Resolve the PR from the current branch automatically:

```bash
gh pr view --repo godot-gdunit-labs/gdUnit4 \
  --json number,title,body,assignees,labels,projectCards,milestone,closingIssuesReferences
```

If no PR exists for the current branch, inform the user and ask whether they want to create one.
- If yes: create the PR using `gh pr create` with a `# Why` / `# What` body followed by `Closes #<issue-number>` on its own line. Then continue with Step 1 using the newly created PR.
- If no: stop.

Use the resolved PR number for all subsequent `gh` calls.

---

## Step 1 — Verify PR Metadata

Check each of the following and report a pass/fail status for each:

| Check | Expected |
|-------|----------|
| Assignees | At least one assignee set |
| Labels | At least one label set |
| Project | Must NOT be set |
| Milestone | Must NOT be set |
| Linked issue (Development) | `closingIssuesReferences` must contain at least one issue, and its number must match the issue ID in the PR title (e.g. title `GD-1085: ...` → linked issue `#1085`) |

Print a summary table with ✅ / ❌ for each check.
If any check fails, report it clearly but continue to Step 2 — do not stop.

---

## Step 2 — Verify Title and Description

### Title

The title must match the pattern:

```
<ISSUE-ID>: <Short meaningful title>
```

Where `<ISSUE-ID>` is the issue number from the linked issue (e.g. `GD-1085`).

### Description

The body must contain both of these sections in order:

```markdown
# Why
<motivation>

# What
<what the PR accomplishes>
```

To evaluate the **Why** section:

1. Fetch the linked issue body:
   ```bash
   gh issue view <issue-number> --repo godot-gdunit-labs/gdUnit4
   ```
2. Fetch the diff summary:
   ```bash
   gh pr diff <pr-number> --repo godot-gdunit-labs/gdUnit4
   ```
3. Read the existing PR description.
4. Cross-reference all three to assess whether the motivation is clearly and accurately captured.
5. **If the motivation is ambiguous or missing, stop and ask the user to clarify before continuing.**

Print a summary with ✅ / ❌ for title format, `# Why` section, and `# What` section.

---

## Step 3 — Suggest Options

Based on the issue body, PR diff, and existing description, generate suggestions.

### Title options — A, B, C

Provide three alternative titles following `<ISSUE-ID>: <Title>`.
Titles should be concise (under 72 characters), specific, and action-oriented.

### Description options — 1, 2, 3

Provide three alternative descriptions. Each option shows the **full** `# Why` / `# What` block
as it would appear in the PR — not just the Why sentence in isolation. The `# What` content may
vary slightly between options if different framings call for it, but keep it grounded in the diff.

Present them like this:

```
TITLE OPTIONS
  A) GD-XXXX: <option A>
  B) GD-XXXX: <option B>
  C) GD-XXXX: <option C>

DESCRIPTION OPTIONS

  1)
  # Why
  <motivation paragraph 1>

  # What
  <what paragraph/bullets 1>

  ---

  2)
  # Why
  <motivation paragraph 2>

  # What
  <what paragraph/bullets 2>

  ---

  3)
  # Why
  <motivation paragraph 3>

  # What
  <what paragraph/bullets 3>

Enter a combination (e.g. A2):
```

Wait for the user's input before proceeding.

---

## Step 4 — Apply Changes

Take the user's combination (e.g. `B2`) and construct the updated PR.

Keep the existing `# What` section unchanged unless it is missing or clearly wrong,
in which case generate a concise bullet-point summary from the PR diff.

Always include `Closes #<issue-number>` as the last line of the body — GitHub requires
this keyword to populate `closingIssuesReferences` and link the issue. Derive the issue
number from the `closingIssuesReferences` already on the PR, or from the issue ID in the title.

Apply the update:

```bash
gh pr edit <pr-number> --repo godot-gdunit-labs/gdUnit4 \
  --title "<selected title>" \
  --body "$(cat <<'EOF'
# Why
<selected why>

# What
<existing or generated what section>

Closes #<issue-number>
EOF
)"
```

Confirm the update was applied by printing the final title and description.
