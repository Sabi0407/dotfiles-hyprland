#!/bin/bash
# Créer et ouvrir une note rapide avec Obsidian

NOTE_DIR="$HOME/Documents/Notes/Quick"
NOTE_DATE=$(date +%Y%m%d_%H%M%S)
NOTE_FILE="$NOTE_DIR/note_$NOTE_DATE.md"

mkdir -p "$NOTE_DIR"

# Créer la note avec template
cat > "$NOTE_FILE" << EONOTE
# Note rapide - $(date)

## Description
Note prise rapidement

## Contenu



## Tags
#quick #$(date +%Y%m%d)

---
*Créée le $(date)*
EONOTE

# Ouvrir avec Obsidian
obsidian "$NOTE_FILE"
