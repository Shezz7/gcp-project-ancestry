#!/bin/bash

# Check if gcloud is installed
if ! command -v gcloud &>/dev/null; then
    echo "gcloud is not installed. Please install it before running this script."
    exit 1
fi

# Fetch projects
projects=$(gcloud projects list --format=json | jq -r '.[].projectId')
for project in $projects
do
    printf "%s," "$project"

    ancestry=$(gcloud projects get-ancestors "$project" --format=json)
    folders=$(echo "$ancestry" | jq -r '.[] | select(.type=="folder") | .id')

    # Retrieve folders iteratively
    for folder in $folders
    do
        folderName=$(gcloud resource-manager folders describe "$folder" --format=json | jq -r '.displayName')
        printf "%s," "$folderName"
    done

    # Get GCP org
    organization=$(echo "$ancestry" | jq -r '.[] | select(.type=="organization") | .id')
    if [ -n "$organization" ]
    then
        orgName=$(gcloud organizations describe "$organization" --format=json | jq -r '.displayName')
        printf "%s\n" "$orgName"
    fi
done
