#!/usr/bin/env bash
###########################
# Written by: Ron Negrov
# Date: 3.21.2025
# Purpose: A libray file that has usefull functions. 
# Version: 0.0.12
###########################
. /etc/os-release


function install_missing_packages() {
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

function distro_check_and_install() {
    source /etc/os-release

    case "$ID" in
        debian|ubuntu)
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
