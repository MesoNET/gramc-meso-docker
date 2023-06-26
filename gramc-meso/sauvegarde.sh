#! /bin/bash

# Sauvegarde la base de données dans containers/db/sauvegarde
# A faire tourner quotidiennement (ou plus) dans un crontab
#
#
# Une fois par jour pour les sauvegardes:
#          ./sauvegarde j 
#
# Une fois par heure pour récupérer la base en cas de bug très méchant:
#          ./sauvegarde h
#

# Calcul du repertoire dans lequel le script est depose - ca marche meme si on part d'un lien symbolique
fullpath=$(readlink --no-newline --canonicalize-existing $0) 
if [[ -z $fullpath ]]; then echo "ERREUR - on pointe sur le vide !"; exit 1; fi
DIR=$(dirname "$fullpath")

(

cd $DIR 
. env.sh

FREQUENCE=$1
if [[ -z $FREQUENCE ]]; then echo "Usage: $0 [jh]"; exit 1; fi

cd containers/db
mkdir -p sauvegarde
[ $FREQUENCE = "j" ] && docker compose exec db mysqldump --password=$(cat secrets/MARIADB_ROOT_PASSWORD) gramc | gzip > sauvegarde/gramc.$(date +%j).sql.gz && exit 0
[ $FREQUENCE = "h" ] && docker compose exec db mysqldump --password=$(cat secrets/MARIADB_ROOT_PASSWORD) gramc | gzip > sauvegarde/gramc.$(date +%H-%M).sql.gz && exit 0
echo "ni j ni h je ne fais rien !"

)

