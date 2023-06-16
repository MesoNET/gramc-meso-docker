#! /bin/bash
#
# Contruit le fichier .env à partir de l'environnement ../env.sh et à partir du fichier env.docker
# A UTILISER AVEC LE docker compose build !
#
cat env.docker | while read a; do eval echo  $a; done | grep "\S" > .env
APP_SECRET=$(php <<< '<?php echo bin2hex(random_bytes(40));')
echo "APP_SECRET=$APP_SECRET" >> .env

