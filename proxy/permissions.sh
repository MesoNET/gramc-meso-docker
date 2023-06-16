#! /bin/bash

# Variables d'environnement à positionner AVANT la construction et l'exécution des conteneurs

. env.sh

if [ -z $PROXY_ROOT_DIR ]
then
		echo "PAS ENCORE CONFIGURE"
			exit 1
fi

if [ ! $(id -u) = 0 ]
then
		echo "VOUS DEVEZ ETRE ROOT"
			exit 1
fi

echo "UTILISATEURS UTILES:"
echo "==================="
echo "SUR LE HOST	DANS LES CONTENEURS"
echo "___________	___________________"
echo "mesonet		root"
echo "100033		www-data"
echo "100999		mysql"

ROOT="mesonet.mesonet"
WWWDATA="100033.100033"
MYSQL="100999.100999"

echo "PERMISSIONS DANS LE REPERTOIRE dans containers/nginx"
set -x

chown -R $ROOT $PROXY_ROOT_DIR/containers/nginx/html
chmod -R u=rwX,go=rX $PROXY_ROOT_DIR/containers/nginx/html
set +x

echo "That's all Folks !"

