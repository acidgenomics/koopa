#!/usr/bin/env python3
"""
Download RefSeq genome.
"""

from argparse import ArgumentParser
from os.path import join, realpath

from koopa.arg import dir_path
from koopa.files import download
from koopa.genome.refseq import (
    download_refseq_genome,
    download_refseq_gff,
    download_refseq_gtf,
    download_refseq_transcriptome,
    refseq_version,
)
from koopa.strings import paste_url
from koopa.syntactic import kebab_case
from koopa.system import koopa_help

koopa_help()


parser = ArgumentParser()
parser.add_argument(
    "--build",
    default="GRCh38",
    const="GRCh38",
    nargs="?",
    choices=["GRCh38", "GRCh37"],
)
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


def main(annotation, build, decompress, genome_type, output_dir):
    """
    Download RefSeq genome.
    """
    organism = "Homo sapiens"
    organism_short = "H_sapiens"
    release = refseq_version()
    release_url = paste_url(
        "ftp://ftp.ncbi.nlm.nih.gov",
        "refseq",
        organism_short,
        "annotation",
        build + "_latest",
        "refseq_identifiers",
    )
    output_basename = kebab_case(
        organism + " " + build + " " + "refseq" + " " + release
    )
    output_dir = join(realpath(output_dir), output_basename)
    download(url=paste_url(release_url, "README.txt"), output_dir=output_dir)
    download(
        url=paste_url(release_url, build + "_latest_assembly_report.txt"),
        output_dir=output_dir,
    )
    if genome_type == "genome":
        download_refseq_genome(
            build=build,
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
        )
    elif genome_type == "transcriptome":
        download_refseq_transcriptome(
            build=build,
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
        )
    elif genome_type == "all":
        download_refseq_genome(
            build=build,
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
        )
        download_refseq_transcriptome(
            build=build,
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
        )
    if annotation == "gtf":
        download_refseq_gtf(
            build=build,
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
        )
    elif annotation == "gff":
        download_refseq_gff(
            build=build,
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
        )
    elif annotation == "all":
        download_refseq_gtf(
            build=build,
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
        )
        download_refseq_gff(
            build=build,
            release_url=release_url,
            output_dir=output_dir,
            decompress=decompress,
        )
    print("Genome downloaded successfully to '" + output_dir + "'.")


main(
    annotation=args.annotation,
    build=args.build,
    decompress=args.decompress,
    genome_type=args.type,
    output_dir=args.output_dir,
)
