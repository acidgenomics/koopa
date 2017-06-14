file_name="$1"
bsub -q priority -W 12:00 Rscript -e 'rmarkdown::render("$file_name.Rmd")'
