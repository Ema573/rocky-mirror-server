#!/usr/bin/env bash

# This is version 0.1
# This script converts your rocky linux system to the mirror
# It can be used to serve the updates to your offline environment
# The mirror internet connection is enabled only during the download of the updates on the random times in the day you set
# It provides lot of features, try it out

#Implementations
# 1. Select your upstream server or use default

printf "Current configured repos:\n"

dnf repolist -v | grep Repo-id

printf "\n"
printf "Select what you want to mirror:\n"
printf "[1]Mirror existing repo\n"
printf "[2]Add custom repo\n"
read -p "Enter:" mirrorDecission

if [[ "$mirrorDecission " -eq 1 ]]; then
    read -p "Enter the repo ID you want to mirror: " repoID
    validatingRepoID=$(dnf repolist -v | grep Repo-id | grep $repoID)
    while [[ -z "$validatingRepoID" ]]; do
        printf "Provided RepoID is not available.\n"
        read -p "Enter the repo ID you want to mirror: " repoID
        validatingRepoID=$(dnf repolist -v | grep Repo-id | grep "$repoID")
    done
else
    echo "Feature not yet implemented"
fi

read -p "Enter the location you want to save downloaded files:" LOCATION

if [[ ! -d $LOCATION ]]; then
    printf "Location $LOCATION does not exists, creating it now..."
    mkdir -p $LOCATION
else
    printf "Function to be added in case directory not empty, contains some files, some additinoal checks"
fi