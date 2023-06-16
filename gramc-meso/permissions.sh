#! /bin/bash

# Variables d'environnement à positionner AVANT la construction et l'exécution des conteneurs

. env.sh

if [ -z $GRAMCMESO_URL ]
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
echo "mesonet           root"
echo "100033		www-data"
echo "100999		mysql"

ROOT="mesonet.mesonet"
WWWDATA="100033.100033"
MYSQL="100999.100999"

echo "PERMISSIONS DANS LE REPERTOIRE dans containers/app"
set -x

chown $WWWDATA $GRAMCMESO_ROOT_DIR/containers/app/.env
chmod 400 $GRAMCMESO_ROOT_DIR/containers/app/.env

chown -R $WWWDATA $GRAMCMESO_ROOT_DIR/containers/app/data/
chmod -R o= $GRAMCMESO_ROOT_DIR/containers/app/data/

chown -R $WWWDATA $GRAMCMESO_ROOT_DIR/containers/app/gramc-meso-var/
chmod -R o= $GRAMCMESO_ROOT_DIR/containers/app/gramc-meso-var/

chown -R $ROOT $GRAMCMESO_ROOT_DIR/containers/app/var-log/
chmod -R o= $GRAMCMESO_ROOT_DIR/containers/app/var-log/ 
set +x

echo "PERMISSIONS DANS LE REPERTOIRE dans containers/db"
set -x

chown -R $MYSQL $GRAMCMESO_ROOT_DIR/containers/db/mysql
chown -R $MYSQL $GRAMCMESO_ROOT_DIR/containers/db/reprise

chmod -R o= $GRAMCMESO_ROOT_DIR/containers/db/secrets
chmod -R o= $GRAMCMESO_ROOT_DIR/containers/db/mysql
chmod -R o= $GRAMCMESO_ROOT_DIR/containers/db/reprise

set +x

echo "That's all Folks !"

