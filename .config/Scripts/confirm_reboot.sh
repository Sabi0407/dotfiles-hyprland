#!/bin/bash
exec "$(dirname "$0")/confirm-action.sh" reboot "$@"
