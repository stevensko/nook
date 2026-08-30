Houseroom Dotfiles Manager - multiple Git repositories in $HOME

A fork of vcsh (https://github.com/RichiH/vcsh). The command is `room`; data lives
under `~/.config/house/` (repositories in `~/.config/house/rooms/`).


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

A lot of modern UNIX-based systems offer packages for `room`. In case yours
does not read `INSTALL.md` for install instructions or `PACKAGING.md` to create
a package, yourself. If you do end up packaging `room` please let us know so we
can give you your own packaging branch in the upstream repository.

## Talks

Some people found it useful to look at slides and videos explaining how `room`
works instead of working through the docs.
All slides, videos, and further information can be found
[on the author's talk page][talks].


# Usage Examples

There are three different ways to interact with `room` repositories; this
section will only show the simplest and easiest way.

Certain more advanced use cases require the other two ways, but don't worry
about this for now. If you never even bother playing with the other two
modes you will still be fine.

`room enter` and `room run`  will be covered in later sections.


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

`room` was designed with [myrepos][myrepos], a tool to manage Multiple
Repositories, in mind and the two integrate very nicely. The myrepos tool
(`mr`) has native support for `room` repositories and the configuration for
myrepos is just another set of files that you can track with `room` like any
other. This makes setting up any new machine a breeze. It can take literally
less than five minutes to go from standard installation to fully set up system.

We suggest using [myrepos][myrepos] to manage both `room` and other
repositories. The `mr` utility takes care of pulling in and pushing
out new data for a variety of version control systems. While the use
of myrepos is technically optional, it will be an integral part of the
proposed system that follows. For instance, you can use
[myrepos][myrepos] to track repositories in home such as `.emacs.d`,
which `mr` can clone and update for you automatically. To do this,
just add a `mr` configuration file to `available.d` with a `checkout`
command to clone the repo, and set the [title] to the desired
location, e.g. `$HOME/.emacs.d`. Try the `mr register` command in an
existing repository, then view `~/.mrconfig` for an example.

## Default Directory Layout

To illustrate, this is what a possible directory structure looks like.

    $HOME
        |-- $XDG_CONFIG_HOME (defaults to $HOME/.config)
        |   |-- mr
        |   |   |-- available.d
        |   |   |   |-- zsh.room
        |   |   |   |-- gitconfigs.room
        |   |   |   |-- lftp.room
        |   |   |   |-- offlineimap.room
        |   |   |   |-- s3cmd.room
        |   |   |   |-- tmux.room
        |   |   |   |-- vim.room
        |   |   |   |-- vimperator.room
        |   |   |   `-- snippets.git
        |   |   `-- config.d
        |   |       |-- zsh.room        -> ../available.d/zsh.room
        |   |       |-- gitconfigs.room -> ../available.d/gitconfigs.room
        |   |       |-- tmux.room       -> ../available.d/tmux.room
        |   |       `-- vim.room        -> ../available.d/vim.room
        |   `-- room
        |       |-- config
        |       `-- rooms
        |           |-- zsh.git  -----------+
        |           |-- gitconfigs.git      |
        |           |-- tmux.git            |
        |           `-- vim.git             |
        |-- [...]                           |
        |-- .zshrc   <----------------------+
        |-- .gitignore.d
        |   `-- zsh
        |-- .mrconfig
        `-- .mrtrust

### available.d

The files you see in $XDG\_CONFIG\_HOME/mr/available.d are myrepos
configuration files that contain the commands to manage (checkout, update
etc.) a single repository. room repo configs end in .room, git configs end
in .git, etc. This is optional and your preference. For example, this is
what a zsh.room with read-only access to my zshrc repo looks likes. I.e. in
this specific example, push can not work as you will be using the author's
repository. This is for demonstration, only. Of course, you are more than
welcome to clone from this repository and fork your own.

    [$XDG_CONFIG_HOME/house/rooms/zsh.git]
    checkout = room clone 'git://github.com/RichiH/zshrc.git' 'zsh'
    update   = room zsh pull
    push     = room zsh push
    status   = room zsh status
    gc       = room zsh gc

    [$HOME/.emacs.d]
    checkout = room clone 'git://github.com/andschwa/emacs.git' '.emacs.d'

### config.d

$XDG\_CONFIG\_HOME/mr/available.d contains *all available* repositories. Only
files/links present in mr/config.d, however, will be used by myrepos. That means
that in this example, only the zsh, gitconfigs, tmux and vim repositories will
be checked out. A simple `mr update` run in $HOME will clone or update those
four repositories listed in config.d.

### ~/.mrconfig

Finally, ~/.mrconfig will tie together all those single files which will allow
you to conveniently run `mr up` etc. to manage all repositories. It looks like
this:

    [DEFAULT]
    include = cat ${XDG_CONFIG_HOME:-$HOME/.config}/mr/config.d/*

### rooms

$XDG\_CONFIG\_HOME/house/rooms is the directory where all git repositories which
are under room's control are located. Since their working trees are configured
to be in $HOME, the files contained in those repositories will be put in $HOME
directly.

Of course, [myrepos][myrepos] will work with this layout if configured according to
this document (see above).

room will check if any file it would want to create exists. If it exists, room
will throw a warning and exit. Move away your old config and try again.
Optionally, merge your local and your global configs afterwards and push with
`room repo_name push`.

## Moving into a New Host

To illustrate further, the following steps could move your desired
configuration to a new host.

1. Clone the myrepos repository (containing available.d, config.d etc.); for
   example: `room clone git://github.com/RichiH/vcsh_mr_template.git mr`
2. Choose your repositories by linking them in config.d (or go with the default
   you may have already configured by adding symlinks to git).
3. Run myrepos to clone the repositories: `cd; mr update`.
4. Done.

Hopefully the above could help explain how this approach saves time by

1. making it easy to manage, clone and update a large number of repositories
   (thanks to myrepos) and
2. making it unnecessary to create symbolic links in $HOME (thanks to room).

If you want to give room a try, follow the instructions below.


# Getting Started

Below, you will find a few different methods for setting up room:

1. The Template Way
2. The Steal-from-Template Way
3. The Manual Way

### The Template Way

#### Prerequisites

Make sure none of the following files and directories exist for your test
(user). If they do, move them away for now:

* `~/.gitignore.d`
* `~/.mrconfig`
* `$XDG\_CONFIG\_HOME/mr/available.d/mr.room`
* `$XDG\_CONFIG\_HOME/mr/available.d/zsh.room`
* `$XDG\_CONFIG\_HOME/mr/config.d/mr.room`
* `$XDG\_CONFIG\_HOME/house/rooms/mr.git/`

All of the files are part of the template repository, the directory is where
the template will be stored.

### Install room

#### Debian

If you are using Debian Squeeze, you will need to enable backports and the
package name for myrepos will be 'mr'.

From Wheezy onwards, you can install both directly:

    apt-get install myrepos room

#### Gentoo

To install room in Gentoo Linux just give the following command as root:

    emerge dev-vcs/room

Note the portage package for myrepos still has the old project name:

    emerge dev-vcs/mr

#### Arch Linux

room is available via this [AUR](https://aur.archlinux.org/packages/house/)
package. Likewise myrepos is available [here](https://aur.archlinux.org/packages/myrepos/).
You may install both using your favorite AUR helper. e.g. with yaourt:

    yaourt -Sya myrepos room

Or you can do it yourself manually using the documentation on installing AUR packages 
[on Arch's wiki](https://wiki.archlinux.org/index.php/Arch_User_Repository#Installing_packages).

If you prefer to use the devel package that installs the git HEAD version it
is available [here](https://aur.archlinux.org/packages/room-git/).

#### Mac OS X

Formulas are available for room as well as git and myrepos through [homebrew](http://brew.sh). The
room formula is set to depend on myrepos, so you only need one install command:

    brew install room

#### From source

To install the latest version from git:

    # choose a location for your checkout
    mkdir -p ~/work/git
    cd ~/work/git
    git clone git://github.com/RichiH/vcsh.git
    cd room
    sudo ln -s room /usr/local/bin               # or add it to your PATH

For myrepos:

    # use checkout location from above
    cd ~/work/git
    git clone git://myrepos.branchable.com/ myrepos
    cd myrepos
    make install

#### Clone the Template

    room clone git://github.com/RichiH/vcsh_mr_template.git mr

#### Enable Your Test Repository

    mv ~/.zsh   ~/zsh.bak
    mv ~/.zshrc ~/zshrc.bak
    cd $XDG_CONFIG_HOME/mr/config.d/
    ln -s ../available.d/zsh.room .  # link, and thereby enable, the zsh repository
    cd
    mr up

#### Set Up Your Own Repositories

Now, it's time to edit the template config and fill it with your own remotes:

    vim $XDG_CONFIG_HOME/mr/available.d/mr.room
    vim $XDG_CONFIG_HOME/mr/available.d/zsh.room

And then create your own stuff:


    room init repo_name
    room repo_name add bar baz quux
    room repo_name remote add origin git://quuux
    room repo_name commit
    room repo_name push

    cp $XDG_CONFIG_HOME/mr/available.d/mr.room $XDG_CONFIG_HOME/mr/available.d/repo_name.room
    vim $XDG_CONFIG_HOME/mr/available.d/repo_name.room # add your own repo

Done!

### The Steal-from-Template Way

You're welcome to clone the example repository:

    room clone git://github.com/RichiH/vcsh_mr_template.git mr
    # make sure 'include = cat /usr/share/mr/room' points to an exiting file
    vim .mrconfig

Look around in the clone. It should be reasonably simple to understand. If not,
poke RichiH or alerque on Libera (#vcs-home) or OFTC (#vcs-home).


### The Manual Way

This is how my old setup procedure looked like. Adapt it to your own style or
copy mine verbatim, either is fine.

    # Create workspace
    mkdir -p ~/work/git
    cd !$

    # Clone room and make it available
    git clone git://github.com/RichiH/vcsh.git room
    sudo ln -s ~/work/git/house/room /usr/bin/local
    hash -r

Grab my myrepos config. see below for details on how I set this up

    room clone ssh://<remote>/mr.git
    cd $XDG_CONFIG_HOME/mr/config.d/
    ln -s ../available.d/* .


[myrepos][myrepos] is used to actually retrieve configs, etc.

    ~ % cat ~/.mrconfig
    [DEFAULT]
    include = cat $XDG_CONFIG_HOME/mr/config.d/*
    ~ % echo $XDG_CONFIG_HOME
    /home/richih/.config
    ~ % ls $XDG_CONFIG_HOME/mr/available.d # random selection of my repos
    git-annex gitk.room git.room ikiwiki mr.room reportbug.room snippets.git wget.room zsh.room
    ~ %
    # then simply ln -s whatever you want on your local machine from
    # $XDG_CONFIG_HOME/mr/available.d to $XDG_CONFIG_HOME/mr/config.d
    ~ % cd
    ~ % mr -j 5 up


# myrepos usage ; will be factored out & rewritten

### Keeping repositories Up-to-Date

This is the beauty of it all. Once you are set up, just run:

    mr up
    mr push

Neat.

### Making Changes

After you have made some changes, for which you would normally use `git add`
and `git commit`, use the room wrapper (like above):

    room repo_name add bar baz quux
    room repo_name commit
    room repo_name push

### Using room without myrepos

room encourages you to use [myrepos][myrepos]. It helps you manage a large number of
repositories by running the necessary room commands for you. You may choose not
to use myrepos, in which case you will have to run those commands manually or by
other means.


To initialize a new repository: `room init zsh`

To clone a repository: `room clone ssh://<remote>/zsh.git`

To interact with a repository, use the regular Git commands, but prepend them
with `room run $repository_name`. For example:

    room zsh status
    room zsh add .zshrc
    room zsh commit

Obviously, without myrepos keeping repositories up-to-date, it will have to be done
manually. Alternatively, you could try something like this:

    for repo in `room list`; do
        room run $repo git pull;
    done


# Contact

There are several ways to get in touch with the author and a small but committed
community around the general idea of version controlling your (digital) life.

* IRC: #vcs-home on irc.oftc.net

* Mailing list: [http://lists.madduck.net/listinfo/vcs-home][vcs-home-list]

* Pull requests or issues on [https://github.com/RichiH/vcsh][room]


[myrepos]: http://myrepos.branchable.com/
[talks]: http://richardhartmann.de/talks/
[room]: https://github.com/RichiH/vcsh
[vcs-home-list]: http://lists.madduck.net/listinfo/vcs-home
