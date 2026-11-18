"""Tests for auditing Visual Studio Code settings."""

import json
from pathlib import Path

import pytest
from koopa.cli_app import _APP_TREE, _PYTHON_HANDLERS
from koopa.vscode_settings import audit_vscode_settings, fix_vscode_settings


def _write_extension_manifest(extension_dir: Path) -> None:
    extension_dir.mkdir(parents=True)
    manifest = {
        "name": "example",
        "publisher": "test",
        "version": "1.0.0",
        "contributes": {
            "configuration": {
                "properties": {
                    "test.array": {"type": "array", "items": {"type": "string"}},
                    "test.enum": {"type": "string", "enum": ["valid", "other"]},
                    "test.deprecated": {
                        "type": "boolean",
                        "deprecationMessage": "Use test.replacement instead.",
                    },
                    "test.replacement": {"type": "boolean"},
                    "r.executablePath": {"type": "string"},
                }
            },
            "iconThemes": [{"id": "test-icons", "label": "Test Icons", "path": "icons.json"}],
            "themes": [{"label": "Test Theme", "uiTheme": "vs-dark", "path": "theme.json"}],
        },
    }
    (extension_dir / "package.json").write_text(json.dumps(manifest), encoding="utf-8")


def test_code_audit_settings_is_registered() -> None:
    """The audit command is reachable as koopa app code audit-settings."""
    assert _APP_TREE["code"]["audit-settings"] == "code-audit-settings"
    assert callable(_PYTHON_HANDLERS["code-audit-settings"])


def test_audit_vscode_settings_reports_duplicate_unknown_and_schema_issues(
    tmp_path: Path,
) -> None:
    """Reports duplicates, unregistered and deprecated keys, and schema errors."""
    extension_dir = tmp_path / "extensions" / "test.example-1.0.0"
    _write_extension_manifest(extension_dir)
    settings_path = tmp_path / "settings.json"
    settings_path.write_text(
        """{
  "test.array": ["ok", 1],
  "test.enum": "invalid",
  "test.deprecated": true,
  "test.unknown": false,
  "r.executablePath": 42,
  "chat.agent.maxRequests": 200,
  "remote.extensionKind": {"GitHub.copilot": ["ui"]},
  "workbench.iconTheme": "test-icons",
  "workbench.colorTheme": "Test Theme",
  "debug.terminal.clearBeforeReusing": true,
  "debug.terminal.clearBeforeReusing": false
}
""",
        encoding="utf-8",
    )

    result = audit_vscode_settings(settings_path, [extension_dir.parent])
    codes = [finding.code for finding in result.findings]

    assert result.manifest_count == 1
    assert result.error_count == 4
    assert codes.count("type") == 2
    assert "enum" in codes
    assert "duplicate" in codes
    assert "unregistered" in codes
    assert "deprecated" in codes
    assert "unknown-icon-theme" not in codes
    assert "unknown-color-theme" not in codes


def test_audit_vscode_settings_rejects_missing_manifests(tmp_path: Path) -> None:
    """A schema audit fails explicitly when no extension manifests are available."""
    settings_path = tmp_path / "settings.json"
    settings_path.write_text("{}", encoding="utf-8")

    with pytest.raises(RuntimeError, match="No VS Code extension manifests"):
        audit_vscode_settings(settings_path, [tmp_path / "extensions"])


def test_audit_vscode_settings_rejects_non_object_root(
    tmp_path: Path,
) -> None:
    """A settings file must contain an object, not an array or scalar."""
    extension_dir = tmp_path / "extensions" / "test.example-1.0.0"
    _write_extension_manifest(extension_dir)
    settings_path = tmp_path / "settings.json"
    settings_path.write_text("[]", encoding="utf-8")

    with pytest.raises(RuntimeError, match="must contain a JSON object"):
        audit_vscode_settings(settings_path, [extension_dir.parent])


def _migration_fixture(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> tuple[Path, Path, Path]:
    home = tmp_path / "home"
    monkeypatch.setenv("HOME", str(home))
    monkeypatch.setenv("XDG_CONFIG_HOME", str(home / ".config"))
    source = tmp_path / "chezmoi"
    partial = source / ".chezmoitemplates" / "vscode-app-code.tmpl"
    partial.parent.mkdir(parents=True)
    partial.write_text('{\n  "r.rtermSendDelay": 50,\n  "r.rpath.mac": "/R"\n}\n')
    target_template = source / "dot_config" / "Code" / "User" / "settings.json.tmpl"
    target_template.parent.mkdir(parents=True)
    target_template.write_text('{{ includeTemplate "vscode-app-code.tmpl" . }}\n')
    settings = home / ".config" / "Code" / "User" / "settings.json"
    settings.parent.mkdir(parents=True)
    settings.write_text('{"r.rtermSendDelay":50,"r.rpath.mac":"/R"}\n')
    extension = tmp_path / "extensions" / "r"
    extension.mkdir(parents=True)
    (extension / "package.json").write_text(
        json.dumps(
            {
                "publisher": "REditorSupport",
                "name": "r",
                "version": "3.4.0",
                "contributes": {
                    "configuration": {
                        "properties": {
                            "r.rtermSendDelay": {
                                "type": "number",
                                "deprecationMessage": "Use r.consoleSendDelay instead.",
                            },
                            "r.consoleSendDelay": {"type": "number"},
                            "r.rpath.mac": {
                                "type": "string",
                                "deprecationMessage": "Use r.executablePath instead.",
                            },
                        }
                    }
                },
            }
        )
    )
    return settings, source, extension.parent


def test_fix_updates_source_and_target_preserving_legacy_debugger_path(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Apply supported renames without changing unrelated legacy settings."""
    settings, source, extensions = _migration_fixture(tmp_path, monkeypatch)

    changes = fix_vscode_settings(settings, [extensions], source)
    partial = source / ".chezmoitemplates" / "vscode-app-code.tmpl"
    assert changes == ["r.rtermSendDelay -> r.consoleSendDelay"]
    assert '"r.consoleSendDelay": 50' in partial.read_text()
    assert json.loads(settings.read_text()) == {"r.consoleSendDelay": 50, "r.rpath.mac": "/R"}
    assert fix_vscode_settings(settings, [extensions], source) == []


def test_fix_refuses_drift_and_conflicting_replacement(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Refuse drift and avoid overriding a replacement in another partial."""
    settings, source, extensions = _migration_fixture(tmp_path, monkeypatch)
    partial = source / ".chezmoitemplates" / "vscode-app-code.tmpl"
    original = partial.read_text()
    settings.write_text('{"r.rtermSendDelay":99,"r.rpath.mac":"/R"}\n')
    with pytest.raises(RuntimeError, match="differ from the chezmoi source"):
        fix_vscode_settings(settings, [extensions], source)
    assert partial.read_text() == original
    settings.write_text('{"r.rtermSendDelay":50,"r.rpath.mac":"/R"}\n')
    (partial.parent / "other.tmpl").write_text('"r.consoleSendDelay": 100,\n')
    assert fix_vscode_settings(settings, [extensions], source) == []
    assert partial.read_text() == original


@pytest.mark.parametrize("problem", ["duplicate", "missing-schema", "invalid-value", "target"])
def test_fix_skips_or_refuses_unsafe_migrations(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, problem: str
) -> None:
    """Do not modify source when validation or target checks fail."""
    settings, source, extensions = _migration_fixture(tmp_path, monkeypatch)
    partial = source / ".chezmoitemplates" / "vscode-app-code.tmpl"
    if problem == "duplicate":
        settings.write_text('{"r.rtermSendDelay":50,"r.rtermSendDelay":50}')
    elif problem == "missing-schema":
        manifest_path = extensions / "r" / "package.json"
        manifest = json.loads(manifest_path.read_text())
        del manifest["contributes"]["configuration"]["properties"]["r.consoleSendDelay"]
        manifest_path.write_text(json.dumps(manifest))
    elif problem == "invalid-value":
        partial.write_text(partial.read_text().replace(": 50", ': "bad"'))
        settings.write_text('{"r.rtermSendDelay":"bad","r.rpath.mac":"/R"}')
    else:
        settings = tmp_path / "other.json"
        settings.write_text("{}")
    original = partial.read_text()
    if problem in {"duplicate", "target"}:
        with pytest.raises(RuntimeError, match=r"duplicate|XDG-managed"):
            fix_vscode_settings(settings, [extensions], source)
    else:
        assert fix_vscode_settings(settings, [extensions], source) == []
    assert partial.read_text() == original


def test_r_debugger_deprecation_explains_compatibility_and_path_mismatch(tmp_path: Path) -> None:
    """Explain the R Debugger compatibility tradeoff and mismatched paths."""
    extension = tmp_path / "extensions" / "r"
    _write_extension_manifest(extension)
    data = json.loads((extension / "package.json").read_text())
    data["publisher"] = "REditorSupport"
    data["name"] = "r"
    data["contributes"]["configuration"]["properties"]["r.rpath.mac"] = {
        "type": "string",
        "deprecationMessage": "Use r.executablePath instead.",
    }
    (extension / "package.json").write_text(json.dumps(data))
    debugger = extension.parent / "z-debugger"
    debugger.mkdir()
    (debugger / "package.json").write_text(
        json.dumps(
            {
                "publisher": "RDebugger",
                "name": "r-debugger",
                "version": "0.5.6",
                "contributes": {
                    "configuration": {"properties": {"r.rpath.mac": {"type": "string"}}}
                },
            }
        )
    )
    settings = tmp_path / "settings.json"
    settings.write_text('{"r.rpath.mac":"/R","r.executablePath":"/other"}')
    result = audit_vscode_settings(settings, [extension.parent])
    finding = next(f for f in result.findings if f.location == "r.rpath.mac")
    assert "R Debugger manifest also registers" in finding.detail
    assert "the paths differ" in finding.detail
    assert "does not detect whether extensions are enabled" in finding.detail
