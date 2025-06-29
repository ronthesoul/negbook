#!/usr/bin/env bash
###########################
# Written by: Ron Negrov
# Date: 3.21.2025
# Purpose: A library file that has useful functions.
# Version: 0.0.14
###########################

install_missing_packages() {
    local package_manager=$1
    shift
    local package_list=("$@")

    for package in "${package_list[@]}"; do
        if ! command -v "$package" &>/dev/null && ! dpkg -l 2>/dev/null | grep -q "$package"; then
            echo "Installing missing package: $package"
            eval "$package_manager install -y $package"
        fi
    done
    echo "Finished installing packages"
}

distro_check_and_install() {
    source /etc/os-release

    case "$ID" in
        debian|ubuntu|kali)
            install_missing_packages "sudo apt" "$@"
            ;;
        centos|rhel|fedora)
            install_missing_packages "sudo yum" "$@"
            ;;
        arch)
            install_missing_packages "sudo pacman -S --noconfirm" "$@"
            ;;
        *)
            echo "Unsupported OS: $ID"
            exit 1
            ;;
    esac
}


ask_user_packages() {
    local varname=$1
    local pkg
    local temp_list=()

    echo "Enter package names one by one. Type 'exit' to finish:"
    while true; do
        read -p "Package: " pkg
        if [[ "$pkg" == "exit" ]]; then
            break
        elif [[ -n "$pkg" ]]; then
            temp_list+=("$pkg")
        fi
    done

    eval "$varname=(\"\${temp_list[@]}\")"
}


venv_init() {
    local full_path="$1"

    echo "Setting up virtual environment with pipenv..."

    if ! command -v pipenv &>/dev/null; then
        echo "Installing pipenv via pipx..."
        pipx install pipenv > /dev/null 2>&1 || { echo "Failed to install pipenv"; return 1; }
        export PATH="$HOME/.local/bin:$PATH"
        
    fi

    export PIPENV_VENV_IN_PROJECT=1

    cd "$full_path" || { echo "Cannot access project directory"; return 1; }

    if [[ ! -f Pipfile ]]; then
        pipenv --python 3 || { echo "Failed to create virtual environment"; return 1; }
    fi
    pipenv lock || { echo "Failed to generate Pipfile.lock"; return 1; }

    echo "Virtual environment created at: $(pipenv --venv)"
    pipx ensurepath
}

git_connect (){
local username=$1
local repository=$2
local full_path=$3

local remote_url="git@github.com:${username}/${repository}.git"
cd "$full_path" || { echo "Cannot access project directory"; return 1; }
 if ! git remote get-url origin &>/dev/null; then
    git remote add origin "$remote_url"
    echo "Connected to remote: $remote_url"
    git remote -v
else
     echo "Remote 'origin' already exists."
 fi

}


function validate_ip (){
local ip=$1
local regex='^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$'

if [[ $ip =~ $regex ]]; then
        oct1=${BASH_REMATCH[1]}
        oct2=${BASH_REMATCH[2]}
        oct3=${BASH_REMATCH[3]}
        oct4=${BASH_REMATCH[4]}
        if (( oct1 >= 0 && oct1 <= 255 )) && \
            (( oct2 >= 0 && oct2 <= 255 )) && \
             (( oct3 >= 0 && oct3 <= 255 )) && \
             (( oct4 >= 0 && oct4 <= 255 ))
                 then
                    return 0
                else
                    echo "Invalid IP Address"
                    return 1
        fi
    else
        echo "Invalid IP Address"
        return 1
fi
}



function download_template() {
  path="$1"
  project_name="$2"

  cd "$path" || exit

  wget https://github.com/startbootstrap/startbootstrap-coming-soon/archive/gh-pages.zip
  unzip gh-pages.zip

  mkdir -p "src/$project_name/static"
  mkdir -p "src/$project_name/templates"

  mv "startbootstrap-coming-soon-gh-pages/css" "src/$project_name/static/"
  mv "startbootstrap-coming-soon-gh-pages/js" "src/$project_name/static/"
  mv "startbootstrap-coming-soon-gh-pages/assets" "src/$project_name/static/"
  mv "startbootstrap-coming-soon-gh-pages/index.html" "src/$project_name/templates/"

  rm -rf gh-pages.zip startbootstrap-coming-soon-gh-pages

  cat << EOF >> "src/$project_name/app.py"
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True)
EOF
}
 

function pipenv_download () {
  local pip_list=("$@")

  for package in "${pip_list[@]}"; do
    echo "Installing pip package: $package"
    pipenv install "$package" || echo "Failed to install $package"
  done
}

# Used to install packages in a specifc file
install_deb_files_from_dir() {
    local dir="$1"
    for deb in "$dir"/*.deb; do
        echo "Installing $deb"
        sudo apt install -y "$deb"
    done
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}
