"""SRA toolkit functions.

Converted from Bash functions in ``lang/bash/functions/core/sra-*.sh``.
"""

from __future__ import annotations

import gzip
import os
import shutil
import subprocess
from pathlib import Path


def sra_prefetch(
    accession_file: str,
    output_dir: str,
    *,
    jobs: int = 4,
) -> None:
    """Prefetch files from SRA."""
    prefetch = shutil.which("prefetch")
    if prefetch is None:
        msg = "prefetch is not installed."
        raise RuntimeError(msg)
    if not os.path.isfile(accession_file):
        msg = f"Accession file not found: '{accession_file}'."
        raise FileNotFoundError(msg)
    os.makedirs(output_dir, exist_ok=True)
    print(f"Prefetching SRA samples from '{accession_file}' to '{output_dir}'.")
    with open(accession_file) as f:
        accessions = [line.strip() for line in f if line.strip()]
    for acc in accessions:
        print(f"Prefetching '{acc}'.")
        subprocess.run(
            [
                prefetch,
                "--force",
                "no",
                "--max-size",
                "500G",
                "--output-directory",
                output_dir,
                "--progress",
                "--resume",
                "yes",
                "--type",
                "sra",
                "--verbose",
                "--verify",
                "yes",
                acc,
            ],
            check=True,
        )


def sra_fastq_dump(
    prefetch_dir: str,
    fastq_dir: str,
    *,
    compress: bool = True,
    threads: int | None = None,
) -> None:
    """Dump FASTQ files from SRA prefetch directory."""
    fasterq_dump = shutil.which("fasterq-dump")
    if fasterq_dump is None:
        msg = "fasterq-dump is not installed."
        raise RuntimeError(msg)
    if threads is None:
        threads = os.cpu_count() or 1
    if not os.path.isdir(prefetch_dir):
        msg = f"Prefetch directory not found: '{prefetch_dir}'."
        raise FileNotFoundError(msg)
    prefetch_dir = os.path.realpath(prefetch_dir)
    os.makedirs(fastq_dir, exist_ok=True)
    print(f"Dumping FASTQ files from '{prefetch_dir}' to '{fastq_dir}'.")
    sra_files = sorted(Path(prefetch_dir).rglob("*.sra"))
    if not sra_files:
        msg = f"No .sra files found in '{prefetch_dir}'."
        raise RuntimeError(msg)
    for sra_file in sra_files:
        sample_id = sra_file.stem
        if (
            Path(fastq_dir, f"{sample_id}.fastq").exists()
            or Path(fastq_dir, f"{sample_id}_1.fastq").exists()
            or Path(fastq_dir, f"{sample_id}.fastq.gz").exists()
            or Path(fastq_dir, f"{sample_id}_1.fastq.gz").exists()
        ):
            print(f"Skipping '{sra_file}' (already dumped).")
            continue
        print(f"Dumping '{sra_file}'.")
        subprocess.run(
            [
                fasterq_dump,
                "--details",
                "--force",
                "--outdir",
                fastq_dir,
                "--progress",
                "--skip-technical",
                "--split-3",
                "--threads",
                str(threads),
                "--verbose",
                str(sra_file),
            ],
            check=True,
        )
        if compress:
            for fq in sorted(Path(fastq_dir).glob(f"{sample_id}*.fastq")):
                print(f"Compressing '{fq}'.")
                with open(fq, "rb") as f_in:
                    with gzip.open(str(fq) + ".gz", "wb") as f_out:
                        shutil.copyfileobj(f_in, f_out)
                fq.unlink()


def sra_download_accession_list(srp_id: str, output_file: str = "") -> None:
    """Download SRA accession list."""
    esearch = shutil.which("esearch")
    efetch = shutil.which("efetch")
    if esearch is None or efetch is None:
        msg = "NCBI Entrez Direct (esearch/efetch) is required."
        raise RuntimeError(msg)
    if not output_file:
        output_file = f"{srp_id.lower()}-accession-list.txt"
    print(f"Downloading SRA accession list for '{srp_id}' to '{output_file}'.")
    esearch_proc = subprocess.Popen(
        [esearch, "-db", "sra", "-query", srp_id],
        stdout=subprocess.PIPE,
    )
    efetch_proc = subprocess.Popen(
        [efetch, "-format", "runinfo"],
        stdin=esearch_proc.stdout,
        stdout=subprocess.PIPE,
        text=True,
    )
    esearch_proc.stdout.close()
    stdout, _ = efetch_proc.communicate()
    if efetch_proc.returncode != 0:
        msg = f"Failed to fetch accession list for '{srp_id}'."
        raise RuntimeError(msg)
    lines = stdout.strip().splitlines()
    accessions = []
    for line in lines[1:]:
        parts = line.split(",")
        if parts and parts[0].strip():
            accessions.append(parts[0].strip())
    Path(output_file).write_text("\n".join(accessions) + "\n")


def sra_download_run_info_table(srp_id: str, output_file: str = "") -> None:
    """Download SRA run info table."""
    esearch = shutil.which("esearch")
    efetch = shutil.which("efetch")
    if esearch is None or efetch is None:
        msg = "NCBI Entrez Direct (esearch/efetch) is required."
        raise RuntimeError(msg)
    if not output_file:
        output_file = f"{srp_id.lower()}-run-info-table.csv"
    print(f"Downloading SRA run info for '{srp_id}' to '{output_file}'.")
    esearch_proc = subprocess.Popen(
        [esearch, "-db", "sra", "-query", srp_id],
        stdout=subprocess.PIPE,
    )
    efetch_proc = subprocess.Popen(
        [efetch, "-format", "runinfo"],
        stdin=esearch_proc.stdout,
        stdout=subprocess.PIPE,
        text=True,
    )
    esearch_proc.stdout.close()
    stdout, _ = efetch_proc.communicate()
    if efetch_proc.returncode != 0:
        msg = f"Failed to fetch run info for '{srp_id}'."
        raise RuntimeError(msg)
    Path(output_file).write_text(stdout)
