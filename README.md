# Overview

A shell script that helps enforce a [git workflow](http://nvie.com/posts/a-successful-git-branching-model/).

It includes shell functions that will be loaded into your terminal. It may conflict with other scripts/functions if you use the same names.

# Installation

Download `git-extensions.sh` and store in some directory. I recommend `~/scripts` as a useful location.

In your `.bash_profile` (loaded on terminal start):

`source ~/scripts/git-extensions.sh` (or wherever you stored your script).

# Usage

When you use the commands, it will automatically prefix the branch name with the appropriate type of branch.  For instance:
`$ feature name-of-new-feature-branch # => git checkout -b feature/name-of-feature-branch development`
You do not need to prefix your branch names with `feature/...`, `bug/...` if you use the provided shell functions.

You can provide branch names either with or without spaces.
`$ feature name of branch # => git checkout -b feature/name-of-branch development`
`$ feature name-of-branch # => git checkout -b feature/name-of-branch development`

# Commands
