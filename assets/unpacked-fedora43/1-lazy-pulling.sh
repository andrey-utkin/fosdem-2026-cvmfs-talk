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
	run "$ONLY_PANE" 'cvmfs_config setup'
	sleep 1
	run "$ONLY_PANE" 'systemctl enable --now autofs'
	sleep 1
	run "$ONLY_PANE" 'echo CVMFS_HTTP_PROXY=DIRECT > /etc/cvmfs/default.local'
	sleep 1
	run "$ONLY_PANE" 'mkdir /tmp/root'
	sleep 1

	run "$ONLY_PANE" 'ls /cvmfs/unpacked.cern.ch'
	sleep 1
	while incus exec "$HOST" -- pgrep --exact ls; do sleep 1; done

	tmux send-keys -t "$ONLY_PANE" Up
	sleep 1
	run "$ONLY_PANE" '/registry.hub.docker.com/rootproject'
	sleep 1

	# slowly_type "$ONLY_PANE" 'time podman run --rm --root /tmp/root --rootfs '
	# tmux send-keys -t "$ONLY_PANE" '/cvmfs/unpacked.cern.ch/registry.hub.docker.com/rootproject/root:6.38.00-ubuntu25.10:O '
	# run "$ONLY_PANE" "bash -c '. /opt/root/bin/thisroot.sh && python -c \"import ROOT; print(ROOT)\"'"

	run "$ONLY_PANE" "time  podman run --rm --root /tmp/root --rootfs /cvmfs/unpacked.cern.ch/registry.hub.docker.com/rootproject/root:6.38.00-ubuntu25.10:O  bash -c '. /opt/root/bin/thisroot.sh && python -c \"import ROOT; print(ROOT)\"'"
	while incus exec "$HOST" -- pgrep --full 'podman run'; do sleep 1; done
	sleep 1

	run "$ONLY_PANE" 'du -sh /var/lib/cvmfs/shared'
	sleep 1
	#killall asciinema
}

demonstrate
tmux detach-client -s "$SESSION_NAME"
