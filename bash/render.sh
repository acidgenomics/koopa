# Note the use of double quotes in the Rscript command. Single quote usage,
# which is common in online examples, will not escape the bash variables
# properly.
file_name="$1"
bsub -W 12:00 -q priority -J "$file_name" -n 1 -R rusage[mem=65536] Rscript -e "rmarkdown::render('$file_name')"
