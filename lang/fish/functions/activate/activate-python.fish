function _koopa_activate_python
    # Activate Python environment variables.
    # @note Updated 2026-06-13.
    if not set -q PIP_REQUIRE_VIRTUALENV
        set -gx PIP_REQUIRE_VIRTUALENV true
    end
    if not set -q PYTHONDONTWRITEBYTECODE
        set -gx PYTHONDONTWRITEBYTECODE 1
    end
    if not set -q PYTHONSTARTUP
        set -l startup_file "$HOME/.pyrc"
        if test -f "$startup_file"
            set -gx PYTHONSTARTUP "$startup_file"
        end
    end
    if not set -q PYTHONWARNINGS
        set -gx PYTHONWARNINGS 'ignore::SyntaxWarning'
    end
    if not set -q VIRTUAL_ENV_DISABLE_PROMPT
        set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
    end
end
