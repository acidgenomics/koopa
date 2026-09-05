"""DNS lookup and nameserver provider utilities."""

import json
import shutil
import subprocess

_DEFAULT_DOMAINS: tuple[str, ...] = ("acidgenomics.com", "steinbaugh.com")

_RECORD_TYPES: tuple[str, ...] = ("NS", "A", "AAAA", "MX", "TXT")


def _dig(name: str, rtype: str, *, nameserver: str | None = None) -> list[str]:
    """Run dig +short and return non-empty lines.

    Parameters
    ----------
    name : str
        Domain or hostname to query.
    rtype : str
        DNS record type to request (e.g. ``"A"``, ``"NS"``, ``"TXT"``).
    nameserver : str | None, optional
        Nameserver to query directly. Queries the resolver's default
        nameserver when None.

    Returns
    -------
    list[str]
        Non-empty output lines from ``dig +short``.
    """
    dig = shutil.which("dig")
    if dig is None:
        msg = "Command not found: dig"
        raise RuntimeError(msg)
    cmd = [dig, "+short", name, rtype]
    if nameserver is not None:
        cmd.append(f"@{nameserver}")
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    return [line for line in result.stdout.splitlines() if line.strip()]


def nameserver_provider(ns_values: list[str]) -> str:
    """Classify nameservers as Route 53, Hover, or Other.

    Parameters
    ----------
    ns_values : list[str]
        Nameserver hostnames to classify.

    Returns
    -------
    str
        ``"Route 53"``, ``"Hover"``, or ``"Other"``.
    """
    # Route 53 nameservers have the pattern: ns-XXX.awsdns-YY.com
    if any(".awsdns-" in ns.lower() for ns in ns_values):
        return "Route 53"
    # Hover nameservers end with .hover.com (with or without trailing dot)
    if any(ns.lower().rstrip(".").endswith(".hover.com") for ns in ns_values):
        return "Hover"
    return "Other"


def dns_records(domain: str) -> dict[str, list[str]]:
    """Query NS, A, AAAA, MX, TXT, and _dmarc TXT for a domain.

    Parameters
    ----------
    domain : str
        Domain name to query.

    Returns
    -------
    dict[str, list[str]]
        Record type mapped to its non-empty list of values. A record
        type is absent from the result when the query returns nothing.
    """
    records: dict[str, list[str]] = {}
    for rtype in _RECORD_TYPES:
        values = _dig(domain, rtype)
        if values:
            records[rtype] = values
    dmarc = _dig(f"_dmarc.{domain}", "TXT")
    if dmarc:
        records["_dmarc TXT"] = dmarc
    return records


def route53_zone_records(
    domain: str,
    *,
    profile: str = "acidgenomics",
) -> dict[str, list[str]] | None:
    """Return Route 53 record set for domain, or None if unavailable.

    Keys match dns_records() output (NS, A, AAAA, MX, TXT, _dmarc TXT).
    Alias records are represented as their target DNS name.

    Parameters
    ----------
    domain : str
        Domain name whose hosted zone to query.
    profile : str, optional
        AWS CLI profile name used for the Route 53 calls.

    Returns
    -------
    dict[str, list[str]] | None
        Record type mapped to its non-empty list of values, or None if
        the AWS CLI is missing, the hosted zone lookup fails, or no
        matching hosted zone exists.
    """
    import os

    aws = shutil.which("aws")
    if aws is None:
        return None
    env = os.environ.copy()
    env["AWS_PAGER"] = ""
    try:
        zones_result = subprocess.run(
            [
                aws,
                "--profile",
                profile,
                "route53",
                "list-hosted-zones",
                "--query",
                f"HostedZones[?Name=='{domain}.'].Id",
                "--output",
                "json",
            ],
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    except subprocess.CalledProcessError:
        return None
    zone_ids: list[str] = json.loads(zones_result.stdout)
    if not zone_ids:
        return None
    zone_id = zone_ids[0].split("/")[-1]
    try:
        rrs_result = subprocess.run(
            [
                aws,
                "--profile",
                profile,
                "route53",
                "list-resource-record-sets",
                "--hosted-zone-id",
                zone_id,
            ],
            capture_output=True,
            text=True,
            check=True,
            env=env,
        )
    except subprocess.CalledProcessError:
        return None
    data = json.loads(rrs_result.stdout)
    records: dict[str, list[str]] = {}
    domain_dot = f"{domain}."
    for rrs in data.get("ResourceRecordSets", []):
        name: str = rrs["Name"]
        rtype: str = rrs["Type"]
        alias = rrs.get("AliasTarget", {}).get("DNSName")
        if alias is not None:
            values = [alias.rstrip(".")]
        else:
            values = [r["Value"] for r in rrs.get("ResourceRecords", [])]
        if name == domain_dot:
            key = rtype
        elif name == f"_dmarc.{domain_dot}":
            key = "_dmarc TXT"
        else:
            continue
        if key in ("NS", "SOA"):
            continue
        if values:
            records[key] = values
    return records


def _normalise(value: str) -> str:
    """Normalise a DNS record value for comparison.

    Strips surrounding quotes (dig returns them for TXT; R53 API also wraps
    them), trailing dots, and collapses internal whitespace so that MX
    priority spacing differences ("1  aspmx" vs "1 aspmx") are ignored.

    Parameters
    ----------
    value : str
        Raw DNS record value to normalise.

    Returns
    -------
    str
        Normalised value with quotes and trailing dot stripped and
        internal whitespace collapsed to single spaces.
    """
    v = value.strip().strip('"').rstrip(".")
    return " ".join(v.split())


def diff_live_vs_route53(domain: str) -> list[str]:
    """Return drift lines between live DNS and Route 53 zone.

    Returns an empty list when in sync or when Route 53 is unreachable.
    Skips A/AAAA (R53 stores CloudFront alias targets; live returns resolved
    IPs from the same distro — equivalent but not byte-comparable) and NS
    (R53 delegation set is not returned by list-resource-record-sets).

    Parameters
    ----------
    domain : str
        Domain name to compare.

    Returns
    -------
    list[str]
        One formatted line per record type with mismatched values.
        Contains a single explanatory line instead when Route 53 is
        unreachable, and is empty when live DNS matches Route 53.
    """
    live = dns_records(domain)
    r53 = route53_zone_records(domain)
    if r53 is None:
        return ["  (AWS not authenticated — skipping Route 53 diff)"]
    drift: list[str] = []
    skip = {"A", "AAAA", "NS"}
    all_keys = sorted((set(live) | set(r53)) - skip)
    for key in all_keys:
        live_vals = sorted(_normalise(v) for v in live.get(key, []))
        r53_vals = sorted(_normalise(v) for v in r53.get(key, []))
        if live_vals != r53_vals:
            drift.append(f"  {key}: live={live_vals}  r53={r53_vals}")
    return drift
