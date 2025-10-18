#!/bin/bash

# Script de démarrage : délègue la restauration au gestionnaire central
exec "$HOME/.config/Scripts/wallpaper-manager.sh" restore "$@"
