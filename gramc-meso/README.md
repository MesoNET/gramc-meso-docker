
# INSTALLATION dans des conteneurs docker

**Note** - Cette documentation est validée pour un host Debian 11 Bullseye

**Note -** Pour installer plusieurs instances de `gramc-meso`, il suffit de copier le *répertoire* `gramc-meso`. Par exemple pour installer `gramc-meso-1`:

```
cp -a gramc-meso gramc-meso-toto
```

Puis suivre la documentation ci-dessous

Configuration de gramc-meso
-----
1. Copiez le fichier env-dist.sh:
```
cp -a env-dist.sh env.sh
```
2. Éditez le fichier `env.sh` (nom, url, ...)
3. De même, copiez et éditez les 4 fichiers se trouvant dans le répertoire `containers/db/secrets` (1 mot par fichier) (mots de passe, BD, etc)
4. Copiez et éditez le `containers/app/env-dist`, bien sûr en cohérence avec les fichiers ci-dessus:
```
cp -a env-dist .env
```
5. Copiez et éditez le fichier `containers/app/gramc-meso-dist.conf` (essentiellement Servername et configuration iam)
6. Copiez et éditez le fichier `containers/app/parameters.yaml.dist` 
7. Exécutez le script `permissions.sh` *en tant que root*:
```
sudo ./permissions.sh
```
-----

Construction des conteneurs:
-----

- Construisez les conteneurs par:

```
./build.sh
```
- Ou par:
```
./build.sh --no-cache
```

Démarrage ou arrêt des conteneurs:
-----

- Déposez une copie de la base de données dans `containers/db/reprise`
- Déposez les données (éventuellement https://github.com/MesoNET/gramc-meso/blob/master/data-dist.tar.gz) dans `containers/app/data`

```
./run.sh
./stop.sh
```

Recharger la base de données:
-----

- Arrêtez l'application par le script `stop.sh`
- Déposez le fichier .sql.gz issu de la sauvegarde dans le répertoire `containers/db/reprise`
- *En root*, supprimez les données mysql et changez l'utilisateur du fichier de reprise:
```
cd containers/db
rm -r mysql/*
chown 100999.100999 reprise/gramc.xxx.sql.gz
```
- Redémarrez l'application par le script `run.sh`
- Vérifiez que tout se passe bien par:
```
docker compose logs -f
```

Entrer dans un conteneur pour déboguage:
-----

Utiliser la commande:

```
docker compose exec
```

**ATTENTION** il y a un problème avec le conteneur app:

```
mesonet@portailmesonet:~/gramc-meso/containers/app$ docker compose exec -u www-data app bash
open /home/mesonet/gramc-meso/containers/app/.env: permission denied
```
- La solution est de modifier provisoirement la permission de `.env`:
```
sudo chmod go+r /home/mesonet/gramc-meso/containers/app/.env
docker compose exec bash
...
exit
sudo chmod go-r /home/mesonet/gramc-meso/containers/app/.env
```

