#!/bin/bash

#======================================================================
# Desc: Adds convenient extensions/aliases to Git via shell scripts.
# Maintainer: Dan LeGrand
# * Functions prefixed with '__' are script-related functions and
#   should not be called by external scripts.
#======================================================================

# Certain types of branches can only branch from/to select branches
# feature: from develop to develop (deploy to development/test)
# bug:     from develop to develop (deploy to development)
# release: from develop to develop/master (deploy to production)
# hotfix:  from master  to develop/master (deploy to development/production)

# Config
#----------------------------------------------------------------------

__development_branch_name() {
  echo "development"
}

__master_branch_name() {
  echo "master"
}

# Helper methods
#----------------------------------------------------------------------

# See: http://stackoverflow.com/a/27552913/667772
__current_dir_has_git() {
  local dir=${1:-$PWD}             # allow optional argument
  while [[ $dir = */* ]]; do       # while not at root...
    [[ -d $dir/.git ]] && return 0 # ...if a .git exists, return success
    dir=${dir%/*}                  # ...otherwise trim the last element
  done
  echo "-----> ERROR: no '.git' directory found in: '$PWD'"
  echo "If this is a new repo, initiate it with: git init ."
  return 1                         # if nothing was found, return failure
}

# Absolute URL of git repo
__git_repo_url() {
  git ls-remote --get-url
}

__current_git_branch() {
  git rev-parse --abbrev-ref HEAD
}

# Extract type of branch: feature/name => feature
__current_type_of_git_branch() {
  local current_branch_name=$(__current_git_branch)

  # BUG: [: too many arguments
  if [ "$current_branch_name" == *"/"* ]; then
    IFS="/"
    set -- $current_branch_name
    echo $1
  else
    echo "-----> ERROR: invalid branch name; no '/' separator found."
  fi
}

__no_branch_name_error_message() {
  echo "-----> ERROR: No branch name given!"
}

__join_text_with_hyphens() {
  local new_branch_name=""
  local i=0
  for i in "$@"; do
    new_branch_name="$new_branch_name-$i"
  done

  # Strip out leading '-'
  echo ${new_branch_name:1}
}

# Create branches
#----------------------------------------------------------------------

# New feature/... branch
# From development
feature() {
  __current_dir_has_git || return
  if [ -z "$1" ]; then
    __no_branch_name_error_message
  else
    if [ "$(__current_git_branch)" != "$(__development_branch_name)" ]; then
      echo "-----> ERROR: Feature branches must branch from the '$(__development_branch_name)' branch."
      echo "-----> Stash or commit your local changes then checkout the 'development' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b feature/$new_branch_name $(__development_branch_name)"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: $(__development_branch_name)"
      echo "*   To: feature/$new_branch_name"
      echo "=> $cmd"
    fi
  fi
}

# New bug/... branch
# From release to development/release
bug() {
  __current_dir_has_git || return
  if [ -z "$1" ]; then
    __no_branch_name_error_message
  else
    if [ "$(__current_type_of_git_branch)" != "release" ]; then
      echo "-----> ERROR: Bug branches must branch from a 'release/...' branch."
      echo "-----> Stash or commit your local changes then checkout a 'release/...' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b bug/$new_branch_name $(__current_git_branch)"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: $(__current_git_branch)"
      echo "*   To: bug/$new_branch_name"
      echo "=> $cmd"
    fi
  fi
}

# New refactor/... branch
# From development to development
refactor() {
  __current_dir_has_git || return
  if [ -z "$1" ]; then
    __no_branch_name_error_message
  else
    if [ "$(__current_git_branch)" != "$(__development_branch_name)" ]; then
      echo "-----> ERROR: Refactor branches must branch from the '$(__development_branch_name)' branch."
      echo "-----> Stash or commit your local changes then checkout the 'development' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b refactor/$new_branch_name $(__development_branch_name)"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: $(__development_branch_name)"
      echo "*   To: refactor/$new_branch_name"
      echo "=> $cmd"
    fi
  fi
}

# New release/... branch
# From development to development/master
release() {
  __current_dir_has_git || return
  if [ -z "$1" ]; then
    __no_branch_name_error_message
  else
    if [ "$(__current_git_branch)" != "$(__development_branch_name)" ]; then
      echo "-----> ERROR: Release branches must branch from the '$(__development_branch_name)' branch."
      echo "-----> Stash or commit your local changes then checkout the 'development' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b release/$new_branch_name $(__development_branch_name)"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: $(__development_branch_name)"
      echo "*   To: release/$new_branch_name"
      echo "=> $cmd"
    fi
  fi
}

# New hotfix/... branch
# From master to development/master
hotfix() {
  __current_dir_has_git || return
  if [ -z "$1" ]; then
    __no_branch_name_error_message
  else
    if [ "$(__current_git_branch)" != "$(__master_branch_name)" ]; then
      echo "-----> ERROR: Hotfix branches must branch from the '$(__master_branch_name)' branch."
      echo "-----> Stash or commit your local changes then checkout the 'master' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b hotfix/$new_branch_name $(__master_branch_name)"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: $(__master_branch_name)"
      echo "*   To: hotfix/$new_branch_name"
      echo "=> $cmd"
    fi
  fi
}

# Read branches
#----------------------------------------------------------------------

# List branches ('*' marks current branch)
branches() {
  __current_dir_has_git || return
  git branch
}

# Switch to new branch
checkout() {
  __current_dir_has_git || return
  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
  else
    local cmd="git checkout $1"
    echo "=> $cmd"
    $cmd
  fi
}

# Update branches
#----------------------------------------------------------------------

commit() {
  __current_dir_has_git || return
  if [ -z "$1" ]; then
    echo "-----> ERROR: Must provide a commit message!"
    echo "Usage: commit <message>"
  else
    echo "=> git add ."
    echo "=> git commit -m '$*'"
    # git add .
    # git commit -m "$1"
  fi
}

# Delete branches
#----------------------------------------------------------------------

# Only delete local branch
delete_local_branch() {
  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
    echo "Usage: delete_local_branch <branch_name>"
  else
    local cmd="git branch -d $1"
    echo "=> $cmd"
  fi
}

# Only delete remote branch
delete_remote_branch() {
  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
    echo "Usage: delete_local_branch <branch_name>"
  else
    local cmd="git push origin --delete $1"
    echo "=> $cmd"
  fi
}

# Delete both local and remote branch
delete_branch() {
  # Have user confirm they want to completely delete this branch
  read -p "Are you sure? (Y/N): " -r

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting branch from both local and remote repos"
    delete_local_branch $1
    delete_remote_branch $1
  else
    echo "Canceling delete; no branches were deleted."
  fi
}

# Merge
#----------------------------------------------------------------------

# Certain types of branches can only branch from/to select branches
# feature: from develop to develop (deploy to development/test)
# bug:     from develop to develop (deploy to development)
# release: from develop to develop/master (deploy to production)
# hotfix:  from master  to develop/master (deploy to development/production)
# merge_to() {
 # local current_branch=__current_git_branch
# }
