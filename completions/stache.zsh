#compdef stache

function __stache_repositories () {
	local -a repos
	repos=( ${(f)"$(_call_program repositories stache list)"} )
	_describe -t repositories 'repository' repos
}

function __stache_not_implemented_yet () {
	_message "Subcommand completion '${1#*-}': not implemented yet"
}

function _stache-clone () {
	__stache_not_implemented_yet "$0" #TODO
}

function _stache-delete () {
	(( CURRENT == 2 )) && __stache_repositories
}

function _stache-enter () {
	(( CURRENT == 2 )) && __stache_repositories
}

function _stache-foreach () {
	_dispatch stache-foreach git
}

function _stache-help () {
	_nothing
}

function _stache-init () {
	_nothing
}

function _stache-list () {
	_nothing
}

function _stache-list-tracked () {
	(( CURRENT == 2 )) && __stache_repositories
}

function _stache-list-untracked () {
	_nothing
}

function _stache-pull () {
	_nothing
}

function _stache-push () {
	_nothing
}

function _stache-rename () {
	case $CURRENT in
		2) __stache_repositories ;;
		3) _message "new repository name" ;;
		*) _nothing ;;
	esac
}

function _stache-run () {
	(( CURRENT == 2 )) && __stache_repositories
	(( CURRENT == 3 )) && _command_names -e
	if (( CURRENT >= 4 )); then
		# see _precommand in zsh
		words=( "${(@)words[3,-1]}" )
		(( CURRENT -= 2 ))
		_normal
	fi
}

function _stache-status () {
	(( CURRENT == 2 )) && __stache_repositories
}

function _stache-upgrade () {
	(( CURRENT == 2 )) && __stache_repositories
}

function _stache-version () {
	_nothing
}

function _stache-which () {
	_files
}

function _stache-write-gitignore () {
	(( CURRENT == 2 )) && __stache_repositories
}

function _stache () {
	local curcontext="${curcontext}" ret=1
	local state stachecommand
	local -a args subcommands

	local STACHE_REPO_D
	: ${STACHE_REPO_D:="${XDG_CONFIG_HOME:-"$HOME/.config"}/stache"}

	subcommands=(
		"add:add a repo (or --all) to stache.repos"
		"clone:clone an existing repository"
		"commit:commit in all repositories"
		"delete:delete an existing repository"
		"enter:enter repository; spawn new <\$SHELL>"
		"foreach:execute for all repos"
		"help:display help"
		"init:initialize an empty repository"
		"list:list all local stache repositories"
		"list-tracked:list all files tracked by stache"
		"list-untracked:list all files not tracked by stache"
		"pull:pull from all stache remotes"
		"push:push to stache remotes"
		"rename:rename a repository"
		"run:run command with <\$GIT_DIR> and <\$GIT_WORK_TREE> set"
		"status:show statuses of all/one stache repositories"
		"upgrade:upgrade repository to currently recommended settings"
		"version:print version information"
		"which:find <substring> in name of any tracked file"
		"config:edit shared git config included by every repo"
		"bootstrap:clone every repo in stache.repos not already present"
		"write-gitignore:write <repo>.stache/.gitignore via git ls-files"
	)

	args=(
		'-c[source <file> prior to other configuration files]:config files:_path_files'
		'-d[enable debug mode]'
		'-v[enable verbose mode]'
		'*:: :->subcommand_or_options_or_repo'
	)

	_arguments -C ${args} && ret=0

	if [[ ${state} == "subcommand_or_options_or_repo" ]]; then
		if (( CURRENT == 1 )); then
			_describe -t subcommands 'stache sub-commands' subcommands && ret=0
			__stache_repositories && ret=0
		else
			stachecommand="${words[1]}"
			if ! (( ${+functions[_stache-$stachecommand]} )); then
				# There is no handler function, so this is probably the name
				# of a repository. Act accordingly.
				# FIXME: this may want to use '_dispatch stache git'
				GIT_DIR=$STACHE_REPO_D/$words[1].stache/$words[1].git _dispatch git git && ret=0
			else
				curcontext="${curcontext%:*:*}:stache-${stachecommand}:"
				_call_function ret _stache-${stachecommand} && (( ret ))
			fi
		fi
	fi
	return ret
}

_stache "$@"
