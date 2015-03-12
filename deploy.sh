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
  curl -ks -o tmp/status.json https://api.github.com/repos/CrshOverride/EmberTodo/commits/f1988d4fa45824724e56e18bf4c0a4a098565178/status
  GITHUB_STATUS=`eval $NODE_EXE --eval "var json = require('./tmp/status.json'); console.log(json.state);"`
}

# Prerequisites
# -------------

# Verify node.js installed
hash node 2>/dev/null
exitWithMessageOnError "Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment."

# Verify that we have access to tar
hash tar 2> /dev/null
exitWithMessageOnError "Missing tar. I figured as much."

#Verify that curl is installed
hash curl 2> /dev/null
exitWithMessageOnError "Missing curl. Who would've thunk it?"

# Wait for GitHub Status
# ----------------------
getGithubStatus
echo $GITHUB_STATUS

while [$GITHUB_STATUS -eq "pending"]; do
  getGithubStatus
done

echo Made it here!

