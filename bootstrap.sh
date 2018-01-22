#!/bin/bash

# Set guest machine username
USERNAME="vagrant"

# Guest machine provision data
HOME_DIR=/home/$USERNAME
PROVISION_DIR=/home/$USERNAME/provision

# Generate proper UTF-8 locale
rm /etc/default/locale
touch /etc/default/locale
{
  echo 'LANG="en_US.UTF-8"';
  echo 'LANGUAGE="en_US.UTF-8"';
  echo 'LC_ALL="en_US.UTF-8"';
} >> /etc/default/locale
locale-gen en_US.UTF-8

# Make sure SSH host checks accepted automatically
touch $HOME_DIR/.ssh/config
chown -R $USERNAME:$USERNAME $HOME_DIR/.ssh
chmod 600 $HOME_DIR/.ssh/config
echo "StrictHostKeyChecking no" >> $HOME_DIR/.ssh/config

# Update Ubuntu package repository and install required packages
apt-get update
apt-get upgrade
apt-get install -y rlwrap build-essential automake libtool coreutils python2.7 python-software-properties
apt-get install -y nginx postgresql postgis postgresql-contrib redis-server vim tmux git libpq5 libpq-dev htop

# Configure PostgreSQL authentication
rm /etc/postgresql/9.3/main/pg_hba.conf
touch /etc/postgresql/9.3/main/pg_hba.conf
{
  echo "local all all trust";
  echo "host all all 0.0.0.0/0 trust";
  echo "host all all ::1/128 trust";
} >> /etc/postgresql/9.3/main/pg_hba.conf

echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
service postgresql restart

# Create databases
for DB in savana_development savana_test
do
    echo "Creating DB: $DB"
    createdb -U postgres $DB
done

# Install Node 8.9.4 LTS
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs

# Install required NPM global modules
# npm i -g typescript typings semver js-beautify json napa eslint node-gyp

# Add local to PWD dev npm_modules to PATH
# echo 'export PATH="./node_modules/.bin:$PATH"' >> $HOME_DIR/.bashrc

# Remove obsolete files
apt-get -y autoremove

