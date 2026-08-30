Git St/a/che Dotfiles Manager - multiple Git repositories in $HOME

A fork of vcsh (https://github.com/RichiH/vcsh). The command is `stache`. Everything
lives under `~/.config/stache/` -- one `<name>.stache/` directory per repo; nothing
is created in `$HOME`.


# Index

1. [30 Second How-to](#30-second-how-to)
2. [Introduction](#introduction)
3. [Usage Examples](#usage-examples)
4. [Overview](#overview)
5. [Getting Started](#getting-started)
6. [Contact](#contact)


# 30 Second How-to

While it may appear that there's an overwhelming amount of documentation and
while the explanation of the concepts behind `stache` needs to touch a few gory
details of `git` internals, getting started with `stache` is extremely simple.

Let's say you want to version control your `vim` configuration:

    stache init vim
    stache vim add ~/.vimrc ~/.vim
    stache vim commit -m 'Initial commit of my Vim configuration'
    # optionally push your files to a remote
    stache vim remote add origin <remote>
    stache vim push -u origin main
    # from now on you can push additional commits like this
    stache vim push

If all that looks a _lot_ like standard `git`, that's no coincidence; it's
a design feature.


# Introduction

[stache][stache] allows you to maintain several Git repositories in one single
directory. They all maintain their working trees without clobbering each other
or interfering otherwise. By default, all Git repositories maintained via
`stache` store the actual files in `$HOME` but you can override this setting if
you want to.

All this means that you can have one repository per application or application
family, i.e. `zsh`, `vim`, `ssh`, etc. This, in turn, allows you to clone
custom sets of configurations onto different machines or even for different
users; picking and mixing which configurations you want to use where.
For example, you may not need to have your `mplayer` configuration on a server
or available to root and you may want to maintain different configuration for
`ssh` on your personal and your work machines.

See [INSTALL.md](INSTALL.md) for how to install `stache`.

## Talks

Some people found it useful to look at slides and videos explaining how `stache`
works instead of working through the docs.
All slides, videos, and further information can be found
[on the author's talk page][talks].


# Usage Examples

The common way to work with a repo is `stache <repo> <git command>`, shown below.
`stache enter <repo>` (a shell with `$GIT_DIR` set) and `stache run <repo> <cmd>`
are covered in stache(1).


| Task                                                  | Command                                           |
| ----------------------------------------------------- | ------------------------------------------------- |
| _Initialize a new repository called "vim"_            |   `stache init vim`                                 |
| _Clone an existing repository_                        |   `stache clone <remote> <repository_name>`         |
| _Add files to repository "vim"_                       |   `stache vim add ~/.vimrc ~/.vim`                  |
|                                                       |   `stache vim commit -m 'Update Vim configuration'` |
| _Add a remote for repository "vim"_                   |   `stache vim remote add origin <remote>`           |
|                                                       |   `stache vim push origin main:main`            |
|                                                       |   `stache vim branch --track main origin/main`  |
| _Push to remote of repository "vim"_                  |   `stache vim push`                                 |
| _Pull from remote of repository "vim"_                |   `stache vim pull`                                 |
| _Show status of changed files in all repositories_    |   `stache status`                                   |
| _Pull from all repositories_                          |   `stache pull`                                     |
| _Push to all repositories_                            |   `stache push`                                     |


# Overview

## From zero to stache

You put a lot of effort into your configuration and want to both protect and
distribute this configuration.

Most people who decide to put their dotfiles under version control start with a
single repository in `$HOME`, adding all their dotfiles (and possibly more)
to it. This works, of course, but can become a nuisance as soon as you try to
manage more than one host.

The next logical step is to create single-purpose repositories in, for example,
`~/.dotfiles` and to create symbolic links into `$HOME`. This gives you the
flexibility to check out only certain repositories on different hosts. The
downsides of this approach are the necessary manual steps of cloning and
symlinking the individual repositories.

`stache` takes this approach one step further. It enables single-purpose
repositories and stores them in a hidden directory. However, it does not create
symbolic links in `$HOME`; it puts the actual files right into `$HOME`.

As `stache` allows you to put an arbitrary number of distinct repositories into
your `$HOME`, you will end up with a lot of repositories very quickly.

`stache` has a built-in bootstrap. It keeps
`~/.config/stache/stache.repos` -- one line per repo, `<name> <url> <branch>`,
for every repo with an `origin` remote -- current **automatically** (after
init/clone/delete/rename/upgrade). Track that file in one of your repos; on a
new machine, clone that repo and run `stache bootstrap`, and every other repo in
the list is cloned for you. `stache clone --all` (or `-a`) does the same thing --
with `clone`, the `--all` / `-a` must be the first word, before any URL or `-b`.

    stache dotfiles add -f ~/.config/stache/stache.repos
    stache dotfiles commit -m 'track repo list' && stache dotfiles push

    # on a new machine, after installing stache:
    stache clone <url-of-the-repo-holding-stache.repos> dotfiles
    stache bootstrap

`stache pull` / `stache push` / `stache status` then operate on the whole set.
Repositories that are not `stache` repos (a plain `~/src/project`, work
checkouts) are out of scope; use a separate tool for those if you need it.

## Directory layout

Everything `stache` uses lives under `$XDG_CONFIG_HOME/stache/`
(`~/.config/stache/` by default). **Nothing is created in `$HOME`** except the
tracked files themselves.

    ~/.config/stache/
        config                  # optional: shell config sourced for every repo
        .gitconfig              # git config included by every repo (edit: stache config ...)
        .gitignore              # shared fallback ignore file (seeded with '*')
        .gitattributes          # shared fallback attributes file
        stache.repos            # the repo list, maintained automatically
        hooks/                  # optional: hook scripts
        overlays/               # optional: function overrides
        <name>.stache/          # one directory per repo, containing:
            <name>.git/         #   the git directory
            config              #   optional: shell config sourced for this repo only
            .gitignore          #   optional: per-repo ignore file
            .gitattributes      #   optional: per-repo attributes file

Each `<name>.git` is an ordinary git directory with `core.worktree` set to
`$HOME` and `core.bare` false, so the working files land straight in `$HOME`;
`stache` never creates symlinks. `upgrade` sets `core.excludesfile` /
`core.attributesfile` to the per-repo file in `<name>.stache/` if it exists,
otherwise to the shared `~/.config/stache/.gitignore` /
`~/.config/stache/.gitattributes` (see `$STACHE_GITIGNORE`). Unlike vcsh, these
files are **not** tracked by the repo and do not clone to other machines --
regenerate with `stache write-gitignore <repo>` if you want a per-repo one.

`stache` refuses to overwrite an existing file: if a checkout would clobber
something already in `$HOME`, it warns and exits. Move the old file aside and
retry, then merge and `stache <name> push`.


# Getting Started

Install `stache` -- see [INSTALL.md](INSTALL.md). Then:

    stache init zsh                          # new repo
    stache zsh add ~/.zshrc                  # track files
    stache zsh commit -m 'initial zsh config'
    stache zsh remote add origin <url>
    stache zsh push -u origin main

Day to day:

    stache zsh add -u && stache zsh commit -m '...' && stache zsh push
    stache pull       # every repo that has a remote
    stache push
    stache status     # every repo

## New machine

    # install stache, then:
    stache clone <url-of-repo-holding-stache.repos> dotfiles
    stache bootstrap   # clones every repo listed in ~/.config/stache/stache.repos

`stache.repos` is kept current automatically -- no command to run.


# Contact

* Issues and pull requests: <https://github.com/stevensko/stache>
* Upstream project (vcsh): <https://github.com/RichiH/vcsh>

[talks]: http://richardhartmann.de/talks/
[stache]: https://github.com/stevensko/stache
[vcs-home-list]: http://lists.madduck.net/listinfo/vcs-home
