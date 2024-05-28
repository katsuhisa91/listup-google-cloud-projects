#!/bin/bash

# Function to list projects recursively
list_projects() {
  local parent_folder=$1

  # List projects under the given folder
  projects=$(gcloud projects list --filter="parent.id=$parent_folder" --format="value(projectId)")

  for project in $projects; do
    # Print the project
    echo "$project"
  done

  # List subfolders under the given folder
  subfolders=$(gcloud resource-manager folders list --folder="$parent_folder" --format="value(name)")

  for folder in $subfolders; do
    # Recursively list projects in subfolders
    list_projects "$folder"
  done
}

# Function to list all folders under the organization
list_folders() {
  local organization_id=$1

  # List folders under the organization
  folders=$(gcloud resource-manager folders list --organization="$organization_id" --format="value(name)")

  for folder in $folders; do
    # Recursively list projects in each folder
    list_projects "$folder"
  done
}

# The organization ID
ORGANIZATION_ID=$(gcloud organizations list --format="value(ID)")

# Start listing folders and projects from the organization
list_folders "$ORGANIZATION_ID"