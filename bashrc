# get rid of the message, that pip knows that it is inside of a virtualenv
export PIPENV_VERBOSITY=-1

# develop the invenio rdm
export FLASK_ENV=development

# to use pycharm in a tiled window manager
export _JAVA_AWT_WM_NONREPARENTING=1

# this is to avoid the necessity to use root to link a react module
export NPM_CONFIG_PREFIX=~/.npm/global

######
#
# repository development
#
######

# this approach would need the virtualenvironment in env directory
# created by venv(). further the repository would then be installed in
# rdm this would be customized by invenio-cli init

function venv() {
  python -m venv env
}

function activate() {
  base=${PWD}

  if [ -d "env" ]
  then
    source env/bin/activate
  elif [[ ${PWD} =~ "env" ]]
  then
    while [ ! -d "env" ]
    do
      cd ..
    done

    source env/bin/activate
    cd $base
  else
    echo "wrong directory, no env directory and no env in the parent directories"
  fi
}

function jumpToRdmIfNecessary() {
  if [ ${PWD##*/} != "rdm" ]
  then
    cd rdm
  fi
}

function run() {
  jumpToRdmIfNecessary
  invenio-cli run
}

function webpack_run() {
  jumpToRdmIfNecessary
  invenio webpack run start
}
