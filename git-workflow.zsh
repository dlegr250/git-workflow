#!/bin/zsh

#======================================================================
# Desc: Adds convenient extensions/aliases to Git via shell scripts.
# Maintainer: Dan LeGrand (dan.legrand@gmail.com)
# * Functions prefixed with '__' are script-related functions and
#   should NOT be called by external scripts.
#======================================================================

# Certain types of branches can only branch from/to select branches
# feature: from development to development (deploy to development/test)
# issue:   from development to development (deploy to development/test)
# bug:     from development to development (deploy to development)
# release: from development to develop/main (deploy to production)

# Helper methods
#----------------------------------------------------------------------

__git_workflow_version() {
  echo "2.3.0 / 2021-01-27"
}

# Absolute URL of git repo `git@<host>:<owner>/<repo>.git`
__git_repo_url() {
  git ls-remote --get-url
}

__current_branch() {
  git rev-parse --abbrev-ref HEAD
}

# `git@<host>:<owner>/<repo>.git` => <host>
__git_repo_host() {
  echo $(__git_repo_url) | cut -d'@' -f 2 | cut -d':' -f 1
}

# `git@<host>:<owner>/<repo>.git` => <owner>
__git_repo_owner() {
  echo $(__git_repo_url) | cut -d'@' -f 2 | cut -d':' -f 2 | cut -d'/' -f 1
}

# `git@<host>:<owner>/<repo>.git` => <repo>
__git_repo_name() {
  echo $(__git_repo_url) | cut -d'/' -f 2 | cut -d'.' -f 1
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

# `YYYY-MM-DDTHH:MM` format (ie, "2021-01-27T11:04")
__timestamp() {
  date +"%Y-%m-%dT%H:%M"
}

# Create branches
#----------------------------------------------------------------------

# Create new general branch
# Usage: `branch name-of-branch-to-create`
branch() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
  else
    local new_branch_name=$(__join_text_with_hyphens $*)
    local cmd=(git checkout -b $new_branch_name)

    echo "* Repo: $(__git_repo_url)"
    echo "* From: $(__current_branch)"
    echo "*   To: $new_branch_name"
    echo "=> ${cmd[@]}"
    $cmd
  fi
}

# Create new "feature/name-of-branch" branch following naming convention.
# Only allowed to branch fron `development` branch.
# Usage: `feature name-of-feature` (do not add "feature/" prefix, added automatically)
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
      local cmd=(git checkout -b feature/$new_branch_name development)

      echo "* Repo: $(__git_repo_url)"
      echo "* From: development"
      echo "*   To: feature/$new_branch_name"
      echo "=> ${cmd[@]}"
      $cmd
    fi
  fi
}

# Create new "bug/name-of-branch" branch following naming convention.
# Only allowed to branch fron `development` branch.
# Usage: `bug name-of-feature` (do not add "bug/" prefix, added automatically)
bug() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
  else
    if [ "$(__current_branch)" != "development" ]; then
      echo "-----> ERROR: Bug branches must branch from the 'development' branch."
      echo "-----> Stash or commit your local changes then checkout the 'development' branch."
    else
      local new_branch_name=$(__join_text_with_hyphens $*)
      local cmd=(git checkout -b bug/$new_branch_name development)

      echo "* Repo: $(__git_repo_url)"
      echo "* From: development"
      echo "*   To: bug/$new_branch_name"
      echo "=> ${cmd[@]}"
      $cmd
    fi
  fi
}

# Create new "refactor/name-of-branch" branch following naming convention.
# Only allowed to branch fron `development` branch.
# Usage: `refactor name-of-feature` (do not add "refactor/" prefix, added automatically)
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
      local cmd=(git checkout -b refactor/$new_branch_name development)

      echo "* Repo: $(__git_repo_url)"
      echo "* From: development"
      echo "*   To: refactor/$new_branch_name"
      echo "=> ${cmd[@]}"
      $cmd
    fi
  fi
}

# Read branches
#----------------------------------------------------------------------

# List branches ('*' marks current branch)
# Usage: `branches`
branches() {
  __current_dir_using_git || return

  git branch
}

# Switch to new branch
# Usage: `checkout name-of-branch-to-checkout`
checkout() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name provide!"
  else
    local cmd=(git checkout $1)
    echo "=> ${cmd[@]}"
    $cmd
  fi
}

# Shortcut to switch to development branch
# Usage: `development`
development() {
  __current_dir_using_git || return

  local cmd=(git checkout development)
  echo "=> ${cmd[@]}"
  $cmd
}

tags() {
  __current_dir_using_git || return

  local cmd=(git tag)
  echo "=> ${cmd[@]}"
  $cmd
}

# Alias for `git pull`
gp() {
  __current_dir_using_git || return

  local cmd=(git pull)
  echo "=> ${cmd[*]}"
  "${cmd[@]}"
}

# Alias for `git status`
gs() {
  __current_dir_using_git || return

  local cmd=(git status)
  echo "=> ${cmd[@]}"
  $cmd
}

# Update branches
#----------------------------------------------------------------------

# Commit code to local repo and push to remote repo
# Usage: `commit "commit msg"` (requires quotes `""` around message)
commit() {
  __current_dir_using_git || return

  local current_branch=$(__current_branch)

  if [ -z "$1" ]; then
    echo "-----> ERROR: Must provide a commit message!"
    echo "Usage: commit <message>"
  elif [ "$current_branch" = "main" ]; then
    echo "-----> ERROR: cannot commit code directly to main (production) branch!"
  else
    echo "=> git add ."
    echo "=> git commit -m '$*'"
    echo "=> git push --set-upstream origin $current_branch"
    git add .
    git commit -m "$*"
    git push --set-upstream origin $current_branch
  fi
}

# Opens browser to submit pull request to specified branch (defaults to "development").
# Assumes you are using github to maintain project, may need to adapt for other uses.
# Usage: `pull-request`
pull-request() {
  __current_dir_using_git || return

  local current_branch=$(__current_branch)

  if [ "$current_branch" = "main" ]; then
    echo "-----> ERROR: cannot submit Pull Request directly from main (production) branch!"
  else
    # Submit Pull Request to specified branch name or default to "development"
    local to_branch=""
    if [ -z "$1" ]; then
      to_branch="development"
    else
      to_branch="$1"
    fi

    echo "=> submitting Pull Request to $to_branch (opens browser)..."
    open "$(__git_pull_request_url)/$to_branch...$current_branch?expand=1"
  fi
}

# Submit Pull Request from "development"  branch to "main" branch
# Usage: `deploy`
deploy() {
  __current_dir_using_git || return

  local current_branch=$(__current_branch)

  if [ "$current_branch" = "main" ]; then
    echo "----> ERROR: cannot deploy from main to main!"
  fi

  if [ "$current_branch" = "development" ]; then
    echo "=> submitting Pull Request to main (opens browser)..."
    open -n "$(__git_pull_request_url)/main...development?expand=1&title=Deploy:$(__timestamp)"
  else
    echo "----> ERROR: can only deploy from development branch to main!"
  fi
}

# Alias for "commit and deploy"
cad() {
  commit "$*"
  deploy
}

tag() {
  __current_dir_using_git || return

  local cmd=()

  read -p "* Release tag version: " -r
  local tag_version=$REPLY

  read -p "* Release tag message: " -r
  local tag_message=$REPLY

  echo "* Tagging $(__current_branch)..."
  echo "  => git tag -a $tag_version -m '$tag_message'"
  git tag -a $tag_version -m "$tag_message"

  echo "* Pushing tag to remote..."
  cmd=(git push origin $tag_version)
  echo "  => $cmd"
  $cmd
}

# Delete branches
#----------------------------------------------------------------------

# Only delete local branch
delete-local-branch() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
    echo "Usage: delete_local_branch <branch_name>"
  else
    local cmd=(git branch -d $1)
    echo "=> ${cmd[@]}"
    $cmd
  fi
}

# Only delete remote branch
delete-remote-branch() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No branch name given!"
    echo "Usage: delete-local-branch <branch_name>"
  else
    local cmd=(git push origin --delete $1)
    echo "=> ${cmd[@]}"
    $cmd
  fi
}

# Delete both local and remote branch
delete-branch() {
  if [[ $1 = "" ]]; then
    echo "-----> ERROR: No branch name provided"
  elif [[ $1 = "development" ]]; then
    echo "-----> ERROR: Cannot delete development branch"
  elif [[ $1 = "main" ]]; then
    echo "-----> ERROR: Cannot delete main branch"
  elif [[ $1 = "master" ]]; then
    echo "-----> ERROR: Cannot delete master branch"
  else
    # Have user confirm they want to completely delete this branch
    echo -n "Are you sure? (Y/N) "
    read RESPONSE

    if [[ $RESPONSE =~ ^[Yy]$ ]]; then
      echo "Deleting branch from both local and remote repos"
      delete-local-branch $1
      delete-remote-branch $1
    else
      echo "Canceling delete; no branches were deleted."
    fi
  fi
}

# Delete tags
#----------------------------------------------------------------------

delete-local-tag() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No tag name given!"
    echo "Usage: delete-local-tag <tag_name>"
  else
    local cmd=(git tag -d $1)
    echo "=> ${cmd[@]}"
    $cmd
  fi
}

delete-remote-tag() {
  __current_dir_using_git || return

  if [ -z "$1" ]; then
    echo "-----> ERROR: No tag name given!"
    echo "Usage: delete-remote-tag <tag_name>"
  else
    local cmd=(git push origin :refs/tags/$1)
    echo "=> ${cmd[@]}"
    $cmd
  fi
}

delete-tag() {
  # Have user confirm they want to completely delete this branch
  read -p "$(tput setaf 1)Are you sure? (Y/N):$(tput sgr 0) " -r

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "* Deleting tag from both local and remote repos"
    delete-local-tag $1
    delete-remote-tag $1
  else
    echo "Canceling delete; no tags were deleted."
  fi
}

# Merge
#----------------------------------------------------------------------

# NOOP

# Aliases
#----------------------------------------------------------------------

alias db="delete-branch"
alias dlb="delete-local-branch"
alias drb="delete-remote-branch"

# Help
#----------------------------------------------------------------------

git-workflow() {
  if [ "$1" = "-v" ]; then
    echo "$(__git_workflow_version)"
  elif [ "$1" = "rules" ]; then
    echo "* feature"
    echo "    development -> development (deploy to development/test)"
    echo "* bug"
    echo "    development -> development (deploy to development)"
    echo "* release"
    echo "    development -> development/main (deploy to production)"
    echo "* hotfix"
    echo "    main      -> development/main (deploy to development/production)"
  else
    echo "version: $(__git_workflow_version)"
    echo ""
    echo "BRANCHING"
    echo "---------"
    echo "* feature <branch> : create new feature branch from development"
    echo "* bug     <branch> : create new bug branch from development"
    echo "* release <branch> : create new release branch from development"
    echo "* hotfix  <branch> : create new hotfix branch from main (production)"
    echo "* gp               : git pull (alias)"
    echo "* gs               : git status (alias)"
    echo ""
    echo "COMMITTING"
    echo "----------"
    echo "* commit '<message>'    : commit changes locally and push remotely (quotes required for message with spaces)"
    echo "* pull_request <branch> : submit Pull Request to remote (opens browser)"
    echo ""
    echo "DELETING"
    echo "--------"
    echo "* delete-local-branch  <branch> : delete local branch only"
    echo "* dlb (alias)          <branch> : alias for delete-local-branch"
    echo "* delete-remote-branch <branch> : delete remote branch only"
    echo "* drb (alias)          <branch> : alias for delete-remote-branch"
    echo "* delete-branch        <branch> : completely delete branch locally and remotely"
    echo "* db (alias)           <branch> : alias for delete-branch"
    echo "* delete-local-tag     <tag>    : delete local tag only"
    echo "* delete-remote-tag    <tag>    : delete remote tag only"
    echo "* delete-tag           <tag>    : completely delete branch locally and remotely"
    echo ""
    echo "TAGGING"
    echo "-------"
    echo "* tag : interactively create annotated tag"
  fi
}
