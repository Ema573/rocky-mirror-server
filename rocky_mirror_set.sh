#!/usr/bin/env bash

# This is version 0.1
# This script converts your rocky linux system to the mirror
# It can be used to serve the updates to your offline environment
# The mirror internet connection is enabled only during the download of the updates on the random times in the day you set
# It provides lot of features, try it out

#Implementations
# 1. Select your upstream server or use default
#set -euo pipefail
# Questionable logic, if the grepo does not find anything it will return 1. -e will break/exit script

download_repo() {
    printf "Downloading full repo."
    printf "Repo %s" "${repo_id}"
    printf "Repo size" dnf repolist -v --repo=baseos | awk -F': ' '/Repo-size/ {print $2}'
    dnf repolist -v --repo="${repo_id}" | grep Repo-available-pkgs
    #dnf reposync -v --repo="${repo_id}" --download-metadata --download-path="${LOCATION}
    # Il reacticvate this once i am done this is just a test
    if [[ "$?" -eq 0 ]]; then
        printf "All files downloaded. Repo sync finished succsefully!\n"
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

while true; do
    read -p "Enter:" mirror_decission
    if [[ "${mirror_decission}" -lt 1 || "${mirror_decission}" -gt 2  ]]; then
        printf "%s invalid input. Try again\n" "$mirror_decission"
        continue
    fi
    break
done

if [[ "$mirror_decission" -eq 1 ]]; then
    read -p "Enter the repo ID you want to mirror: " repo_id
    validatingRepoID=$(dnf repolist -v | awk -F': ' '/Repo-id/ {print $2}' | grep -x "${repo_id}")
    while [[ -z "$validatingRepoID" ]]; do
        printf "Provided RepoID %s is not available.\n" "${repo_id}"
        read -p "Enter the repo ID you want to mirror: " repo_id
        printf "Looking up for %s\n" "$repo_id"
        validatingRepoID=$(dnf repolist -v | awk -F': ' '/Repo-id/ {print $2}' | grep -x "${repo_id}")
    done
    printf "%s founded as in the available repos.\n" "${repo_id}"
elif [[ "${mirror_decission}" -eq 2 ]]; then
    printf "Feature not yet implemented\n"
fi


read -p "Enter the location you want to save downloaded files:" LOCATION

if [[ ! -d "$LOCATION" ]]; then
    printf "Location %s does not exists, creating it now...\n" "$LOCATION"
    mkdir -p "$LOCATION"
else
    printf "Function to be added in case directory not empty, contains some files, some additinoal checks\n"
fi

REPOSIZE=$(dnf repolist -v --repo="${repo_id}" | grep Repo-size | awk '{print $3,$4}')
read -r -p "Do you want to download the full repository? Size: ${REPOSIZE}. [y/n]: " answer

if [[ "$answer" == "y" ]]; then    
    while ! download_repo; do
        read -r -p "Download failed. Repeat [y/n]: " answer
            if [[ "$answer" != "y" ]]; then
                printf "Stopping download... If you want to retry rerun the script!\n"
                break
            printf "Retrying gownload...\n"
            fi
        done
else
    printf "Need to verify if packages locally present.\n"
fi
# checking if reposync succeded