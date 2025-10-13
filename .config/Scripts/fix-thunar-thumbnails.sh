#!/bin/bash
# Script pour corriger les problèmes de miniatures dans Thunar

# Nettoyer le cache des miniatures
echo "Nettoyage du cache des miniatures..."
rm -rf ~/.cache/thumbnails/*
rm -rf ~/.thumbnails/* 2>/dev/null


