# Usage: asciinema record --overwrite publish-demo.v2.asciicast --command ./publish-demo.sh
incus exec hp:cvmfs-ci-archlinux --  podman exec -it upstream-cvmfs-posix-tools-only-fedora_43-with-systemd  bash -l <<-EOF
set -euo pipefail
set -x
mount | grep my.repo
cvmfs_server transaction my.repo
mount | grep my.repo
ls /cvmfs/my.repo
echo hello > /cvmfs/my.repo/hello
ls /cvmfs/my.repo
ls /var/spool/cvmfs/my.repo/rdonly
ls /var/spool/cvmfs/my.repo/scratch/current
cvmfs_server publish my.repo
ls /cvmfs/my.repo
ls /var/spool/cvmfs/my.repo/rdonly
ls /var/spool/cvmfs/my.repo/scratch/current
EOF
