---
name: koopa-dotfiles
description: >
  Managing the opt/dotfiles standalone git clone — git state, committing changes,
  and license/metadata updates. Use when making changes to opt/dotfiles/ that need
  to be committed, or when the clone is in a detached HEAD state.
---

# koopa Dotfiles Repo Management

## Repo layout

`opt/dotfiles/` is a **standalone git clone** of `github.com/acidgenomics/dotfiles`,
not a submodule of koopa. It is cloned by `koopa install dotfiles` and pinned at a
specific commit (blobless partial clone with `partialclonefilter = blob:none`).

The chezmoi source tree lives inside it at `opt/dotfiles/chezmoi/`. See skill
`koopa-chezmoi-dotfiles` for editing dotfiles via chezmoi.

## Detached HEAD — always check before committing

`koopa install` pins the clone at a specific commit, leaving it in **detached HEAD**
state. Any `git commit` from a detached HEAD lands on no branch and will be
unreachable after a `git checkout`.

Before committing any change inside `opt/dotfiles/`, always check:

```sh
cd opt/dotfiles
git status         # "(HEAD detached at <sha>)" means detached
git checkout main  # re-attach to main before committing
```

Then commit normally and push to `origin` (`github.com/acidgenomics/dotfiles`).

## License

The repo carries a single top-level `LICENSE` file (no extension). There are no
per-file SPDX headers or package-metadata `license` fields.

In June 2026 the license was switched from AGPL-3.0 to Apache-2.0, matching koopa.
The Apache-2.0 text is the verbatim stock text (APPENDIX placeholders left unfilled);
the README carries the attribution line:

```
Apache-2.0 — Copyright 2016 Acid Genomics LLC — see [LICENSE](LICENSE).
```

To verify no AGPL traces remain: `grep -i "affero\|agpl" opt/dotfiles/LICENSE`
should return nothing.
