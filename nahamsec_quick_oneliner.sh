#!/bin/bash

# NahamSec Quick One-Liner Recon
# Ejecuta los comandos exactos del minuto 16 del video

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
    echo "Uso: $0 <dominio>"
    echo "Ejemplo: $0 example.com"
    exit 1
fi

echo "[+] Ejecutando one-liner NahamSec para: $DOMAIN"
echo "[+] Comando: subfinder -d $DOMAIN -all -silent | alterx -silent | dnsx -silent | httpx -silent | katana -jc -silent"
echo ""

# El one-liner exacto mencionado en el video (minuto 16)
subfinder -d "$DOMAIN" -all -silent | alterx -silent | dnsx -silent | httpx -silent | katana -jc -silent

echo ""
echo "[+] One-liner completado!"
