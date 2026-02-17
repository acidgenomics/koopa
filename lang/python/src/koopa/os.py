"""Operating system (platform)-specific variables.

.. deprecated::
    This module is retained for backward compatibility. Use
    :mod:`koopa.system` and :mod:`koopa.prefix` instead.
"""

from koopa.prefix import app_prefix as koopa_app_prefix  # noqa: F401
from koopa.prefix import koopa_prefix  # noqa: F401
from koopa.prefix import opt_prefix as koopa_opt_prefix  # noqa: F401
from koopa.system import arch, arch2, os_string  # noqa: F401


def os_id() -> str:
    """Platform and architecture-specific identifier.

    Returns
    -------
    str
        Platform-architecture string (e.g. 'macos-amd64').
    """
    return os_string()
