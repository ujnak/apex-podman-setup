#!/bin/sh

name=$1

podman stop ${name}-ords
podman rm   ${name}-ords
podman stop ${name}-db
podman rm   ${name}-db
podman volume rm ${name}-ords_config
podman volume rm ${name}-oradata
