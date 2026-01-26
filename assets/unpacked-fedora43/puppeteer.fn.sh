slowly_type() {
	local PANE=$1
	local TEXT="$2"
	while IFS= read -r -n1 character; do
		if [[ "$character" == ';' ]]; then
			# https://github.com/tmux/tmux/issues/4350
			character="\\$character"
		fi
		tmux send-keys  -t "$PANE"   "$character"
		sleep 0.05
	done < <(echo -n "$TEXT")
}

comment() {
	local PANE=$1
	local TEXT=$2
	slowly_type "$PANE" "$TEXT"
	tmux send-keys -t "$PANE" " "
	sleep 1
	tmux send-keys -t "$PANE" C-c
	sleep 1
}

run() {
	local PANE=$1
	local TEXT=$2
	slowly_type "$PANE" "$TEXT"
	sleep 1
	tmux send-keys -t "$PANE" Enter
	sleep 1
}

run_and_wait() {
	local HOST=$1
	local PANE=$2
	local TEXT=$3
	run "$PANE" "$TEXT"
	# Assume the first word is a command and that pgrep will find it
	local COMMAND="${TEXT%% *}" # ${parameter%%word} "Remove matching suffix pattern"
	while incus exec --force-noninteractive "$HOST" -- pgrep --exact "$COMMAND" < /dev/null; do sleep 1; done
	#while incus exec "$HOST" -- pgrep --exact --full "$TEXT"; do sleep 1; echo run_and_WAIT; done
	return 0
}
