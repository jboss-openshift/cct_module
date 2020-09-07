#!/bin/bash
set -euo pipefail

for mgr in yum dnf microdnf; do
    if test -x "/usr/bin/$mgr"; then
        mgr="/usr/bin/$mgr"
        break
    fi
done
if ! test -x "$mgr"; then
    echo "cannot find a package manager" >&2
    exit 1
fi

"$mgr" update -y
