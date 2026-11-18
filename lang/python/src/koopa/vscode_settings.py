"""Audit Visual Studio Code settings against installed extension manifests."""

import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

from koopa.xdg import xdg_config_home

_SAFE_RENAMES = {
    "r.rterm.option": "r.consoleArgs",
    "r.rtermSendDelay": "r.consoleSendDelay",
}

_CORE_PREFIXES = (
    "[",
    "breadcrumbs.",
    "chat.",
    "debug.",
    "diffEditor.",
    "editor.",
    "extensions.",
    "explorer.",
    "files.",
    "git.",
    "http.",
    "markdown.",
    "notebook.",
    "outline.",
    "problems.",
    "remote.",
    "scm.",
    "search.",
    "security.",
    "task.",
    "telemetry.",
    "terminal.",
    "update.",
    "window.",
    "workbench.",
)


@dataclass(frozen=True)
class AuditFinding:
    """A settings audit finding."""

    severity: str
    code: str
    location: str
    detail: str


@dataclass(frozen=True)
class AuditResult:
    """Results from auditing one VS Code settings file."""

    manifest_count: int
    findings: list[AuditFinding]

    @property
    def error_count(self) -> int:
        """Return the number of error-level findings.

        Returns
        -------
        int
            Number of findings with error severity.
        """
        return sum(finding.severity == "ERROR" for finding in self.findings)


@dataclass
class _JsonObject:
    pairs: list[tuple[str, object]]


def default_settings_path() -> Path:
    """Return the XDG-managed VS Code user settings path.

    Returns
    -------
    pathlib.Path
        Path to the current user's VS Code settings.json.
    """
    return Path(xdg_config_home()) / "Code" / "User" / "settings.json"


def default_extension_dirs() -> list[Path]:
    """Return common VS Code extension and bundled-extension directories.

    Returns
    -------
    list[pathlib.Path]
        User and application extension manifest directories.
    """
    home = Path.home()
    dirs = [
        home / ".vscode" / "extensions",
        home / ".vscode-server" / "extensions",
    ]
    if sys.platform == "darwin":
        app_paths = (
            Path("/Applications/Visual Studio Code.app"),
            home / "Applications" / "Visual Studio Code.app",
        )
        dirs.extend(path / "Contents" / "Resources" / "app" / "extensions" for path in app_paths)
    elif sys.platform.startswith("linux"):
        dirs.extend(
            Path(path)
            for path in (
                "/usr/share/code/resources/app/extensions",
                "/usr/lib/code/resources/app/extensions",
                "/opt/visual-studio-code/resources/app/extensions",
                "/snap/code/current/usr/share/code/resources/app/extensions",
            )
        )
    return dirs


def _normalize_json(value: object, location: str, findings: list[AuditFinding]) -> object:
    if isinstance(value, _JsonObject):
        result: dict[str, object] = {}
        for key, child in value.pairs:
            child_location = f"{location}.{key}" if location else key
            if key in result:
                findings.append(
                    AuditFinding(
                        severity="ERROR",
                        code="duplicate",
                        location=child_location,
                        detail="JSON object contains this key more than once.",
                    )
                )
            result[key] = _normalize_json(child, child_location, findings)
        return result
    if isinstance(value, list):
        return [
            _normalize_json(child, f"{location}[{i}]", findings) for i, child in enumerate(value)
        ]
    return value


def _version_key(version: object) -> tuple[int, ...]:
    if not isinstance(version, str):
        return ()
    return tuple(int(part) for part in re.findall(r"\d+", version))


def _extension_manifests(extension_dirs: list[Path]) -> list[tuple[Path, dict[str, object]]]:
    paths = sorted(
        {
            manifest_path
            for directory in extension_dirs
            if directory.is_dir()
            for manifest_path in directory.glob("*/package.json")
        }
    )
    latest: dict[tuple[str, str], tuple[tuple[int, ...], Path, dict[str, object]]] = {}
    for path in paths:
        try:
            manifest = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            msg = f"Unable to read VS Code extension manifest {path}: {error}"
            raise RuntimeError(msg) from error
        if not isinstance(manifest, dict):
            continue
        publisher = manifest.get("publisher")
        name = manifest.get("name")
        identity = (
            str(publisher) if publisher is not None else "",
            str(name) if name is not None else path.parent.name,
        )
        entry = (_version_key(manifest.get("version")), path, manifest)
        previous = latest.get(identity)
        if previous is None or entry[0] >= previous[0]:
            latest[identity] = entry
    return [(path, manifest) for _, path, manifest in latest.values()]


def _load_schemas(
    manifests: list[tuple[Path, dict[str, object]]],
) -> tuple[dict[str, dict[str, object]], set[str], set[str]]:
    properties: dict[str, dict[str, object]] = {}
    icon_theme_ids: set[str] = set()
    color_theme_labels: set[str] = set()
    for _path, manifest in manifests:
        contributes = manifest.get("contributes")
        if not isinstance(contributes, dict):
            continue
        configuration = contributes.get("configuration")
        configurations = configuration if isinstance(configuration, list) else [configuration]
        for config in configurations:
            if not isinstance(config, dict):
                continue
            config_properties = config.get("properties")
            if isinstance(config_properties, dict):
                for key, schema in config_properties.items():
                    if isinstance(key, str) and isinstance(schema, dict):
                        properties[key] = schema
        icon_themes = contributes.get("iconThemes")
        if isinstance(icon_themes, list):
            for theme in icon_themes:
                if isinstance(theme, dict) and isinstance(theme.get("id"), str):
                    icon_theme_ids.add(theme["id"])
        color_themes = contributes.get("themes")
        if isinstance(color_themes, list):
            for theme in color_themes:
                if isinstance(theme, dict) and isinstance(theme.get("label"), str):
                    color_theme_labels.add(theme["label"])
    return properties, icon_theme_ids, color_theme_labels


def _debugger_rpath_keys(manifests: list[tuple[Path, dict[str, object]]]) -> set[str]:
    keys: set[str] = set()
    for path, manifest in manifests:
        if str(manifest.get("publisher", "")).lower() != "rdebugger":
            continue
        if str(manifest.get("name", "")).lower() != "r-debugger":
            continue
        properties, _, _ = _load_schemas([(path, manifest)])
        keys.update(key for key in properties if key.startswith("r.rpath."))
    return keys


def _matches_type(value: object, expected: object) -> bool:
    if isinstance(expected, list):
        return any(_matches_type(value, item) for item in expected)
    matches = True
    if expected == "null":
        matches = value is None
    elif expected == "array":
        matches = isinstance(value, list)
    elif expected == "object":
        matches = isinstance(value, dict)
    elif expected == "boolean":
        matches = isinstance(value, bool)
    elif expected == "integer":
        matches = isinstance(value, int) and not isinstance(value, bool)
    elif expected == "number":
        matches = isinstance(value, (int, float)) and not isinstance(value, bool)
    elif expected == "string":
        matches = isinstance(value, str)
    return matches


def _schema_findings(
    key: str,
    value: object,
    schema: dict[str, object],
) -> list[AuditFinding]:
    findings: list[AuditFinding] = []
    expected_type = schema.get("type")
    if expected_type is not None and not _matches_type(value, expected_type):
        findings.append(
            AuditFinding(
                severity="ERROR",
                code="type",
                location=key,
                detail=f"Expected {expected_type!r}, got {type(value).__name__}.",
            )
        )
    enum = schema.get("enum")
    if isinstance(enum, list) and value not in enum:
        findings.append(
            AuditFinding(
                severity="ERROR",
                code="enum",
                location=key,
                detail=f"Expected one of {enum!r}, got {value!r}.",
            )
        )
    items = schema.get("items")
    if isinstance(value, list) and isinstance(items, dict) and items.get("type") is not None:
        item_type = items["type"]
        for i, item in enumerate(value):
            if not _matches_type(item, item_type):
                findings.append(
                    AuditFinding(
                        severity="ERROR",
                        code="type",
                        location=f"{key}[{i}]",
                        detail=f"Expected {item_type!r}, got {type(item).__name__}.",
                    )
                )
    return findings


def audit_vscode_settings(
    settings_path: Path,
    extension_dirs: list[Path],
) -> AuditResult:
    """Audit settings JSON for duplicates and extension-schema mismatches.

    Parameters
    ----------
    settings_path : pathlib.Path
        VS Code user settings JSON file.
    extension_dirs : list[pathlib.Path]
        Directories whose immediate subdirectories contain extension manifests.

    Returns
    -------
    AuditResult
        Extension manifest count and all warnings or errors found.
    """
    try:
        raw = json.loads(
            settings_path.read_text(encoding="utf-8"),
            object_pairs_hook=_JsonObject,
        )
    except (OSError, json.JSONDecodeError) as error:
        msg = f"Unable to read VS Code settings {settings_path}: {error}"
        raise RuntimeError(msg) from error

    findings: list[AuditFinding] = []
    settings = _normalize_json(raw, "", findings)
    if not isinstance(settings, dict):
        msg = f"VS Code settings must contain a JSON object: {settings_path}"
        raise RuntimeError(msg)

    manifests = _extension_manifests(extension_dirs)
    if not manifests:
        msg = "No VS Code extension manifests found; pass --extensions-dir."
        raise RuntimeError(msg)
    properties, icon_theme_ids, color_theme_labels = _load_schemas(manifests)
    debugger_rpaths = _debugger_rpath_keys(manifests)
    r_properties, _, _ = _load_schemas(
        [
            (path, manifest)
            for path, manifest in manifests
            if str(manifest.get("publisher", "")).lower() == "reditorsupport"
            and str(manifest.get("name", "")).lower() == "r"
        ]
    )

    for key, value in settings.items():
        if key == "workbench.iconTheme" and isinstance(value, str):
            if value not in icon_theme_ids:
                findings.append(
                    AuditFinding(
                        severity="WARNING",
                        code="unknown-icon-theme",
                        location=key,
                        detail=f"No discovered extension contributes icon theme {value!r}.",
                    )
                )
        elif (
            key == "workbench.colorTheme"
            and isinstance(value, str)
            and color_theme_labels
            and value not in color_theme_labels
        ):
            findings.append(
                AuditFinding(
                    severity="WARNING",
                    code="unknown-color-theme",
                    location=key,
                    detail=f"No discovered extension contributes color theme {value!r}.",
                )
            )

        if key.startswith(_CORE_PREFIXES):
            continue
        schema = properties.get(key)
        if schema is None:
            findings.append(
                AuditFinding(
                    severity="WARNING",
                    code="unregistered",
                    location=key,
                    detail=(
                        "No discovered extension contributes this setting; it may belong to "
                        "an extension installed on another machine."
                    ),
                )
            )
            continue
        deprecation = schema.get("deprecationMessage")
        if key.startswith("r.rpath."):
            deprecation = r_properties.get(key, {}).get("deprecationMessage") or deprecation
        if isinstance(deprecation, str) and deprecation:
            if key.startswith("r.rpath."):
                if "r.executablePath" not in settings:
                    status = "r.executablePath is not set"
                elif value == settings["r.executablePath"]:
                    status = "the paths match"
                else:
                    status = "the paths differ"
                registration = (
                    "The installed R Debugger manifest also registers this key."
                    if key in debugger_rpaths
                    else "R Debugger may also use this key on another machine."
                )
                deprecation = (
                    f"{deprecation} {registration} "
                    "If you use R Debugger, retain it and keep it in sync with "
                    f"r.executablePath ({status}); otherwise it can be removed after review. "
                    "This audit does not detect whether extensions are enabled."
                )
            findings.append(
                AuditFinding(
                    severity="WARNING",
                    code="deprecated",
                    location=key,
                    detail=deprecation,
                )
            )
        findings.extend(_schema_findings(key, value, schema))

    return AuditResult(manifest_count=len(manifests), findings=findings)


def _parse_rendered_code(text: str) -> dict[str, object]:
    findings: list[AuditFinding] = []
    rendered = _normalize_json(json.loads(text, object_pairs_hook=_JsonObject), "", findings)
    if not isinstance(rendered, dict) or findings:
        msg = "The assembled Code template is not an object or contains duplicate keys."
        raise RuntimeError(msg)
    return rendered


def _render_code_template(source: Path, text: str) -> dict[str, object]:
    result = subprocess.run(
        ["chezmoi", "execute-template", f"--source={source}"],
        input=text,
        capture_output=True,
        text=True,
        check=True,
    )
    return _parse_rendered_code(result.stdout)


def fix_vscode_settings(
    settings_path: Path,
    extension_dirs: list[Path],
    source: Path,
) -> list[str]:
    """Apply supported safe migrations to the Code chezmoi source and target.

    Only the standard Code settings target is supported. A fix is skipped if
    its replacement already exists in any template or cannot be validated
    against the installed extension schema.

    Parameters
    ----------
    settings_path : pathlib.Path
        XDG-managed VS Code user settings path.
    extension_dirs : list[pathlib.Path]
        Directories containing installed extension manifests.
    source : pathlib.Path
        Chezmoi source directory containing Code's template partials.

    Returns
    -------
    list[str]
        Descriptions of the migrations applied.
    """
    if settings_path.resolve() != default_settings_path().resolve():
        msg = "--fix supports only the XDG-managed Code settings target."
        raise RuntimeError(msg)
    template = source / ".chezmoitemplates" / "vscode-app-code.tmpl"
    if template.is_symlink() or not template.is_file():
        msg = f"Code settings source is missing or is a symlink: {template}"
        raise RuntimeError(msg)

    audit = audit_vscode_settings(settings_path, extension_dirs)
    if any(f.code == "duplicate" for f in audit.findings):
        msg = "Cannot fix settings with duplicate keys; resolve them manually first."
        raise RuntimeError(msg)
    properties, _, _ = _load_schemas(_extension_manifests(extension_dirs))
    original = template.read_text(encoding="utf-8")
    rendered = _render_code_template(source, original)
    target_render = subprocess.run(
        ["chezmoi", "cat", f"--source={source}", str(settings_path)],
        capture_output=True,
        text=True,
        check=True,
    )
    if _parse_rendered_code(target_render.stdout) != rendered:
        msg = "The Code target renders differently from its partial; nothing was written."
        raise RuntimeError(msg)
    deployed_text = settings_path.read_text(encoding="utf-8")
    deployed = _parse_rendered_code(deployed_text)
    if rendered != deployed:
        msg = "Code settings differ from the chezmoi source; review the drift before using --fix."
        raise RuntimeError(msg)

    updated = original
    expected = dict(rendered)
    changes: list[str] = []
    partials = list((source / ".chezmoitemplates").glob("*.tmpl"))
    for old, new in _SAFE_RENAMES.items():
        schema = properties.get(new)
        old_schema = properties.get(old)
        if old not in rendered or new in rendered or schema is None or old_schema is None:
            continue
        deprecation = old_schema.get("deprecationMessage")
        if (
            not isinstance(deprecation, str)
            or new not in deprecation
            or not schema.get("type")
            or schema.get("deprecationMessage")
            or _schema_findings(old, rendered[old], old_schema)
            or _schema_findings(new, rendered[old], schema)
        ):
            continue
        old_pattern = re.compile(rf'^  "{re.escape(old)}"\s*:', re.MULTILINE)
        new_pattern = re.compile(rf'^\s*"{re.escape(new)}"\s*:', re.MULTILINE)
        if len(old_pattern.findall(updated)) != 1:
            continue
        if any(new_pattern.search(path.read_text(encoding="utf-8")) for path in partials):
            continue
        updated = old_pattern.sub(f'  "{new}":', updated, count=1)
        expected[new] = expected.pop(old)
        changes.append(f"{old} -> {new}")

    if not changes:
        return []
    if _render_code_template(source, updated) != expected:
        msg = "The proposed template migrations changed unrelated settings; nothing was written."
        raise RuntimeError(msg)
    if template.read_text(encoding="utf-8") != original:
        msg = "The Code source changed during the audit; nothing was written."
        raise RuntimeError(msg)
    if settings_path.read_text(encoding="utf-8") != deployed_text:
        msg = "Code settings changed during the audit; nothing was written."
        raise RuntimeError(msg)
    template.write_text(updated, encoding="utf-8")
    try:
        subprocess.run(
            ["chezmoi", "apply", f"--source={source}", str(settings_path)],
            check=True,
        )
    except (OSError, subprocess.CalledProcessError) as error:
        msg = f"Updated {template}, but chezmoi apply failed; review source and target."
        raise RuntimeError(msg) from error
    return changes
