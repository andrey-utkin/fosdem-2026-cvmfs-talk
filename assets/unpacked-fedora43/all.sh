#!/bin/bash
set -euo pipefail
set -x

INCUS_REMOTE=hp-by-sfp:
VM_NAME="${INCUS_REMOTE}"cvmfs-unpacked-fedora43-scripted

source "$(dirname "$(readlink -f "$0")")"/puppeteer.fn.sh
SESSION_NAME="cvmfs-demo"
WINDOW="$SESSION_NAME":1
ONLY_PANE="$WINDOW".0
### # There must be already a terminal running this session
### tmux list-sessions | grep -q ^"$SESSION_NAME":

#if incus info "$VM_NAME" &>/dev/null; then
#	#incus snapshot restore "$VM_NAME" vol0-done
#	#while ! incus list --format json "$VM_NAME" | jq --raw-output .[0].state.network.enp5s0.addresses[0].address | grep -F . >/dev/null; do echo -n .; sleep 1; done; echo
#	incus rm -f "$VM_NAME"
#	./0-host-setup-not-for-presentation.sh
#else
#	./0-host-setup-not-for-presentation.sh
#fi


### run "$ONLY_PANE" "asciinema record --overwrite rec-1-lazy-pulling.asciicast --command 'incus exec $VM_NAME -- bash -l'"

tmux kill-session -t cvmfs-demo || true
xfce4-terminal --minimize --command "tmux new-session -s cvmfs-demo -c '$PWD'  asciinema record --overwrite rec-1-lazy-pulling.asciicast --command 'incus exec $VM_NAME -- bash -l'" & TERMINAL_PID=$!
#xfce4-terminal --execute bash -lc "tmux new-session -s cvmfs-demo -c "$PWD"  asciinema record --overwrite rec-1-lazy-pulling.asciicast --command 'incus exec $VM_NAME -- bash -l'" & TERMINAL_PID=$!
while ! tmux list-sessions | grep -q ^cvmfs-demo: ; do sleep 1; done
./1-lazy-pulling.sh
tmux kill-session -t cvmfs-demo || true
#kill "$TERMINAL_PID"

### run "$ONLY_PANE" "asciinema record --overwrite rec-2-podman-run-regular.asciicast --command 'incus exec $VM_NAME -- bash -l'"
tmux kill-session -t cvmfs-demo || true
xfce4-terminal --minimize --command "tmux new-session -s cvmfs-demo -c '$PWD'  asciinema record --overwrite rec-2-podman-run-regular.asciicast --command 'incus exec $VM_NAME -- bash -l'" & TERMINAL_PID=$!
#xfce4-terminal --execute bash -lc "tmux new-session -s cvmfs-demo -c "$PWD"  asciinema record --overwrite rec-2-podman-run-regular.asciicast --command 'incus exec $VM_NAME -- bash -l'" & TERMINAL_PID=$!
while ! tmux list-sessions | grep -q ^cvmfs-demo: ; do sleep 1; done
./2-podman-run-regular.sh
tmux kill-session -t cvmfs-demo || true
#kill "$TERMINAL_PID"
