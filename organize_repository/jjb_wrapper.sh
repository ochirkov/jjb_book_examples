#!/bin/bash -e


# Vars declaration
#
GREEN='\033[0;32m'
NC='\033[0m'
WRAPPER_HOME_DIR=/tmp/jjb_wrapper_home
ARTIFACTS="jobs macroses views descriptions scripts"
METHOD=$1
SOURCE=$2
CONFIG=$3


# Only create/update methods supported
#
if [[ $METHOD == "update" || $METHOD == "test" ]]; then
  echo -e "${GREEN}Method is ${METHOD}\n${NC}"
else
  echo -e "${GREEN}Only test/update methods supported\n${NC}"
  exit 0
fi

# Only jobs/views sources supported
#
if [[ $SOURCE == "jobs" || $SOURCE == "views" ]]; then
  echo -e "${GREEN}Source is ${SOURCE}\n${NC}"
else
  echo -e "${GREEN}Only jobs/views sources supported\n${NC}"
  exit 0
fi


function clean_jjb_home () {
  echo -e "${GREEN}Cleaning JJB work dir\n${NC}"
  rm -rf $WRAPPER_HOME_DIR/*
}

function copy_artifacts_to_jjb_home () {
  echo -e "${GREEN}Copying $1 to JJB work dir\n${NC}"
  cp -ra $1 $WRAPPER_HOME_DIR/
}

# Create temp dir for wrapper home
# If exists than clean it
#
if [[ ! -d $WRAPPER_HOME_DIR ]]; then
  mkdir -p $WRAPPER_HOME_DIR
else
  clean_jjb_home
fi


# Copy jjb jobs into wrapper's home dir
#
for directory in $ARTIFACTS; do
  copy_artifacts_to_jjb_home $directory
done


# Append macroses into each job in wrapper's home
#
JOB=$(find $WRAPPER_HOME_DIR/jobs -type f | head -1)
VIEWS=$(find $WRAPPER_HOME_DIR/views -type f)
MACROSES="$(find $WRAPPER_HOME_DIR/macroses -type f)"

for macros in $MACROSES; do
  cat $macros >> $JOB
done


# Perform JJB action
#
cd $WRAPPER_HOME_DIR

echo -e "${GREEN}Performing ${METHOD} on ${SOURCE}\n${NC}"
if [[ $SOURCE == "jobs" ]]; then
  jenkins-jobs --conf $CONFIG $METHOD -r jobs/
elif [[ $SOURCE == "views" ]]; then
  jenkins-jobs --conf $CONFIG $METHOD -r views/
fi

# Clean after work
#
clean_jjb_home
