#!/bin/bash
set -euo pipefail
set -x

# To start, open a terminal window with this command:
# tmux new-session -s cvmfs-demo  asciinema rec unpacked-vol1.asciicast  --command "incus exec hp-by-sfp:cvmfs-unpacked-fedora43-scripted -- bash -l"

SESSION_NAME="cvmfs-demo"
WINDOW="$SESSION_NAME":1
ONLY_PANE="$WINDOW".0
HOST="hp-by-sfp:cvmfs-unpacked-fedora43-scripted"

source "$(dirname "$(readlink -f "$0")")"/puppeteer.fn.sh

demonstrate() {
	tmux select-pane -t "$ONLY_PANE"

	run "$ONLY_PANE" "time  podman run --rm docker.io/rootproject/root:6.38.00-ubuntu25.10  bash -c '. /opt/root/bin/thisroot.sh && python -c \"import ROOT; print(ROOT)\"'"
	while incus exec "$HOST" -- pgrep --full 'podman run'; do sleep 1; done
	sleep 1
	#killall asciinema
}

demonstrate
tmux detach-client -s "$SESSION_NAME"
