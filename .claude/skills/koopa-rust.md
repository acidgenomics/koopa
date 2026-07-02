---
name: koopa-rust
description: >
  Rust and cargo conventions for koopa installers — hermetic CARGO_HOME, build
  dependency wiring, and the NO_RUST opt-out pattern. Use when writing or debugging
  any installer that builds with cargo, whether directly (rust-package installers) or
  indirectly (build tools like git that shell out to cargo from their own Makefile).
---

# koopa Rust / Cargo Conventions

## Hermetic `CARGO_HOME` (required for all koopa cargo builds)

**Always point `CARGO_HOME` at a temp dir.** Never let cargo read from or write to
`~/.cargo` during an installer build — that leaks toolchain state across builds and
can corrupt the user's personal cargo registry.

```python
import tempfile

subprocess_env = env.to_env_dict()
subprocess_env["CARGO_HOME"] = tempfile.mkdtemp(prefix="koopa-cargo-")
```

`subprocess_env` is then passed to every `subprocess.run(...)` call for the build.
This applies whether:

- koopa is **directly** invoking `cargo install` (the `_rust_pkg.py` / `install_rust_package`
  path in `install.py:1313`), or
- koopa is invoking another build tool (`make`, `cmake`, …) that **itself** shells out
  to `cargo` (e.g. git ≥ 2.50, which runs `cargo build target/release/libgitcore.a`).

Existing examples using this pattern:
- `lang/python/src/koopa/installers/rust_app.py` — sets `CARGO_HOME` in the rustup
  install env.
- `lang/python/src/koopa/install.py:1313` (`install_rust_package`) — uses
  `tempfile.mkdtemp(prefix="koopa-cargo-")`.
- `lang/python/src/koopa/installers/git_app.py` — sets `CARGO_HOME` on `subprocess_env`
  before the `make` build so git's internal cargo call is hermetic.

## Declaring `rust` as a build dependency

Any installer that needs `cargo` must list `"rust"` in the app's
`build_dependencies` in `etc/koopa/app.json`. This:

1. Installs `rust` before the current app (if not already present).
2. Prepends `opt/rust/bin` to the build PATH via `activate_app_deps()` →
   `activate_app(..., build_only=True)` in `_build_helper.py`, so `cargo` (and
   `rustc`, `clippy`, etc.) resolve inside `make`/`cmake`/any subprocess.

```json
"build_dependencies": [
  "...",
  "rust",
  "..."
]
```

`rust` has `"default": false` in the registry — that is intentional and correct (it
is a large optional toolchain). Listing it in `build_dependencies` still causes it to
be installed before the dependent app regardless of `default`.

## `NO_RUST` opt-out

If an app's build system provides a Makefile variable to disable its Rust path
(e.g. `NO_RUST=1` for git ≥ 2.50), do **not** use it in koopa installers. The goal
is to enable Rust features, not suppress them. Reserve `NO_RUST` only for emergency
fallback builds when the `rust` app is unavailable.

## Offline / self-contained crates

Before wiring `cargo` into a new installer, check the upstream `Cargo.toml` for
external dependencies. If `[dependencies]` is empty (as it is for git 2.55.0), the
cargo build is fully offline and requires no special network flags or vendoring.

If there are `[dependencies]`, the build needs network access or a vendored tarball —
handle the same way as `install_rust_package` (see `install.py`), setting
`CARGO_NET_GIT_FETCH_WITH_CLI=true` and pre-downloading crates if offline builds
are required.
