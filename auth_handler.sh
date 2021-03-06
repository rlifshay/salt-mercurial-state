#!/bin/sh
[ "$1" = "hg" ] || exit 0

# The permissions file has one line per user, and each line has three fields:
# 
# user:  The username. This is just for reference purposes and is not actually
#        used. If the username is a single '*', then the repository list on
#        this line applies to all users in the lines below the current line,
#        and the key field is ignored if it exists.
# 
# repos: A space separated list of repositories. You can use shell globbing in
#        repository names to match more than one at once.
# 
# key:   The SSH public key for this user. If the user is '*', then this field
#        is ignored if it is present.
# 
# Each line is a list of fields separated by colons in the format:
# 
#        user:repos:key
# 
# Blank lines and lines starting with a '#' are ignored.
# 

SSH_HANDLER="/usr/local/lib/hg/ssh_connection_handler.py"
ESCAPE_ARGS=1
PERMS_FILE="/etc/mercurial/server-perms.conf"

[ -r "$PERMS_FILE" ] || exit 0

trim () { echo "$@" | grep -o '[^[:space:]]\(.*[^[:space:]]\)\?'; }
escape () { for i in "$@"; do printf "'%s' " "$(printf %s "$i" | sed "s/'/'\\\''/g")"; done | head -c -1; }
splitstr () { local -; set -f; set -- $@; escape "$@"; }

# die gracefully when we are killed with SIGPIPE once the key is found
trap "exit 0" PIPE

global_perms=""
while IFS=: read user perms key; do
	user=$(trim "$user")
	[ -n "$user" ] || continue
	[ "$(printf '%c' "$user")" != "#" ] || continue
	if [ "$user" = "*" ]; then
		if [ -z "$global_perms" ]; then
			global_perms=$(trim "$perms")
		else
			global_perms="$global_perms $(trim "$perms")"
		fi
	else
		perms=$(trim "$perms")
		if [ -n "$global_perms" ]; then
			perms="$global_perms $perms"
		fi
		if [ $ESCAPE_ARGS -gt 0 ]; then
			perms=$(splitstr "$perms")
		fi
		printf 'command="cd /srv/hg && %s %s" %s -- %s\n' "$SSH_HANDLER" "$perms" "$(trim "$key")" "$user"
	fi
done < "$PERMS_FILE"
