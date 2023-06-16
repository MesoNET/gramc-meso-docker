#!/bin/bash
#
# Script de construction, arrêt ou redémarrage des conteneurs
#
# Usage: path/to/directory/build.sh
#        path/to/directory/run.sh
#        path/to/directory/stop.sh
#
# Ce script arrête le conteneur si besoin, et le redémarre aussitôt
#

# set -v

# Calcul du repertoire dans lequel run.sh est depose - ca marche meme si on part d'un lien symbolique
fullpath=$(readlink --no-newline --canonicalize-existing $0) 
if [[ -z $fullpath ]]; then echo "ERREUR - run.sh pointe sur le vide !"; exit 1; fi
DIR=$(dirname "$fullpath")

(
   cd $DIR

   # Variables d'environnement 
   if [[ -f env.sh ]]; then source env.sh; else echo "ERREUR - ${DIR}/env.sh n'existe pas."; exit 1; fi

   # Construction des conteneurs
   [ $(basename $0) = 'build.sh' ] && docker compose build $* && exit 0;

   # Arrêt et démarrage éventuel des conteneurs
   docker compose down
   [ $(basename $0) = 'run.sh' ] &&  docker compose up -d
)

