---
name: koopa-plugin-hooks
description: >-
  Maintaining the agent hooks the koopa plugin ships under plugins/koopa/hooks,
  covering the layout, the two hooks.json registries, a checklist for adding a hook, testing
  a hook without a harness, loading the plugin locally with --plugin-dir, and telling
  plugin hooks apart from user-level hooks. Use when adding, changing, testing, or
  debugging a hook under plugins/koopa/hooks, editing hooks.json registration, a hook
  that does not fire or fires twice, loading the plugin from a checkout, or isolating
  plugin hooks from user-level hooks to see which one blocked a call.
---

# koopa plugin hooks

This skill is for maintainers of the hooks. It is a repo skill and is not shipped in
the plugin. User-facing behavior of each hook is documented in the plugin README
(`plugins/koopa/README.md`, "Hooks"); each hook's docstring is the source of truth for
what it blocks.

## Layout

- One Python entry per hook in `plugins/koopa/hooks/`, run as `python3 <file>`.
- `hook_adapter.py` (normalizes Claude Code and Copilot CLI payloads into file
  targets) and `shell_command_scan.py` (reads a command the way a shell does) sit
  beside the hooks. Scanners (`guard_git_scan.py`, `guard_installs_scan.py`,
  `uv_command_scan.py`) are imported by name, so a script and its helpers must stay in
  the same directory. Run as a script, Python puts that directory first on `sys.path`.
- Two registration files:
  - `plugins/koopa/hooks/hooks.json`: read by Claude Code and Codex. Commands use
    `${CLAUDE_PLUGIN_ROOT}`, with no `timeout`.
  - `plugins/koopa/com.github.copilot/hooks/hooks.json`: read by Copilot (`version: 1`).
    Commands use `${PLUGIN_ROOT}` and every hook has `"timeout": 5`.
- Claude Code only hooks (`guard_settings_keywords.py` on `SessionStart` and `Stop`,
  `guard_workspace_root.py` on `SessionStart`) are registered only in the first file.
- A hook that must answer in Copilot's output shape (the ask hooks
  `guard_hook_writes.py`, `guard_sensitive_paths.py`, `guard_installs.py` and
  `block_uv.py`) is registered in the Copilot file with an
  `env AGENT_HOOK_HARNESS=copilot` prefix before `python3`.

## Checklist for adding a hook

1. Write `plugins/koopa/hooks/<name>.py` with a module docstring that states what it
   blocks, what it does not, the input shapes, and the fail policy. Follow the house
   pattern:
   - No `jq`, no non-stdlib imports. Parse stdin as JSON in Python.
   - Fail open on empty or malformed stdin (exit 0).
   - A block prints the reason on stderr and exits 2.
   - An ask hook prints a `permissionDecision` on stdout and never denies.
   - Keep the file parseable as Python 3.10 (see Gotchas).
2. Register it in the right file or files, in the right matcher group. Add the Copilot
   entry with `"timeout": 5`, plus the `env AGENT_HOOK_HARNESS=copilot` prefix if it
   needs the Copilot output shape. Claude-only hooks go in the first file only.
3. Add `lang/python/tests/test_plugin_hooks_<name>.py`:
   - scanner or function cases, parametrized;
   - the real entry through `subprocess` for a Claude payload
     (`{"tool_name": "Bash", "tool_input": {"command": ...}}`) and for a Copilot
     `toolCalls[]` batch (`{"toolCalls": [{"args": {"command": ...}}]}`), with the
     command hidden in a later batch entry;
   - empty stdin and malformed stdin;
   - a negative control: text that only mentions the command must pass.
4. Update the two cross-hook tests: the registration test
   `test_hooks_json_files_register_all_hooks_in_order` in
   `test_plugin_hooks_git.py` (group counts, order, totals, timeouts) and the file list
   in `test_hook_files_parse_as_python_310` in `test_plugin_hooks_tmux.py`.
5. Update the plugin README "Hooks" section (counts, the group list, the shared-file
   notes, the "not verified" list if the hook relies on unconfirmed harness behavior).
6. Run the gates:

   ```sh
   PYTHONDONTWRITEBYTECODE=1 pytest lang/python/tests/test_plugin_*.py
   koopa develop generate-agent-config --check
   ```

7. Run the live check (see "Safe live checks").

## Testing without a harness

A hook is a stdin to exit-code function. Pipe a payload and read `$?`:

```sh
# Claude Code shape
printf '%s' '{"tool_name":"Bash","tool_input":{"command":"tmux -L koopa-hook-test kill-server"}}' \
  | python3 -B plugins/koopa/hooks/block_tmux_kill_server.py; echo "exit $?"

# Copilot CLI shape: a batch, the offending command is not first
printf '%s' '{"toolCalls":[{"args":{"command":"pwd"}},{"args":{"command":"tmux -L koopa-hook-test kill-server"}}]}' \
  | python3 -B plugins/koopa/hooks/block_tmux_kill_server.py; echo "exit $?"
```

Both exit 2 with the reason on stderr. A command that merely mentions the text, such as
`echo "tmux kill-server"`, exits 0.

- Run Python with `-B` and tests with `PYTHONDONTWRITEBYTECODE=1`, so no `__pycache__`
  appears under `plugins/`. Since 2026-10-23 koopa's shell activation exports
  `PYTHONPYCACHEPREFIX` (`${XDG_CACHE_HOME}/python`) instead of `PYTHONDONTWRITEBYTECODE`.
  A harness not started from a koopa shell has neither, so only `-B` reliably keeps the
  hooks clean: they import shared modules such as `hook_adapter`. Both `hooks.json` registries run every hook as `python3 -B`, and
  `test_hooks_json_files_register_all_hooks_in_order` pins that. The existing tests set
  `PYTHONDONTWRITEBYTECODE=1` in the subprocess environment and run entries with `-B`.
- Tests that read git config isolate it: `GIT_CONFIG_GLOBAL` points at a file under
  `tmp_path`, `GIT_CONFIG_SYSTEM=/dev/null` (the tests also set `GIT_CONFIG_NOSYSTEM=1`),
  and `HOME` is under `tmp_path`. See `test_plugin_hooks_keywords.py`. Do the same in any
  new test that touches git, so the real user and system config are never read.

## Loading the plugin locally

- Claude Code: `claude --plugin-dir <path to plugins/koopa>`. The hook source label then
  reads `koopa@inline`. Observed 2026-10-11, not covered by a test.
- An installed plugin whose marketplace is a directory is read from that folder, so edits
  apply at the next session start or on `/reload-plugins`, and `claude plugin update`
  reports nothing to update. Observed 2026-10-11, not covered by a test.
- `claude plugin details koopa@koopa` shows the component counts, and `/hooks` lists the
  plugin hooks with their source. Observed 2026-10-11, not covered by a test.
- Copilot CLI: `copilot --plugin-dir <path>`. Observed 2026-10-11, not covered by a test.

## Isolating plugin hooks from user-level hooks

Several hooks run side by side and the first denial is the one shown, so a block message
alone may not prove which hook fired.

- Claude Code: the block message names the hook script and its source plugin. Read that
  before assuming the plugin hook is the one that fired.
- Copilot CLI: run with a scratch `COPILOT_HOME`: a `mktemp -d` directory holding a copy
  of `config.json` at mode 600, deleted afterwards (only what you created, under
  `$TMPDIR`). Add `--log-level debug --log-dir <scratch>`. In the debug log, the line
  `loadDeferredRepoHooks ... loaded repo hooks (hookCount=N)` shows how many user and repo
  hooks loaded, and `[rust:hooks] [hook stderr]` shows a hook's output. Observed
  2026-10-11, not covered by a test.

## Safe live checks

- Any git guard: use a scratch repository from `mktemp -d`, never a real checkout.
- The tmux guard: use a made-up socket, for example `tmux -L koopa-hook-test kill-server`.
  It is harmless if the hook fails, because no such server exists.
- Never aim a destructive-command test at a real repository or real paths.
- Keep the payload on stdin (the piping recipe above) when you only need to check the
  hook. Reserve a real harness session for the registration and loading questions.

## Gotchas

- **Remove the registration first, then delete the file.** Removing or renaming a hook
  script that is still registered makes every tool call that matches fail with a hook
  error until the registration is removed. Observed 2026-10-11, not covered by a test.
- **`python3` may be an old system interpreter.** Hooks run under whichever `python3` is
  first on `PATH`, so keep every file parseable as Python 3.10
  (`test_hook_files_parse_as_python_310` parses each file with `feature_version=(3, 10)`).
  `X | None` annotations are fine; newer syntax is not.
- **A shell guard must read the command the way a shell does.** Matching raw text blocks
  reports and commit messages that merely mention a command. Use
  `shell_command_scan.py`, keep the old text pattern only as the fallback when parsing
  raises, and add a negative-control test.
- **New plugin files can look absent from `git status`.** Some checkouts set
  `status.showUntrackedFiles=no`. The repository's own files and docs do not set it, so
  this was observed on the author's machine only. Use
  `git status --untracked-files=all` to see new files.
- **Deny beats ask beats allow** when several plugin and user hooks answer the same call.
  This is documented harness behavior, not repository behavior.
- **Claude-only hooks.** GitHub's hooks reference documents a `stop_hook_active` flag on Copilot's
  `agentStop` (not checked in a live session), and `guard_settings_keywords.py` relies on
  that flag on Claude Code's `Stop` to avoid a loop. The
  Claude-only hooks gate themselves on `CLAUDE_PROJECT_DIR` being set and non-empty, and
  exit 0 without output otherwise, because Codex reads the same `hooks/hooks.json`.
- **Do not copy files out of the shared set.** `guard_sensitive_paths.py` and
  `guard_settings_keywords.py` import their git config helpers from `guard_keywords.py`,
  and most hooks need `hook_adapter.py`; see the README note on files that travel together.

## Cross-repo changes

A hook change often spans the plugin repo, the public dotfiles repo, and a private
overlay repo that applies on top of the dotfiles. Observed 2026-10-11, not covered by a
test.

- **Push the repo that adds before the repo that removes.** Move a guard into the plugin
  first, then delete the old copy from the dotfiles, then update any overlay that
  depended on it. A user who pulls the removal before the addition has no guard until
  `koopa update` runs.
- **Never leave one repo creating a path while another deletes it.** A tracked
  `.gitkeep` keeps an empty folder such as `chezmoi/dot_agents/hooks` in git, and chezmoi
  then creates the matching target folder. If a `.chezmoiremove` in another repo deletes
  that folder, every apply flips back and forth. Remove the folder entry from the removal
  list first (list the old files individually), then push the `.gitkeep`. Check with
  `chezmoi status` against each source: the path must appear in neither.
- **Rename a shared config key in two steps.** Let every reader accept the old and the
  new key (the union of their values) for one release, rename the key in the private
  config, then drop the alias. Otherwise a guard goes quiet between the two pushes.
- **Tell users the order:** `koopa update`, then `koopa configure user dotfiles`.
- **A shell without credentials for a private overlay cannot fetch it.** A failed fetch
  leaves a stale `origin` ref. Trust the local `git status`, and confirm the remote from
  a shell that is logged in to the right account.

## Not verified

- How Codex loads `hooks/hooks.json`, whether it sets `${CLAUDE_PLUGIN_ROOT}`, and whether
  it runs `SessionStart` and `Stop`.
- How VS Code Copilot loads the plugin hooks.
- Whether `${PLUGIN_ROOT}` and the `env AGENT_HOOK_HARNESS=copilot` prefix are honored by
  Copilot CLI hook commands. The README lists these as unconfirmed.
- Any flag or log line above marked "observed 2026-10-11" can change with a harness
  release; re-check before relying on it.
