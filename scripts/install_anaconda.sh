# https://www.anaconda.com/download

if [[ $(uname -s) = "Linux" ]]; then
    wget https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh
elif [[ $(uname -s) = "Darwin" ]]; then
    wget https://repo.anaconda.com/archive/Anaconda3-5.2.0-MacOSX-x86_64.sh
else
    echo "$(uname -s) operating system not supported"
    return 1
fi

bash Anaconda3-*-x86_64.sh

echo "conda install succeeded. Shell must be reloaded."
return 1
