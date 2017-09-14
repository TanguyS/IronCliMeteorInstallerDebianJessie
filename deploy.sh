#!/bin/bash

IP='IP_SITE'
NAME='NAME_OF_APP'
USER='NAME_OF_USER' # Has key access
TARGZ_NAME="$NAME.tar.gz"
DIR="/opt/$NAME"
HOSTNAME="NAME_OF_HOST"

if [ -z "$1" ]; then
  echo 'Usage: deploy STAGE'
  exit 0
else
  STAGE=$1
fi

CONFIG=$(<config/$STAGE/env.sh)
SETTINGS=$(<config/$STAGE/settings.json)

URL="http://$HOSTNAME"
REMOTE="$USER@$IP"

echo '---------------------'
echo 'Build'
echo '---------------------'
iron build --architecture os.linux.x86_32

echo '---------------------'
echo 'compress'
echo '---------------------'
tar -zcf ./build/$TARGZ_NAME ./build/bundle

# if you also have mobile version add server option:
# meteor build /tmp/ --server $URL

echo '---------------------'
echo 'CREATE DIR'
echo '---------------------'
ssh $REMOTE "mkdir -p $DIR"

echo '---------------------'
echo 'TRANSFER APP'
echo '---------------------'
scp ./build/$TARGZ_NAME $REMOTE:$DIR

echo '---------------------'
echo 'INSTALL'
echo '---------------------'
# install production with force and fibers
CMD="
cd $DIR && tar xfz $TARGZ_NAME
rm -rf $DIR/build/bundle/programs/server/npm/npm-bcrypt
cd $DIR/build/bundle/programs/server && npm install --production --force && npm install bcrypt && npm install fibers
"
# mkdir -p $DIR/tmp $DIR/public
# cd $DIR && touch tmp/restart.txt
ssh $REMOTE "$CMD"

echo '---------------------'
echo 'START'
echo '---------------------'
CMD="
cd $DIR/build/bundle && forever stop main.js
$CONFIG
export METEOR_SETTINGS='$SETTINGS'
cd $DIR/build/bundle && forever start main.js
"

ssh $REMOTE "$CMD"
