# Variables d'environnement à positionner AVANT la construction et l'exécution des conteneurs

export PROXY_ROOT_DIR=~/proxy/

# Adresse connue de letsencrypt
# Si un certificat n'est pas correctement renouvelé en temps utile letscencrypt enverra plusieurs mails à cette adresse
export DEFAULT_EMAIL=

erreur=0

[ -z $PROXY_ROOT_DIR ] && (( erreur += 1 ))

