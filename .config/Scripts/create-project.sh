#!/bin/bash
# Script de création de projets pour Thunar

PROJECT_DIR="$1"
PROJECT_NAME=$(basename "$PROJECT_DIR")

if [ -z "$PROJECT_DIR" ]; then
    echo "❌ Aucun dossier spécifié"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Le dossier $PROJECT_DIR n'existe pas"
    exit 1
fi

echo "🚀 Création d'un nouveau projet dans : $PROJECT_DIR"

# Fonction pour créer un fichier avec du contenu par défaut
create_file() {
    local file="$1"
    local content="$2"

    if [ ! -f "$file" ]; then
        echo "$content" > "$file"
        echo "   ✅ Créé : $file"
    else
        echo "   ⚠️ Existe déjà : $file"
    fi
}

# Créer la structure de base du projet
echo "📁 Création de la structure..."

# README.md
create_file "$PROJECT_DIR/README.md" "# $PROJECT_NAME

## Description
Description du projet

## Installation
Instructions d'installation

## Utilisation
Guide d'utilisation

## Auteur
Votre nom"

# .gitignore (pour les projets de développement)
create_file "$PROJECT_DIR/.gitignore" "# Système
.DS_Store
Thumbs.db

# Éditeurs
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
logs/

# Environnement virtuel Python
venv/
env/
__pycache__/

# Node.js
node_modules/
npm-debug.log*

# Archives
*.zip
*.tar.gz
*.rar"

# Makefile (pour les projets C/C++)
create_file "$PROJECT_DIR/Makefile" "# Makefile basique
CC = gcc
CFLAGS = -Wall -Wextra -O2

.PHONY: all clean

all: programme

programme: main.c
	\$(CC) \$(CFLAGS) -o \$@ \$<

clean:
	rm -f programme *.o"

# main.c (exemple de fichier C)
create_file "$PROJECT_DIR/main.c" "#include <stdio.h>

int main() {
    printf(\"Hello, World!\\n\");
    return 0;
}"

# package.json (pour les projets Node.js)
create_file "$PROJECT_DIR/package.json" "{
  \"name\": \"$PROJECT_NAME\",
  \"version\": \"1.0.0\",
  \"description\": \"Description du projet\",
  \"main\": \"index.js\",
  \"scripts\": {
    \"start\": \"node index.js\",
    \"dev\": \"nodemon index.js\"
  },
  \"dependencies\": {},
  \"devDependencies\": {}
}"

# index.js (exemple Node.js)
create_file "$PROJECT_DIR/index.js" "const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World\\n');
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(\`Serveur démarré sur le port \${PORT}\`);
});"

# Créer les dossiers de base
echo "📂 Création des dossiers..."
mkdir -p "$PROJECT_DIR/src"
mkdir -p "$PROJECT_DIR/docs"
mkdir -p "$PROJECT_DIR/tests"
mkdir -p "$PROJECT_DIR/assets"

echo "✅ Projet créé avec succès !"
echo ""
echo "📋 Structure créée :"
echo "   📄 README.md - Documentation"
echo "   📄 .gitignore - Fichiers à ignorer"
echo "   📄 Makefile - Compilation (C/C++)"
echo "   📄 main.c - Exemple C"
echo "   📄 package.json - Configuration Node.js"
echo "   📄 index.js - Exemple Node.js"
echo "   📁 src/ - Code source"
echo "   📁 docs/ - Documentation"
echo "   📁 tests/ - Tests"
echo "   📁 assets/ - Ressources"

echo ""
echo "💡 Prochaines étapes :"
echo "   1. Éditer README.md avec votre description"
echo "   2. Personnaliser les fichiers selon votre projet"
echo "   3. Commencer le développement dans src/"
