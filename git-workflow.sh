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

# Helper methods
#----------------------------------------------------------------------

__git_workflow_version() {
  echo "1.0.0"
}

# Absolute URL of git repo (git@<host>:<owner>/<repo>.git)
__git_repo_url() {
  git ls-remote --get-url
}

__current_branch() {
  git rev-parse --abbrev-ref HEAD
}

# git@<host>:<owner>/<repo>.git => <host>
__git_repo_host() {
  local url=$(__git_repo_url)
  IFS=":"
  set -- $url
  echo ${1:4}
}

# git@<host>:<owner>/<repo>.git => <owner>
__git_repo_owner() {
  local url=$(__git_repo_url)
  IFS=":"
  set -- $url
  IFS="/"
  set -- $2
  echo $1
}

# git@<host>:<owner>/<repo>.git => <repo>
__git_repo_name() {
  local url=$(__git_repo_url)
  IFS="/"
  set -- $url
  IFS="."
  set -- $2
  echo $1
}

__git_pull_request_url() {
  echo "https://$(__git_repo_host)/$(__git_repo_owner)/$(__git_repo_name)/compare"
}

# Inform user if there is not a .git directory
# See: http://stackoverflow.com/a/27552913/667772
__current_dir_using_git() {
  local dir=${1:-$PWD}             # allow optional argument
  while [[ $dir = */* ]]; do       # while not at root...
    [[ -d $dir/.git ]] && return 0 # ...if a .git exists, return success
    dir=${dir%/*}                  # ...otherwise trim the last element
  done
  echo "-----> ERROR: no '.git' directory found in: '$PWD'"
  echo "If this is a new repo, initiate it with: git init"
  return 1                         # if nothing was found, return failure
}

# Extract type of branch: <type>/<name> => <type>
__current_branch_type() {
  local current_branch_name=$(__current_branch)
  if [[ $current_branch_name == *"/"* ]]; then
    IFS="/"
    set -- $current_branch_name
    echo $1
  else
    echo "-----> ERROR: invalid branch name; no '/' found in branch name."
  fi
}

# "some string    text" => "some-string-text"
__join_text_with_hyphens() {
  local new_branch_name=""
  local i=0
  for i in "$@"; do
    new_branch_name="$new_branch_name-$i"
  done

  # Strip out leading '-' (-some-string-text => some-string-text)
  echo ${new_branch_name:1}
}

# Create branches
#----------------------------------------------------------------------

# New feature/... branch; from development
feature() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
  else
    if [ "$(__current_branch)" != "development" ]; then
      echo "-----> ERROR: Feature branches must branch from the 'development' branch."
      echo "-----> Stash or commit your local changes then checkout the 'development' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b feature/$new_branch_name development"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: development"
      echo "*   To: feature/$new_branch_name"
      echo "=> $cmd"
      $cmd
    fi
  fi
}

# New bug/... branch; from release
bug() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
  else
    if [ "$(__current_branch_type)" != "release" ]; then
      echo "-----> ERROR: Bug branches must branch from a 'release/...' branch."
      echo "-----> Stash or commit your local changes then checkout a 'release/...' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b bug/$new_branch_name $(__current_branch)"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: $(__current_branch)"
      echo "*   To: bug/$new_branch_name"
      echo "=> $cmd"
      $cmd
    fi
  fi
}

# New refactor/... branch; from development
refactor() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
  else
    if [ "$(__current_branch)" != "development" ]; then
      echo "-----> ERROR: Refactor branches must branch from the 'development' branch."
      echo "-----> Stash or commit your local changes then checkout the 'development' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b refactor/$new_branch_name development"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: development"
      echo "*   To: refactor/$new_branch_name"
      echo "=> $cmd"
      $cmd
    fi
  fi
}

# New release/... branch; from development
release() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
  else
    if [ "$(__current_branch)" != "development" ]; then
      echo "-----> ERROR: Release branches must branch from the 'development' branch."
      echo "-----> Stash or commit your local changes then checkout the 'development' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b release/$new_branch_name development"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: development"
      echo "*   To: release/$new_branch_name"
      echo "=> $cmd"
      $cmd
    fi
  fi
}

# New hotfix/... branch; from master (production)
hotfix() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
  else
    if [ "$(__current_branch)" != "master" ]; then
      echo "-----> ERROR: Hotfix branches must branch from the 'master' branch."
      echo "-----> Stash or commit your local changes then checkout the 'master' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd="git checkout -b hotfix/$new_branch_name master"

      echo "* Repo: $(__git_repo_url)"
      echo "* From: master"
      echo "*   To: hotfix/$new_branch_name"
      echo "=> $cmd"
      $cmd
    fi
  fi
}

# Read branches
#----------------------------------------------------------------------

# List branches ('*' marks current branch)
branches() {
  __current_dir_using_git || return

  git branch
}

# Switch to new branch
checkout() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name provide!"
  else
    local cmd="git checkout $1"
    echo "=> $cmd"
    $cmd
  fi
}

# Shortcut to switch to development branch
development() {
  __current_dir_using_git || return

  local cmd="checkout development"
  $cmd
}

tags() {
  git tag
}

# Update branches
#----------------------------------------------------------------------

# Commit code to local repo and push to remote
commit() {
  __current_dir_using_git || return

  local current_branch=$(__current_branch)

  if [ -z "$1" ]; then
    echo "-----> ERROR: Must provide a commit message!"
    echo "Usage: commit <message>"
  elif [ "$current_branch" == "master" ]; then
    echo "-----> ERROR: cannot commit code directly to master (production) branch!"
  else
    echo "=> git add ."
    echo "=> git commit -m '$*'"
    echo "=> git push --set-upstream origin $current_branch"
    git add .
    git commit -m "$*"
    git push --set-upstream origin $current_branch
  fi
}

# Opens browser to submit pull request to appropriate branch.
#   Certain types of branches can only branch from/to select branches.
#     feature: from develop to develop (deploy to development/test)
#     bug:     from develop to develop (deploy to development)
#     release: from develop to develop/master (deploy to production)
#     hotfix:  from master  to develop/master (deploy to development/production)
pull_request() {
  __current_dir_using_git || return

  local current_branch=$(__current_branch)
  local current_branch_type=$(__current_branch_type)
  local cmd=""

  if [ "$current_branch" == "master" ]; then
    echo "-----> ERROR: cannot submit code directly from master (production) branch!"

  # feature to development
  elif [ "$current_branch_type" == "feature" ]; then
    echo "=> submitting Pull Request to development (opens browser)..."
    open "$(__git_pull_request_url)/development...$current_branch?expand=1"

  # bug to development
  elif [ "$current_branch_type" == "bug" ]; then
    echo "=> submitting Pull Request to development (opens browser)..."
    open "$(__git_pull_request_url)/development...$current_branch?expand=1"

  # refactor to development
  elif [ "$current_branch_type" == "refactor" ]; then
    echo "=> submitting Pull Request to development (opens browser)..."
    open "$(__git_pull_request_url)/development...$current_branch?expand=1"

  # release to development/master
  elif [ "$current_branch_type" == "release" ]; then
    echo "Pushing from a RELEASE branch constitutes a code DEPLOY to master and will:"
    echo "* Automatically merge this release branch with development"
    echo "* Submit a Pull Request to the master branch"
    echo "* You may have to manually resolve merge conflicts"
    echo ""

    # Confirm deployment merges
    # tput changes text color
    read -p "$(tput setaf 1)Are you sure you want to submit a Pull Request to master? (Y/N): $(tput sgr 0)" -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo ""
      echo "* Merging code to development..."
      cmd="git merge --no-ff $current_branch development"
      echo "  => $cmd"
      $cmd

      echo "=> submitting Pull Request to master (opens browser)..."
      open "$(__git_pull_request_url)/$current_branch?expand=1"
    else
      echo ""
      echo "Push stopped. No code merged to any branches."
    fi

  # hotfix to development/master
  # elif [ "$current_branch_type" == "hotfix" ]; then
  #   echo "=> submitting Pull Request to development and master..."
  #   open "$(__git_pull_request_url)/development...$current_branch?expand=1"
  else
    echo "-----> ERROR: invalid branch to submit Pull Request from/to!"
  fi
}

tag() {
  __current_dir_using_git || return

  local cmd=""

  read -p "* Release tag version: " -r
  local tag_version=$REPLY

  read -p "* Release tag message: " -r
  local tag_message=$REPLY

  echo "* Tagging $(__current_branch)..."
  echo "  => git tag -a $tag_version -m '$tag_message'"
  git tag -a $tag_version -m "$tag_message"

  echo "* Pushing tag to remote..."
  cmd="git push origin $tag_version"
  echo "  => $cmd"
  $cmd
}

# Delete branches
#----------------------------------------------------------------------

# Only delete local branch
delete_local_branch() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
    echo "Usage: delete_local_branch <branch_name>"
  else
    local cmd="git branch -d $1"
    echo "=> $cmd"
    $cmd
  fi
}

# Only delete remote branch
delete_remote_branch() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
    echo "Usage: delete_local_branch <branch_name>"
  else
    local cmd="git push origin --delete $1"
    echo "=> $cmd"
    $cmd
  fi
}

# Delete both local and remote branch
delete_branch() {
  # Have user confirm they want to completely delete this branch
  read -p "$(tput setaf 1)Are you sure? (Y/N):$(tput sgr 0) " -r

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting branch from both local and remote repos"
    delete_local_branch $1
    delete_remote_branch $1
  else
    echo "Canceling delete; no branches were deleted."
  fi
}

delete_tag() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: no tag name given!"
    echo "Usage: delete_tag <tag_name>"
  else
    echo "* Deleting tag from both local and remote repos"
    local cmd="git tag -d $1"
    echo "=> $cmd"
    $cmd
    local remote_cmd="git push origin :refs/tags/$1"
    echo "=> $remote_cmd"
    $remote_cmd
  fi
}

# Merge
#----------------------------------------------------------------------

# NOOP

# Help
#----------------------------------------------------------------------

git_workflow() {
  if [ "$1" == "-v" ]; then
    echo "$(__git_workflow_version)"
  elif [ "$1" == "rules" ]; then
    echo "* feature"
    echo "    development -> development (deploy to development/test)"
    echo "* bug"
    echo "    development -> development (deploy to development)"
    echo "* release"
    echo "    development -> development/master (deploy to production)"
    echo "* hotfix"
    echo "    master      -> development/master (deploy to development/production)"
  else
    echo "version: $(__git_workflow_version)"
    echo ""
    echo "BRANCHING"
    echo "---------"
    echo "* feature <branch> : create new feature branch from development"
    echo "* bug     <branch> : create new bug branch from release"
    echo "* release <branch> : create new release branch from development"
    echo "* hotfix  <branch> : create new hotfix branch from master (production)"
    echo ""
    echo "COMMITTING"
    echo "----------"
    echo "* commit <message> : commit changes locally and push remotely"
    echo "* pull_request     : submit Pull Request to remote (opens browser)"
    echo ""
    echo "DELETING"
    echo "--------"
    echo "* delete_local_branch  <branch> : delete local branch only"
    echo "* delete_remote_branch <branch> : delete remote branch only"
    echo "* delete_branch        <branch> : completely delete branch locally and remotely"
    echo ""
  fi
}
