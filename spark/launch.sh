#!/usr/bin/env bash

set -euf -o pipefail

# Global variables
REPO_URL="https://dlcdn.apache.org/spark"
CURL="/usr/bin/curl"
SHA512SUM="/usr/bin/sha512sum"
ECHO="/usr/bin/echo"
RM="/usr/bin/rm"

if [ "${#}" -ne 1 ]; then
    "${ECHO}" "Usage ${0} <spark-version>"
    exit 1
fi

sparkVersion="${1}"
if [[ ! "${sparkVersion}" =~ ^[0-9](\.[0-9]){2}$ ]]; then
    "${ECHO}" "Spark version should be provided in N.N.N format"
    exit 1
fi

# Let's check if the provided version is still available on the main Apache repository
if ! "${CURL}" --head --silent --output /dev/null "${REPO_URL}/spark-${sparkVersion}"; then
    "${ECHO}" "Unable to find this version of Spark on ${REPO_URL}"
    exit 1
fi

# Build the archive name with the provided information
sparkDlPath="${REPO_URL}/spark-${sparkVersion}"
sparkArchive="spark-${sparkVersion}-bin-hadoop3.tgz"
sparkSHA512="${sparkArchive}.sha512"

# Now let's try to dl the sha512 of the tgz
"${ECHO}" "Downloading the ${sparkSHA512} SHA512 file"
if ! "${CURL}" --silent -O "${sparkDlPath}/${sparkSHA512}"; then
    "${ECHO}" "Unable to download ${sparkDlPath}/${sparkSHA512}"
    exit 1
fi

# To gain time, if the TGZ is already downloaded, check if the SHA512 is matching, if not rm & dl
if [ ! -f "${sparkArchive}" ]; then
    "${ECHO}" "No archive found, downloading it..."
    if ! "${CURL}" --silent -O "${sparkDlPath}/${sparkArchive}"; then
        "${ECHO}" "Unable to download ${sparkDlPath}/${sparkArchive}"
        exit 1
    fi
fi
"${ECHO}" "Checking if the archive is corrupted"
if ! "${SHA512SUM}" --check "${sparkSHA512}"; then
    "${ECHO}" "The archive is corrupted, removing it, relaunch the script to download it"
    "${RM}" "${sparkArchive}"
    exit 1
fi

docker build -t apache-spark:${sparkVersion} --build-arg SPARK_VERSION=${sparkVersion} .