"""Tests for the koopa plugin's skills (plugins/koopa/skills)."""

import re
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

_PLUGIN_DIR = Path(koopa_prefix()) / "plugins" / "koopa"
_SKILLS_DIR = _PLUGIN_DIR / "skills"
_MAX_DESCRIPTION = 1023
_OLD_SKILL_NAMES = (
    "dotfiles-claude-permissions",
    "dotfiles-git-history-surgery",
    "dotfiles-git-recovery",
    "dotfiles-maintain-claude-config",
    "dotfiles-python",
    "dotfiles-todo-org",
    "dotfiles-workflow-guidance",
)
_SKILL_DIRS = sorted(p for p in _SKILLS_DIR.iterdir() if p.is_dir())


def _frontmatter(path: Path) -> dict[str, str]:
    """Parse the flat frontmatter of a SKILL.md with plain text handling.

    Handles `key: value` and folded/literal block scalars (`>-`, `>`, `|`).
    """
    lines = path.read_text(encoding="utf-8").split("\n")
    assert lines[0] == "---", f"{path}: missing opening frontmatter fence"
    end = lines.index("---", 1)
    fields: dict[str, str] = {}
    key = None
    block: list[str] = []
    for line in lines[1:end]:
        match = re.match(r"^([A-Za-z_-]+):\s*(.*)$", line)
        if match and not line.startswith(" "):
            if key is not None:
                fields[key] = " ".join(block).strip()
            key, value = match.group(1), match.group(2)
            block = [] if value in (">-", ">", "|", "|-") else [value]
        elif key is not None:
            block.append(line.strip())
    if key is not None:
        fields[key] = " ".join(block).strip()
    return fields


def test_skills_present() -> None:
    """The plugin ships at least one skill directory."""
    assert _SKILL_DIRS


@pytest.mark.parametrize("skill_dir", _SKILL_DIRS, ids=lambda p: p.name)
def test_skill_layout_and_frontmatter(skill_dir: Path) -> None:
    """Each skill has SKILL.md, a matching koopa-* name, and a bounded description."""
    skill_file = skill_dir / "SKILL.md"
    assert skill_file.is_file()
    fields = _frontmatter(skill_file)
    assert fields["name"] == skill_dir.name
    assert skill_dir.name.startswith("koopa-")
    description = fields["description"]
    assert description
    assert len(description) <= _MAX_DESCRIPTION
    # Copilot CLI's YAML parser reads a colon followed by a space as a mapping entry and
    # rejects the whole skill.
    assert ": " not in description


@pytest.mark.parametrize("skill_dir", _SKILL_DIRS, ids=lambda p: p.name)
def test_skill_has_no_old_dotfiles_names(skill_dir: Path) -> None:
    """No skill still references one of the retired dotfiles-* skill names."""
    text = (skill_dir / "SKILL.md").read_text(encoding="utf-8")
    for old in _OLD_SKILL_NAMES:
        # Rule files such as dotfiles-python.md are not skills.
        assert not re.search(rf"(?<![\w-]){re.escape(old)}(?![\w-]|\.md)", text), old


def test_plugin_has_no_symlinks() -> None:
    """The plugin must be self-contained: no symlinks anywhere under it."""
    links = [str(p) for p in _PLUGIN_DIR.rglob("*") if p.is_symlink()]
    assert links == []
