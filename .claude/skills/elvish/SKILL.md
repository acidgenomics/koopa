---
name: elvish
description: >-
  Elvish shell programming pitfalls, namespace semantics, and koopa activation
  architecture. Use when writing or debugging .elv files, editing
  lang/elvish/include/header.elv or any activate-*.elv, or porting shell logic
  from bash/zsh to elvish.
---

# Elvish Programming

## eval Namespace Isolation

Every `eval` call runs in an **isolated temporary namespace**. Functions defined
inside an `eval` are NOT visible to the caller:

```elvish
eval "fn greet { echo hi }"; greet  # Exception: greet not found
```

**The koopa fix**: slurp all function-file bodies, concatenate into one string, and
`eval` the entire blob ONCE so every function shares one namespace. This is how
`lang/elvish/include/header.elv` loads the 22 function files.

## fn Captures Namespace at Execution Time (Closure Semantics)

`fn` snapshots the current namespace when the definition line **executes**, not at
compile time. A function that calls another function only works if the callee already
exists in the namespace at the moment `fn` runs.

**Consequence for the concat-and-eval-once loader**: if `activate-koopa.elv`
(alphabetically mid-sort in `activate/`) is concatenated in filename order,
`activate-starship` and `activate-zoxide` (which sort after it) don't exist yet when
`fn activate-koopa { ... }` executes — so calls to them fall through to external
command lookup.

**Fix**: filter `activate-koopa.elv` out of the main glob loop and append it last,
after all other activate/ files.

## use Is Lexical / Compile-Time

A function that references `path:`/`platform:`/`str:`/`math:` fails to **compile**
(not just runtime-error) unless a matching `use` appears earlier in the same
compilation unit. In the concat-and-eval-once blob, per-file `use` lines land
mid-blob in filename order and can precede or follow functions that need them.

**Fix**: hoist `use path`, `use platform`, `use str`, `use math` to the very TOP of
the assembled blob string before eval-ing. Duplicate `use` lines later in the blob
are harmless.

## Testing a Function File in Isolation Gives False Positives

Because `use path`/`platform`/`str`/`math` are hoisted once at the top of the
assembled blob (see above), an individual function file calling `str:trim-space` or
`path:is-regular` with no `use` line of its own is **not broken** — it relies on the
hoist, exactly like every other file in `functions/`. Running that file's function
standalone (`eval (slurp < functions/export/export-env.elv); export-env`) without
also hoisting those `use` lines first produces a `Command not found` error that
looks like a real bug but is a testing artifact.

**Rule**: always verify against the real mechanism — replicate `header.elv`'s
concat-and-hoist (or just source `header.elv` itself, excluding
`activate-color-mode-sync.elv` for headless runs per the note below) — never eval a
single function file in isolation and conclude it's broken from that alone.

## edit: Module Is Interactive-Only (Eager Compilation)

The `edit:` namespace (`$edit:before-readline`, etc.) only exists in a real
interactive line-editor session. References to `edit:` in any code — even inside a
function body — cause a **compilation error** when eval'd under `elvish -c` or
piped stdin, because elvish compiles the whole blob eagerly before running.

**Consequence**: the full blob (including `activate-color-mode-sync.elv`) cannot be
tested with `elvish -c`. Headless smoke tests must exclude that file. Production is
safe: `activate.elv` gates activation on `tty`, so the blob only runs in a real
terminal.

## Double-Quoted Strings: $ Is Already Literal

Elvish double-quoted strings do **not** interpolate variables. `$` is literal.
`\$` is an **invalid escape sequence** (parse error). Write `$paths`, not `\$paths`.

Valid escapes in double-quoted strings: `\n`, `\t`, `\\`, `\"`, `\uXXXX`.

## Wildcard / Glob Syntax

Globbing is native wildcard syntax, not a `path:` function (`path:glob` doesn't
exist). The `*` must be **unquoted**:

```elvish
for f [$dir/*[nomatch-ok].elv] { ... }  # correct
for f [(path:glob $dir'/*.elv')] { ... } # WRONG on two counts
```

`[nomatch-ok]` attaches directly after the wildcard character (`*[nomatch-ok].elv`),
NOT at the end of the pattern. Without it, elvish throws on zero matches.

## path: Module — What Exists in 0.21.0

**Valid**: `path:abs`, `path:base`, `path:clean`, `path:dir`, `path:eval-symlinks`,
`path:ext`, `path:is-dir`, `path:is-regular` (accepts `&follow-symlink`),
`path:join`, `path:temp-dir`, `path:temp-file`.

**Does NOT exist**: `path:glob`, `path:is-newer`, `path:exists`, `path:is-file`.

For mtime comparison use an external test: `(bool ?(e:test $a -nt $b))`.
`os:stat` in 0.21.0 has no portable mtime field.

## String Concatenation

`+` is **arithmetic** in elvish. For string joining use `str:join` or variable
compounding (`$a$b` or `$a'/suffix'`).

## brew shellenv Has No Elvish Emitter

`brew shellenv` (even with `elvish` as argument) always emits bash `export VAR="..."`
syntax. Homebrew supports bash/zsh/fish/csh/pwsh only. `eval`-ing its output in
elvish throws on the first `export` token.

**Fix**: set Homebrew env vars directly (`set-env HOMEBREW_PREFIX ...`), mirroring
what `lang/bash/functions/macos/macos-activate-homebrew.sh` does.

## (src)[name] Under eval (slurp < ...)

`(src)[name]` returns the literal string `[eval N]` when a script is loaded via
`eval (slurp < $file)`. `path:dir` of that yields `.` (relative). Elvish cannot
self-locate a script sourced this way.

**Consequence for activate.elv**: never derive `KOOPA_PREFIX` from `(src)` when the
file is eval-slurped. Trust the env var already set by rc.elv (koopa's rc.elv sets
`KOOPA_PREFIX` to an absolute path before calling activate). Mirror bash
`__koopa_export_koopa_prefix` which early-returns when `KOOPA_PREFIX` is already set
and valid.

## koopa Activation Architecture (lang/elvish/)

```
~/.config/elvish/rc.elv
  → sets $KOOPA_PREFIX (absolute, from XDG)
  → eval (slurp < activate.elv)
      → validates $KOOPA_PREFIX is set + is-dir; returns if not
      → sets KOOPA_ACTIVATE=1
      → eval (slurp < lang/elvish/include/header.elv)
          → globs core/prefix/export/activate/*.elv (excluding activate-koopa.elv)
          → appends activate-koopa.elv last
          → prepends hoisted `use path/platform/str/math`
          → appends fn-driver (KOOPA_DEFAULT_SYSTEM_PATH save + activate-koopa call)
          → eval the whole blob once in a shared namespace
```

The concatenate-and-eval-once loader is intentional — it is the only way to share
functions across files given elvish's `eval` namespace isolation.

## Starship elvish_indicator

Starship's default `elvish_indicator` is `"esh"`. Set it to `'>'` in the `[shell]`
block of `opt/dotfiles/chezmoi/dot_config/starship.toml.tmpl` to match elvish's
native prompt convention (`set edit:prompt = { tilde-abbr $pwd; put '> ' }`).
