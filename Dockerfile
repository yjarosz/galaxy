# Base image for Galaxy projects (http://galaxyproject.org/)
#
# VERSION       0.1

FROM debian:wheezy
MAINTAINER yohan.jarosz@uni.lu

# Up to date package manager

RUN apt-get update
RUN apt-get -y upgrade

# Set Python, using 2.7
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python2.7 python2.7-dev


# Set mercurial to fetch galaxy release
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q mercurial

# install galaxy dependencies (from https://wiki.galaxyproject.org/Admin/Config/ToolDependenciesList)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q autoconf automake autotools-dev build-essential cmake git-core libatlas-base-dev libblas-dev liblapack-dev libc6-dev subversion pkg-config sudo wget


####################
# install postgres #
####################
#as database (installation steps mainly taken from https://docs.docker.com/examples/postgresql_service/)
# Add PostgreSQL's repository. It contains the most recent stable release of PostgreSQL, ``9.3``.
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN DEBIAN_FRONTEND=noninteractive apt-key add ACCC4CF8.asc
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-9.3

USER postgres
RUN /etc/init.d/postgresql start && psql --command "CREATE USER galaxy WITH SUPERUSER PASSWORD 'galaxy';" && createdb -O galaxy galaxy

# Adjust PostgreSQL configuration so that remote connections to the database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf


##################
# install galaxy #
##################
USER root

# Clone galaxy (from https://wiki.galaxyproject.org/Admin/GetGalaxy)
WORKDIR /home/galaxy
RUN mkdir -p /home/galaxy
RUN hg clone https://bitbucket.org/galaxy/galaxy-dist/

WORKDIR /home/galaxy/galaxy-dist
RUN hg update stable

# Configure universe_wsgi.ini file
COPY configure_universe_wsgi.sh /home/galaxy/galaxy-dist/configure_universe_wsgi.sh
COPY wait_galaxy_conf_finished.py /home/galaxy/galaxy-dist/wait_galaxy_conf_finished.py
RUN cp universe_wsgi.ini.sample universe_wsgi.ini && sh configure_universe_wsgi.sh universe_wsgi.ini
RUN service postgresql start && sh run.sh --daemon && python wait_galaxy_conf_finished.py paster.log

##################
# install apache #
##################
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q apache2 libapache2-mod-xsendfile libapache2-mod-proxy-html libxml2-dev

# enable apache modules, configuration of galaxy then restart service
RUN a2enmod expires deflate xsendfile rewrite proxy proxy_balancer
COPY apache2.galaxy.conf /etc/apache2/sites-available/galaxy
RUN a2ensite galaxy
RUN sudo service apache2 restart


#######################
# install supervisord #
#######################
# supervisor will take care of starting all services
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q openssh-server supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY startup.sh /home/galaxy/galaxy-dist/startup.sh

EXPOSE 8080 80
CMD ["daemon"]
ENTRYPOINT ["/bin/bash", "startup.sh"]
