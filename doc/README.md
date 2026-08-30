Homerooms Dotfiles Manager - multiple Git repositories in $HOME

A fork of vcsh (https://github.com/RichiH/vcsh). The command is `room`; data lives
directly in `~/.config/homerooms/` -- one `<name>.git` per repo, no wrapper directory.


# Index

1. [30 Second How-to](#30-second-how-to)
2. [Introduction](#introduction)
3. [Usage Examples](#usage-examples)
4. [Overview](#overview)
5. [Getting Started](#getting-started)
6. [Contact](#contact)


# 30 Second How-to

While it may appear that there's an overwhelming amount of documentation and
while the explanation of the concepts behind `room` needs to touch a few gory
details of `git` internals, getting started with `room` is extremely simple.

Let's say you want to version control your `vim` configuration:

    room init vim
    room vim add ~/.vimrc ~/.vim
    room vim commit -m 'Initial commit of my Vim configuration'
    # optionally push your files to a remote
    room vim remote add origin <remote>
    room vim push -u origin master
    # from now on you can push additional commits like this
    room vim push

If all that looks a _lot_ like standard `git`, that's no coincidence; it's
a design feature.


# Introduction

[room][room] allows you to maintain several Git repositories in one single
directory. They all maintain their working trees without clobbering each other
or interfering otherwise. By default, all Git repositories maintained via
`room` store the actual files in `$HOME` but you can override this setting if
you want to.

All this means that you can have one repository per application or application
family, i.e. `zsh`, `vim`, `ssh`, etc. This, in turn, allows you to clone
custom sets of configurations onto different machines or even for different
users; picking and mixing which configurations you want to use where.
For example, you may not need to have your `mplayer` configuration on a server
or available to root and you may want to maintain different configuration for
`ssh` on your personal and your work machines.

See [INSTALL.md](INSTALL.md) for how to install `room`.

## Talks

Some people found it useful to look at slides and videos explaining how `room`
works instead of working through the docs.
All slides, videos, and further information can be found
[on the author's talk page][talks].


# Usage Examples

The common way to work with a repo is `room <repo> <git command>`, shown below.
`room enter <repo>` (a shell with `$GIT_DIR` set) and `room run <repo> <cmd>`
are covered in room(1).


| Task                                                  | Command                                           |
| ----------------------------------------------------- | ------------------------------------------------- |
| _Initialize a new repository called "vim"_            |   `room init vim`                                 |
| _Clone an existing repository_                        |   `room clone <remote> <repository_name>`         |
| _Add files to repository "vim"_                       |   `room vim add ~/.vimrc ~/.vim`                  |
|                                                       |   `room vim commit -m 'Update Vim configuration'` |
| _Add a remote for repository "vim"_                   |   `room vim remote add origin <remote>`           |
|                                                       |   `room vim push origin master:master`            |
|                                                       |   `room vim branch --track master origin/master`  |
| _Push to remote of repository "vim"_                  |   `room vim push`                                 |
| _Pull from remote of repository "vim"_                |   `room vim pull`                                 |
| _Show status of changed files in all repositories_    |   `room status`                                   |
| _Pull from all repositories_                          |   `room pull`                                     |
| _Push to all repositories_                            |   `room push`                                     |


# Overview

## From zero to room

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

`room` takes this approach one step further. It enables single-purpose
repositories and stores them in a hidden directory. However, it does not create
symbolic links in `$HOME`; it puts the actual files right into `$HOME`.

As `room` allows you to put an arbitrary number of distinct repositories into
your `$HOME`, you will end up with a lot of repositories very quickly.

`room` has a built-in bootstrap so setting up a new machine is quick:
`room manifest` writes `~/.config/homerooms/homerooms.list` -- one line per
repository, `<name> <url> <branch>` -- for every repo that has an
`origin` remote. Track that file in one of your repos. On a new machine,
clone that one repo, then run `room restore` and every other repo listed in
the manifest is cloned for you.

    room manifest                     # on your current machine
    room dotfiles add -f ~/.config/homerooms/homerooms.list
    room dotfiles commit -m 'track manifest' && room dotfiles push

    # on a new machine, after installing room:
    room clone <url-of-the-repo-holding-the-manifest> dotfiles
    room restore

`room pull` / `room push` / `room status` then operate on the whole set.
Repositories that are not `room` repos (a plain `~/src/project`, work
checkouts) are out of scope; use a separate tool for those if you need it.

## Directory layout

Everything `room` uses lives directly in `$XDG_CONFIG_HOME/homerooms/`
(`~/.config/homerooms/` by default) -- there is no wrapper directory and no
`repo.d`:

    ~/.config/homerooms/
        config                 # optional: shell config sourced for every repo
        homerooms.list         # the manifest (room manifest / room restore)
        <name>.git/            # one git directory per repo
        <name>.room            # optional: shell config sourced for this repo only
        hooks-enabled/         # optional: hook scripts
        overlays-enabled/      # optional: function overrides

Each `<name>.git` is an ordinary git directory with `core.worktree` set to
`$HOME` and `core.bare` false, so the working files land straight in `$HOME`;
`room` never creates symlinks. Per-repo ignore rules live in
`~/.gitignore.d/<name>` (see `$HOMEROOMS_GITIGNORE`).

`room` refuses to overwrite an existing file: if a checkout would clobber
something already in `$HOME`, it warns and exits. Move the old file aside and
retry, then merge and `room <name> push`.


# Getting Started

Install `room` -- see [INSTALL.md](INSTALL.md). Then:

    room init zsh                          # new repo
    room zsh add ~/.zshrc                  # track files
    room zsh commit -m 'initial zsh config'
    room zsh remote add origin <url>
    room zsh push -u origin main

Day to day:

    room zsh add -u && room zsh commit -m '...' && room zsh push
    room pull       # every repo that has a remote
    room push
    room status     # every repo

## New machine

    # install room, then:
    room clone <url-of-repo-holding-your-manifest> dotfiles
    room restore    # clones every repo listed in ~/.config/homerooms/homerooms.list

Keep the manifest current with `room manifest` (drop it into your push alias).


# Contact

* Issues and pull requests: <https://github.com/stevensko/homerooms>
* Upstream project (vcsh): <https://github.com/RichiH/vcsh>

[talks]: http://richardhartmann.de/talks/
[room]: https://github.com/stevensko/homerooms
[vcs-home-list]: http://lists.madduck.net/listinfo/vcs-home
