#!/usr/bin/env bash

SCRIPT_NAME="subspaceupdate.sh"
DAEMON_FILE="subspace"
SCRIPT_PATH="subspace-scripts"
DAEMON_PATH="subspace"

if [[ "$USER" == "root" ]]; then
        HOMEFOLDER="/root"
else
        HOMEFOLDER="/home/$USER"
fi
SERVICE_NAME="subspace"

CURRENTDIR=$(pwd)
if [ ! -d $HOMEFOLDER/$SCRIPT_PATH ]; then mkdir $HOMEFOLDER/$SCRIPT_PATH; fi
cd $HOMEFOLDER/$SCRIPT_PATH

echo "Create script file..."

echo "#!/bin/bash" > $SCRIPT_NAME
echo >> $SCRIPT_NAME
echo 'FILE_NAME="subspace"' >> $SCRIPT_NAME
echo >> $SCRIPT_NAME
echo 'wget https://api.github.com/repos/subspace/subspace-cli/releases/latest' >> $SCRIPT_NAME
echo 'if [ -f ./latest ]; then' >> $SCRIPT_NAME
echo '   LATEST_TAG=$(jq --raw-output '"'"'.tag_name'"'"' "./latest")' >> $SCRIPT_NAME
echo '   LATEST_TAG=${LATEST_TAG//v/}' >> $SCRIPT_NAME
echo -n '   DAEMON_VERSION=$(' >> $SCRIPT_NAME
echo -n -e "$HOMEFOLDER/$DAEMON_PATH/$DAEMON_FILE -v | awk " >> $SCRIPT_NAME
echo ''\''{print $3}'\'')' >> $SCRIPT_NAME
echo '   if [ -z $DAEMON_VERSION ]; then DAEMON_VERSION="new"; fi' >> $SCRIPT_NAME
echo '   if [ $DAEMON_VERSION != $LATEST_TAG ]; then' >> $SCRIPT_NAME
echo -n '      curl -JL -o ./$FILE_NAME $' >> $SCRIPT_NAME
echo '(jq --raw-output '"'"'.assets | map(select(.name | startswith("subspace-cli-macos-x86_"))) | .[0].browser_download_url'"'"' "./latest")' >> $SCRIPT_NAME
echo '      if [ -f $FILE_NAME ]; then' >> $SCRIPT_NAME
echo '         chmod +x $FILE_NAME' >> $SCRIPT_NAME
echo '         pKILL=$(pwdx $(ps -e | grep subspace | awk '"'"'{print $1 }'"'"') | grep /root)' >> $SCRIPT_NAME
echo '         pKILL=$(echo $pKILL | awk '"'"'{print $1}'"'"' | sed 's/.$//')' >> $SCRIPT_NAME
echo -n '         if [ ! -z pKILL ]; then systemctl ' >> $SCRIPT_NAME
echo -e "stop $SERVICE_NAME.service; fi" >> $SCRIPT_NAME
echo -n '         mv $FILE_NAME ' >> $SCRIPT_NAME
echo -e "$HOMEFOLDER/$DAEMON_PATH/$DAEMON_FILE" >> $SCRIPT_NAME
echo -e "         systemctl start $SERVICE_NAME.service" >> $SCRIPT_NAME
echo '      fi' >> $SCRIPT_NAME
echo '   fi' >> $SCRIPT_NAME
echo 'fi' >> $SCRIPT_NAME
echo 'rm latest*' >> $SCRIPT_NAME
chmod +x $SCRIPT_NAME
cd $CURRENTDIR
