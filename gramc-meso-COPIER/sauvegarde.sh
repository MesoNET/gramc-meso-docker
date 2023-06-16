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

FREQUENCE=$1

cd ~/gramc-meso
. env.sh

cd containers/db
[ $FREQUENCE = "j" ] && docker compose exec db mysqldump --password=$(cat secrets/MARIADB_ROOT_PASSWORD) gramc | gzip > sauvegarde/gramc.$(date +%j).sql.gz
[ $FREQUENCE = "h" ] && docker compose exec db mysqldump --password=$(cat secrets/MARIADB_ROOT_PASSWORD) gramc | gzip > sauvegarde/gramc.$(date +%H-%M).sql.gz


