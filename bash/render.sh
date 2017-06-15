file_name="$1"
bsub -W 12:00 -q priority -J "$file_name" -n 1 -R rusage[mem=65536] Rscript -e 'rmarkdown::render("$file_name.Rmd")'
