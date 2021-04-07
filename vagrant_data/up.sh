#! /bin/bash

# Check if docker is installed or not
if [[ $(which docker) && $(docker --version) ]]; then
  echo "$OSTYPE has $(docker --version) installed"
  else
    echo "You need to Install docker"
    # command
    case "$OSTYPE" in
      darwin*)  echo "$OSTYPE should install Docker Desktop by following this link https://docs.docker.com/docker-for-mac/install/" ;; 
      msys*)    echo "$OSTYPE should install Docker Desktop by following this link https://docs.docker.com/docker-for-windows/install/" ;;
      cygwin*)  echo "$OSTYPE should install Docker Desktop by following this link https://docs.docker.com/docker-for-windows/install/" ;;
      linux*)
        echo "Some $OSTYPE distributions could install Docker, we will try to install Docker for you..." 
        ./installDockerForUbuntu.sh

        echo "Docker Installation complete." ;;
      *) echo "Sorry, this $OSTYPE might not have Docker implementation" ;;
    esac
fi

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose dos2unix

# Make sure that the xlpdata directory is available, otherwise, create it.
if [ ! -e /xlpdata ]; then
  sudo mkdir /xlpdata
  sudo chmod +777 /xlpdata
fi


cd /xlpdata

# Just incase the /xlpdata has not been given write access
sudo chmod 777 /xlpdata

# Make sure that the docker-compose.yml is available in this directory, otherwise, download it.
if [ ! -e ./docker-compose.yml ]; then
  sudo curl https://raw.githubusercontent.com/xlp0/XLPWikiMountPoint/main/docker-compose.yml > docker-compose.yml
fi

# Make sure that LocalSettings.php is available in this directory, otherwise, download it.
if [ ! -e ./LocalSettings.php ]; then
  sudo curl https://raw.githubusercontent.com/xlp0/XLPWikiMountPoint/main/LocalSettings.php > LocalSettings.php
fi

# If docker is running already, first run a data dump before shutting down docker processes
# One can use the following instruction to find the current directory name withou the full path
# CURRENTDIR=${PWD##*/}
# In Bash v4.0 or later, lower case can be obtained by a simple ResultString="${OriginalString,,}"
# See https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash
# However, it will not work in Mac OS X, since it is still using Bash v 3.2
LOWERCASE_CURRENTDIR="$(tr [A-Z] [a-z] <<< "${PWD##*/}")"
MW_CONTAINER=$LOWERCASE_CURRENTDIR"_mediawiki_1"
DB_CONTAINER=$LOWERCASE_CURRENTDIR"_database_1"
ResourceBasePath="/var/www/html"

echo "MediaWiki is named as: "$MW_CONTAINER

# BACKUPSCRIPTFULLPATH=$ResourceBasePath"/extensions/BackupAndRestore/backup.sh"
# RESOTRESCRIPTFULLPATH=$ResourceBasePath"/extensions/BackupAndRestore/restore.sh"

# echo "Executing: " docker exec $MW_CONTAINER $BACKUPSCRIPTFULLPATH
# docker exec $MW_CONTAINER $BACKUPSCRIPTFULLPATH
# stop all docker processes
sudo docker-compose down --volumes

# If the mountPoint directory doesn't exist, 
# Decompress the InitialDataPackage to ./mountPoint 
if [ ! -e ./mountPoint/ ]; then

if [ ! -e ./InitialContentPackage.tar.gz ]; then 
  sudo curl  https://raw.githubusercontent.com/xlp0/XLPWikiMountPoint/main/InitialContentPackage.tar.gz > temp.tar.gz
fi
  tar -xzvf ./temp.tar.gz -C .
  if [ -e ./temp.tar.gz ]; then 
    rm ./temp.tar.gz
  fi
fi

# Start the docker processes
sudo docker-compose up -d --build


# After docker processes are ready, reload the data from earlier dump
# echo "Loading data from earlier backups..."
# echo "Executing: " docker exec $MW_CONTAINER $RESOTRESCRIPTFULLPATH
# docker exec $MW_CONTAINER $RESOTRESCRIPTFULLPATH

echo "$MW_CONTAINER will do regular database content dump."
sudo docker exec $MW_CONTAINER service cron start

echo "${ResourceBasePath}/images in docker container ${MW_CONTAINER} will be given all write access."
sudo docker exec $MW_CONTAINER chmod -R 777 /var/www/html/images/

echo "Please go to a browser and use http://localhost:9352 to test the service"
