#!/bin/bash

# NahamSec Quick One-Liner Recon - con creacion de carpetas y descarga wordlists

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

ensure_dirs(){
  mkdir -p subdomains permutations resolved ports httpx content wordlists
}

download_wordlists(){
  mkdir -p wordlists
  cd wordlists || exit
  if [ ! -f "subdomains-top1million-5000.txt" ]; then
      log "Descargando wordlist de subdominios..."
      curl -s -O https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt
  fi
  if [ ! -f "resolvers.txt" ]; then
      log "Descargando resolvers..."
      curl -s -O https://raw.githubusercontent.com/projectdiscovery/public-resolvers/master/resolvers.txt
  fi
  cd ..
}

if [ $# -eq 0 ]; then
  echo "Uso: $0 <dominio>"
  exit 1
fi

DOMAIN=$1

log "Ejecutando quick oneliner para $DOMAIN"

ensure_dirs
download_wordlists

subfinder -d "$DOMAIN" -all -silent | alterx -silent | dnsx -silent | httpx -silent | katana -jc -silent

log "Quick oneliner completado"
