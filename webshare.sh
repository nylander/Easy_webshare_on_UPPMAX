#!/bin/bash -l

## Description: Quick webshare a folder on UPPMAX.
##              Folder needs to be in /proj/<projid>/webexport/.
##              All files need to be readable by all on the server
##              (chmod -R a+r /proj/<projid>/webshare/<folder>).
##              Access to URL will be password protected.
##              Password and, optimally, user, will be set randomly.
## Folder:      /proj/<projid>/webexport/<folder>
## URL:         http://export.uppmax.uu.se/<projid>/<folder>
## Usage:       webshare.sh [-f folder] [-u user] [-h]
## By:          Johan Nylander, BILS
## Version:     12/17/2015 09:25:54 AM
## Src:         https://github.com/nylander/Easy_webshare_on_UPPMAX

## Check if we can run on system (UPPMAX)
if [ ! -d "/proj" ] ; then
    echo "Can not find /proj directory on this system."
    exit 1
fi
if [ ! -r "/dev/urandom" ] ; then
    echo "Can not read file /dev/urandom on this system."
    exit 1
fi

## Check arguments, "space style" ( proa.sh -f arg -b arg)
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -f|--folder)
    FOLDER="$2"
    shift
    ;;
    -d|--dir)
    FOLDER="$2"
    shift
    ;;
    -n|--name)
    NAME="$2"
    shift
    ;;
    -u|--user)
    NAME="$2"
    shift
    ;;
    -p|--project)
    PROJID="$2"
    shift
    ;;
    -h|--help)
    echo "Webshare files in /proj/<projid>/webshare/<folder>."
    echo "The URL (password protected) will be http://export.uppmax.uu.se/<projid>/<folder>"
    echo "Usage:"
    echo "    First, create <folder> with content to be shared."
    echo "    Then, cd to <folder> and run:"
    echo ""
    echo "        webshare.sh"
    echo ""
    echo "    The user and password will be written to stdout. Write them down."
    echo "    Optionally, both <folder> and <user> can be given as arguments:"
    echo ""
    echo "        webshare.sh -f <folder> -u <user>"
    echo ""
    echo "    The <folder> will be created if not already present."
    exit 1
    ;;
    *)
    echo "Unknown argument"
    echo "Usage: webshare.sh [-h] [-f folder] [-u user]"
    exit 1
    ;;
esac
shift
done

## Set project id
if [ -z "$PROJID" ]; then
    ## Looks for b2014211 in /proj/b2014211/...
    ## Need to be in the project tree to work (since using pwd)
    PROJID=$(pwd | sed -e 's@/proj/\([^/]*\)/.*$@\1@')
fi
if [ ! -e "/proj/$PROJID" ] ; then
    echo "Can not find folder /proj/$PROJID. Is project ID correct?"
    exit 1
fi

## Set folder
WEBDIR="/proj/$PROJID/webexport"
if [ -n "$FOLDER" ]; then
    if [ -e "$WEBDIR/$FOLDER" ] ; then
        echo "folder exists in $WEBDIR: $(realpath $FOLDER)"
    else
        echo "folder does not exist in $WEBDIR"
        FOLDER=$WEBDIR/$FOLDER
        mkdir -v -p $FOLDER
        chmod -v -R a+r $FOLDER
        if [ ! -e "$FOLDER" ] ; then
            echo "failed to create $FOLDER"
            exit 1
        fi
    fi
else
    FOLDER=$(pwd)
    F=$(basename $FOLDER)
    if [[ "$FOLDER" == $WEBDIR/$F ]] ; then
        echo "folder to share (set by pwd): $FOLDER"
    else
        echo "$FOLDER is not inside $WEBDIR ?"
        echo "Need to run the script from inside the directory to be shared if run without arguments."
        exit 1
    fi
fi

## Set user
if [ -n "$NAME" ]; then
    echo ""
    #echo "name set manually: $NAME"
else
    NAME=$(< /dev/urandom tr -dc a-z | head -c6)
    #echo "name set randomly: $NAME"
fi

## Create password
PWD=$(< /dev/urandom tr -dc a-z | head -c6)
#echo "generated password: $PWD"

## Create .htpasswd. If file exists, add user.
if [ -e "$FOLDER/.htpasswd" ] ;then
    echo -e "$NAME:$(perl -le 'print crypt("$ENV{PWD}","moresalt")')" >> $FOLDER/.htpasswd
else
    echo -e "$NAME:$(perl -le 'print crypt("$ENV{PWD}","moresalt")')" > $FOLDER/.htpasswd
fi

## Create .htaccess. If file exists, do nothing.
if [ ! -e "$FOLDER/.htaccess" ] ;then
    touch $FOLDER/.htaccess
    echo "Options +Indexes"                  >> $FOLDER/.htaccess
    echo "AuthType Basic"                    >> $FOLDER/.htaccess
    echo "AuthUserFile $FOLDER/.htpasswd"    >> $FOLDER/.htaccess
    echo "AuthName \"Private project area\"" >> $FOLDER/.htaccess
    echo "Require valid-user"                >> $FOLDER/.htaccess
fi

## Set files readable to all
chmod -R ugo+r $FOLDER

## Make sure folders have o+x
find $FOLDER -type d -exec chmod 755 {} +

## Print user+passwd to stdout. Write them down.
echo "      URL: http://export.uppmax.uu.se/$PROJID/$F"
echo "User Name: $NAME"
echo " Password: $PWD"

 
