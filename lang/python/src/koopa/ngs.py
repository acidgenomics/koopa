"""Next-generation sequencing (NGS) bioinformatics pipeline functions.

Converted from Bash functions: salmon-index, salmon-quant, star-index,
star-align, samtools-index, samtools-sort, bowtie2-build, bowtie2-align,
hisat2-build, kallisto-index, kallisto-quant, bam-filter, bam-to-fastq,
fastqc, multiqc, etc.
"""

from __future__ import annotations

import subprocess
from pathlib import Path


def _run_cmd(
    args: list[str],
    *,
    cwd: str | None = None,
    capture: bool = False,
) -> subprocess.CompletedProcess:
    """Run a subprocess command."""
    return subprocess.run(
        args,
        cwd=cwd,
        capture_output=capture,
        text=True,
        check=True,
    )


# -- Salmon ------------------------------------------------------------------


def salmon_index(
    fasta: str,
    output_dir: str,
    *,
    threads: int = 1,
    kmer: int = 31,
    gencode: bool = False,
) -> None:
    """Build a Salmon index."""
    args = [
        "salmon",
        "index",
        "-t",
        fasta,
        "-i",
        output_dir,
        "-p",
        str(threads),
        "-k",
        str(kmer),
    ]
    if gencode:
        args.append("--gencode")
    _run_cmd(args)


def salmon_quant(
    index_dir: str,
    output_dir: str,
    *,
    r1: str | list[str] | None = None,
    r2: str | list[str] | None = None,
    unmated: str | list[str] | None = None,
    threads: int = 1,
    lib_type: str = "A",
) -> None:
    """Quantify with Salmon."""
    args = [
        "salmon",
        "quant",
        "-i",
        index_dir,
        "-o",
        output_dir,
        "--threads",
        str(threads),
        "-l",
        lib_type,
    ]
    if r1 and r2:
        if isinstance(r1, list):
            r1 = " ".join(r1)
        if isinstance(r2, list):
            r2 = " ".join(r2)
        args.extend(["-1", r1, "-2", r2])
    elif unmated:
        if isinstance(unmated, list):
            unmated = " ".join(unmated)
        args.extend(["-r", unmated])
    _run_cmd(args)


# -- STAR ---------------------------------------------------------------------


def star_index(
    fasta: str,
    output_dir: str,
    *,
    gtf: str | None = None,
    threads: int = 1,
    sa_index_nbases: int | None = None,
) -> None:
    """Build a STAR genome index."""
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    args = [
        "STAR",
        "--runMode",
        "genomeGenerate",
        "--genomeDir",
        output_dir,
        "--genomeFastaFiles",
        fasta,
        "--runThreadN",
        str(threads),
    ]
    if gtf:
        args.extend(["--sjdbGTFfile", gtf])
    if sa_index_nbases is not None:
        args.extend(["--genomeSAindexNbases", str(sa_index_nbases)])
    _run_cmd(args)


def star_align(
    genome_dir: str,
    output_prefix: str,
    *,
    r1: str,
    r2: str | None = None,
    threads: int = 1,
    out_sam_type: str = "BAM SortedByCoordinate",
) -> None:
    """Align reads with STAR."""
    args = [
        "STAR",
        "--runMode",
        "alignReads",
        "--genomeDir",
        genome_dir,
        "--outFileNamePrefix",
        output_prefix,
        "--runThreadN",
        str(threads),
        "--outSAMtype",
        *out_sam_type.split(),
        "--readFilesIn",
        r1,
    ]
    if r2:
        args.append(r2)
    if r1.endswith(".gz"):
        args.extend(["--readFilesCommand", "zcat"])
    _run_cmd(args)


# -- samtools -----------------------------------------------------------------


def samtools_index(bam: str, *, threads: int = 1) -> None:
    """Index a BAM file."""
    _run_cmd(["samtools", "index", "-@", str(threads), bam])


def samtools_sort(
    input_bam: str,
    output_bam: str,
    *,
    threads: int = 1,
    by_name: bool = False,
) -> None:
    """Sort a BAM file."""
    args = ["samtools", "sort", "-@", str(threads), "-o", output_bam]
    if by_name:
        args.append("-n")
    args.append(input_bam)
    _run_cmd(args)


def samtools_flagstat(bam: str, *, threads: int = 1) -> str:
    """Get BAM flagstat."""
    result = _run_cmd(
        ["samtools", "flagstat", "-@", str(threads), bam],
        capture=True,
    )
    return result.stdout


def samtools_stats(bam: str, *, threads: int = 1) -> str:
    """Get BAM stats."""
    result = _run_cmd(
        ["samtools", "stats", "-@", str(threads), bam],
        capture=True,
    )
    return result.stdout


def samtools_view(
    input_bam: str,
    output_bam: str | None = None,
    *,
    threads: int = 1,
    flags_include: int | None = None,
    flags_exclude: int | None = None,
    min_mapq: int | None = None,
    output_fmt: str = "BAM",
) -> str | None:
    """View/filter a BAM file."""
    args = ["samtools", "view", "-@", str(threads)]
    if output_fmt.upper() == "BAM":
        args.append("-b")
    if flags_include is not None:
        args.extend(["-f", str(flags_include)])
    if flags_exclude is not None:
        args.extend(["-F", str(flags_exclude)])
    if min_mapq is not None:
        args.extend(["-q", str(min_mapq)])
    args.append(input_bam)
    if output_bam:
        args.extend(["-o", output_bam])
        _run_cmd(args)
        return None
    result = _run_cmd(args, capture=True)
    return result.stdout


# -- bowtie2 ------------------------------------------------------------------


def bowtie2_build(
    fasta: str,
    index_prefix: str,
    *,
    threads: int = 1,
) -> None:
    """Build a Bowtie2 index."""
    _run_cmd(
        [
            "bowtie2-build",
            "--threads",
            str(threads),
            fasta,
            index_prefix,
        ]
    )


def bowtie2_align(
    index_prefix: str,
    output_sam: str,
    *,
    r1: str,
    r2: str | None = None,
    threads: int = 1,
    sensitive: bool = True,
) -> None:
    """Align reads with Bowtie2."""
    args = [
        "bowtie2",
        "-x",
        index_prefix,
        "-p",
        str(threads),
        "-S",
        output_sam,
    ]
    if sensitive:
        args.append("--very-sensitive")
    if r2:
        args.extend(["-1", r1, "-2", r2])
    else:
        args.extend(["-U", r1])
    _run_cmd(args)


# -- HISAT2 -------------------------------------------------------------------


def hisat2_build(
    fasta: str,
    index_prefix: str,
    *,
    threads: int = 1,
) -> None:
    """Build a HISAT2 index."""
    _run_cmd(
        [
            "hisat2-build",
            "-p",
            str(threads),
            fasta,
            index_prefix,
        ]
    )


# -- kallisto -----------------------------------------------------------------


def kallisto_index(fasta: str, output: str, *, kmer: int = 31) -> None:
    """Build a Kallisto index."""
    _run_cmd(["kallisto", "index", "-i", output, "-k", str(kmer), fasta])


def kallisto_quant(
    index: str,
    output_dir: str,
    *,
    r1: str,
    r2: str | None = None,
    threads: int = 1,
    bootstrap: int = 100,
) -> None:
    """Quantify with Kallisto."""
    args = [
        "kallisto",
        "quant",
        "-i",
        index,
        "-o",
        output_dir,
        "-t",
        str(threads),
        "-b",
        str(bootstrap),
    ]
    if r2:
        args.extend([r1, r2])
    else:
        args.extend(["--single", r1])
    _run_cmd(args)


# -- BAM utilities ------------------------------------------------------------


def bam_filter(
    input_bam: str,
    output_bam: str,
    *,
    min_mapq: int = 10,
    exclude_flags: int = 0x04,
    threads: int = 1,
) -> None:
    """Filter a BAM file by quality and flags."""
    samtools_view(
        input_bam,
        output_bam,
        min_mapq=min_mapq,
        flags_exclude=exclude_flags,
        threads=threads,
    )
    samtools_index(output_bam, threads=threads)


def bam_to_fastq(
    bam: str,
    r1: str,
    r2: str | None = None,
    *,
    threads: int = 1,
) -> None:
    """Convert BAM to FASTQ."""
    args = ["samtools", "fastq", "-@", str(threads)]
    if r2:
        args.extend(["-1", r1, "-2", r2, "-0", "/dev/null", "-s", "/dev/null"])
    else:
        args.extend(["-o", r1])
    args.append(bam)
    _run_cmd(args)


# -- QC -----------------------------------------------------------------------


def fastqc(
    *files: str,
    output_dir: str | None = None,
    threads: int = 1,
) -> None:
    """Run FastQC on FASTQ files."""
    args = ["fastqc", "--threads", str(threads)]
    if output_dir:
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        args.extend(["--outdir", output_dir])
    args.extend(files)
    _run_cmd(args)


def multiqc(
    input_dir: str,
    output_dir: str | None = None,
    *,
    force: bool = True,
) -> None:
    """Run MultiQC to aggregate reports."""
    args = ["multiqc"]
    if force:
        args.append("--force")
    if output_dir:
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        args.extend(["--outdir", output_dir])
    args.append(input_dir)
    _run_cmd(args)


# -- RSEM ---------------------------------------------------------------------


def rsem_prepare_reference(
    fasta: str,
    reference_prefix: str,
    *,
    gtf: str | None = None,
    threads: int = 1,
) -> None:
    """Prepare RSEM reference."""
    args = [
        "rsem-prepare-reference",
        "-p",
        str(threads),
    ]
    if gtf:
        args.extend(["--gtf", gtf])
    args.extend([fasta, reference_prefix])
    _run_cmd(args)


def rsem_calculate_expression(
    bam: str,
    reference_prefix: str,
    output_prefix: str,
    *,
    threads: int = 1,
    paired_end: bool = True,
) -> None:
    """Calculate expression with RSEM."""
    args = [
        "rsem-calculate-expression",
        "-p",
        str(threads),
        "--bam",
        "--no-bam-output",
    ]
    if paired_end:
        args.append("--paired-end")
    args.extend([bam, reference_prefix, output_prefix])
    _run_cmd(args)


# -- bedtools -----------------------------------------------------------------


def bedtools_intersect(
    a: str,
    b: str,
    output: str | None = None,
    *,
    v: bool = False,
) -> str | None:
    """Run bedtools intersect."""
    args = ["bedtools", "intersect", "-a", a, "-b", b]
    if v:
        args.append("-v")
    if output:
        with open(output, "w") as f:
            subprocess.run(args, stdout=f, check=True)
        return None
    result = _run_cmd(args, capture=True)
    return result.stdout


# -- minimap2 -----------------------------------------------------------------


def minimap2_align(
    reference: str,
    query: str,
    output: str | None = None,
    *,
    preset: str = "map-ont",
    threads: int = 1,
) -> str | None:
    """Align with minimap2."""
    args = ["minimap2", "-x", preset, "-t", str(threads), "-a", reference, query]
    if output:
        with open(output, "w") as f:
            subprocess.run(args, stdout=f, check=True)
        return None
    result = _run_cmd(args, capture=True)
    return result.stdout
