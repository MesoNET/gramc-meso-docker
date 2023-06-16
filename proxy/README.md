# gramc-meso-docker
Déploiement de gramc-meso en utilisant docker

Configuration du proxy
-----
- Copiez le fichier env-dist.sh:

  ```
  cp -a env-dist.sh env.sh
  ```

- Éditez le fichier `env.sh` (mail pour letsencrypt, ...)

- Exécutez le script `permissions.sh` *en tant que root*:
```
sudo ./permissions.sh
```


Construction des conteneurs:
-----

- Créez un réseau docker par la commande:
```
docker network create --subnet=192.168.0.0/16 gramc_bridge
```
- Construisez les conteneurs par:
```
./build.sh
```
- Ou par:
```
./build.sh --no-cache
```
(en fait il n'y a rien à construire, juste récupérer des conteneurs tous faits)

Démarrage ou arrêt des conteneurs:
-----

```
./run.sh
./stop.sh
```

PUIS ALLEZ VOIR DANS LE RÉPERTOIRE `~/gramc-meso-xxx` pour configurer l'application `gramc-meso`

**NOTES** - 

1. On peut avoir autant d'instances de l'application que nécessaire. 

2. On peut avoir autant d’applications web que nécessaire

3. Le proxy adaptera le fichier de configuration, générera et renouvellera automatiquement les certificats à condition que les conteneurs applicatifs définissent deux ou trois variables d'environnement:

   ```
   VIRTUAL_HOST=${GRAMCMESO_URL}
   LETSENCRYPT_HOST=${GRAMCMESO_URL}
   LETSENCRYPT_TEST=true ou false
   ```

## Configuration du nginx:

Tout est dans `containers/nginx`.

| Répertoire        | description                                                  |
| ----------------- | ------------------------------------------------------------ |
| `certs`           | Les certificats générés et renouvelés                        |
| `conf.d`          | La configuration générée automatiquement (`default.conf`)    |
| `vhost.d`         | Le fichier `default_location` permet de configurer le répertoire de challenges pour letsencrypt<br />Pour une configuration spécifique à un virtual host déterminé, un fichier portant son nom remplacera `default_location`.<br />On peut y mettre par exemple les contrôles d'accès par IP sur les sites non publics. |
| `html`            | `coucou.html` permet de vérifier que letsencrypt a accès à la bonne location |
| `vhost.d.INACTIF` | contournement d'un bug du conteneur docker-gen               |

### Le conteneur docker-gen:

C'est lui qui génère le fichier de configuration de letencrypt en fonction des conteneurs applicatifs. Il utilise pour cela un fichier de templace qui se trouve dans le répertoire `containers/docker-gen/tmpl`