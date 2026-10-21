"""Tests for the koopa plugin's skills (plugins/koopa/skills)."""

import re
from pathlib import Path

import pytest
from koopa.prefix import koopa_prefix

_PREFIX = Path(koopa_prefix())
_PLUGIN_DIR = _PREFIX / "plugins" / "koopa"
_SKILLS_DIR = _PLUGIN_DIR / "skills"
_REPO_SKILLS_DIR = _PREFIX / ".agents" / "skills"
_MAX_DESCRIPTION = 1023
# Name plus description of every skill. 2026-10-20: plugin 4,163, repo 15,061.
_PLUGIN_SKILL_INDEX_BUDGET = 5_000
_REPO_SKILL_INDEX_BUDGET = 20_000
_HARNESS_SPECIFIC_RE = re.compile(
    r"mcp__|\b(?:AskUserQuestion|TodoWrite|ExitPlanMode|EnterPlanMode|NotebookEdit|WebFetch"
    r"|WebSearch)\b|\b(?:Task|Skill) tool\b"
)
_HARNESS_DOCUMENTING_SKILLS = frozenset(
    {
        "koopa-agent-guards",
        "koopa-claude-permissions",
        "koopa-maintain-claude-config",
        "koopa-plugin-hooks",
    }
)
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


def _index_size(skills_dir: Path) -> tuple[int, list[tuple[int, str]]]:
    """Return the total name plus description length of every skill, and the longest."""
    sizes = []
    for skill_file in sorted(skills_dir.glob("*/SKILL.md")):
        fields = _frontmatter(skill_file)
        sizes.append((len(fields["name"]) + len(fields["description"]), skill_file.parent.name))
    return sum(size for size, _ in sizes), sorted(sizes, reverse=True)[:5]


@pytest.mark.parametrize(
    ("skills_dir", "budget"),
    [
        # The plugin's skills are listed in every session of every project that
        # enables the plugin, so they get the tighter cap.
        (_SKILLS_DIR, _PLUGIN_SKILL_INDEX_BUDGET),
        (_REPO_SKILLS_DIR, _REPO_SKILL_INDEX_BUDGET),
    ],
    ids=["plugin", "repo"],
)
def test_skill_index_stays_within_budget(skills_dir: Path, budget: int) -> None:
    """Every harness puts each skill's name and description in context on every turn.

    The full instructions load only when a skill is used, so the description carries
    one strong trigger and the detail lives in the body.
    """
    total, longest = _index_size(skills_dir)
    assert total <= budget, f"{total} chars over the {budget} budget; shorten: {longest}"


def _skill_name(path: Path) -> str:
    """Return the skill directory name of a file under either skills root."""
    for root in (_SKILLS_DIR, _REPO_SKILLS_DIR):
        if path.is_relative_to(root):
            return path.relative_to(root).parts[0]
    raise ValueError(path)


@pytest.mark.parametrize(
    "skill_file",
    sorted([*_SKILLS_DIR.glob("*/**/*.md"), *_REPO_SKILLS_DIR.glob("*/**/*.md")]),
    ids=lambda p: str(p.relative_to(_PREFIX)),
)
def test_skill_uses_harness_neutral_tool_names(skill_file: Path) -> None:
    """Skills name tools every harness has, not one harness's own tool names.

    `mcp__server__tool` is Claude Code's naming (Copilot shows `server-tool`), and the
    UI tools below exist only in Claude Code. Skills about a harness's own
    configuration are exempt.
    """
    if _skill_name(skill_file) in _HARNESS_DOCUMENTING_SKILLS:
        return
    for number, line in enumerate(skill_file.read_text(encoding="utf-8").splitlines(), 1):
        match = _HARNESS_SPECIFIC_RE.search(line)
        assert match is None, f"line {number}: {match and match.group(0)}"
