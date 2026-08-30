#compdef room

function __room_repositories () {
	local -a repos
	repos=( ${(f)"$(_call_program repositories room list)"} )
	_describe -t repositories 'repository' repos
}

function __room_not_implemented_yet () {
	_message "Subcommand completion '${1#*-}': not implemented yet"
}

function _room-clone () {
	__room_not_implemented_yet "$0" #TODO
}

function _room-delete () {
	(( CURRENT == 2 )) && __room_repositories
}

function _room-enter () {
	(( CURRENT == 2 )) && __room_repositories
}

function _room-foreach () {
	_dispatch room-foreach git
}

function _room-help () {
	_nothing
}

function _room-init () {
	_nothing
}

function _room-list () {
	_nothing
}

function _room-list-tracked () {
	(( CURRENT == 2 )) && __room_repositories
}

function _room-list-untracked () {
	_nothing
}

function _room-pull () {
	_nothing
}

function _room-push () {
	_nothing
}

function _room-rename () {
	case $CURRENT in
		2) __room_repositories ;;
		3) _message "new repository name" ;;
		*) _nothing ;;
	esac
}

function _room-run () {
	(( CURRENT == 2 )) && __room_repositories
	(( CURRENT == 3 )) && _command_names -e
	if (( CURRENT >= 4 )); then
		# see _precommand in zsh
		words=( "${(@)words[3,-1]}" )
		(( CURRENT -= 2 ))
		_normal
	fi
}

function _room-status () {
	(( CURRENT == 2 )) && __room_repositories
}

function _room-upgrade () {
	(( CURRENT == 2 )) && __room_repositories
}

function _room-version () {
	_nothing
}

function _room-which () {
	_files
}

function _room-write-gitignore () {
	(( CURRENT == 2 )) && __room_repositories
}

function _room () {
	local curcontext="${curcontext}" ret=1
	local state roomcommand
	local -a args subcommands

	local HOMEROOMS_REPO_D
	: ${HOMEROOMS_REPO_D:="${XDG_CONFIG_HOME:-"$HOME/.config"}/homerooms"}

	subcommands=(
		"clone:clone an existing repository"
		"commit:commit in all repositories"
		"delete:delete an existing repository"
		"enter:enter repository; spawn new <\$SHELL>"
		"foreach:execute for all repos"
		"help:display help"
		"init:initialize an empty repository"
		"list:list all local room repositories"
		"list-tracked:list all files tracked by room"
		"list-untracked:list all files not tracked by room"
		"pull:pull from all room remotes"
		"push:push to room remotes"
		"rename:rename a repository"
		"run:run command with <\$GIT_DIR> and <\$GIT_WORK_TREE> set"
		"status:show statuses of all/one room repositories"
		"upgrade:upgrade repository to currently recommended settings"
		"version:print version information"
		"which:find <substring> in name of any tracked file"
		"write-gitignore:write .gitignore.d/<repo> via git ls-files"
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
			_describe -t subcommands 'room sub-commands' subcommands && ret=0
			__room_repositories && ret=0
		else
			roomcommand="${words[1]}"
			if ! (( ${+functions[_room-$roomcommand]} )); then
				# There is no handler function, so this is probably the name
				# of a repository. Act accordingly.
				# FIXME: this may want to use '_dispatch room git'
				GIT_DIR=$HOMEROOMS_REPO_D/$words[1].git _dispatch git git && ret=0
			else
				curcontext="${curcontext%:*:*}:room-${roomcommand}:"
				_call_function ret _room-${roomcommand} && (( ret ))
			fi
		fi
	fi
	return ret
}

_room "$@"
