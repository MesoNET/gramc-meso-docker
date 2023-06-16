#! /bin/bash

# Cet umask assure que les permissions des fichiers créés par apache soient rw-rw---- 
#echo "umask g=rwx,o=" >> /etc/apache2/envvars 

# Création de quelques sous-répertoires ou fichiers de /var/log, qui est persistent 
mkdir -p /var/log/apache2 

# Création des sous-répertoires de /app/gramc-meso/var
cd /app/gramc-meso/var
for d in log cache sessions
do
   [ \! -d ${d} ] && mkdir ${d} && chmod u+w ${d} && chown www-data:www-data ${d}
done
	
# Création des sous-répertoires de /app/gramc-meso/data, qui est persistent
cd /app/gramc-meso/data
for d in modeles rapports fiches figures
do
   [ \! -d ${d} ] && mkdir ${d} && chmod u+w ${d} && chown www-data:www-data ${d}
done

# Droits corrects sur .env
cd /app/gramc-meso && chmod 400 .env && chown www-data.www-data .env

# Droits corrects sur le fichier de conf d'apache
cd /etc/apache2/sites-available && chmod 440 gramc-meso.conf && chown root:root gramc-meso.conf

# Démarrage d'apache en mode "Pas de démon"
source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND

