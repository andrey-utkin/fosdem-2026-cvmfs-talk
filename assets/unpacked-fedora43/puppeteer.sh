#!/bin/bash
set -euo pipefail
set -x

# To start, open a terminal window with this command:
# tmux new-session -s cvmfs-demo  asciinema rec publish-demo.asciicast  --command "incus exec hp:cvmfs-ci-archlinux --  podman exec -it upstream-cvmfs-posix-tools-only-fedora_43-with-systemd  bash -l"

SESSION_NAME="cvmfs-demo"
WINDOW="$SESSION_NAME":1
ONLY_PANE="$WINDOW".0
INCUS_VM_NAME="hp:cvmfs-ci-archlinux"

#source "$(dirname "$(readlink -f "$0")")"/puppeteer.fn.sh
source /home/j/work/clients/jump-trading/workcopies/cvmfs-demo/puppeteer.fn.sh

demonstrate() {
	tmux select-pane -t "$ONLY_PANE"
	run "$ONLY_PANE" 'mount | grep my.repo | grep "\<ro\|rw\>"'
	sleep 1
	run "$ONLY_PANE" "cvmfs_server transaction my.repo"
	while incus exec "$INCUS_VM_NAME" -- pgrep --exact cvmfs_server; do sleep 1; done
	sleep 1
	run "$ONLY_PANE" 'mount | grep my.repo | grep "\<ro\|rw\>"'
	sleep 1
	run "$ONLY_PANE" "echo hello > /cvmfs/my.repo/hello"
	run "$ONLY_PANE" "ls /cvmfs/my.repo"
	run "$ONLY_PANE" "ls /var/spool/cvmfs/my.repo/rdonly"
	run "$ONLY_PANE" "ls /var/spool/cvmfs/my.repo/scratch/current"
	sleep 1
	run "$ONLY_PANE" "cvmfs_server publish my.repo"
	while incus exec "$INCUS_VM_NAME" -- pgrep --exact cvmfs_server; do sleep 1; done

	run "$ONLY_PANE" "ls /cvmfs/my.repo"
	run "$ONLY_PANE" "ls /var/spool/cvmfs/my.repo/rdonly"
	run "$ONLY_PANE" "ls /var/spool/cvmfs/my.repo/scratch/current"
	killall asciinema
}

demonstrate
tmux detach-client -s "$SESSION_NAME"
