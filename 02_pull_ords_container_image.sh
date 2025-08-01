#!/bin/sh
# ############################################################################
# pull ords container image
# ############################################################################
# 1st argument is the version of the container image

# pull container image
podman pull container-registry.oracle.com/database/ords:${1:-"latest"}
if [ $? -ne 0 ]; then
    echo failed to pull the container image, exit.
    exit 1
fi
