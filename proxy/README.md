
# UTILISATION du reverse proxy utilisant nginx 

**Note** - Cette documentation est validée pour un host Debian 11 Bullseye

Installations de docker en mode rootless
-----

- Installer Docker comme indiqué ici: https://docs.docker.com/engine/install/debian/

- Vérifier que le fichier /etc/hosts est bien lisible par tout le monde (sudo chmod a+r /etc/hosts)

- Pour plus de sécurité, installer le mode rootless: https://docs.docker.com/engine/security/rootless/ (d'où la remarque précédente)

- Pour tracer les vraies IP il faudra créer le fichier `~/.config/systemd/user/docker.service.d/override.conf` 
  comme expliqué ici: https://rootlesscontaine.rs/getting-started/docker/#changing-the-port-forwarder

- On aura besoin d'exposer des ports privilégiés ET tracer les IP sources, au moins au niveau du reverse proxy. Donc il faut changer une variable du noyau comme expliqué ici: https://docs.docker.com/engine/security/rootless/#exposing-privileged-ports
  
  ```
  sudo sysctl net.ipv4.ip_unprivileged_port_start=0
  ```
  
  
  voir ici pour les détails: https://github.com/rootless-containers/slirp4netns/issues/251
  
- Ajouter les lignes suivantes dans `~/.bashrc`:
```
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
export DOCKER_SOCK=/run/user/$(id -u)/docker.sock
```

Modification des subuid et subgid
-----

Les étapes précédentes installent les fichiers `/etc/subuid` et `/etc/subgid` avec la ligne: `mesonet:100000:65536` Il est préférable de remplacer 100000 par 100001 dans ce fichier, en effet sachant que le user root du conteneur sera le user courant du host, cette modification permettra de mapper le uid `xyz` avec `100xyz`, ce qui est très pratique au quotidien. D'où les commandes:

```
systemctl --user stop docker
vi /etc/subuid /etc/subgid
systemctl --start docker
```

Configuration du proxy
-----
- Editez le fichier `env.sh` (mail pour letsencrypt, ...)
- Exécutez le script permissions en tant que root:
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

PUIS ALLEZ VOIR DANS LE REPERTOIRE `~/gramc-meso-xxx` pour configurer l'application `gramc-meso`

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
