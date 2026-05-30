# Lessons

## Plan Files: System-Generated Names Must Be Used As-Is

When the system specifies a plan filename (in the plan mode system message), use that exact path — do NOT rename it with a `YYYY-MM-DD-` prefix. VS Code's plan review UI looks for the exact filename the system specified; renaming breaks the UI.

The `YYYY-MM-DD-` date prefix convention applies only to manually created plan/reference docs, not system-assigned plan filenames.

## Use `has_sudo` for Sudo Checks — Don't Add New Sudo Functions

`koopa.system.has_sudo()` is the single function for checking whether
sudo is currently usable without a password prompt. Do not create additional helpers
(e.g., `_has_sudo`, `can_sudo`, `check_sudo`) for this purpose — they duplicate it.
Always import and reuse `has_sudo` from `koopa.system`.

## app.json Edits Require Formatting and a Revision Bump

After modifying `etc/koopa/app.json`, always run:

```
koopa develop format-app-json
```

This keeps formatting consistent and all keys sorted correctly. Also increment
the `revision` field for the edited app entry (add `"revision": 1` if absent)
to signal that installed instances need to be re-linked or reinstalled.

## Chezmoi Templates Run Before Post-Install Generators

When a chezmoi template needs to detect something that an install script
generates *after* `chezmoi apply` (e.g., a file written by a post-chezmoi
function), `stat` on the generated output will always miss — chezmoi runs
first. Instead, detect the *source* that triggers generation (e.g., the
upstream `.tmTheme` file that causes `.rstheme` to be generated) rather than
the generated artifact itself.

## CLI Changes Require Regenerating Completions

When renaming, adding, or removing CLI commands in koopa, always run
`koopa develop generate-completion` afterward. The shell autocomplete definitions
are generated, not hand-maintained, so they go stale if not regenerated. This
caused `koopa app brew upgrade-brews` to appear in completions even though the
command was renamed to `koopa app brew upgrade`.

## Correct Command to Re-run Dotfiles Installer

The command to re-run the dotfiles install script is:

```
koopa configure user dotfiles
```

NOT `koopa configure-dotfiles` (that command does not exist).

## Dev Tools Are Standalone Apps — Never Add to .venv

Tools like `ruff`, `ty`, `pyright`, and `pytest` are installed as standalone
koopa apps (under `app/` or `opt/`), NOT as dependencies in the project `.venv`.
Never suggest adding them to `[project.optional-dependencies]` or installing
them via `uv pip install` into the venv. They run from PATH as independent
binaries with their own Python environments.

## macOS Sandboxed App Preferences Cannot Be Written From External Processes

macOS TCC (Transparency, Consent, and Control) blocks ALL external process I/O
to sandboxed app containers on modern macOS — including `defaults write`,
`PlistBuddy`, and direct `plistlib` file writes. This is a kernel-level
restriction, not a Python or API issue.

**Do not attempt to write sandboxed app preferences from install scripts.**
Instead:
- Write only to non-sandboxed paths the app reads (e.g., `~/Library/Application
  Support/<App>/` for theme files, config files, etc.)
- Print a one-time human-readable notice telling the user to set the preference
  manually inside the app

Example pattern:

```python
# Install the theme file (non-sandboxed path — this works fine)
with open(os.path.join(schemes_dir, "MyTheme.bbColorScheme"), "w") as fh:
    fh.write(scheme_content)

# Do NOT attempt: defaults write, plistlib, PlistBuddy to the container
# Instead, tell the user:
print("⚠ BBEdit: set the active color scheme in BBEdit > Preferences > Appearance.")

## Dotfiles Are Managed by Chezmoi — Edit the Source

Home-directory dotfiles (e.g., `~/.claude/settings.json`, `~/.bashrc`,
`~/.config/...`) are managed by chezmoi. The source of truth lives in
`~/.config/koopa/dotfiles/chezmoi/`. When modifying a dotfile, always edit
the corresponding chezmoi source template/file (e.g.,
`dot_claude/settings.json`) in addition to (or instead of) the deployed copy.
Otherwise the change will be overwritten on the next `chezmoi apply`.
