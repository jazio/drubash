#!/usr/bin/env bash
echo -n "Type the project machine-name: "
read project
echo -n "Type JIRA ticket no. MULTISITE-: "
read jirano

jira="MULTISITE-"$jirano
username="farcaov"

echo "Initiating preparing $project under $jira ticket. "
echo "https://webgate.ec.europa.eu/CITnet/jira/browse/$jira"


# Configure working directories
stash=~/www/stash
svn=~/www/svn
tmp=~/www/tmp

# Colors. 0 = Normal; 1 = Bold.
RED=$'\e[1;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
BLUE=$'\e[0;34m'
MAGENTA=$'\e[0;35m'
CYAN=$'\e[0;36m'
NO_COLOR=$'\e[0m'


# Check there is a temp folder or create it.
function create_directories ()
{
   if [ ! -d "$tmp" ]; then
       mkdir $tmp
       chmod -R u+rwx $tmp
       cd $tmp
       mkdir $project
   elif [ ! -d "$svn" ]; then
       mkdir $svn
       chmod -R u+rwx $svn
   elif [ ! -d "$stash" ]; then
       mkdir $stash
       chmod -R u+rwx $stash
   else
       echo "All required folders are created."
   fi
}


function command_exists ()
{
  type "$1" &> /dev/null
}

function check_input () {
 # Parameter #1 is zero length.
 args=("$@")
  if [ -z "$1" ]
    then 
    echo "Parameter empty."
    exit 
  else
   echo "${CYAN} ${args[0]} OK. ${NO_COLOR}"
  fi
}


function fetch_stash_repository ()
{
  cd $stash
  if [ -d "$stash/${project}-reference" ]; then
    cd ${project}-reference
    git checkout master
    git reset --hard
    git clean -f -d
    git pull
    echo "${YELLOW}Updated repository. ${NO_COLOR}"
  else
    git clone https://${username}@webgate.ec.europa.eu/CITnet/stash/scm/multisite/${project}-reference.git
    cd ${project}-reference
    echo "${YELLOW}Reference repository cloned to $stash/${project}-reference ${NO_COLOR}"
  fi

  # Delay 2 seconds
  sleep 2
  git status
  sleep 5
  git log -3 --oneline --decorate --graph
  #todo check coding standards
}

function prepare_what_to_deploy () 
{
 # delete first the existing folders
  rm -rfv $tmp/$project
  mkdir $tmp/$project
  cd $stash/${project}-reference

  if [ -d "$stash/${project}-reference/themes" ]; then
    mkdir $tmp/$project/themes
    cp -R themes/ $tmp/$project/
  elif [ -d "$stash/${project}-reference/modules" ]; then
    mkdir $tmp/$project/modules
    cp -R modules/ $tmp/$project/
  elif [ -d "$stash/${project}-reference/libraries" ]; then
    mkdir $tmp/$project/libraries
    cp -R libraries/ $tmp/$project/
  fi
  echo "These are the files to deploy:"
  ls -lah $tmp
  sleep 6
  #todo run make file and fetch its content.
}

function prepare_svn ()
{
    cd $svn
    if [ -d "$project" ]; then
      cd $svn/$project
      svn up
    else
      mkdir -p $project
      svn co https://webgate.ec.europa.eu/CITnet/svn/MULTISITE/trunk/custom_subsites/$project
      cd $svn/$project
    fi
    
    cp -fR $tmp/$project  $svn/$project
    svn status
    sleep 10
}

function commit_svn ()
{
    # todo commit only after checking if the folder not empty.
    cd $svn/$project
    echo -n "${RED} Commit folder svn $svn/$project to server ? (y/n): ${NO_COLOR}"
    read answer
    if [ "$answer" == "y" ]; then
      #todo remove all files and commit.
      svn add * --force
      svn commit -m "$jira"
    else
      exit 1
    fi
}
 


check_input "$project"
check_input "$jira"
git --version
create_directories
fetch_stash_repository
prepare_what_to_deploy
prepare_svn
commit_svn
