---
name: koopa-obsidian
description: >-
  Driving the Obsidian desktop app's CLI against a local vault, and saving
  links as dated bookmark notes with `koopa app obsidian bookmark`. Use when
  asked to add a bookmark, bookmark this link, save a URL, search, read, or
  write a note, use daily notes, run obsidian property:set, build a Bases or
  Dataview view, or when hitting "Command line interface is not enabled" or
  "unable to find Obsidian".
---

# Obsidian CLI and bookmarks

`obsidian` is a command-line client bundled with the Obsidian desktop app. It
talks to the already-running app, not a headless engine, so every command needs
Obsidian open. Its default vault is the one marked active in
`~/Library/Application Support/obsidian/obsidian.json` (macOS) or
`~/.config/obsidian/obsidian.json` (Linux).

## Which vault, and where `KOOPA_BUCKET` fits

koopa resolves the vault in this order: `KOOPA_BUCKET`, then
`OBSIDIAN_VAULT_DIR`, then Obsidian's registry (the vault with `"open": true`,
else the highest `"ts"`). The result is symlink-resolved with `realpath`.

A vault is often reached through a symlink (for example `~/Documents` pointing
into a cloud-synced folder), so the path `obsidian vaults verbose` prints and
`KOOPA_BUCKET` can differ as strings while naming the same directory. Run
`realpath` on both before concluding they are different vaults.

## Bookmarks

Three mechanisms exist. Do not mix them up.

| Mechanism | Where it lives | Visible in |
|---|---|---|
| Dated bookmark note | `<vault>/YYYY/MM/DD/bookmarks.md`, one `- [Title](url)` per link | `bookmarks.base`, a `bookmarks-all` Dataview note, search |
| Native Bookmarks pane | `<vault>/.obsidian/bookmarks.json` | Obsidian's Bookmarks sidebar tab only |
| Link in a topic note | any `.md` note | that note |

The native pane is a JSON list read by the core Bookmarks plugin. It is separate
from the dated notes: a link added to one does not appear in the other. Use the
dated note by default, and the native pane only when the user asks for a sidebar
bookmark.

### Add a dated bookmark (preferred)

```sh
koopa app obsidian bookmark "https://example.com/page" --title "Page title"
koopa app obsidian bookmark "https://example.com/page" --title "Page title" --date 2026-10-14
koopa app obsidian bookmark "https://example.com/page" --vault-dir "$KOOPA_BUCKET"
```

It creates `YYYY/MM/DD/bookmarks.md` when missing, appends `- [Title](url)`, and
skips a line already present. It prints `Added: <path>` or `Already present:
<path>`. Only absolute `http://` and `https://` URLs are accepted. Prefer the
page's own title over a generic label.

Fallback when `koopa` is unavailable:

1. `obsidian read path="YYYY/MM/DD/bookmarks.md"` to see if the note exists.
2. Missing: `obsidian create path="YYYY/MM/DD/bookmarks.md" content="- [Title](url)"`.
3. Present: `obsidian append path="YYYY/MM/DD/bookmarks.md" content="- [Title](url)"`.

### Add a native Bookmarks-pane entry (only when asked)

```sh
obsidian bookmark url="https://example.com/page" title="Page title"
obsidian bookmarks verbose      # lists entries; confirms it landed
```

`obsidian web url="..."` only opens a URL in the Web viewer and saves nothing.

### Browsing all dated bookmarks

`bookmarks.base` (a Bases view filtered to notes named `bookmarks`) is a file
index, one row per day. Bases cannot show individual links. For one row per
link, use a `bookmarks-all` note holding a single `dataviewjs` block that
re-runs on every render:

````
```dataviewjs
const dayNoteRe = /^(\d{4})\/(\d{2})\/(\d{2})\/bookmarks\.md$/

const days = dv.pages()
  .where(p => p.file.name === "bookmarks" && dayNoteRe.test(p.file.path))
  .sort(p => p.file.path, "desc")

for (const p of days) {
  const text = await dv.io.load(p.file.path)
  const kept = text
    .split("\n")
    .filter(line => {
      const trimmed = line.trim()
      return trimmed.length > 0 && !trimmed.startsWith(">")
    })
    .join("\n")
  if (!kept) continue
  const [, y, m, d] = dayNoteRe.exec(p.file.path)
  dv.header(2, p.file.link.withDisplay(`${y}-${m}-${d}`))
  dv.paragraph(kept)
}
```
````

One-time prerequisites:

1. `obsidian plugins:restrict off` (no args reports `on` or `off`).
2. `obsidian plugin:install id=dataview`, then `obsidian plugin:enable id=dataview`.
3. Settings, Community plugins, Dataview, "Enable JavaScript queries" (GUI only).

## Prerequisites for the CLI (both required)

1. **Obsidian must be running.** Otherwise every command fails with `The CLI is
   unable to find Obsidian.` Fix: `open -a Obsidian`, then poll `pgrep -x Obsidian`.
2. **The CLI must be enabled in-app**, once: Settings > General > Advanced >
   "Command line interface". Until then: `Command line interface is not enabled.`

`obsidian help` and `obsidian help <command>` match the installed version and
are the authority.

## Argument syntax

- Arguments are `key=value` pairs, not flags. Quote values with spaces.
- `vault=<name>` targets a non-default vault.
- `file=<name>` resolves like a wikilink; `path=<path>` is exact, relative to the
  vault root. Always prefer `path=` in scripts.
- A bare word (`total`, `inline`, `permanent`, `verbose`) is a boolean switch.
- `\n` and `\t` inside `content=` become newline and tab.

## Command reference (curated subset)

| Area | Command | Result |
|---|---|---|
| Daily notes | `obsidian daily:path`, `daily:read`, `daily:append content="..."`, `daily:prepend` | path, content, append, prepend |
| Search | `obsidian search query="x" total`, `search:context query="x" limit=2`, `search query="x" format=json` | count, matching lines, JSON paths |
| Files | `create path=... content=...` (`overwrite` to replace), `read`, `append`, `prepend`, `rename`, `move`, `delete` (`permanent` skips trash), `file`, `wordcount` | file operations |
| Properties | `property:set path=... name="status" value="draft" type=text`, `property:read`, `properties`, `property:remove` | frontmatter |
| Counts | `tasks total`, `tags total`, `unresolved total`, `orphans total`, `files total`, `folders total` | counts |
| Structure | `outline path=... format=tree`, `backlinks path=...`, `links path=...` | per-file |
| Vault | `vault`, `vaults verbose`, `version` | vault facts |

For a large multi-paragraph note (tables, code spans, pipes), a direct
filesystem write is more reliable than `key=value` syntax when the vault is
writable that way; reserve `create`/`append` for short content.

## Vault layout and config

- **Registry file** (`obsidian.json`) maps a vault id to a `path`. Repoint a vault
  by editing that `path`, never by symlinking the vault folder: sync clients may
  skip symlinks or duplicate the target.
- **`.obsidian/app.json`**: `attachmentFolderPath`, `useMarkdownLinks` (false
  means `[[wikilinks]]`), `alwaysUpdateLinks`, `showUnsupportedFiles`.
- **`.obsidian/daily-notes.json`**: the daily-note `format`, a moment.js string
  such as `YYYY/MM/DD/[daily]`. A literal word needs square brackets, or it is
  silently parsed into a garbled path.
- **`.obsidian/core-plugins.json`** lists enabled core plugins; confirm live with
  `obsidian plugins:enabled filter=core`.
- Never let a dotfiles manager own `.obsidian/*.json`: the app rewrites them on
  every settings change, so a later apply silently overwrites the app's writes.

## Bases: give every table view a clickable title column

A Bases column showing a plain frontmatter string renders as text. `file.name`
is always rendered as a link. For a frontmatter label, add a formula and put it
first in `order`:

```yaml
formulas:
  titleLink: file.asLink(note.title)
properties:
  formula.titleLink:
    displayName: Title
views:
  - type: table
    order:
      - formula.titleLink
```

`file.asLink(display?)` links the row's own file; `link(path, display?)` links
an arbitrary path. A formula is always referenced with the `formula.` prefix.
Filter report-style bases on a frontmatter property such as `type == "report"`,
not `file.ext == "md"`.

## Should a `.txt` file become `.md`?

Obsidian indexes, searches, links, and graphs only `.md` files.

| Shape | Verdict |
|---|---|
| Prose, meeting notes, a pasted terminal session kept as a note, a short list | Convert with `mv file.txt file.md`. Use `mv`, not `cp`: it keeps the birth time and does not force a cloud placeholder to hydrate. |
| Header-row TSV/CSV, a path or ID manifest, a long command transcript | Leave as data. |

When unsure, search the vault for the basename before renaming.

## Markdown formatting review

The recurring defect is raw terminal output pasted with no code fence or
heading. Pre-filter with grep instead of reading every file, and write
intermediate lists under `mktemp`, never a fixed `/tmp` name:

```sh
nofence="$(mktemp)"
find -L . -name '*.md' -not -path './.obsidian/*' -print0 \
  | xargs -0 grep -L '```' > "$nofence"
tr '\n' '\0' < "$nofence" | xargs -0 grep -lE \
  '^\$ |Traceback|Error:|command not found|npm ERR|Exception|Permission denied|fatal:'
```

A file starting with a heading or frontmatter is almost always fine. Fix by shape:

- **Pure raw paste:** add an `# H1` from the filename and wrap the body in one
  fenced block, with a language hint when unambiguous.
- **Mixed prose and commands:** fence only the command or path block.
- **Ad hoc checklist:** convert to `- [x]` / `- [ ]` so `obsidian tasks total`
  sees them.
- **Label-then-URL pairs:** convert to `[label](url)`.

Verify fences are balanced (empty output means every fence closed):

```sh
find -L . -name '*.md' -print0 | xargs -0 grep -c '```' | awk -F: '$2 % 2 != 0'
```

## Failure modes

| Failure | Symptom | Action |
|---|---|---|
| App not running | `The CLI is unable to find Obsidian...` | `open -a Obsidian`; poll `pgrep -x Obsidian` |
| CLI not enabled | `Command line interface is not enabled...` | Toggle it in Settings (GUI, once) |
| Bare `obsidian` | Opens a blocking TUI | Always pass a subcommand from a script |
| `file=` ambiguous | wrong or no note | Use `path=` |
| `wordcount` on non-markdown | `Word count is only available for markdown files.` | Use `.md` only |
| `property:read` right after `property:set` says not found | seen once on a new file | `obsidian read path=...` or retry once |
| Direct read or write denied ("Operation not permitted") | macOS privacy protection on a cloud-synced folder | Use the `obsidian` CLI or `koopa app obsidian bookmark` |
| Editor tool refuses a write ("parent-directory symlink resolution changed") | Symlink check races a cloud provider | Retry via the CLI |
| New bookmark missing from `bookmarks-all` | It went to the native pane, or the note has not re-rendered | `obsidian bookmarks verbose`; reopen the note |

## Gotchas

- **App running and CLI enabled are independent prerequisites** with different
  errors. The setting is toggled once; only the app needs starting each session.
- **Never run bare `obsidian` from a non-interactive shell.** It hangs.
- **`orphans` and `deadends` ignore the markdown-only default.** Filter a
  `format=json` list against `.md` yourself.
- **`total` is command-specific.** `plugins` and `plugins:enabled` ignore it
  silently; check `obsidian help <command>`.
- **`obsidian eval code="..."` runs arbitrary JavaScript inside Obsidian.** Treat
  it like `eval()`.
- **`git status` can look clean with untracked files present** when
  `status.showUntrackedFiles` is `no`; use `--untracked-files=all`.
- **Compare vault paths with `realpath`, never as strings.**

## Limitations

- No headless mode: every command needs the GUI running.
- The command table is a curated subset; `obsidian help` is the authority.
- `obsidian search` is plain text; there is no semantic mode.
- `koopa app obsidian bookmark` writes dated notes only, not the native pane.
