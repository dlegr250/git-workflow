# Overview

A shell script that helps enforce a [git workflow](http://nvie.com/posts/a-successful-git-branching-model/). It is not useful
for general workflow as it is specifically created to enforce a single git workflow.

It includes shell functions that will be loaded into your terminal. It may conflict with other scripts/functions if you use the same names.

It assumes you have 2 permanent branches:
* `development` => where all new features come from
* `master` => production-ready code (head of master corresponds to current production code)

There is a strict process for where branches may come from and where they may be merged to.

* feature branches
* from: development
*   to: development (deploy automatically to development/test environments)
* bug branches
* from: development
*   to: development (deploy automatically to development environment)
* release branches
* from: development
*   to: development and master (deploy automatically to production environment)
* hotfix branches
* from: master
*   to: develoment and master (deploy automatically to develoment/production environments)

When you use the commands, it will automatically prefix the branch name with the appropriate type of branch.  For instance:

```
$ feature name-of-new-feature-branch
# => git checkout -b feature/name-of-new-feature-branch development
```

```
$ hotfix name-of-new-hotfix-branch
# => git checkout -b hotfix/name-of-new-hotfix-branch master
```

You do not need to prefix your branch names with `feature/...`, `bug/...` if you use the provided shell functions.

You can provide branch names either with or without spaces.

```
$ feature name of branch
# => git checkout -b feature/name-of-branch development
```

```
$ feature name-of-branch
# => git checkout -b feature/name-of-branch development
```

# Dependencies

This script requires the following scripts in order to work properly:
* [official git/git-completion.bash](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash)
* [official git/git-prompt.sh](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh)

You can find these 2 files in this repo under `dependencies/*` or download the latest from the above URLs.

# Installation

Download `git-workflow.sh` and store in some directory. I recommend `~/scripts` as a useful location.

In your `.bash_profile` (loaded on terminal start) source this script file:

```
# ~/.bash_profile
export "PATH=$PATH:~/scripts"    # Add to $PATH
source ~/scripts/git-workflow.sh
```

If you wish to work on the script and submit Pull Requests, I recommend putting it in your
normal project/app directory and then source it from that location so that your
changes will automatically update your terminal source.

Make the script executable so it may be called in your terminal:

```
$ cd ~/scripts
$ chmod +x git-workflow.sh
```

# Commands

A list of available commands.

### Creating new branches

```
$ feature <name_of_branch>
# => git checkout -b feature/<name_of_branch> development
# Must branch from development
```

```
$ bug <name_of_branch>
# => git checkout -b bug/<name_of_branch> development
# Must branch from development
```

```
$ release <name_of_branch>
# => git checkout -b release/<name_of_branch> development
# Must branch from development
```

```
$ hotfix <name_of_branch>
# => git checkout -b hotfix/<name_of_branch> master
# Must branch from master
```

### Committing code

```
$ commit <commit_message>
# => git add .
# => git commit -m "<commit_message>"
# Shortcut for committing code; you do not have to use quotes ("...")
```

```
$ pull_request
# => submit Pull Request to remote
# Opens browser with appropriate from/to branch options. Github utilizes their own
format for Pull Requests (different from git `request-pull`) so this script cannot fully automate that process.
```

### Listing branches

```
$ branches
# => git branch
# Current branch marked by '*'
```

### Deleting branches

```
$ delete_local_branch <name_of_branch>
# => git branch -d <name_of_branch>
# Delete branch in local repo only
```

```
$ delete_remote_branch <name_of_branch>
# => git push origin --delete <name_of_branch>
# Delete branch in remote repo only
```

```
$ delete_branch <name_of_branch>
# => Are you sure? (Y/N): <confirm>
# => git branch -d <name_of_branch>
# => git push origin --delete <name_of_branch>
# Delete branch in both local and remote repos
```

### Help/Usage

```
$ git_workflow
# => ...
# Displays usage commands
```

```
$ git_workflow -v
# => x.x.x
# Displays version
```
