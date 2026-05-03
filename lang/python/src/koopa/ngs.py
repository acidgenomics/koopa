"""Next-generation sequencing (NGS) bioinformatics pipeline functions.

Converted from Bash functions: salmon-index, salmon-quant, star-index,
star-align, samtools-index, samtools-sort, bowtie2-build, bowtie2-align,
hisat2-build, kallisto-index, kallisto-quant, bam-filter, bam-to-fastq,
fastqc, multiqc, etc.
"""

from __future__ import annotations

import os
import shutil
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


def salmon_detect_fastq_library_type(
    index_dir: str,
    r1: str,
    r2: str | None = None,
    *,
    threads: int = 1,
    num_reads: int = 200000,
) -> str:
    """Detect FASTQ library type using Salmon."""
    import tempfile

    with tempfile.TemporaryDirectory() as tmpdir:
        args = [
            "salmon",
            "quant",
            "-i",
            index_dir,
            "-o",
            tmpdir,
            "--threads",
            str(threads),
            "-l",
            "A",
            "--skipQuant",
        ]
        if r2:
            args.extend(["-1", r1, "-2", r2])
        else:
            args.extend(["-r", r1])
        result = _run_cmd(args, capture=True)
        for line in result.stderr.splitlines():
            if "library type" in line.lower():
                return line.strip()
        lib_info = os.path.join(tmpdir, "lib_format_counts.json")
        if os.path.isfile(lib_info):
            import json

            with open(lib_info) as f:
                data = json.load(f)
            return data.get("expected_format", "unknown")
    return "unknown"


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
    output_fmt: str = "sam",
    reference_fasta: str | None = None,
) -> None:
    """Align reads with Bowtie2."""
    if output_fmt == "cram" and not reference_fasta:
        msg = "reference_fasta is required when output_fmt is 'cram'."
        raise ValueError(msg)
    bowtie2_args = [
        "bowtie2",
        "-x",
        index_prefix,
        "-p",
        str(threads),
    ]
    if sensitive:
        bowtie2_args.append("--very-sensitive")
    if r2:
        bowtie2_args.extend(["-1", r1, "-2", r2])
    else:
        bowtie2_args.extend(["-U", r1])
    if output_fmt == "sam":
        bowtie2_args.extend(["-S", output_sam])
        _run_cmd(bowtie2_args)
        return
    # Pipe bowtie2 SAM stdout → samtools sort → sorted BAM/CRAM
    samtools_args = [
        "samtools",
        "sort",
        "-@",
        str(threads),
        "-O",
        output_fmt.upper(),
        "-o",
        output_sam,
    ]
    if output_fmt == "cram":
        samtools_args.extend(["--reference", reference_fasta])
    samtools_args.append("-")
    bowtie2_proc = subprocess.Popen(bowtie2_args, stdout=subprocess.PIPE)
    samtools_proc = subprocess.Popen(samtools_args, stdin=bowtie2_proc.stdout)
    bowtie2_proc.stdout.close()
    samtools_proc.wait()
    bowtie2_proc.wait()
    if bowtie2_proc.returncode != 0:
        raise subprocess.CalledProcessError(bowtie2_proc.returncode, "bowtie2")
    if samtools_proc.returncode != 0:
        raise subprocess.CalledProcessError(samtools_proc.returncode, "samtools sort")
    samtools_index(output_sam, threads=threads)


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


# -- MISO ---------------------------------------------------------------------


def miso_index(
    gff_file: str,
    output_dir: str,
    *,
    min_exon_size: int = 1000,
) -> None:
    """Generate a MISO index directory."""
    import gzip as gz
    import tempfile

    exon_utils = shutil.which("exon_utils")
    index_gff = shutil.which("index_gff")
    if exon_utils is None or index_gff is None:
        msg = "MISO (exon_utils, index_gff) is required."
        raise RuntimeError(msg)
    if not os.path.isfile(gff_file):
        msg = f"GFF file not found: '{gff_file}'."
        raise FileNotFoundError(msg)
    gff_file = os.path.realpath(gff_file)
    os.makedirs(output_dir, exist_ok=True)
    log_file = os.path.join(output_dir, "index.log")
    decomp_file = None
    if gff_file.endswith(".gz"):
        fd, decomp_file = tempfile.mkstemp(suffix=".gff")
        os.close(fd)
        with gz.open(gff_file, "rb") as f_in, open(decomp_file, "wb") as f_out:
            shutil.copyfileobj(f_in, f_out)
        gff_file = decomp_file
    print(f"Generating MISO index at '{output_dir}'.")
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    with tempfile.TemporaryDirectory() as tmp_exons_dir:
        with open(log_file, "a") as log:
            subprocess.run(
                [
                    exon_utils,
                    "--get-const-exons",
                    gff_file,
                    "--min-exon-size",
                    str(min_exon_size),
                    "--output-dir",
                    tmp_exons_dir,
                ],
                env=env,
                stdout=log,
                stderr=subprocess.STDOUT,
                check=True,
            )
        exon_files = list(
            Path(tmp_exons_dir).glob(
                f"*.min_{min_exon_size}.const_exons.gff",
            ),
        )
        if exon_files:
            dest = os.path.join(
                output_dir,
                f"min_{min_exon_size}.const_exons.gff",
            )
            shutil.move(str(exon_files[0]), dest)
    with open(log_file, "a") as log:
        subprocess.run(
            [index_gff, "--index", gff_file, output_dir],
            env=env,
            stdout=log,
            stderr=subprocess.STDOUT,
            check=True,
        )
    if decomp_file and os.path.isfile(decomp_file):
        os.remove(decomp_file)
    print(f"MISO index created at '{output_dir}'.")


def rnaeditingindexer(
    *,
    bam_dir: str = "bam",
    output_dir: str = "rnaedit",
    genome: str = "hg38",
    bam_suffix: str = ".Aligned.sortedByCoord.out.bam",
    example: bool = False,
) -> None:
    """Run dockerized RNAEditingIndexer pipeline."""
    docker = shutil.which("docker")
    if docker is None:
        msg = "docker is not installed."
        raise RuntimeError(msg)
    image = "public.ecr.aws/acidgenomics/rnaeditingindexer"
    mnt_bam_dir = "/mnt/bam"
    mnt_output_dir = "/mnt/output"
    run_args: list[str] = []
    if example:
        bam_suffix = "_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam"
        mnt_bam_dir = "/bin/AEI/RNAEditingIndexer/TestResources/BAMs"
    else:
        if not os.path.isdir(bam_dir):
            msg = f"BAM directory not found: '{bam_dir}'."
            raise FileNotFoundError(msg)
        bam_dir = os.path.realpath(bam_dir)
        os.makedirs(output_dir, exist_ok=True)
        run_args.extend(
            [
                "-v",
                f"{bam_dir}:{mnt_bam_dir}:ro",
                "-v",
                f"{output_dir}:{mnt_output_dir}:rw",
            ]
        )
    run_args.append(image)
    subprocess.run(
        [
            docker,
            "run",
            *run_args,
            "RNAEditingIndex",
            "--genome",
            genome,
            "--keep_cmpileup",
            "--verbose",
            "-d",
            mnt_bam_dir,
            "-f",
            bam_suffix,
            "-l",
            f"{mnt_output_dir}/logs",
            "-o",
            f"{mnt_output_dir}/cmpileups",
            "-os",
            f"{mnt_output_dir}/summary",
        ],
        check=True,
    )
