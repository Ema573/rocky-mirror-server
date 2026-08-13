#!/usr/bin/env bash

# This is version 0.1
# This script converts your rocky linux system to the mirror
# It can be used to serve the updates to your offline environment
# The mirror internet connection is enabled only during the download of the updates on the random times in the day you set
# It provides lot of features, try it out

#Implementations
# 1. Select your upstream server or use default
set -euo pipefail

download_repo() {
    printf "Downloading full repo."
    dnf repolist -v --repo="${repo_id}" | grep Repo-available-pkgs
    #dnf reposync -v --repo="${repo_id}" --download-metadata --download-path="${LOCATION}
    if [[ "$?" -eq 0 ]]; then
        printf "All files downloaded. Repo sync finished succsefully!"
        return 0
    else
        return 1
    fi
}

printf "Current configured repos:\n"

dnf repolist -v | grep Repo-id

printf "\n"
printf "Select what you want to mirror:\n"
printf "[1]Mirror existing repo\n"
printf "[2]Add custom repo\n"
read -p "Enter:" mirror_decission

if [[ "$mirror_decission" -eq 1 ]]; then
    read -p "Enter the repo ID you want to mirror: " repo_id
    validatingRepoID=$(dnf repolist -v | grep Repo-id | grep $repo_id)
    while [[ -z "$validatingRepoID" ]]; do
        printf "Provided RepoID is not available.\n"
        read -p "Enter the repo ID you want to mirror: " repo_id
        validatingRepoID=$(dnf repolist -v | grep Repo-id | grep "{$repo_id}")
    done
else
    echo "Feature not yet implemented"
fi

read -p "Enter the location you want to save downloaded files:" LOCATION

if [[ ! -d "$LOCATION" ]]; then
    printf "Location %s does not exists, creating it now..." "$LOCATION"
    mkdir -p $LOCATION
else
    printf "Function to be added in case directory not empty, contains some files, some additinoal checks"
fi

REPOSIZE=$(dnf repolist -v --repo="${repo_id}" | grep Repo-size | awk '{print $3,$4}')
read -r -p "Do you want to download the full repository? Size: ${REPOSIZE}. [y/n]: " answer

if [[ "$answer" == "y" ]]; then    
    download_success=download_repo
    while [[ "$download_success" -ne 0 ]]; do
        read -r -p "Download failed. Repeat [y/n]: " answer
            if [[ "$answer" == "y "]]; then
                download_repo
            else
                break
            fi
else
    printf "Need to verify if packages locally present."
fi
# checking if reposync succeded
