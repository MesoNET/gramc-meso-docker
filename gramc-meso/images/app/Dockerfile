FROM debian:bullseye-slim

LABEL maintainer="emmanuel.courcelle@toulouse-inp.fr"

ARG GRAMCMESO_URL
ENV DEBIAN_FRONTEND=non-interactive

# ------------ INSTALLATIONS --------------------
# Installer les dernières mises à jour
RUN apt-get update && apt-get dist-upgrade -y

# Install msmtp et autres paquets utiles
RUN apt-get install -y --no-install-recommends msmtp less bzip2 lbzip2 curl wget gnupg2 ca-certificates lsb-release apt-transport-https imagemagick mariadb-client sudo \
    rsyslog locales 
RUN apt-get install -y iproute2

RUN mkdir /var/run/mysqld

# Instal wkhtmltopdf, pour générer les pdf
RUN apt-get install -y --no-install-recommends fontconfig libxrender1 xfonts-75dpi xfonts-base
RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb && \
    dpkg -i wkhtmltox_0.12.6.1-2.bullseye_amd64.deb && \
    rm wkhtmltox*.deb
 
# Timezone
ENV TZ=Europe/Paris

# Locale
RUN sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure locales && \
    update-locale LANG=fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr  
ENV LC_ALL fr_FR.UTF-8
     
# ------------ INSTALLATIONS --------------------
# Installer apache et php
# Install msmtp, python3, nslcd, apache2 et modules
RUN apt-get install -y --no-install-recommends apache2 libapache2-mod-auth-openidc openssl ssl-cert

# Install php cf. https://www.itzgeek.com/how-tos/linux/debian/how-to-install-php-7-3-7-2-7-1-on-debian-10-debian-9-debian-8.html
RUN wget https://packages.sury.org/php/apt.gpg && apt-key add apt.gpg
RUN rm apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php8.list
RUN apt-get update

RUN apt-get install -y --no-install-recommends php8.0 php8.0-common \
    php8.0-cli libapache2-mod-php8.0 php8.0-mysql php8.0-sqlite3 php8.0-gd php8.0-xml php8.0-apcu php8.0-bcmath php8.0-bz2 php8.0-curl php8.0-dba php8.0-intl php8.0-mbstring  php8.0-soap php8.0-zip php8.0-tidy php8.0-imagick

# Durcissement d'apache: le fichier security.conf peut être modifié pour agir sur le durcissement
# Certaines directives utilisent le module headers
RUN a2enmod headers
COPY security.conf /etc/apache2/conf-available

# On expose 80 pour http derriere un reverse proxy
EXPOSE 80 

# Création d'un utilisateur à qui appartiendront (presque) tous les fichiers
RUN adduser --no-create-home --disabled-password --disabled-login  --gecos '' gramc-meso

# Installation du code de gramc-meso
RUN mkdir -p /app/gramc-meso \
    && cd /app \
    && chown -R gramc-meso.gramc-meso gramc-meso 

RUN apt-get install -y git
RUN cd /app && sudo -u gramc-meso git clone https://github.com/mesonet/gramc-meso gramc-meso
RUN cd /app/gramc-meso && mkdir var data && chown -R www-data.www-data var data

# Installation de composer
RUN cd /usr/local/bin \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');"
RUN cd /usr/local/bin && mv composer.phar composer

# Installation des composants de symfony
RUN cd /app/gramc-meso && sudo -u gramc-meso composer --no-scripts -n install

# Configuration d'apache
RUN cd /var/www/html && ln -s /app/gramc-meso/public gramc-meso
COPY gramc-meso.conf /etc/apache2/sites-available
RUN sed -i -e "s/SERVERNAME/ServerName ${GRAMCMESO_URL}/" /etc/apache2/sites-available/gramc-meso.conf
RUN a2ensite gramc-meso && a2enmod rewrite && a2enmod ssl && a2enmod auth_openidc

# index.php (provisoire)
COPY index.php /app/gramc-meso/public
RUN chown gramc-meso.gramc-meso /app/gramc-meso/public/index.php && chmod a+r /app/gramc-meso/public/index.php
RUN cd /app/gramc-meso/config && cp -a parameters.yaml.dist parameters.yaml

# .env
# ATTENTION - Avez-vous configuré .env ?
COPY .env /app/gramc-meso

# Logo etc...
# Utilisez les logos proposés...
RUN cd /app/gramc-meso/public \
    && cp css/colors.css.dist css/colors.css \
    && cp icones/banniere.png.dist icones/banniere.png \
    && cp icones/favicon.ico.dist icones/favicon.ico \
    && cp icones/header.png.dist icones/header.png

# config de msmtp
# cf. https://stackoverflow.com/questions/47247952/send-email-on-testing-docker-container-with-php-and-sendmail
COPY msmtprc /etc/msmtprc

# lance apache en mode no daemon
ENTRYPOINT ["/bin/bash","-c","source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"]

