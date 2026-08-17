# koopa develop

(koopa-develop-activation-fork-audit)=
## `develop activation-fork-audit`

Static analysis of subprocess forks in the shell activation path.

- `--threshold-bash`
- `--threshold-zsh`
- `--verbose`

(koopa-develop-activation-speed-test)=
## `develop activation-speed-test`

Measure shell activation time and check against thresholds.

- `--runs`
- `--shells`
- `--threshold-bash`
- `--threshold-fish`
- `--threshold-zsh`
- `--verbose`

(koopa-develop-app-deps)=
## `develop app-deps name`

List the dependencies of an app.

(koopa-develop-app-revdeps)=
## `develop app-revdeps name [--all]`

List the reverse dependencies of an app.

- `--all`

(koopa-develop-audit-src-mirror)=
## `develop audit-src-mirror`

Audit S3 source mirror for missing or stale tarballs.

(koopa-develop-bump-bootstrap)=
## `develop bump-bootstrap`

Bump the bootstrap version, marking existing bootstraps as stale.

(koopa-develop-bump-revision)=
## `develop bump-revision name...`

Bump the revision of one or more apps in app.json.

(koopa-develop-bump-venv-version)=
## `develop bump-venv-version`

Bump the Python venv version.

(koopa-develop-cache-functions)=
## `develop cache-functions`

Regenerate the cached Bash function library.

(koopa-develop-check-app-versions)=
## `develop check-app-versions`

Check upstream versions for all apps in app.json.

- `--json`
- `--source`
- `--no-update`
- `--s3-upload`
- `--reset-cache`

(koopa-develop-check-skills)=
## `develop check-skills [path...]`

Validate SKILL.md frontmatter for cross-CLI compatibility.

(koopa-develop-circular-dependencies)=
## `develop circular-dependencies`

Detect circular dependency chains in app.json.

(koopa-develop-color-mode-audit)=
## `develop color-mode-audit`

Detect dark/light color-mode thrash in the sync log.

- `--threshold`
- `--log`
- `--verbose`

(koopa-develop-conda-candidates)=
## `develop conda-candidates`

Find source-built apps that are available on conda-forge or bioconda.

- `--verify`

(koopa-develop-edit-app-json)=
## `develop edit-app-json`

Open app.json in the default editor.

(koopa-develop-find-ignored-bin-files)=
## `develop find-ignored-bin-files`

Find files in bin/ that are ignored by git.

(koopa-develop-format-app-json)=
## `develop format-app-json`

Sort and format app.json.

(koopa-develop-generate-completion)=
## `develop generate-completion`

Regenerate shell tab-completion scripts.

(koopa-develop-generate-docs)=
## `develop generate-docs`

Regenerate the Sphinx CLI reference pages under docs/reference/.

(koopa-develop-generate-man)=
## `develop generate-man`

Regenerate the koopa(1) man page.

(koopa-develop-log)=
## `develop log`

View the latest temporary log file.

(koopa-develop-mirror-src)=
## `develop mirror-src name...`

Mirror source tarballs to S3.

- `--prune`
- `--help`

(koopa-develop-orphan-apps)=
## `develop orphan-apps`

Find apps in app.json that no other app depends on.

- `--all`

(koopa-develop-prune-app-binaries)=
## `develop prune-app-binaries`

Remove stale application binaries from the cache.

(koopa-develop-push-all-app-builds)=
## `develop push-all-app-builds`

Push all application builds to the binary cache.

(koopa-develop-push-app-build)=
## `develop push-app-build name...`

Push a specific application build to the binary cache.

(koopa-develop-push-app-builds)=
## `develop push-app-builds`

Push all stale application builds to the binary cache.

(koopa-develop-push-installer)=
## `develop push-installer app file [--version version] [--force]`

Stage a downloaded vendor installer tarball to the artifacts bucket.

- `--version`
- `--force`

(koopa-develop-pyright)=
## `develop pyright`

Run the pyright type checker on the Python source tree.

(koopa-develop-pytest)=
## `develop pytest`

Run the Python test suite.

(koopa-develop-remove-app)=
## `develop remove-app name`

Tombstone an app entry in app.json.

- `--revdeps`

(koopa-develop-reset-revisions)=
## `develop reset-revisions`

Remove the revision key from all apps in app.json.

(koopa-develop-scrub-install-info)=
## `develop scrub-install-info [name...] [--dry-run]`

Rewrite .install/info.json environ blocks down to the allowlist.

- `--dry-run`

(koopa-develop-shellcheck)=
## `develop shellcheck`

Run shellcheck on all shell scripts.

(koopa-develop-update-docs)=
## `develop update-docs`

Update generated documentation files.

