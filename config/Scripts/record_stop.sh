#!/bin/bash

if pkill -INT wf-recorder; then
  notify-send "Enregistrement arrêté"
else
  notify-send "Aucun enregistrement en cours"
fi
