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

# Need to add validate the config

SCRIPT_LOCATION=$(realpath "$0" | sed 's|\(.*\)/.*|\1|')
CONFIG_FILE=$SCRIPT_LOCATION/mirror.conf

auto_config(){
    echo
}

create_folder() {
    mkdir -p "$1"
    LOCATION=$(realpath "$1")
    return 0
}

download_repo() {
    printf "Downloading full repo...\n"
    printf '\n'
    printf "Repo %s" "${repo_id}"
    printf '\n'
    printf 'Repo size: %s\n' "$(dnf repolist -v --repo=baseos | awk -F': ' '/Repo-size/ {print $2}')"
    printf '\n'
    dnf repolist -v --repo="${repo_id}" | grep Repo-available-pkgs
    dnf reposync -v --repo="${repo_id}" --download-metadata --download-path="${LOCATION}"
    # Il reacticvate this once i am done this is just a test
    if [[ "$?" -eq 0 ]]; then
        printf "All files downloaded. Repo sync finished succsefully!\n"
        printf '\n'
        return 0
    else
        return 1
    fi
}

save_config() {
    {
        printf 'repo_id=%s\n' "$repo_id"
        printf 'LOCATION=%s\n' "$LOCATION"
    } > "${SCRIPT_LOCATION}/mirror.conf"
}

load_config() {
    while IFS="=" read -r key value; do
        case "$key" in
            repo_id)
                repo_id="$value"
                ;;
            LOCATION)
                LOCATION="$value"
                ;;
        esac
    done < "$CONFIG_FILE"

}

configure_manually() {
    printf "Current configured repos:\n"
    printf '\n'

    dnf repolist -v | grep Repo-id

    printf "\n"
    printf "Select what you want to mirror:\n"
    printf "[1]Mirror existing repo\n"
    printf "[2]Add custom repo\n"

    while true; do
        read -p "Enter:" mirror_decission
        if [[ "${mirror_decission}" -lt 1 || "${mirror_decission}" -gt 2  ]]; then
            printf "%s invalid input. Try again\n" "$mirror_decission"
            printf '\n'
            continue
        fi
        break
    done

    if [[ "$mirror_decission" -eq 1 ]]; then
        read -p "Enter the repo ID you want to mirror: " repo_id
        printf '\n'
        validatingRepoID=$(dnf repolist -v | awk -F': ' '/Repo-id/ {print $2}' | grep -x "${repo_id}")
        save_config "repo_id" "${repo_id}"
        while [[ -z "$validatingRepoID" ]]; do
            printf "Provided RepoID %s is not available.\n" "${repo_id}"
            read -p "Enter the repo ID you want to mirror: " repo_id
            printf "Looking up for %s\n" "$repo_id"
            printf '\n'
            validatingRepoID=$(dnf repolist -v | awk -F': ' '/Repo-id/ {print $2}' | grep -x "${repo_id}")
        done
        printf "%s founded as in the available repos.\n" "${repo_id}"
        printf '\n'
    elif [[ "${mirror_decission}" -eq 2 ]]; then
        printf "Feature not yet implemented\n"
        printf '\n'
    fi


    while true; do
        read -p "Enter the location you want to save downloaded files. Default [/srv/mirror]:" LOCATION
        printf '\n'

        if [[ "${LOCATION}" = "" ]]; then
            LOCATION="/srv/mirror"
            break
        elif [[ ! -d "$LOCATION" ]]; then
            printf "Location %s does not exists, creating it now...\n" "$LOCATION"
            printf '\n'
            create_folder "$LOCATION"
            LOCATION=$(realpath "$LOCATION")
            break
        else
            printf "Folder already exists. Listing content.\n"
            printf '\n'
            ls "${LOCATION}"
            printf "Enter again.\n"
            printf '\n'
            continue
        fi
    done
}

run_repo() {
    REPOSIZE=$(dnf repolist -v --repo="${repo_id}" | grep Repo-size | awk '{print $3,$4}')
    printf '\n'
    read -r -p "Do you want to download the full repository? Size: ${REPOSIZE}. [y/n]: " answer
    printf '\n'

    if [[ "$answer" == "y" ]]; then    
        while ! download_repo; do
            read -r -p "Download failed. Repeat [y/n]: " answer
                if [[ "$answer" != "y" ]]; then
                    printf "Stopping download... If you want to retry rerun the script!\n"
                    printf '\n'
                    break
                printf "Retrying gownload...\n"
                printf '\n'
                fi
            done
        printf "Download succsefull. Repo path %s" ""
        printf '\n'
    else
        printf "Stopped repo initialization. Saving files to config.\n"
        printf '\n'
        exit 1
    fi

    printf "Listing the local current repo directory... %s" "${LOCATION}"
    printf '\n'

    ls "${LOCATION}"

    #if [[ -n "$(find ${LOCATION} -iname repomd.xml -print -quit)" ]]; then
    #    printf "Repo %s is valid\n" "${repo_id}"
    #fi

    if [[ -f "${LOCATION}/${repo_id}/repodata/repomd.xml" ]]; then
        printf "Repo %s is valid.\n" "${repo_id}"
        printf '\n'
    else
        printf "Missing: %s\n" "${LOCATION}/${repo_id}/repodata/repomd.xml"
        printf '\n'
    fi
}


main() {
    local answer
    printf "This script configures the local repo on your linux machine. This repo is hosted and can be used for your other machines\n"
    if [[ -s "${CONFIG_FILE}" ]]; then
        read -r -p "Use saved configuration? [y/n]: " answer
        printf '\n'
        if [[ "${answer}" == "y" ]]; then
            load_config
        else
            configure_manually
            save_config
        fi
    else
        configure_manually 
        save_config
    fi

    run_repo
}

main