#!/bin/bash

# Declare the associative array to hold folder names
declare -A folder_names

# Function to list projects recursively
list_projects() {
  local parent_folder=$1
  local parent_folder_name=$2

  # List projects under the given folder
  projects=$(gcloud projects list --filter="parent.id=$parent_folder" --format="value(projectId)")

  for project in $projects; do
    # Print the project with parent folder name
    echo "$parent_folder_name > $project"
  done

  # List subfolders under the given folder
  subfolders=$(gcloud resource-manager folders list --folder="$parent_folder" --format="value(name, displayName)")

  while IFS=$'\t' read -r folder_id folder_name; do
    if [[ -n "$folder_id" && -n "$folder_name" ]]; then
      folder_names["$folder_id"]="$folder_name"
      # Recursively list projects in subfolders
      list_projects "$folder_id" "$folder_name"
    fi
  done <<< "$subfolders"
}

# Function to list all folders under the organization
list_folders() {
  local organization_id=$1

  # List folders under the organization
  folders=$(gcloud resource-manager folders list --organization="$organization_id" --format="value(name, displayName)")

  while IFS=$'\t' read -r folder_id folder_name; do
    if [[ -n "$folder_id" && -n "$folder_name" ]]; then
      folder_names["$folder_id"]="$folder_name"
      # Recursively list projects in each folder
      list_projects "$folder_id" "$folder_name"
    fi
  done <<< "$folders"

  # List projects without a parent folder under the organization
  projects_without_parent=$(gcloud projects list --filter="parent.type=organization AND parent.id=$organization_id" --format="value(projectId)")

  for project in $projects_without_parent; do
    # Print the project without a parent folder
    echo "$project"
  done
}

# The organization ID
ORGANIZATION_ID=$(gcloud organizations list --format="value(ID)")

# Start listing folders and projects from the organization
list_folders "$ORGANIZATION_ID"