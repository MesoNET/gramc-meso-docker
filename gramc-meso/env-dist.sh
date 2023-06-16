# Variables d'environnement à positionner AVANT la construction et l'exécution des conteneurs

export GRAMCMESO_ROOT_DIR=
export GRAMCMESO_URL=

# true ou false
export LETSENCRYPT_TEST=

erreur=0

[ -z $GRAMCMESO_ROOT_DIR ] && (( erreur += 1 ))
[ -z $GRAMCMESO_URL ] && (( erreur += 1 ))

for f in ${GRAMCMESO_ROOT_DIR}/containers/db/secrets/MARIADB*
do
	[ \! -s $f ] && echo "ATTENTION - $f doit être configuré" && (( erreur += 1 ))
done


