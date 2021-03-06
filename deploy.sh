#!/bin/bash

# ----------------------
# KUDU Deployment Script
# Version: 0.1.11
# ----------------------

# Variable Setup
# --------------
SCRIPT_DIR="${BASH_SOURCE[0]%\\*}"
SCRIPT_DIR="${SCRIPT_DIR%/*}"
ARTIFACTS=$SCRIPT_DIR/../artifacts
KUDU_SYNC_CMD=${KUDU_SYNC_CMD//\"}
NODE_EXE="$PROGRAMFILES\\nodejs\\0.10.32\\node.exe"
NPM_CMD="\"$NODE_EXE\" \"$PROGRAMFILES\\npm\\1.4.28\\node_modules\\npm\\bin\\npm-cli.js\""
NODE_MODULES_DIR="$APPDATA\\npm\\node_modules"

EMBER_PATH="$NODE_MODULES_DIR\\ember-cli\\bin\\ember"
BOWER_PATH="$NODE_MODULES_DIR\\bower\\bin\\bower"
GRUNT_PATH="$NODE_MODULES_DIR\\grunt-cli\\bin\\grunt"
PHANTOMJS_PATH="$NODE_MODULES_DIR\\phantomjs\\bin\\phantomjs"

# Helpers
# -------

exitWithMessageOnError () {
  if [ ! $? -eq 0 ]; then
    echo "An error has occurred during web site deployment."
    echo $1
    exit 1
  fi
}

getGithubStatus () {
  GIT_REVISION=`git rev-parse HEAD`
  curl -ks -o tmp/status.json https://api.github.com/repos/CrshOverride/EmberTodo/commits/$GIT_REVISION/status
  GITHUB_STATUS=`"$NODE_EXE" --eval "var json = require('./tmp/status.json'); console.log(json.state);"`
}

# Prerequisites
# -------------

# Verify node.js installed
hash node 2>/dev/null
exitWithMessageOnError "Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment."

# Verify that we have access to tar
hash tar 2> /dev/null
exitWithMessageOnError "Missing tar. I figured as much."

# Verify that curl is installed
hash curl 2> /dev/null
exitWithMessageOnError "Missing curl. Who would've thunk it?"

# Wait for GitHub Status
# ----------------------
if [ "$SCM_WAIT_FOR_CI_BEFORE_BUILD" == "1" ]; then
  echo Waiting for external CI Systems to update GitHub state
  getGithubStatus

  # Originally looped on 'pending' status but got undefined every once in a while
  # so check for the only two statuses that we care about instead.
  while [ "$GITHUB_STATUS" != "success" -a "$GITHUB_STATUS" != "failure" ]
  do
    sleep 15
    getGithubStatus
  done

  if [ "$GITHUB_STATUS" == "failure" ]; then
    echo "GitHub Status indicates a CI Failure. Aborting the deployment."
    exit 1
  fi
fi

# Setup
# -----
echo Copy assets to $DEPLOYMENT_TEMP for build
tar cf - --exclude=node_modules --exclude=bower_components --exclude=dist --exclude=tmp --exclude=.git . | (cd $DEPLOYMENT_TEMP && tar xvf - )
exitWithMessageOnError "Failed to create and extract tarball"

echo Switch to the temp directory
cd $DEPLOYMENT_TEMP

if [[ -d node_modules ]]; then
  echo Removing node_modules folder
  rm -Rf node_modules
  exitWithMessageOnError "node_modules removal failed"
fi

SCRIPT_DIR="${BASH_SOURCE[0]%\\*}"
SCRIPT_DIR="${SCRIPT_DIR%/*}"
ARTIFACTS=$SCRIPT_DIR/../artifacts
KUDU_SYNC_CMD=${KUDU_SYNC_CMD//\"}
NODE_EXE="$PROGRAMFILES\\nodejs\\0.10.32\\node.exe"
NPM_CMD="\"$NODE_EXE\" \"$PROGRAMFILES\\npm\\1.4.28\\node_modules\\npm\\bin\\npm-cli.js\""
NODE_MODULES_DIR="$APPDATA\\npm\\node_modules"

EMBER_PATH="$NODE_MODULES_DIR\\ember-cli\\bin\\ember"
BOWER_PATH="$NODE_MODULES_DIR\\bower\\bin\\bower"
GRUNT_PATH="$NODE_MODULES_DIR\\grunt-cli\\bin\\grunt"
PHANTOMJS_PATH="$NODE_MODULES_DIR\\phantomjs\\bin\\phantomjs"

export PATH=$PATH:"/d/local/AppData/npm/node_modules/phantomjs/lib/phantom"

EMBER_CMD="\"$NODE_EXE\" \"$EMBER_PATH\""
BOWER_CMD="\"$NODE_EXE\" \"$BOWER_PATH\""
GRUNT_CMD="\"$NODE_EXE\" \"$GRUNT_PATH\""

if [[ ! -n "$DEPLOYMENT_SOURCE" ]]; then
  DEPLOYMENT_SOURCE=$SCRIPT_DIR
fi

if [[ ! -n "$NEXT_MANIFEST_PATH" ]]; then
  NEXT_MANIFEST_PATH=$ARTIFACTS/manifest

  if [[ ! -n "$PREVIOUS_MANIFEST_PATH" ]]; then
    PREVIOUS_MANIFEST_PATH=$NEXT_MANIFEST_PATH
  fi
fi

if [[ ! -n "$DEPLOYMENT_TARGET" ]]; then
  DEPLOYMENT_TARGET=$ARTIFACTS/wwwroot
else
  KUDU_SERVICE=true
fi

if [[ ! -n "$KUDU_SYNC_CMD" ]]; then
  # Install kudu sync
  echo Installing Kudu Sync
  npm install kudusync -g --silent
  exitWithMessageOnError "npm failed"

  if [[ ! -n "$KUDU_SERVICE" ]]; then
    # In case we are running locally this is the correct location of kuduSync
    KUDU_SYNC_CMD=kuduSync
  else
    # In case we are running on kudu service this is the correct location of kuduSync
    KUDU_SYNC_CMD=$APPDATA/npm/node_modules/kuduSync/bin/kuduSync
  fi
fi

if [[ ! -e "$EMBER_PATH" ]]; then
  echo Installing ember-cli
  eval $NPM_CMD install -g ember-cli
  exitWithMessageOnError "ember-cli failed"
else
  echo ember-cli already installed, nothing to do
fi

if [[ ! -e "$PHANTOMJS_PATH" ]]; then
  echo Installing phantom-js
  eval $NPM_CMD install -g phantomjs
  exitWithMessageOnError "phantomjs failed"
else
  echo phantomjs already installed, nothing to do
fi

if [[ ! -e "$BOWER_PATH" ]]; then
  echo Installing bower
  eval $NPM_CMD install -g bower
  exitWithMessageOnError "bower failed"
else
  echo bower already installed, nothing to do
fi

if [[ ! -e "$GRUNT_PATH" ]]; then
  echo Installing grunt-cli
  eval $NPM_CMD install -g grunt-cli
  exitWithMessageOnError "grunt-cli failed"
else
  echo grunt-cli already installed, nothing to do
fi

##################################################################################################################################
# Build
# -----

echo Installing npm modules
eval $NPM_CMD install
exitWithMessageOnError "npm install failed"

echo Installing bower dependencies
eval $BOWER_CMD install
exitWithMessageOnError "bower install failed"

echo Build the dist folder
eval $GRUNT_CMD --no-color --verbose
exitWithMessageOnError "grunt build failed"

echo Copy web.config to the dist folder
cp web.config dist\

##################################################################################################################################
# Deployment
# ----------

if [[ "$IN_PLACE_DEPLOYMENT" -ne "1" ]]; then
  "$KUDU_SYNC_CMD" -v 50 -f "$DEPLOYMENT_TEMP/dist" -t "$DEPLOYMENT_TARGET" -n "$NEXT_MANIFEST_PATH" -p "$PREVIOUS_MANIFEST_PATH" -i ".git;.hg;.deployment;deploy.sh"
  exitWithMessageOnError "Kudu Sync failed"
fi

##################################################################################################################################
# Post deployment stub
# --------------------

if [[ -n "$POST_DEPLOYMENT_ACTION" ]]; then
  POST_DEPLOYMENT_ACTION=${POST_DEPLOYMENT_ACTION//\"}
  cd "${POST_DEPLOYMENT_ACTION_DIR%\\*}"
  "$POST_DEPLOYMENT_ACTION"
  exitWithMessageOnError "post deployment action failed"
fi

echo "Finished successfully."

