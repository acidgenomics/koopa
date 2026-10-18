---
name: koopa-claude-permissions
description: >-
  Claude Code permission system internals, protected paths, permission modes,
  allow/ask/deny rule precedence, and the PreToolUse permissionDecision hook
  contract. Use when debugging unexpected permission prompts, understanding why
  Edit(.claude/**) or Bash(*) allow rules have no effect on .claude/ writes,
  reasoning about acceptEdits vs plan vs bypassPermissions mode tradeoffs, a
  headless claude -p call that hangs with no output, interpreter allow entries
  (bash, python, sh, xargs) that bypass deny rules, a deny rule that blocks a
  harmless test command, or a settings.json change that did not deploy on a
  work host.
---

# Claude Code Permission System

## Evaluation model

Permission modes set the **baseline**. Rules layer on top in order `deny → ask →
allow`. The first match wins; specificity does not change the order. Allow rules
cannot expand beyond the mode's capability boundary.

```
[mode baseline] → deny → ask → allow → default for unmatched
```

A matching `ask` rule still prompts even when a more specific `allow` rule also
matches the same call. A `PreToolUse` hook that exits with code 2 blocks before
rules are evaluated, so a blocking hook wins over an allow rule.

## Permission modes

| Mode | What runs without asking | Notes |
|---|---|---|
| `default` | Reads only | Prompts on first tool use |
| `acceptEdits` | Reads + file edits + common filesystem Bash† | See detail below |
| `plan` | Reads only | Same prompting as default; blocks edits by design |
| `auto` | Everything (background classifier) | Research preview |
| `dontAsk` | Only pre-approved tools | Non-interactive; ask rules are denied |
| `bypassPermissions` | Everything | Isolated containers/VMs only |

† `acceptEdits` Bash auto-approvals: `mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`,
`sed`: for paths inside the working directory or `additionalDirectories` only.
Protected paths (see below) still prompt in every mode except `bypassPermissions`.

### Headless `claude -p` hangs when `defaultMode` is `plan`

With `permissions.defaultMode: "plan"` in `settings.json`, a bare `claude -p "..."` hangs
with no output at all (not even `--debug` prints anything), so it looks like an auth,
network, or policy problem. It is not. Headless mode starts in plan mode with nobody to
approve a plan. Found by bisecting a copy of `settings.json` in a clean
`CLAUDE_CONFIG_DIR`: dropping only `permissions.defaultMode` fixed it, while dropping
`allow`, `ask`, `deny`, hooks, or `awsAuthRefresh` did not.

**Fix:** pass a mode on every headless call and keep `defaultMode` as is for interactive
sessions, for example `claude -p "..." --permission-mode default` (or `acceptEdits` when
the call must write files). Wrap scripted calls in a hard limit
(`perl -e 'alarm 90; exec @ARGV' claude -p ...`), since macOS has no `timeout`.
Intermittent `API Error: 503` from Bedrock is a separate, temporary problem.

## Protected paths: the key insight

**Writes to protected paths are never auto-approved in any mode except
`bypassPermissions`.** `permissions.allow` rules do NOT pre-approve them, the
safety check runs *before* allow-rule evaluation. An entry like `Edit(.claude/**)`
in `settings.json` has no effect on the per-mode outcome table.

In modes that prompt, the dialog offers **"Yes, and allow Claude to edit its own
settings for this session"**, a per-session approval that covers subsequent writes
without further prompting (file edits only; does not cover Bash `mkdir`).

### Per-mode behavior for protected paths

| Mode | Protected-path write |
|---|---|
| `default`, `acceptEdits`, `plan` | Prompted |
| `auto` | Routed to classifier |
| `dontAsk` | Denied |
| `bypassPermissions` | Allowed |

### Protected directories

- `.git`
- `.config/git`
- `.vscode`
- `.idea`
- `.husky`
- `.cargo`
- `.devcontainer`
- `.yarn`
- `.mvn`
- `.claude` (except `.claude/worktrees`)

### Protected files

`.gitconfig`, `.gitmodules`; shell rc/profile files (`.bashrc`, `.zshrc`,
`.zprofile`, `.zshenv`, `.zlogin`, `.zlogout`, `.profile`, `.envrc`, etc.);
package manager configs (`.npmrc`, `.yarnrc`, `.yarnrc.yml`, `.pnpmfile.cjs`,
`bunfig.toml`, etc.); build tool configs (`.bazelrc`, `.bazelversion`, etc.);
hook configs (`.pre-commit-config.yaml`, `lefthook.yml`, etc.); `.mcp.json`,
`.claude.json`, `pyrightconfig.json`, `.ripgreprc`.

## Escape hatches (ranked by practicality)

1. **Per-session click**: "Yes, and allow Claude to edit its own settings for this
   session." One click per session; covers file edits only (not Bash `mkdir`).
   This is the only reliable in-session option short of `bypassPermissions`.
2. **`bypassPermissions` mode**: skips all protected-path prompts. Too broad for
   general use; suitable only in isolated containers/VMs.

## PreToolUse hook permissionDecision contract

The hook writes JSON to stdout and exits 0:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "reason string (shown only on deny)"
  }
}
```

| Value | Effect |
|---|---|
| `"allow"` | Skips the permission prompt; tool call proceeds |
| `"deny"` | Blocks the call; reason shown to user |
| `"ask"` | Forces a prompt regardless of allow rules |
| `"defer"` | Passes to normal permission flow (same as no output) |

Exit code 2 (+ stderr) blocks the tool call *before* rules are evaluated, a
blocking hook wins even when an allow rule would otherwise pass.

Hook decisions do **not** bypass `deny` or `ask` rules, those are still evaluated
after the hook. A matching `deny` rule blocks even when the hook returned `"allow"`.

### ✗ Verified (Claude Code 2.1.177, Bedrock): hook `allow` does NOT override the protected-path gate

Tested empirically with three headless `claude -p --permission-mode acceptEdits`
probes from a real project root (koopa, 2026-06-14):

| Probe | Protected? | Hook | File created? |
|---|---|---|---|
| `_probe_normal_DELETEME.md` (repo root) | no | n/a | ✓ (positive control) |
| `.claude/rules/_probe_DELETEME.md` | yes | `allow` emitted | ✗: still prompted |
| `.claude/_probe_DELETEME.md` | yes | defer | ✗ (expected) |

**Conclusion:** A `PreToolUse` hook returning `permissionDecision: "allow"` does not
suppress the protected-path prompt. The safety check runs outside the hook's reach.
`permissions.allow` rules and hooks are both ineffective. The per-session click
("Yes, and allow Claude to edit its own settings for this session") is the only
config-level escape hatch for file edits. There is no workaround for Bash `mkdir`
into `.claude/`.

The `guard-claude-allow.sh` hook deployed on this machine (`~/.agents/hooks/`) is
**ineffective for protected-path writes**. It correctly emits `allow` JSON (unit
tests pass), but Claude Code ignores that decision for protected paths. The hook
can be left in place harmlessly or removed, it provides no benefit for `.claude/`
writes.

### ✓ Verified (Claude Code, 2026-10-11): `~/.claude/{rules,skills,hooks}` are symlink aliases, and edits through them are still gated

`~/.claude/rules` (and `skills`, `hooks`) are symlinks to `~/.agents/*`. Two headless
`claude -p --permission-mode acceptEdits` Write probes ran from a scratch directory:

| Path written | Result |
|---|---|
| `~/.agents/rules/_probe_headless_a.md` | ✗ blocked, pending a prompt (outside the working directories) |
| `~/.claude/rules/_probe_headless_b.md` | ✗ blocked: "sensitive file", and it "resolves through a symlink" to `~/.agents/rules/...` |

**Conclusion:** the protected-path check uses the lexical `.claude` path, and the
working-directory check uses the resolved `.agents` path, so the alias is gated twice.
Despite the `Edit(**)` allow, a write to `~/.agents/rules` from an unrelated directory
was blocked pending a prompt (not tested from inside the dotfiles repo). No `ask` twin
was added for rules or skills.
`~/.agents/hooks` has an explicit `ask` rule on top of that, because hooks are the
guards themselves.

**Rule syntax:** use `Edit(path)` for ask, allow and deny rules. A `Write(path)` rule is
rejected with "not matched by file permission checks"; Edit rules cover all file-editing
tools. `Edit(//**/*lessons.md)` is redundant with `Edit(**)`.

## Gotchas from a settings-hardening session (2026-10)

Observed while tightening the allow and deny lists. Items marked *untested* come
from how rules match, not from a probe.

- **An interpreter in `allow` can sidestep `deny` (untested).** Deny patterns
  match the command text. `Bash(git push*)` matches `git push` but not
  `bash -c "git push"` or `python -c "import subprocess; ..."`. So `Bash(bash:*)`,
  `Bash(sh:*)`, `Bash(python:*)`, `Bash(python3:*)` and `Bash(xargs:*)` in `allow`
  quietly turn the git deny list into advice. `find -exec`, `find -delete`,
  `sed -i` and `awk` with `system()` are the same class. `env` and `printenv` in
  `allow` read secret values past a path-based deny. The 2026-10 hardening removed
  all of these from the allow list and added explicit denies for secret paths.
- **Deny the secret *paths* as well as the files.** A `Read(**/.env*)` deny does
  not stop `cat`, `rg` or `head` in a Bash command. Add `Bash(cat *.env*)` and
  `Read` denies for `~/.aws`, `~/.gnupg`, `~/.ssh` and `*.pem`.
- **Path styles.** `Read(~/.ssh/**)` is home-relative. A leading double slash
  (`//Users/<name>/...`) is an absolute path, which is what a chezmoi template
  produces from `/{{ .chezmoi.homeDir }}/...`. Keep one style per file.
- **A changed deny list takes effect in the running session.** After
  `koopa configure user dotfiles` rewrote `~/.claude/settings.json`, the next Bash
  command that touched `~/.gnupg` was denied in the same session. The denial text
  only says the command "has been denied", so it does not name the rule.
- **Deny rules also hit throwaway test repositories.** `Bash(git add*)` and
  `Bash(git commit*)` denied a command that built a scratch repo in `$TMPDIR`.
  Test git aliases with a stub `git` on `PATH` that prints its arguments, and
  append `"$@"` to the alias body to mimic how git passes arguments.
- **On a work host the public settings template does not deploy.** When
  `~/.config/koopa/dotfiles-work` exists, the public `.chezmoiignore` skips
  `.claude/settings.json`, `.npmrc`, pip, uv and Zed settings, and the work repo
  supplies them. Mirror every security change into the work repo's own
  `dot_claude/settings.json.tmpl`, and never copy work-only content back into the
  public repo. See `koopa-dotfiles` ("Work-host layering").

## See also

- `koopa-maintain-claude-config`: where a new rule/hook/skill belongs; token budgets;
  the two-tree chezmoi ownership model for `~/.claude`.
- `koopa-agent-guards`: the plugin hooks that block harmless commands, with the
  alternative for each.
