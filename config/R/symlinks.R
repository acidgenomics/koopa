# Symlink R config files

from_dir <- file.path(Sys.getenv("KOOPA_DIR"), "config", "R", "etc")
to_dir <- file.path(Sys.getenv("R_HOME"), "etc")

from_file <- file.path(from_dir, "Renviron.site")
to_file <- file.path(to_dir, "Renviron.site")

file.remove(to_file)
file.symlink(from = from_file, to = to_file)

