"""Install r-devel."""


from koopa.installers.r_app import main as r_main


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install r-devel."""
    r_main(name="r-devel", version=version, prefix=prefix)
