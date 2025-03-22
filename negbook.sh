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
