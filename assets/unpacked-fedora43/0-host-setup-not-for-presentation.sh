#!/bin/bash
set -euo pipefail
#set -x
#INCUS_REMOTE=
#INCUS_REMOTE=local:
INCUS_REMOTE=hp-by-sfp:
INCUS_LAUNCH_OPTS=(--storage=zfs)
VM_NAME_ONLY=cvmfs-unpacked-fedora43-scripted
VM_NAME="$INCUS_REMOTE$VM_NAME_ONLY"
incus launch --vm "${INCUS_LAUNCH_OPTS[@]}" images:fedora/43 "$VM_NAME"
echo -n "Waiting for network bringup"
while ! incus list --format json "$VM_NAME" | jq --raw-output .[0].state.network.enp5s0.addresses[0].address | grep -F . >/dev/null; do echo -n .; sleep 1; done; echo
incus exec "$VM_NAME" -- bash -l <<EOF
set -x
set -euo pipefail

dnf install -q -y podman

dnf install -q -y https://cvmrepo.s3.cern.ch/cvmrepo/yum/cvmfs-release-latest.noarch.rpm
dnf install -q -y cvmfs
sed -i /etc/selinux/config -e s/SELINUX=enforcing/SELINUX=permissive/
EOF
# rebooting into restored snapshot after installing cvmfs doesn't work on fedora due to selinux or something
#incus stop "$VM_NAME"
#incus snapshot create "$VM_NAME" vol0-done
#incus start "$VM_NAME"
