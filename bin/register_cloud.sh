#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error and immediately exit
set -o errexit # If a command fails exit the whole script

if [ "${DEBUG:-false}" = "true" ]; then
    set -x # Run the entire script in debug mode
fi

usage() {
    echo "usage: $(basename $0) <box_name> <box_suffix> <version>"
    echo
    echo "Requires the following environment variables to be set:"
    echo "  ATLAS_USERNAME"
    echo "  ATLAS_ACCESS_TOKEN"
}

args() {
    if [ $# -lt 3 ]; then
        usage
        exit 1
    fi

    if [ -z ${ATLAS_USERNAME+x} ]; then
        echo "ATLAS_USERNAME environment variable not set!"
        usage
        exit 1
    elif [ -z ${ATLAS_ACCESS_TOKEN+x} ]; then
        echo "ATLAS_ACCESS_TOKEN environment variable not set!"
        usage
        exit 1
    fi

    BOX_NAME=$1
    BOX_SUFFIX=$2
    VERSION=$3
}

get_short_description() {
    if [[ "${BOX_NAME}" =~ i386 ]]; then
        BIT_STRING="32-bit"
    else
        BIT_STRING="64-bit"
    fi
    DOCKER_STRING=
    if [[ "${BOX_NAME}" =~ docker ]]; then
        DOCKER_STRING=" with Docker preinstalled"
    fi
    EDITION_STRING=
    if [[ "${BOX_NAME}" =~ desktop ]]; then
        EDITION_STRING=" Desktop"
    fi
    RAW_VERSION=${BOX_NAME#ubuntu}
    RAW_VERSION=${RAW_VERSION%-i386}
    RAW_VERSION=${RAW_VERSION%-docker}
    RAW_VERSION=${RAW_VERSION%-desktop}
    PRETTY_VERSION=${RAW_VERSION:0:2}.${RAW_VERSION:2}
    case ${PRETTY_VERSION} in
    20.04)
        PRETTY_VERSION="20.04.3 Focal Fossa"
        ;;
    18.04)
        PRETTY_VERSION="18.04.5 Bionic Beaver"
        ;;
    esac

    VIRTUALBOX_VERSION=$(VirtualBox --help | head -n 1 | awk '{print $NF}')
    VMWARE_VERSION=$(vmrun | sed -n '2p' | awk '{print $(NF-1)}')
    SHORT_DESCRIPTION="Ubuntu${EDITION_STRING} ${PRETTY_VERSION} (${BIT_STRING})${DOCKER_STRING}"
}

create_description() {
    if [[ "${BOX_NAME}" =~ i386 ]]; then
        BIT_STRING="32-bit"
    else
        BIT_STRING="64-bit"
    fi
    DOCKER_STRING=
    if [[ "${BOX_NAME}" =~ docker ]]; then
        DOCKER_STRING=" with Docker preinstalled"
    fi
    EDITION_STRING=
    if [[ "${BOX_NAME}" =~ desktop ]]; then
        EDITION_STRING=" Desktop"
    else
        EDITION_STRING=" Server"
    fi
    RAW_VERSION=${BOX_NAME#ubuntu}
    RAW_VERSION=${RAW_VERSION%-i386}
    RAW_VERSION=${RAW_VERSION%-docker}
    RAW_VERSION=${RAW_VERSION%-desktop}
    PRETTY_VERSION=${RAW_VERSION:0:2}.${RAW_VERSION:2}
    case ${PRETTY_VERSION} in
    20.04)
        PRETTY_VERSION="20.04.3 Focal Fossa"
        ;;
    18.04)
        PRETTY_VERSION="18.04.5 Bionic Beaver"
        ;;
    esac

    VIRTUALBOX_VERSION=$(VirtualBox --help | head -n 1 | awk '{print $NF}')
    VMWARE_VERSION=$(vmrun | sed -n '2p' | awk '{print $(NF-1)}')

    VMWARE_BOX_FILE=box/vmware/${BOX_NAME}${BOX_SUFFIX}
    VIRTUALBOX_BOX_FILE=box/virtualbox/${BOX_NAME}${BOX_SUFFIX}
    DESCRIPTION="Ubuntu${EDITION_STRING} ${PRETTY_VERSION} (${BIT_STRING})${DOCKER_STRING}

"
    if [[ -e ${VMWARE_BOX_FILE} ]]; then
        FILESIZE=$(du -k -h "${VMWARE_BOX_FILE}" | cut -f1)
        DESCRIPTION=${DESCRIPTION}"VMWare ${FILESIZE}B/"
    fi
    if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
        FILESIZE=$(du -k -h "${VIRTUALBOX_BOX_FILE}" | cut -f1)
        DESCRIPTION=${DESCRIPTION}"VirtualBox ${FILESIZE}B/"
    fi
    DESCRIPTION=${DESCRIPTION%?}

    if [[ -e ${VMWARE_BOX_FILE} ]]; then
        DESCRIPTION="${DESCRIPTION}

VMware Tools ${VMWARE_VERSION}"
    fi
    if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
        DESCRIPTION="${DESCRIPTION}

VirtualBox Guest Additions ${VIRTUALBOX_VERSION}"
    fi

    VERSION_JSON=$(
        jq -n "{
        version: {
          version: \"${VERSION}\",
          description: \"${DESCRIPTION}\"
        }
      }"
    )
}

publish_provider() {
    atlas_username=$1
    atlas_access_token=$2

    echo "==> Checking to see if ${PROVIDER} provider exists"
    HTTP_STATUS=$(curl \
        -s -o /dev/null -w "%{http_code}" \
        --header "Authorization: Bearer ${atlas_access_token}" \
        "${ATLAS_API_URL}/box/${atlas_username}/${BOX_NAME}/version/${VERSION}/provider/${PROVIDER}")

    VMWARE_BOX_FILE=box/vmware/${BOX_NAME}${BOX_SUFFIX}
    VIRTUALBOX_BOX_FILE=box/virtualbox/${BOX_NAME}${BOX_SUFFIX}

    if [ 200 -eq ${HTTP_STATUS} ]; then
        echo "==> Updating ${PROVIDER} provider"
    else
        echo "==> Creating ${PROVIDER} provider"

        JSON=$(
            jq -n "{
                provider: {
                    name: \"${PROVIDER}\"
                }
            }"
        )

        curl \
            --header "Content-Type: application/json" \
            --header "Authorization: Bearer ${atlas_access_token}" \
            "${ATLAS_API_URL}/box/${atlas_username}/${BOX_NAME}/version/${VERSION}/providers" \
            --data "$JSON"
    fi

    FILE=""
    if [[ "vmware_desktop" == "${PROVIDER}" ]]; then
        FILE=${VMWARE_BOX_FILE}
    elif [[ "virtualbox" == "${PROVIDER}" ]]; then
        FILE=${VIRTUALBOX_BOX_FILE}
    fi

    RESULT=$(curl \
        --header "Authorization: Bearer ${atlas_access_token}" \
        "${ATLAS_API_URL}/box/${atlas_username}/${BOX_NAME}/version/${VERSION}/provider/${PROVIDER}/upload")
    UPLOAD_PATH=$(echo "$RESULT" | jq -r .upload_path)
    curl "$UPLOAD_PATH" --request PUT --upload-file $FILE
}

atlas_publish() {
    atlas_username=$1
    atlas_access_token=$2
    ATLAS_API_URL=https://app.vagrantup.com/api/v1/

    echo "==> Checking for existing box ${BOX_NAME} on ${atlas_username}"
    HTTP_STATUS=$(curl \
        -s -o /dev/null -w "%{http_code}" \
        --header "Authorization: Bearer ${atlas_access_token}" \
        "${ATLAS_API_URL}/box/${atlas_username}/${BOX_NAME}")

    if [ 404 -eq ${HTTP_STATUS} ]; then
        echo "${BOX_NAME} does not exist, creating"
        get_short_description

        JSON=$(
            jq -n "{
                box: {
                    username: \"${atlas_username}\",
                    name: \"${BOX_NAME}\",
                    short_description: \"${SHORT_DESCRIPTION}\",
                    is_private: false
                }
            }"
        )

        curl -s \
            --header "Content-Type: application/json" \
            --header "Authorization: Bearer ${atlas_access_token}" \
            "${ATLAS_API_URL}/boxes" \
            --data "$JSON"
    elif [ 200 -ne ${HTTP_STATUS} ]; then
        echo "Unknown status ${HTTP_STATUS} from box/get" && exit 1
    fi

    echo "==> Checking for existing version ${VERSION} on ${atlas_username}"
    HTTP_STATUS=$(curl \
        -s -o /dev/null -w "%{http_code}" \
        --header "Authorization: Bearer ${atlas_access_token}" \
        "${ATLAS_API_URL}/box/${atlas_username}/${BOX_NAME}/version/${VERSION}")

    if [ 404 -ne ${HTTP_STATUS} ] && [ 200 -ne ${HTTP_STATUS} ]; then
        echo "Unknown HTTP status ${HTTP_STATUS} from version/get" && exit 1
    fi

    create_description
    if [ 404 -eq ${HTTP_STATUS} ]; then
        echo "==> none found; creating"
        JSON_RESULT=$(curl \
            --header "Content-Type: application/json" \
            --header "Authorization: Bearer ${atlas_access_token}" \
            "${ATLAS_API_URL}/box/${atlas_username}/${BOX_NAME}/versions" \
            --data "${VERSION_JSON}")
    else
        echo "==> version found; updating on ${atlas_username}"
        JSON_RESULT=$(curl \
            --header "Content-Type: application/json" \
            --header "Authorization: Bearer ${atlas_access_token}" \
            "${ATLAS_API_URL}/box/${atlas_username}/${BOX_NAME}/version/${VERSION}" \
            --request PUT \
            --data "${VERSION_JSON}")
    fi

    if [[ -e ${VMWARE_BOX_FILE} ]]; then
        PROVIDER=vmware_desktop
        publish_provider ${atlas_username} ${atlas_access_token}
    fi
    if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
        PROVIDER=virtualbox
        publish_provider ${atlas_username} ${atlas_access_token}
    fi

    STATUS=$(echo ${JSON_RESULT} | jq -r .status)
    case $STATUS in
    unreleased)
        curl \
            --header "Authorization: Bearer ${atlas_access_token}" \
            --request PUT \
            "${ATLAS_API_URL}/box/${atlas_username}/${BOX_NAME}/version/${VERSION}/release"

        echo 'released!'
        ;;
    active)
        echo 'already released'
        ;;
    *)
        echo "cannot publish version with status '$STATUS'"
        ;;
    esac
}

main() {
    args "$@"
    atlas_publish ${ATLAS_USERNAME} ${ATLAS_ACCESS_TOKEN}
}

main "$@"
