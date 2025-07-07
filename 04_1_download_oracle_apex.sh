#!/bin/sh
# ############################################################################
# Donwload and expand the latest APEX release archive.
# ############################################################################
#
# Usage: download_oracle_apex.sh
#
# Change History:
# 2025/07/05: Separated from config_apex.sh
# 
# skip if directory apex exists.
if [ ! -d ./apex ]; then
  rm -rf apex META-INF
  curl -OL https://download.oracle.com/otn_software/apex/apex-latest.zip
  unzip apex-latest.zip > /dev/null
fi
