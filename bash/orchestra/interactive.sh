# Launch an interactive session
if [[ "$#" -gt "0" ]]; then
    # Interactive session with user-defined cores and RAM.
    # Hard-coded timeout after 24 hours.
    cores="$1"
    ram_gb="$2"
    # 1 GB = 1024 Mb
    ram_mb="$(($ram_gb * 1024))"
    echo "Starting interactive session with $cores and $ram_gb GB RAM..."
    bsub -Is -W 24:00 -q interactive -n "$cores" -R rusage[mem="$ram_mb"] bash
else
    # Default interactive session
    bsub -Is -q interactive bash
fi
