"""Generic GNU app installer."""

from koopa.install import install_gnu_app
from koopa.installers._args import get_str, parse_passthrough
from koopa.installers._build_helper import activate_app_deps


def main(
    *,
    name: str,
    version: str,
    prefix: str,
    passthrough_args: list[str] | None = None,
) -> None:
    """Install a GNU app from source."""
    env = activate_app_deps()
    if env is not None:
        env.apply()
    kwargs = parse_passthrough(passthrough_args)
    known_keys = {"compress_ext", "jobs", "package_name", "parent_name", "non_gnu_mirror"}
    conf_args: list[str] = []
    for key, value in kwargs.items():
        if key in known_keys:
            continue
        flag = f"--{key.replace('_', '-')}"
        if isinstance(value, list):
            for v in value:
                conf_args.append(f"{flag}={v}" if v else flag)
        elif value:
            conf_args.append(f"{flag}={value}")
        else:
            conf_args.append(flag)
    jobs_str = get_str(kwargs, "jobs")
    install_gnu_app(
        name=name,
        version=version,
        prefix=prefix,
        compress_ext=get_str(kwargs, "compress_ext", "gz"),
        package_name=get_str(kwargs, "package_name"),
        parent_name=get_str(kwargs, "parent_name"),
        non_gnu_mirror=get_str(kwargs, "non_gnu_mirror") == "true",
        conf_args=conf_args or None,
        jobs=int(jobs_str) if jobs_str else None,
    )
