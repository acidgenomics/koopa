#!/usr/bin/env python3
"""
Download FlyBase genome.
"""

from argparse import ArgumentParser
from os.path import join, realpath

from koopa.arg import dir_path
from koopa.genome import tx2gene_from_fasta
from koopa.genome.flybase import (
    download_flybase_genome,
    download_flybase_gff,
    download_flybase_gtf,
    download_flybase_transcriptome,
    flybase_dmel_version,
    flybase_version,
)
from koopa.print import stop
from koopa.strings import paste_url
from koopa.syntactic import kebab_case
from koopa.system import koopa_help

koopa_help()


parser = ArgumentParser()
parser.add_argument("--release", type=str)
parser.add_argument("--dmel", type=str)
parser.add_argument(
    "--type",
    default="all",
    const="all",
    nargs="?",
    choices=["all", "genome", "transcriptome", "none"],
)
parser.add_argument(
    "--annotation",
    default="all",
    const="all",
    nargs="?",
    choices=["all", "gtf", "gff", "none"],
)
parser.add_argument("--output-dir", type=dir_path, default=".")
parser.add_argument("--decompress", action="store_true")
args = parser.parse_args()


def main(annotation, decompress, dmel, genome_type, output_dir, release):
    """
    Download FlyBase genome.
    """
    if genome_type == "none" and annotation == "none":
        stop("'type' or 'annotation' are required.")
    organism = "Drosophila melanogaster"
    build = "BDGP6"
    if release is None:
        release = flybase_version()
    if dmel is None:
        dmel = flybase_dmel_version()
    base_url = "ftp://ftp.flybase.net"
    release_url = paste_url(base_url, "releases", release, "dmel_" + dmel)
    output_basename = kebab_case(
        organism + " " + build + " " + "flybase" + " " + release
    )
    output_dir = join(realpath(output_dir), output_basename)
    if genome_type == "genome":
        download_flybase_genome(
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
            dmel=dmel,
        )
    elif genome_type == "transcriptome":
        download_flybase_transcriptome(
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
            dmel=dmel,
        )
    elif genome_type == "all":
        download_flybase_genome(
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
            dmel=dmel,
        )
        download_flybase_transcriptome(
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
            dmel=dmel,
        )
    if annotation == "gtf":
        download_flybase_gtf(
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
            dmel=dmel,
        )
    elif annotation == "gff":
        download_flybase_gff(
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
            dmel=dmel,
        )
    elif annotation == "all":
        download_flybase_gtf(
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
            dmel=dmel,
        )
        download_flybase_gff(
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
            dmel=dmel,
        )
    if genome_type != "genome":
        tx2gene_from_fasta(source_name="flybase", output_dir=output_dir)
    print("Genome downloaded successfully to '" + output_dir + "'.")


main(
    annotation=args.annotation,
    decompress=args.decompress,
    dmel=args.dmel,
    genome_type=args.type,
    output_dir=args.output_dir,
    release=args.release,
)
