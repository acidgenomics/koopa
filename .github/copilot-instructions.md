# Copilot Instructions for koopa

Shell bootloader for data science. A comprehensive Python toolkit for system
administration, bioinformatics, and development environment management.

## Build, Test, and Lint

### Setup

```sh
# Ensure Python 3.12 is available
python --version  # Should be 3.12.x

# Install/upgrade uv (the project uses uv for dependency management)
python -m pip install --upgrade uv
```

### Running Tests

```sh
# Run all tests
pytest lang/python/tests/

# Run tests for a specific module (e.g., test_app.py)
pytest lang/python/tests/test_app.py

# Run a specific test function
pytest lang/python/tests/test_app.py::test_function_name

# Run tests with verbose output
pytest lang/python/tests/ -v

# Run with coverage
pytest lang/python/tests/ --cov=koopa --cov-report=term-missing
```

### Linting and Formatting

```bash
# Check code with ruff (linting + formatting issues)
ruff check lang/python/src/

# Auto-fix ruff issues
ruff check --fix lang/python/src/

# Format code with ruff
ruff format lang/python/src/

# Type checking with pyright
pyright lang/python/src/

# Check docstrings (interrogate)
interrogate -v lang/python/src/
```

### Development Install

```bash
# Install the package in development mode
pip install -e .

# After install, you can use the CLI
koopa --help
```

## High-Level Architecture

### Project Structure

```
lang/python/
├── src/koopa/
│   ├── cli_*.py          # CLI command dispatchers
│   ├── installers/       # Installation routines for packages/tools
│   ├── configurers/      # System configuration modules
│   ├── shell/            # Shell integration (docker.py)
│   ├── install.py        # Main install orchestration
│   ├── build.py          # Build-related utilities
│   ├── system.py         # System platform detection
│   ├── download.py       # Download utilities
│   ├── check.py          # System checks and validation
│   └── [utility modules] # String, file, AWS, Git, R, NGS utilities
└── tests/
    └── test_*.py         # Test files (one per src module)
```

### Core Design Patterns

1. **CLI Dispatching**: `cli_main.py` is the entry point that routes commands.
   It reads `app.json` to resolve installer/platform arguments without per-app
   Bash wrappers.
2. **Installers Pattern**: Subclasses of `Installer` in `installers/` handle
   installation logic for different package managers (conda, GNU, Python, Ruby,
   Haskell, Perl, Node, Rust).
3. **Configurers Pattern**: Modules in `configurers/` apply system configuration
   (e.g., macOS preferences, Emacs setup, R environment).
4. **Platform Abstraction**: Functions like `_os_id()` and modules like
   `system.py`, `os_linux.py` handle platform-specific logic (Linux x86_64/arm64,
   macOS arm64 only — Intel Macs no longer supported).
5. **App Metadata**: `etc/koopa/app.json` drives installation behavior without
   duplicating logic across shell scripts.

### Entry Points

- **Main CLI**: `koopa.cli_main:main` — routes to CLI subcommands.
- **Subcommands**: `cli_app.py`, `cli_bin.py`, `cli_develop.py`, `cli_system.py`
  implement command groups.

## Key Conventions

### Code Style

- **Line length**: 100 characters (configured in `pyproject.toml`).
- **Python version**: 3.12+ (type hints are expected).
- **Docstring format**: NumPy convention (not Google style).
- Exception: Skip D203 (one-blank-line-before-class), D213
  (multi-line-summary-second-line).
- **Imports**: isort-style imports with sections: future, stdlib, third-party,
  first-party, local.
- CLI modules (`cli_*.py`) allow imports outside top-level (PLC0415 ignored).

### Type Annotations

- Use full type hints (`ANN` rule enabled in ruff).
- Types must be annotated on function parameters and return values.
- Use `TYPE_CHECKING` block for forward references and circular imports.

### Platform-Specific Code

- Always gate Linux-specific code: use `os_linux.py` utilities or check
  `sys.platform`.
- For macOS: target arm64 (Apple Silicon) only; x86_64 no longer supported.
- Use `koopa.system.check_platform()` to validate OS compatibility early.

### Docstrings

- Write numpy-style docstrings with sections: Summary, Extended Summary,
  Parameters, Returns, Raises, Examples.
- Docstring code examples are formatted by ruff (docstring-code-format enabled).
- Maximum docstring line length: 72 characters.
- Allow docstrings to start with: "Access", "Assess", "Process".

### Error Handling

- Use explicit exception types (not bare `except:`).
- Raise errors with descriptive messages.
- Use `koopa.alert` module for user-facing warnings/errors.

### Naming Conventions

- Functions: `snake_case` (PEP8-naming enforced).
- Classes: `PascalCase`.
- Private functions/attributes: prefix with `_`.
- CLI argument names: use hyphens (e.g., `--dry-run`), not underscores.

### Test Organization

- One test file per source module (e.g., `test_app.py` for `app.py`).
- Test functions named `test_<function_or_feature>()`.
- Use pytest fixtures for setup/teardown.
- Pytest configuration in `pyproject.toml`: pythonpath includes
 `lang/python/src`, testpaths is `lang/python/tests`.

### Import Paths

- Internal imports: `from koopa.module import function` (pythonpath set to
 `lang/python/src`).
- Avoid relative imports except in subpackages (e.g., `from . import sibling`).

### Common Utilities

- **Text operations**: `koopa.text` (e.g., camelcase, snakecase conversions).
- **File operations**: `koopa.file_ops`, `koopa.fs`, `koopa.disk`.
- **I/O**: `koopa.io` for standardized output.
- **Alerts**: `koopa.alert` for user messages (warnings, errors, info).
- **System info**: `koopa.system`, `koopa.current` for platform/OS detection.
- **Execution**: `koopa.exec` for subprocess management.
- **Git operations**: `koopa.git` for git commands.
- **Download**: `koopa.download` for remote file fetching.

### Configuration

- Ruff max complexity: 30 (allow for complex orchestration).
- Ruff max arguments: 30 (allow for flexible installers).
- Ruff max statements: 100.
- pyright: verboseOutput enabled, reportMissingModuleSource is error-level.
- Coverage: `lang/python/src` source, `lang/python/tests` test paths.
