#!/bin/bash

# Installation des tâches cron pour le rétroéclairage automatique
SCRIPT_PATH="$HOME/.config/Scripts/auto-backlight.sh"

echo "🕐 Installation des tâches cron pour rétroéclairage automatique..."

# Créer le crontab
cat << EOF | crontab -
# Rétroéclairage automatique - Activation 19h
0 19 * * * $SCRIPT_PATH schedule >/dev/null 2>&1

# Rétroéclairage automatique - Extinction 8h
0 8 * * * $SCRIPT_PATH schedule >/dev/null 2>&1

# Vérification toutes les heures (sécurité)
0 * * * * $SCRIPT_PATH schedule >/dev/null 2>&1
EOF

echo "✅ Tâches cron installées !"
echo ""
echo "📋 Planification active :"
echo "  • 19h00 : Activation automatique"
echo "  • 08h00 : Extinction automatique" 
echo "  • Chaque heure : Vérification"
echo ""
echo "🔍 Vérification :"
crontab -l
echo ""
echo "🧪 Test immédiat :"
$SCRIPT_PATH schedule
$SCRIPT_PATH status
