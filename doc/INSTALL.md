# Distro Packages

Many distributions have packages ready to go.
If yours doesn’t, you can install [from source](#installing-from-source).
Houseroom can also be deployed as a [standalone script](#standalone-script).
If you package Houseroom for a distro please let us know.

## Arch Linux

```
$ pacman -S room
```

## CentOS / Fedora / RedHat

```console
$ yum install room
```

## Debian / Deepin / Kali Linux / Parrot / PureOS / Raspbian / Trisquel / Ubuntu

```console
$ apt install room
```

## Gentoo / Funtoo / LiGurOS

```console
$ emerge --ask dev-vcs/room
```

## GNU Guix

```console
$ guix install room
```

## Homebrew (macOS) / Linuxbrew

```console
$ brew install room
```

## KISS Linux

```console
$ kiss install room
```

## MacPorts (macOS)

```console
$ port install room
```

## NIX

```console
$ nix-env -i room
```

## openSUSE

```console
$ zypper install room
```

## Pardus

```console
$ pisi install room
```

## Termux

```console
$ pkg install room
```

# Installing from Source

First you’ll want a copy of the source code.
The easiest to use place to get this is the [latest release](https://github.com/stevensko/houseroom/releases/latest) posted on GitHub.
The souree distribution will have a name such as `room-2.0.0.tar.zst`.
Note under each release GitHub also show two “Source code” links that will download a snapshot of the repository; this is **not** the file you want (unless you want to jump through extra hoops).
The official source release packages with the release version in the file names are the ones you want.

Alternatively you may `git clone` the source repository.
Note than some extra tooling will be required over using the regular source releases.
Building from a clone will require a system with GNU Autotools installed; something not needed if using a source package.
Also source releases have prebuilt man pages; to (optionally) build them from a Git clone you will need `ronn`.
Finally building from Git clones will check for extra dependencies needed for testing, although tests can be disabled.
If starting from a clone, run `./bootstrap.sh` once before doing anything below.

Once you have the source, it’s time to let it get aquainted with your system:

```console
$ ./configure
```

This command has *lots* of possible options, but the defaults should suite most use cases.
See `./configure --help` for details if you have special needs.

Once configured, you can build:

```console
$ make
```

Lastly you’ll want to install it somewhere.

```console
$ make install
```

If you need elevated system permissions you may need to use `sudo make install` for this step.
If you don’t have such permissions and wish to install to your home directory, something like this might work:

```console
$ ./configure --prefix=/
$ make DESTDIR="$HOME" install-exec
```

This will install to `~/bin/room`; add `~/bin` to your path to use.

# Standalone Script

A special variant of Houseroom can be deployed as a single POSIX shell script with no configure/build step.
Deploying it this way leaves you without any man page or shell completion functions (or possibly with mismatched resources installed by your package manager for a different room version).
This variant is also dependent or your `$PATH` to have proper versions of dependencies such as `git`.
If your user space has different tools by default than your system beware!

The standalone variant can be downloaded from any recent entry in [releases](https://github.com/stevensko/houseroom/releases).

This method is suited for installation to a user space where you don’t have control over the system packages, e.g.:

```console
$ mkdir -p ~/bin
$ curl -fsLS https://github.com/stevensko/houseroom/releases/latest/download/room-standalone.sh -o ~/bin/room
$ chmod u+x ~/bin/room
```

It could also be used to directly bootstrap a dotfiles repository with something like this:

```console
$ sh <(curl -fsLS https://github.com/stevensko/houseroom/releases/latest/download/room-standalone.sh) clone <path_to_your_dotfiles_repo> dotfiles
```

While we are enabling cURL-based workflows on purpose, we still encourage you to avoid them where reasonably possible. If you do use it, please consider using a tagged version that you’ve tested to work for you instead of the “latest” keyword. Note: the URL for tagged releases is in a different order than when using the “latest” keyword, substitute a tag name by changing `latest/download` to `download/v2.0.0`.

[1]: http://rtomayko.github.io/ronn/
