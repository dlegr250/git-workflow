# Overview

A shell script that helps enforce a [git workflow](http://nvie.com/posts/a-successful-git-branching-model/).

It includes shell functions that will be loaded into your terminal. It may conflict with other scripts/functions if you use the same names.

It assumes you have 2 permanent branches:
* `development` => where all new features come from
* `master` => production-ready code (head of master corresponds to current production code)

There is a strict process for where branches may come from and where they may be merge to.

* feature branches
** from: development
**   to: development (deploy automatically to development/test environments)
* bug branches
** from: development
**   to: development (deploy automatically to development environment)
* release branches
** from: development
**   to: development and master (deploy automatically to production environment)
* hotfix branches
** from: master
**   to: develoment and master (deploy automatically to develoment/production environments)

# Installation

Download `git-extensions.sh` and store in some directory. I recommend `~/scripts` as a useful location.

In your `.bash_profile` (loaded on terminal start) source this script file:

```
# ~/.bash_profile
source ~/scripts/git-extensions.sh
```

# Usage

When you use the commands, it will automatically prefix the branch name with the appropriate type of branch.  For instance:

```
feature name-of-new-feature-branch
# => git checkout -b feature/name-of-new-feature-branch development

hotfix name-of-new-hotfix-branch
# => git checkout -b hotfix/name-of-new-hotfix-branch master
```

You do not need to prefix your branch names with `feature/...`, `bug/...` if you use the provided shell functions.

You can provide branch names either with or without spaces.

```
feature name of branch
# => git checkout -b feature/name-of-branch development

feature name-of-branch
# => git checkout -b feature/name-of-branch development
```

# Commands

A list of available commands.

```
feature <name_of_branch>
# => git checkout -b feature/<name_of_branch> development
```
