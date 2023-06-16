# gramc-meso-docker
Déploiement de gramc-meso en utilisant docker

Ce dépôt propose une méthode d'installation de gramc-meso simple et rapide, utilisant docker en mode rootless pour une meilleure sécurité

## L'architecture générale

Le schéma ci-dessous montre l'architecture générale de l'installation. Il est possible d'installer plusieurs instances de `gramc-meso`, par exemple pour des besoins de test.

![](/home/manu/Documents/devt/gramc-meso-docker/architecture.drawio.png)

Installation de docker en mode rootless
-----

- Installer Docker comme indiqué ici: https://docs.docker.com/engine/install/debian/

- Vérifier que le fichier `/etc/hosts` est bien lisible par tout le monde:

  ```
  sudo chmod a+r /etc/hosts
  ```

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
