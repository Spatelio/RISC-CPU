#!/bin/bash
# Delegate to the sim directory flow (single integrated CPU testbench).
exec "$(dirname "$0")/sim/run_sims.sh" "$@"
