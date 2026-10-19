# koopa plugin

Skills for using koopa in any project: what to run, why a tool resolves where
it does, and how to diagnose problems. The plugin also ships agent
shell-safety hooks (see Hooks below). It has no commands or subagents.

Skills and hooks enable together: installing the plugin turns on both, and
there is no per-component off switch.

`plugin.json` is the canonical Agent Plugins 1.0 (agent-plugins.org) package
identity: Copilot and Codex read it directly. `.claude-plugin/plugin.json`
and `gemini-extension.json` are generated from it by
`koopa develop generate-agent-config`; edit `plugin.json`, not those two,
and regenerate.

The dotfiles declare this plugin for Claude Code and Copilot CLI, and
`koopa update` refreshes it (`lang/python/src/koopa/agent_plugins.py`).

To use this plugin from Gemini CLI: `gemini extensions link
~/.local/share/koopa/plugins/koopa`.

## Contents

- `skills/koopa-cli` — command syntax: install, update, list, configure.
- `skills/koopa-env` — why a tool resolves from koopa vs. Homebrew/the system,
  and `KOOPA_AUTO_ACTIVATE` for non-interactive/agentic sessions.
- `skills/koopa-troubleshoot` — `koopa system check`/`info`, install logs, and
  why `koopa system prune-apps` needs confirmation before running.
- `skills/koopa-claude-permissions`: Claude Code permission system internals
  (protected paths, permission modes, allow/ask/deny precedence, the PreToolUse
  `permissionDecision` hook contract).
- `skills/koopa-agent-guards`: what each guard hook blocks or asks about, why, and
  the correct alternative; the `koopa.*` git config keys; and how not to work
  around a block.
- `skills/koopa-git-history-surgery`: rewriting git history safely with
  `git filter-repo` (removing secrets, rewriting author emails, de-duplicating
  commits).
- `skills/koopa-git-recovery`: recovering from git branch/state accidents
  (wrong-branch reset, alias side effects, untracked-file checkout collisions,
  stash cleanup).
- `skills/koopa-maintain-claude-config`: maintaining Claude Code configuration
  (CLAUDE.md, rules, hooks, skills): auditing bloat and deciding where a new
  rule belongs.
- `skills/koopa-obsidian`: the Obsidian desktop CLI and vault mechanics, and
  `koopa app obsidian bookmark` for dated bookmark notes (vs. the native
  Bookmarks pane and `bookmarks-all`).
- `skills/koopa-python`: Python virtual environment lessons (why moving a
  project breaks `.venv/bin/activate`, and why direnv `PATH_add` survives it).
- `skills/koopa-todo-org`: org-mode `todo.org` conventions for project task
  tracking.
- `skills/koopa-workflow-guidance`: workflow orchestration (plan mode etiquette,
  subagent discipline, session hygiene, git commit conventions).

## Hooks

Fifteen `PreToolUse` hooks in five groups, plus two Claude Code only hooks on
`SessionStart` and `Stop`. Ten run on `Bash`, registered in this order
(`guard_sensitive_paths.py` last). `guard_tmp.py` has its own group on
`Bash|Write|Edit|MultiEdit|NotebookEdit`, `guard_report_path.py` has a third group
on `Write|Edit|MultiEdit`, `guard_keywords.py` and then `guard_secret_content.py` share a
fourth on `Edit|Write|MultiEdit|NotebookEdit`, and `guard_env_files.py` has a fifth on
`Edit|Write|Read|Bash`. `guard_settings_keywords.py` (`SessionStart` and `Stop`) and
`guard_workspace_root.py` (`SessionStart`) are registered in `hooks/hooks.json` only, with
no matcher. The Copilot file has the fifteen `PreToolUse` hooks and no `SessionStart` or
`Stop` entry.

These are opinionated defaults. They ship on for every user of the plugin, they are
strict on purpose, and they encode one person's safety habits: no software install
or `uv` dependency change by the agent without your approval, no `rm -rf` outside `$TMPDIR`, no `/tmp` scratch files, session
reports go to your Obsidian vault instead of a `reports/` folder, no reading or editing
of `.env` files, a prompt before the agent touches `~/Documents` or `~/Downloads`, a
warning when a Claude Code session is not rooted in a git repository, and (once you
configure keywords) no configured keyword written into a publishable repository. If
that is not how you work, do not install the plugin. There is no per-hook switch and
no override. To run a blocked command, run it yourself in the terminal (in Claude
Code, type `!` before the command).

- `block_tmux_kill_server.py`: blocks `tmux ... kill-server`. It tears down
  every session on the socket, including concurrent jobs you cannot see or
  recover. Use `kill-session -t <name>`.
- `block_destructive_git.py`: hard-blocks `reset --hard`, `clean -fd`, force
  pushes, `git rm -rf`, `checkout -- .`, `branch -D`, and `git push origin main` or
  `master` (also `x:main`) from the current repo; `--force-with-lease` and `+refspec` count as
  force pushes. A push after a `cd` or `git -C` into a different repo is allowed. A push
  to `main` through another remote name, or a bare `git push`, is not matched by this rule.
- `audit_secrets_before_push.py`: on a real `git push`, lists the files in the
  outgoing commit range (`@{u}..HEAD`, else `origin/<branch>..HEAD`) and blocks
  when a secret-shaped filename appears (an environment file, `.pem`, `.p12`,
  `credentials.json`, `secrets.*`, `*_key.*`). The repository comes from
  `CLAUDE_PROJECT_DIR`, else the payload `cwd`, else the current directory. A
  git failure (not a repo, no range) never blocks.
- `guard_installs.py`: asks (`permissionDecision: ask`, never denies) before a
  command that installs software: `pip`, `npm`, `pnpm`, `yarn`, `cargo`, `gem`,
  `go install`, `brew`, `apt`, `dnf`, `yum`, `pacman`, `port`, `pipx`, `poetry add`,
  `uv add`, `cpan`/`cpanm`, `R install.packages`, `BiocManager::install`,
  `renv::install`, `koopa install`, and `curl ... | sh`. Detection holds behind
  wrappers (`sudo`, `env`, `timeout`), `bash -c`, `ssh host` (quoted or not),
  substitutions, and every command of a batched Copilot call. Read-only probes
  (`pip show`, `npm ls`, `brew info`) pass with no prompt. When the parser cannot
  decide, a text pattern decides whether to ask. Nothing is ever auto-approved.
- `block_uv.py`: asks (never denies) before a `uv` or `uvx` command that can
  change dependencies or environments (`uv sync`, `uv add`, `uv run`, `uv pip
  install`, `uv lock`, any `uvx` tool run), with the same wrapper, `ssh`, and
  batch detection. Read-only probes pass with no prompt: `uv --version`, `uv help`,
  `<sub> --help`, `uv pip list/show/freeze/tree/check`, `uv python list/find/dir`,
  `uv tool list/dir`, `uv cache dir/size`, `uv self version`, `uv version` (no
  bump), `uv tree --frozen/--locked`, and `uv lock --check`. When the parser
  cannot decide, a broad text pattern decides whether to ask. The file name is
  kept so existing registrations stay valid.
- `guard_broad_scan.py`: blocks `find`, `grep -r`, `rg`, and `fd` rooted at `~`,
  `$HOME`, `/`, `/Users`, `/home`, or a bare home directory. Deeper paths pass.
- `guard_rm.py`: denies recursive-force `rm` (and `find -delete`, `find -exec rm`)
  unless every target is strictly inside `$TMPDIR`, in any flag spelling and behind
  wrappers. It also auto-approves plain `rm`/`rmdir` that stay inside `$TMPDIR`
  (`permissionDecision: allow`), and has no opinion on anything else. It is inactive
  as an allow when `$TMPDIR` is unset or too broad, but still denies.
- `guard_tmp.py`: denies writing scratch files to `/tmp`, `/var/tmp`, or
  `/dev/shm` (redirects, `tee`, `touch`, `mkdir`, `cp`/`mv` destinations,
  interpreter code, and the Write/Edit tools) and tells the model to use
  `mktemp -d`. It is inactive when `$TMPDIR` is unset or itself under `/tmp`.
- `guard_hook_writes.py`: asks (`permissionDecision: ask`, never denies) before a
  Bash command rewrites a hook or settings file: `.agents/hooks`, `.claude/hooks`,
  or `.claude/settings*.json`, via `sed -i`, a redirect, `tee`, `mv`, `rm`, `cp`
  onto it, or interpreter code. Reads, running a hook, and editing a source
  checkout stay quiet. It is a speed bump, not a boundary: a script that writes
  the file itself is not seen. The Copilot registration sets
  `AGENT_HOOK_HARNESS=copilot` so the ask uses Copilot's output shape.
- `guard_report_path.py`: when an Obsidian vault is detected (`KOOPA_BUCKET`, else
  `OBSIDIAN_VAULT_DIR`, else Obsidian's own registry, `obsidian.json`), blocks a
  write to a dated `reports/YYYY/MM/DD/` or `reports/YYYY-MM-DD/` path, or directly
  under the project's top-level `reports/`, and names the vault path to use. With
  no vault detected it does nothing. A delete, or the source side of a move, is
  never blocked. `hooks/obsidian_vault.py` is its vault resolver.
- `guard_secret_content.py`: blocks a file write, on any path, whose new content holds a
  well-known credential: an AWS access key ID, a presigned URL signature, a Databricks or
  GitHub token, a bearer credential, or a private key with key material. Documented
  placeholders pass (a value containing `EXAMPLE`, or one with fewer than six distinct
  characters), as does text that only names a shape. The message names the kind, the
  file, and the line, never the value. It also reads `MultiEdit` and `NotebookEdit`
  bodies, which `hook_adapter.py` does not. Fails open on an internal error.
- `guard_keywords.py`: blocks a Write/Edit that would put a configured restricted
  keyword into a publishable repository. It is inert until you configure it, and the
  plugin ships no keywords. It reads three git config keys. The dotfiles `pre-commit`
  hook reads the same keys:
  - `koopa.keywords`: checked in the file path and in the new content.
  - `koopa.contentKeywords`: checked in the new content only (for a keyword such
    as a username that appears in every absolute path under your home).
  - `koopa.allowedRemotes`: remotes where the keywords are legitimate; an
    entry matches when it is a case-sensitive substring of the `origin` URL.

  ```sh
  git config --global --add koopa.keywords acmecorp
  git config --global --add koopa.contentKeywords jdoe42
  git config --global --add koopa.allowedRemotes git.acmecorp.example
  ```

  Deprecated aliases: `koopa.restrictedTokens`, `koopa.restrictedTokensContentOnly` and
  `koopa.corpRemoteAllowlist` are still read for one more release and will be removed
  in a later release. For each setting the hook uses the union of the new key and its
  old alias (de-duplicated), so a config renamed at a different time stays guarded.

  Each value is a case-insensitive regular expression that must not touch an ASCII
  letter or digit on either side (`acmecorp` does not match `acmecorporation`). Only the
  new content is checked, never the text an edit replaces. A match blocks only when the
  target is absolute, its directory exists inside a git work tree, `origin` is not
  allowlisted, and the path is not gitignored; any git failure (5 second timeout per
  call) allows the write. An invalid pattern is skipped with one warning line. Any
  unexpected error exits 0, because the git `pre-commit` hook is the backstop. The block
  message is generic and does not echo the keyword. A delete, or the source side of a
  move, is never checked.
- `guard_env_files.py`: blocks reading or editing `.env` and `.env.local`, through the
  file tools (`Edit`, `Write`, `Read`, Copilot `view`, `edit`, `create`, `apply_patch`) and
  through a shell command that names either file (`cat .env`, `grep KEY .env`,
  `python3 -c "open('.env')"`). A token check, not a verb check, so `ls .env` is blocked
  too. Loading the file without showing it is allowed: `source .env` or `. .env` at the
  start of a command, and `load_dotenv(...)`. `.envrc`, `.env.example`, `.venv` and a
  `.env/` directory do not match. A tool input it cannot read exits 2 (a credential check
  must not pass on input it cannot inspect), and so does any internal error. It is a text check, not a boundary: a glob
  or `$(printf ...)` gets around it.
- `guard_sensitive_paths.py`: asks (`permissionDecision: ask`, never denies) before a Bash
  command references `~/Documents` or `~/Downloads`, spelled `~`, `$HOME`, `${HOME}` or
  `/Users/<name>`. `./MyDocuments`, `~/Documents-old` and `/opt/Users/x/Documents` do not
  match. With no configuration every reference asks. The Copilot registration sets
  `AGENT_HOOK_HARNESS=copilot` so the ask uses Copilot's output shape. Exemptions come
  from the git config key `koopa.allowedPaths`: multi-valued, each value a path relative
  to your home directory that starts with `Documents` or `Downloads`. A reference is
  exempt when it sits at or under an allowed path, matched at a path-segment boundary
  (`Documents/notes` exempts `~/Documents/notes/a.md` but not `~/Documents/notes-old`),
  and not when the rest of the path climbs with `..`. Every reference in the command must
  be exempt. The example values are made up:

  ```sh
  git config --global --add koopa.allowedPaths Documents/notes
  git config --global --add koopa.allowedPaths Documents/tasks
  ```

- `guard_settings_keywords.py` (Claude Code only): on `SessionStart` and `Stop`, scans
  `$CLAUDE_PROJECT_DIR/.claude/settings.json` for a keyword from the same three
  `guard_keywords.py` config keys (and their deprecated aliases), under the same boundary
  rule and the same publishable-repository test. It exists because Claude Code writes a
  "don't ask again" permission rule itself, which is not a tool call, so no `PreToolUse`
  hook sees it. On `SessionStart` it adds the line numbers to the session context; on
  `Stop` it exits 2 with the message on stderr, unless `stop_hook_active` is true (the
  loop guard). The message never echoes the keyword. It is left out of the Copilot file
  because Copilot is documented to keep approvals in a user-level file outside the
  repository, and its `agentStop` event expects a JSON `decision`, not exit 2. Copilot's
  hooks reference documents a `stop_hook_active` flag for `agentStop`; this has not been
  checked in a live session.
- `guard_workspace_root.py` (Claude Code only): on `SessionStart`, prints one warning
  line (never blocks) when `$CLAUDE_PROJECT_DIR` is not inside any git repository, since
  a session rooted outside a repo never loads the project's `.mcp.json` and
  `.claude/settings.json`. A worktree passes. `CLAUDE_ALLOW_NONREPO_ROOT=1` silences it. It
  is left out of the Copilot file because it reads `CLAUDE_PROJECT_DIR`, which Copilot
  does not set.

The two Claude Code only hooks gate themselves: unless `CLAUDE_PROJECT_DIR` is set and
non-empty they exit 0 without output. Codex reads the same `hooks/hooks.json`, and this
gate keeps them quiet if Codex runs them without that variable.

Files:

- `hooks/hooks.json`: Claude Code and Codex format, commands use
  `${CLAUDE_PLUGIN_ROOT}`. It also holds the `SessionStart` and `Stop` entries.
- `com.github.copilot/hooks/hooks.json`: Copilot format (`version: 1`), commands
  use `${PLUGIN_ROOT}`, `timeout` 5. `PreToolUse` only.
- Each hook is a single Python entry point, with no `jq` dependency. It reads
  Claude `tool_input` and Copilot `toolCalls[]` payloads and asks the shell
  parser in `hooks/shell_command_scan.py` (through `hooks/guard_git_scan.py`,
  `hooks/guard_installs_scan.py` or `hooks/uv_command_scan.py` where a hook has
  its own scanner) whether a command would run the thing, so text that merely
  mentions it passes. When the parser cannot decide, a text pattern decides
  (for destructive git with no `cd` exemption). `guard_broad_scan.py` is text
  based only. A block prints the reason to stderr and exits 2; `guard_rm.py` also
  prints an allow decision on stdout for `rm` inside `$TMPDIR`. The ask hooks
  (`guard_hook_writes.py`, `guard_sensitive_paths.py`, `guard_installs.py`,
  `block_uv.py`) print an ask decision on stdout and exit 0.
  `guard_workspace_root.py` prints a plain warning line on stdout. Empty or malformed
  stdin exits 0.
- `hooks/hook_adapter.py`, `hooks/shell_command_scan.py`,
  `hooks/guard_git_scan.py`, `hooks/guard_installs_scan.py`,
  `hooks/uv_command_scan.py`, `hooks/guard_rm.py`, `hooks/guard_tmp.py`,
  `hooks/guard_hook_writes.py`, `hooks/guard_report_path.py`,
  `hooks/guard_keywords.py`, `hooks/guard_env_files.py` and `hooks/obsidian_vault.py` are
  bundled copies of the dotfiles engine and duplicate it until the dotfiles drop
  theirs. Keep them verbatim. The hook files
  must stay valid Python 3.10, because `python3` may be an old system interpreter.
  `hooks/guard_sensitive_paths.py` and `hooks/guard_settings_keywords.py` import their git
  config helpers from `hooks/guard_keywords.py`, so those files travel together.

Not verified (needs a human):

- That Claude Code, Codex, Copilot CLI, and VS Code actually load these hook
  files from the installed plugin and run the hooks.
- That `${PLUGIN_ROOT}` expands in Copilot CLI hook commands. It is documented
  for VS Code plugin hooks but not confirmed for Copilot CLI.
- That Codex reads `hooks/hooks.json` and sets `${CLAUDE_PLUGIN_ROOT}`.
- That a block (exit 2 with the reason JSON on stderr) is shown to the model by
  each harness as the reason for the denial.
- That the 5 second Copilot timeout is enough for the secrets hook on a large
  outgoing range. A timeout makes the hook exit 0 (no block).
- That a Claude Code `permissionDecision: allow` from `guard_rm.py` is honored
  the same way by Codex, Copilot CLI, and VS Code (Claude Code is the documented
  contract; the others are unconfirmed). Where it is ignored, `rm` in `$TMPDIR`
  simply prompts as usual.
- That the `Bash|Write|Edit|MultiEdit|NotebookEdit` matcher for `guard_tmp.py`
  matches Copilot CLI's own tool names (`create`, `apply_patch`). The hook
  recognizes them in the payload, but the matcher may not select them.
- That `$TMPDIR` is set in the hook's environment in each harness. `guard_rm.py`
  and `guard_tmp.py` read it directly.
- That `AGENT_HOOK_HARNESS=copilot` in the `env ... python3 ...` command prefix of
  `guard_hook_writes.py` is honored by Copilot CLI and VS Code, and that each
  harness accepts the bare `permissionDecision: ask` shape it prints for Copilot.
- That the `Write|Edit|MultiEdit` matcher for `guard_report_path.py` matches
  Copilot CLI's own file tool names, and that a Codex session reports file
  writes in a payload the hook recognizes (it reads `apply_patch` envelopes).
- That the Obsidian registry path (`~/Library/Application Support/obsidian/obsidian.json`
  or `~/.config/obsidian/obsidian.json`) matches every Obsidian install, including
  Flatpak and Snap builds.
- That Copilot CLI's `edit`/`create` tool shapes and its `apply_patch` envelope are
  checked end to end by `guard_keywords.py` in a live session (the tests feed
  recorded-shape payloads), and that the `Edit|Write|MultiEdit|NotebookEdit` matcher
  selects Copilot's own tool names. The shared adapter reads neither a `NotebookEdit`
  payload's `notebook_path` nor its cell source, so that tool is matched but not
  actually checked.
- That the hook's regular expressions (Python `re`) agree with the `pre-commit` hook's
  `grep -E` on every pattern. POSIX classes such as `[[:alpha:]]` are not supported by
  Python `re`.
- That Codex runs the `SessionStart` and `Stop` hooks from `hooks/hooks.json` at all, and
  what environment and payload it gives them. A hook that Codex does not run is simply
  inactive.
- That the Claude Code only self-gate holds under Codex: `guard_settings_keywords.py` and
  `guard_workspace_root.py` assume Codex does not set `CLAUDE_PROJECT_DIR`. If Codex
  does set it, both hooks run there; `guard_settings_keywords.py` then relies on Codex
  sending `stop_hook_active` on `Stop`, and a harness that does not could loop on exit 2.
- That Claude Code sets `CLAUDE_PROJECT_DIR` for `SessionStart` and `Stop` hook commands
  in every launch mode (terminal, IDE extension, headless `claude -p`), and that it
  expands `${CLAUDE_PLUGIN_ROOT}` there.
- That `Edit|Write|Read|Bash` selects Copilot CLI's own tool names for `guard_env_files.py`
  (the hook reads `view`, `edit`, `create` and `apply_patch` shapes in the payload), and
  that Copilot CLI and VS Code accept the bare `permissionDecision: ask` that
  `guard_sensitive_paths.py` prints under `AGENT_HOOK_HARNESS=copilot`.
- That a `SessionStart` hook's stdout (`guard_workspace_root.py`) and `additionalContext`
  (`guard_settings_keywords.py`) are shown to the model in each Claude Code version.
