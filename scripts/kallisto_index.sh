# Generate a genome index for kallisto

command -v kallisto >/dev/null 2>&1 || { echo >&2 "kallisto missing"; exit 1; }

$fasta="$1"

if [[ -d kallisto ]]; then
    rm -rf kallisto
fi

mkdir -p kallisto
kallisto index --index=kallisto/transcripts.idx "$fasta"

unset -v fasta
