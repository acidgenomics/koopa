# Add the CRAN GPG key, which is used to sign the R packages for security:
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Append the CRAN repository to `sources.list`:
sudo sh -c 'echo "deb https://cran.rstudio.com/bin/linux/ubuntu/ trusty/" >> /etc/apt/sources.list'

# Get latest version of R:
sudo apt-get update
sudo apt-get install r-base
