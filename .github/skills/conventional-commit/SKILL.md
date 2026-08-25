---
name: conventional-commit
description: 'Create a git commit following the Conventional Commits specification. Use when the user runs /commit or asks to commit staged changes with a conventional message.'
---

You are acting as a **conventional commit assistant**. When the user runs `/commit` or asks you
to commit changes, your job is to analyse the staged (or unstaged) changes, craft a well-formed
[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) message, and perform the
commit.

---

## 1. Resolve Git identity and signing

Before starting, inspect the effective Git identity for the current repository:

```bash
git config --show-origin --get-regexp '^(user\.(name|email|signingkey)|commit\.gpgsign|gpg\.format)$'
```

- Use the resolved `user.name`, `user.email`, and related signing settings from the existing
  Git config files that apply to this repository.
- Do **not** hardcode, invent, or override the author/committer identity with `--author`,
  `GIT_AUTHOR_*`, or `GIT_COMMITTER_*` unless the user explicitly asks.
- If `user.name` or `user.email` do not resolve, ask the user to input them and set them with:

```bash
git config user.name "<name>"
git config user.email "<email>"
```

---

## 2. Check current branch

Run:

```bash
git branch --show-current
```

- If the current branch is `main`, `master`, or another protected/default branch, the changes
  **must not** be committed directly to it.
- If there are **no staged changes yet** (nothing output by `git diff --staged --stat`):
  - Inspect any unstaged changes with `git diff --stat` and `git status --short` to get a sense
    of the scope and type of work.
  - Derive a branch name following this pattern using the appropriate Conventional Commit type
    as the prefix:

    ```
    /<type>/<short-kebab-description>
    ```

    Examples: `/docs/update-readme`, `/fix/fix-the-bug`, `/feat/added-button`

  - Propose the branch name to the user and ask for confirmation before creating it:

    > Create and switch to branch `<proposed-name>`? (yes / rename / cancel)

  - **yes** — run `git checkout -b <branch-name>` and continue.
  - **rename** — ask the user for their preferred branch name, then create it.
  - **cancel** — stop without making any changes.
- If changes **are already staged** on a protected branch, warn the user:

  > ⚠️ You have staged changes directly on `<branch>`. It is recommended to move these to a
  > feature branch before committing. Create a new branch now? (yes / no)

  - **yes** — follow the same branch-naming flow above, then run
    `git checkout -b <branch-name>` (staged changes carry over automatically).
  - **no** — proceed at the user's own risk.

---

## 3. Check for staged changes

Run the following and capture the output:

```bash
git diff --staged --stat
```

- If **nothing is staged**, check for unstaged changes with `git status --short`.
  - If there are unstaged changes: List the unstaged changes and ask the user whether they want to stage everything
    (`git add -A`) before proceeding, or let them stage manually and retry.
  - If the working tree is clean too, respond: "Nothing to commit — working tree is clean."
    and **stop**.
- If changes are staged, continue.

---

## 4. Inspect the diff

Run:

```bash
git diff --staged
```

Read the full diff carefully to understand **what changed and why**.

---

## 5. Determine the commit type

Choose **exactly one** type:

| Type       | When to use |
|------------|-------------|
| `feat`     | A new feature or capability |
| `fix`      | A bug fix |
| `docs`     | Documentation-only changes |
| `style`    | Formatting, whitespace — no logic change |
| `refactor` | Code restructuring without feature or fix |
| `perf`     | Performance improvement |
| `test`     | Adding or updating tests |
| `build`    | Build system, Docker, CI config, dependencies |
| `ci`       | CI/CD pipeline changes only |
| `chore`    | Tooling, maintenance tasks unrelated to src |
| `revert`   | Reverting a previous commit |

If the diff spans multiple types, pick the **dominant** one. If truly mixed, split the suggestion
into two commits and ask the user which to do first.

---

## 6. Determine the scope (optional)

The scope is a short noun in parentheses describing the affected area:

- Use the **module, package, component, or filename** (without extension) that changed most.
- Examples: `(auth)`, `(api)`, `(dockerfile)`, `(deps)`, `(readme)`
- Omit the scope when the change is truly cross-cutting or repo-wide.

---

## 7. Determine breaking changes

If the diff contains any of the following, mark the commit as **breaking** by appending `!`
after the type/scope and adding a `BREAKING CHANGE:` footer:

- Removed or renamed public API, function, env var, or config key
- Changed behaviour of an existing public interface
- Dropped support for a runtime version or dependency

---

## 8. Write the commit message

Follow this structure exactly:

```
<type>[(<scope>)][!]: <description>

[optional body]

[optional footer(s)]
```

Rules for the **description** (first line):
- Imperative mood: "add", "fix", "remove" — not "added", "fixes", "removed"
- No period at the end
- 72 characters max on the first line
- Lower-case first letter (unless it starts with an acronym or proper noun)

Rules for the **body** (optional):
- Separate from the subject with a blank line
- Wrap at 72 characters
- Explain *what* and *why*, not *how*
- Include only when the reason or context isn't self-evident from the diff

Rules for **footers** (optional):
- `BREAKING CHANGE: <description>` — required when breaking
- `Closes #<issue>` / `Fixes #<issue>` — include when the user mentions an issue number
- `Co-authored-by: Name <email>` — include when relevant

---


## 9. Present and confirm

Show the proposed commit message in a fenced code block, then ask:

> Commit with this message? (yes / edit / cancel)

- **yes** — proceed to step 10.
- **edit** — ask the user for their revised message and use that instead.
- **cancel** — stop without committing.

---

## 10. Perform the commit

Run:

```bash
git commit -m "<subject line>" -m "<body + footers joined by newlines>"
```

Or, if the message is complex, write it to a temp file and use:

```bash
git commit -F /tmp/commit_msg.txt
```

- Let Git use the active repository config for author, committer, and signing settings.
- If `commit.gpgsign=true` is configured, do not disable it unless the user explicitly asks.

After the commit succeeds, show the output of `git log --oneline -1` to confirm.

---

## 11. Push the commit

Ask the user:

> Push this commit? (yes / no)

- **yes** — run `git push` and show the output.
    - If the push fails due to no tracking branch, ask if the user wants to set the upstream and push with
      `git push --set-upstream origin <branch>`, where `<branch>` is the current branch name.
- **no** — stop here without pushing.

---

## Key principles

- **Never stage or unstage files without explicit user approval.**
- **Never amend or rebase existing commits** unless the user explicitly asks.
- **One logical change per commit** — suggest splitting if the diff covers unrelated concerns.
- **Ask before acting** on anything destructive or irreversible.
- **Evidence-based** — the message must be grounded in what the diff actually shows.
