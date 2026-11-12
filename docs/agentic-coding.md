# Agentic coding

Koopa can be used alongside coding agents while keeping system changes under your
control. Its safeguards work at two levels: the `koopa` CLI refuses system-changing
commands in an agent session, and the optional koopa plugin provides agent skills and
shell-command hooks.

## CLI safeguards

When koopa detects that a coding agent launched a command, it refuses commands that
would change the system: `install`, `reinstall`, `uninstall`, `update`, `configure`,
`admin` commands, `system prune-apps`, and `develop switch-to-main` or
`develop switch-to-develop` (including its legacy `system` alias). The refusal
shows the command for you to run in your own terminal. Read-only commands, such as
`koopa list` and `koopa system info`, remain available.

Koopa detects markers supplied by agent hosts. Set `KOOPA_AGENT=1` to enable this
mode explicitly, or `KOOPA_AGENT=0` to disable it for a command you choose to run
yourself.

## Koopa agent plugin

The koopa plugin provides skills for using and troubleshooting koopa, along with
shell-safety hooks for agent tools. The hooks can ask before software installations
and block risky operations such as destructive Git commands or writing secrets.
They are optional and opinionated; review the
[plugin documentation](https://github.com/acidgenomics/koopa/blob/main/plugins/koopa/README.md)
for the complete behavior and current tool support.

The koopa dotfiles declare the plugin for Claude Code and Copilot CLI. If the plugin
is installed, `koopa update` refreshes it when its contents change. See
[Dotfiles](dotfiles.md) to apply the agent configuration. These hooks depend on the
agent host's plugin support; the CLI safeguards above are enforced by koopa itself.
