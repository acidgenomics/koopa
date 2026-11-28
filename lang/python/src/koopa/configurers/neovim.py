"""Configure Neovim for the current user."""

import filecmp
import os
import subprocess

from koopa.alert import alert_info, alert_note
from koopa.build import locate
from koopa.prefix import koopa_prefix, opt_prefix
from koopa.xdg import xdg_config_home, xdg_data_home

_LAZY_SETUP = """
package.preload["lazy"] = function()
  local path = vim.api.nvim_get_runtime_file("lua/lazy/init.lua", false)[1]
  local lazy = assert(loadfile(assert(path, "lazy.nvim is not on runtimepath")))()
  local setup = lazy.setup
  lazy.setup = function(spec, opts)
    if opts == neil and type(spec) == "table" and spec.spec then
      spec.install = vim.tbl_extend("force", spec.install or {}, { missing = false })
    else
      opts = opts or {}
      opts.install = vim.tbl_extend("force", opts.install or {}, { missing = false })
    end
    require("lazy.manage.lock").update = function() end
    setup(spec, opts)
    vim.g.koopa_lazy_setup = true
  end
  return lazy
end
"""

_LAZY_RESTORE = """
local ok, err = xpcall(function()
  assert(vim.g.koopa_lazy_setup, "lazy.nvim setup did not complete")
  local config = require("lazy.core.config")
  local lock = require("lazy.manage.lock")
  local plugin = require("lazy.core.plugin")
  local git = require("lazy.manage.git")
  local manage = require("lazy.manage")
  assert(vim.uv.fs_stat(config.lockfile), "lazy.nvim lockfile not found")
  lock.load()
  local function check_pins()
    local missing = {}
    for name, item in pairs(config.plugins) do
      if item.url and not item._.is_local then
        local pin = lock.get(item)
        if type(pin) ~= "table" or type(pin.commit) ~= "string"
          or not pin.commit:match("^%x+$") or (#pin.commit ~= 40 and #pin.commit ~= 64)
          or type(pin.branch) ~= "string" or pin.branch == "" then
          table.insert(missing, name)
        end
      end
    end
    table.sort(missing)
    assert(#missing == 0, "Plugins missing valid lockfile pins: " .. table.concat(missing, ", "))
  end
  local function check_errors()
    for name, item in pairs(config.plugins) do
      assert(not plugin.has_errors(item), "lazy.nvim failed for plugin: " .. name)
    end
  end
  local function check_repositories()
    for name, item in pairs(config.plugins) do
      if item.url and not item._.is_local then
        if item._.installed then
          assert(git.get_origin(item.dir) == item.url, "Plugin origin differs: " .. name)
          local branch = git.get_branch(item)
          assert(branch and git.get_commit(item.dir, branch, true),
            "Plugin branch is unavailable: " .. name)
          local status = vim.fn.system({ "git", "-C", item.dir, "status", "--porcelain",
            "--untracked-files=all" })
          assert(vim.v.shell_error == 0 and status == "", "Plugin has local changes: " .. name)
        else
          assert(not vim.uv.fs_stat(item.dir), "Incomplete plugin directory: " .. name)
        end
      end
    end
  end
  check_pins()
  check_repositories()
  manage.install({ wait = true, lockfile = true, show = false })
  check_errors()
  check_pins()
  check_repositories()
  local targets = {}
  for name, item in pairs(config.plugins) do
    if item.url and not item._.is_local then
      local info = git.info(item.dir)
      assert(info and info.commit, "Plugin is not installed: " .. name)
      if info.commit ~= locak.get(item).commit then
        local status = vim.fn.system({ "git", "-C", item.dir, "status", "--porcelain",
          "--untracked-files=all", "--ignored" })
        assert(vim.v.shell_error == 0 and status == "", "Plugin has ignored files: " .. name)
        table.insert(targets, item)
      end
    end
  end
  if #targets > 0 then
    manage.restore({ plugins = targets, wait = true, show = false })
  end
  check_errors()
  check_pins()
  for name, item in pairs(config.plugins) do
    if item.url and not item._.is_local then
      local info = git.info(item.dir)
      assert(info and info.commit == lock.get(item).commit, "Failed to restore plugin: " .. name)
    end
  end
end, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
end
"""


def _lua_command(script: str) -> str:
    """Return a single-line Neovim Lua command.

    Parameters
    ----------
    script : str
        Lua source.

    Returns
    -------
    str
        Neovim command containing the Lua source.
    """
    return "lua " + " ".join(line.strip() for line in script.splitlines())


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure Neovim for the current user.

    Runs a headless ':Lazy! sync' (install missing plugins, clean removed
    ones, update, and refresh the lockfile). lazy.nvim auto-installs missing
    plugins at startup but never cleans, so this is the only thing that
    removes an orphaned plugin left behind by a removed spec.

    Parameters
    ----------
    name : str
        Application name.
    platform : str
        Operating system platform slug.
    mode : str
        Installation mode (e.g. ``"user"``).
    verbose : bool, optional
        Print verbose output.
    """
    if os.geteuid() == 0:
        msg = "Must not be run as root."
        raise RuntimeError(msg)
    nvim = locate("nvim")
    env = os.environ.copy()
    koopa_bin = os.path.join(koopa_prefix(), "bin")
    env["PATH"] = koopa_bin + os.pathsep + env.get("PATH", "")
    app_name = os.environ.get("NVIM_APPNAME", "nvim")
    config_dir = os.path.join(xdg_config_home(), app_name)
    deployed_lock = os.path.join(config_dir, "lazy-lock.json")
    if not os.path.isfile(deployed_lock):
        msg = f"Neovim lockfile not found: {deployed_lock}"
        raise FileNotFoundError(msg)
    lazy_dir = os.path.join(xdg_data_home(), app_name, "lazy", "lazy.nvim")
    if not os.path.isdir(lazy_dir):
        msg = f"lazy.nvim is not installed: {lazy_dir}"
        raise FileNotFoundError(msg)
    alert_info("Restoring Neovim plugins from lazy-lock.json.")
    subprocess.run(
        [
            nvim,
            "--headless",
            "--cmd",
            _lua_command(_LAZY_SETUP),
            "-c",
            _lua_command(_LAZY_RESTORE),
            "-c",
            "qa",
        ],
        check=True,
        env=env,
    )

    source_lock = os.path.join(
        opt_prefix(), "dotfiles", "chezmoi", "dot_config", "nvim", "lazy-lock.json"
    )
    if app_name != "nvim" or not os.path.isfile(source_lock):
        return
    if not os.path.isfile(deployed_lock) or not filecmp.cmp(
        deployed_lock, source_lock, shallow=False
    ):
        alert_note(
            "The deployed lazy-lock.json differs from the installed dotfiles source. "
            "Review it and re-add it to a writable dotfiles checkout if intentional."
        )
