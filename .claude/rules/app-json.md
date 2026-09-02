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

## Holding a version back from `check-app-versions`

A hold written only as prose in `notes` is not enforced. `check-app-versions`
reads none of these `notes`, so it silently re-bumps the version on the next
run. Use one of these fields instead:

| Field | Shape | Effect |
|---|---|---|
| `version_exclude` | array of version strings | Never write these exact versions. Self-heals: once upstream ships a version not on the list, the pin bumps normally. |
| `version_granularity` | `"minor"` | Accept a bump only when the major or minor component changes; hold a patch-only bump. |
| `version_match` | another app's name | Bump only when this app and the named app agree on the same latest version; hold both otherwise. |
| `version_pin` | `true` | Drop the app from checking entirely. Use only when the app should never be checked again — most holds should use `version_exclude` instead, so the app keeps getting checked and the hold can expire. |

`check-app-versions` also reports a `version_exclude` list that is entirely
below the current pin as a stale hold, so a dead exclusion does not linger
unnoticed. It reports a pin that is itself excluded as a contradiction.

## Edit freely

`app.json` is a routine edit file — never prompt for confirmation before modifying it.
The `Edit` permission already covers it.
