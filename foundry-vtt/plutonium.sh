#!/bin/sh

# This patch script is for use with the felddy/foundryvtt Docker container.
# See: https://github.com/felddy/foundryvtt-docker#readme

# Installs the Plutonium module if it is not yet installed, and then patches the
# Foundry server to call the Plutonium backend.

MAIN_JS="${FOUNDRY_HOME}/resources/app/main.mjs"
PATCHED_MAIN_JS="https://raw.githubusercontent.com/christopher-schneider/Dockerized/main/foundry-vtt/main.mjs"
MODULE_BACKEND_JS="/data/Data/modules/plutonium/server/${FOUNDRY_VERSION:0:3}.x/plutonium-backend.mjs"
MODULE_DIR="/data/Data/modules"
MODULE_URL="https://raw.githubusercontent.com/TheGiddyLimit/plutonium-next/master/plutonium-foundry08.zip"
MODULE_DOC_URL="https://wiki.5e.tools/index.php/FoundryTool_Install"
SUPPORTED_VERSIONS="0.6.5 0.6.6 0.7.1 0.7.2 0.7.3 0.7.4 0.7.5 0.7.6 0.7.7 0.7.8 0.7.9 0.7.10 0.8.8"
WORKDIR=$(mktemp -d)
ZIP_FILE="${WORKDIR}/plutonium-foundry08.zip"


# log "MAIN_JS = ${MAIN_JS}"
# log "MODULE_BACKEND_JS = ${MODULE_BACKEND_JS}"
# log "MODULE_DIR = ${MODULE_DIR}"
# log "MODULE_URL = ${MODULE_URL}"
# log "MODULE_DOC_URL = ${MODULE_DOC_URL}"
# log "SUPPORTED_VERSIONS = ${SUPPORTED_VERSIONS}"
# log "WORKDIR = ${WORKDIR}"
# log "ZIP_FILE = ${ZIP_FILE}"

log "Installing Plutonium module and backend."
log "See: ${MODULE_DOC_URL}"
if [ -z "${SUPPORTED_VERSIONS##*$FOUNDRY_VERSION*}" ] ; then
  log "This patch has been tested with Foundry Virtual Tabletop ${FOUNDRY_VERSION}"
else
  log_warn "This patch has not been tested with Foundry Virtual Tabletop ${FOUNDRY_VERSION}"
fi
if [ ! -f $MODULE_BACKEND_JS ]; then
  log "Downloading Plutonium module."
  curl --output "${ZIP_FILE}" "${MODULE_URL}" 2>&1 | tr "\r" "\n"
  log "Ensuring module directory exists."
  mkdir -p "${MODULE_DIR}"
  log "Installing Plutonium module."
  unzip -o "${ZIP_FILE}" -d "${MODULE_DIR}"
fi
log "Installing Plutonium backend."
cp "${MODULE_BACKEND_JS}" "${FOUNDRY_HOME}/resources/app/"
log "Patching main.mjs to use plutonium-backend."
rm "${MAIN_JS}"
curl -o "${FOUNDRY_HOME}/resources/app/main.mjs" "${PATCHED_MAIN_JS}"
log "Plutonium backend patch was applied successfully."
log "Plutonium art and media tools will be enabled."
log "Cleaning up."
rm -r ${WORKDIR}