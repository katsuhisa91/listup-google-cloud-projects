#!/bin/bash

# Declare the associative array to hold folder names
declare -A folder_names
declare -A parent_folders

# Function to build the full path of the folder/project
build_full_path() {
  local folder_id=$1
  local path=""

  while [[ -n "$folder_id" ]]; do
    local folder_name=${folder_names[$folder_id]}
    if [[ -n "$path" ]]; then
      path="$folder_name > $path"
    else
      path="$folder_name"
    fi
    folder_id=${parent_folders[$folder_id]}
  done

  echo "$path"
}

# Function to print the project and its parent folders in a tree format
print_tree() {
  local prefix=$1
  local project_name=$2
  echo "${prefix}└── $project_name"
}

# Function to list projects recursively
list_projects() {
  local parent_folder=$1
  local depth=$2

  # List projects under the given folder
  projects=$(gcloud projects list --filter="parent.id=$parent_folder" --format="value(projectId)")

  for project in $projects; do
    local prefix=$(printf '%*s' $((depth * 4)) '')
    print_tree "$prefix" "$project"
  done

  # List subfolders under the given folder
  subfolders=$(gcloud resource-manager folders list --folder="$parent_folder" --format="value(name, displayName)")

  while IFS=$'\t' read -r folder_id folder_name; do
    if [[ -n "$folder_id" && -n "$folder_name" ]]; then
      folder_names["$folder_id"]="$folder_name"
      parent_folders["$folder_id"]="$parent_folder"
      local prefix=$(printf '%*s' $((depth * 4)) '')
      echo "${prefix}├── $folder_name"
      # Recursively list projects in subfolders
      list_projects "$folder_id" $((depth + 1))
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
      parent_folders["$folder_id"]=""
      echo "$folder_name"
      # Recursively list projects in each folder
      list_projects "$folder_id" 1
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