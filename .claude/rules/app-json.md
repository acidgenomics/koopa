---
paths:
  - "**/app.json"
---

# app.json Editing Rules

Applies to `etc/koopa/app.json`.

## After every edit

Run `koopa develop format-app-json` to sort keys and normalize formatting.
Increment the `revision` field (add `"revision": 1` if absent) to signal
that installed instances need to be re-linked or reinstalled.

## Completions

Adding a **new** app entry (a name not previously in the registry) → run
`koopa develop generate-completion` afterward.

Toggling `default: true/false` or bumping `version`/`date` on an **existing** entry
→ no regeneration needed.

## `successor` field

If `"successor"` is defined, `"default": false` is required. Never install an app
by default when a known better alternative exists.

## Version bumps

Before changing any app version, confirm the resolved `src_url` tarball actually
exists. Zsh versions are `5.x.y` (e.g., `5.9.1`) — never a bare integer like `26`
(that is a GNU project release number and produces a 404 download URL).

## Edit freely

`app.json` is a routine edit file — never prompt for confirmation before modifying it.
The `Edit` permission already covers it.
