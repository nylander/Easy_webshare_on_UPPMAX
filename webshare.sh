#!/bin/bash -l

## Description: Quick webshare a folder on UPPMAX.
##              Folder needs to be in /proj/<projid>/webexport/.
##              All files need to be readable by all on the server
##              (chmod -R a+r /proj/<projid>/webexport/<folder>).
##              Access to URL will be password protected.
##              Password and, optimally, user, will be set randomly.
## Folder:      /proj/<projid>/webexport/<folder>
## URL:         http://export.uppmax.uu.se/<projid>/<folder>/
## Usage:       webshare.sh [-f folder] [-u user] [-h]
## By:          Johan Nylander, NBIS
## Version:     Mon 19 sep 2022 16:37:45
## Src:         https://github.com/nylander/Easy_webshare_on_UPPMAX
## License:     MIT, https://opensource.org/licenses/MIT

## Check arguments, "space style" ( webshare.sh -f arg -b arg)
while [[ "$#" -gt 0 ]]
do
    key="$1"
    case ${key} in
        -f|--folder)
        FOLDER="$2"
        shift
        ;;
        -d|--dir)
        FOLDER="$2"
        shift
        ;;
        -n|--name)
        USERNAME="$2"
        shift
        ;;
        -u|--user)
        USERNAME="$2"
        shift
        ;;
        -p|--project)
        PROJID="$2"
        shift
        ;;
        -h|--help)
        echo "Webshared files in /proj/<projid>/webexport/<folder>/."
        echo "The URL (password protected) will be https://export.uppmax.uu.se/<projid>/<folder>/"
        echo "Usage:"
        echo "    First, create <folder> with content to be shared."
        echo "    Then, cd to <folder> and run:"
        echo ""
        echo "        webshare.sh"
        echo ""
        echo "    The user and password will be written to stdout. Write them down."
        echo "    Optionally, both <folder> (full path!) and <user> can be given as arguments:"
        echo ""
        echo "        webshare.sh -f <folder> -u <user>"
        echo ""
        echo "    The <folder> will be created if not already present."
        echo "    Also note that the folder must reside inside a projects 'webexport' folder."
        echo ""
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

## Check if we can run on UPPMAX (system specific)
if [ ! -d "/proj" ] ; then
    echo "Can not find /proj directory on this system."
    exit 1
fi

## Check for presence of /dev/urandom
if [ ! -r "/dev/urandom" ] ; then
    echo "Can not read file /dev/urandom on this system."
    exit 1
fi

## Check provided (full) folder path and get PROJID. Folder path need to contain /proj/$PROJID/webexport
if [ -n "${FOLDER}" ]; then
    ## Remove any leading '/crex' (Adhoc solution on current crex file system on uppmax)
    if [[ "${FOLDER}" =~ ^/crex/proj/ ]]; then
        FOLDER="${FOLDER/\/crex/}"
        echo "Corrected the folder path by removing the preceding '/crex'"
    fi
    ## Find PROJID and also check if there is an "webexport" folder in the path
    if [[ "${FOLDER}" =~ ^/proj/([^/]*)/webexport ]]; then
        FOUNDPROJID=${BASH_REMATCH[1]}
        if [ -z "${FOUNDPROJID}" ]; then
            echo "Error: could not extract project id from path"
            exit 1
        fi
        ## Check if PROJID is also given, and if so, does the path and PROJID match
        if [ -n "${PROJID}" ]; then
            if [[ ! "${FOUNDPROJID}" == "${PROJID}" ]]; then
                echo "Error: Can not find folder /proj/${PROJID}/webexport as part of path to folder (${FOLDER})."
                echo "Is project path/project ID correct?"
                exit 1
            fi
        else
            PROJID="${FOUNDPROJID}"
            WEBDIR="/proj/${PROJID}/webexport"
        fi
        WEBDIR="/proj/${PROJID}/webexport"
    else
        echo "Error: Can not find a webexport folder as part of path (${FOLDER})."
        echo "Is project path correct?"
        exit 1
    fi

    ## Path seems to contain necessary parts, but does folder exists?
    if [ -e "${FOLDER}" ] ; then
        echo ""
        echo "Folder to share exists in ${WEBDIR}: $(realpath "${FOLDER}")"
    else
        echo ""
        echo "Folder to share does not exist in ${WEBDIR}."
        echo "Make sure that all files and folders you later put in"
        echo "the shared folder have correct permissions (readable to all)."
        mkdir -v -p "${FOLDER}"
        chmod -v -R a+r "${FOLDER}"
        if [ ! -e "${FOLDER}" ] ; then
            echo "failed to create ${FOLDER}"
            exit 1
        fi
    fi
    F=$(basename "${FOLDER}")
else
    ## If no folder name is given, assume script is run in cwd
    FOLDER=$(pwd)
    ## Remove any leading '/crex' (Adhoc solution on current crex file system on uppmax)
    if [[ "${FOLDER}" =~ ^/crex/proj/ ]]; then
        FOLDER="${FOLDER/\/crex/}"
        echo "Corrected the folder path by removing the preceding '/crex'"
    fi
    F=$(basename "${FOLDER}")
    if [[ "${FOLDER}" =~ ^/proj/([^/]*)/webexport ]] ; then
        FOUNDPROJID=${BASH_REMATCH[1]}
        if [ -z "${FOUNDPROJID}" ]; then
            echo "Error: could not extract project id from path"
            exit 1
        else
            PROJID="${FOUNDPROJID}"
        fi
        echo "Folder to share (set by pwd): ${FOLDER}"
    else
        echo "${FOLDER} is not inside ${WEBDIR} ?"
        echo "Need to run the script from inside the directory to be shared if run without arguments."
        exit 1
    fi
fi

## Set user
if [ -n "${USERNAME}" ]; then
    echo ""
else
    USERNAME=$(< /dev/urandom tr -dc a-z | head -c6)
fi

## Create password. Need export for perl.
PASSWORD=$(< /dev/urandom tr -dc a-z | head -c6)
export PASSWORD

## Create .htpasswd. If file exists, add user.
if [ -e "${FOLDER}/.htpasswd" ] ;then
    echo -e "${USERNAME}:$(perl -le 'print crypt("$ENV{PASSWORD}","moresalt")')" >> "${FOLDER}/.htpasswd"
else
    echo -e "${USERNAME}:$(perl -le 'print crypt("$ENV{PASSWORD}","moresalt")')" > "${FOLDER}/.htpasswd"
fi

## Create .htaccess. If file exists, do nothing.
if [ ! -e "${FOLDER}/.htaccess" ] ; then
    touch "${FOLDER}/.htaccess"
    echo "Options +Indexes"                  >> "${FOLDER}/.htaccess"
    echo "IndexIgnoreReset ON"               >> "${FOLDER}/.htaccess"
    echo "AuthType Basic"                    >> "${FOLDER}/.htaccess"
    echo "AuthUserFile ${FOLDER}/.htpasswd"  >> "${FOLDER}/.htaccess"
    echo "AuthName \"Private project area\"" >> "${FOLDER}/.htaccess"
    echo "Require valid-user"                >> "${FOLDER}/.htaccess"
fi

## Set files readable to all
chmod -R ugo+r "${FOLDER}"

## Make sure folders have o+x
find "${FOLDER}" -type d -exec chmod 755 {} +

## Print user+passwd to stdout. Write them down.
echo ""
echo "      URL: https://export.uppmax.uu.se/${PROJID}/${F}/"
echo "User Name: ${USERNAME}"
echo " Password: ${PASSWORD}"
echo ""
echo "Need a tip? Try"
echo ""
echo "  wget -m -nH -np --cut-dirs=1 -R \"index.html*\" --user=${USERNAME} --password=${PASSWORD} \"https://export.uppmax.uu.se/${PROJID}/${F}/\""
echo ""

