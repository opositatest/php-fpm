#!/bin/bash

set -euo pipefail

SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_NAME

TEMP_DIR=$(mktemp -d)
readonly TEMP_DIR

readonly SLACK_FILE="${TEMP_DIR}/error.txt"

cleanup() {
    rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

DRY_RUN=0
PROJECT_NAME=""
COMMAND_RUN=""

check_dependencies() {
    local missing=()
    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: Missing dependencies: ${missing[*]}" >&2
        exit 1
    fi
}

usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [-d] project_name command_run

Options:
    -d          Dry-run mode (only displays content, does not send to Slack)
    -h          Show this help message

Arguments:
    project_name    Name of the project
    command_run     Command that generated the error

Required environment variables:
    SLACK_TOKEN     Slack authentication token
    SLACK_CHANNEL   Channel to send the message to

The script reads errors from stdin.

Note: project_name and command_run are now required arguments (previously defaulted to "not found").
EOF
    exit 2
}

validate_env() {
    if [[ -z "${SLACK_TOKEN:-}" ]]; then
        echo "Error: SLACK_TOKEN is not set" >&2
        exit 1
    fi
    
    if [[ -z "${SLACK_CHANNEL:-}" ]]; then
        echo "Error: SLACK_CHANNEL is not set" >&2
        exit 1
    fi
}

while getopts "dh" name; do
    case $name in
        d)  DRY_RUN=1 ;;
        h)  usage ;;
        ?)  usage ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -lt 2 ]]; then
    echo "Error: 2 arguments required (project_name and command_run)" >&2
    usage
fi

PROJECT_NAME="$1"
COMMAND_RUN="$2"

IN_ERRORS="$(cat)"

if [[ -z "${IN_ERRORS}" ]]; then
    exit 0
fi

check_dependencies
validate_env

printf '%s' "${IN_ERRORS}" > "${SLACK_FILE}"

if [[ ${DRY_RUN} -eq 1 ]]; then
    echo "=== DRY-RUN MODE ==="
    echo "Content that would be sent to Slack:"
    cat "${SLACK_FILE}"
    exit 0
fi

# Prepare message
SLACK_COMMENT="Please, look at this error
Project: *${PROJECT_NAME}*
Command: _${COMMAND_RUN}_"

FILE_SIZE=$(stat -c%s "${SLACK_FILE}" 2>/dev/null)

RESULT=$(
    curl --silent --fail --show-error \
        --max-time 30 \
        -L https://slack.com/api/files.getUploadURLExternal \
        --data-urlencode "filename=${SLACK_FILE##*/}" \
        --data-urlencode "length=${FILE_SIZE}" \
        -H "Authorization: Bearer ${SLACK_TOKEN}" 2>&1
) || {
    echo "Error in files.getUploadURLExternal request: $RESULT" >&2
    exit 1
}

OK=$(echo "$RESULT" | jq -r '.ok')
UPLOAD_URL=$(echo "$RESULT" | jq -r '.upload_url // empty')
FILE_ID=$(echo "$RESULT" | jq -r '.file_id // empty')

if [[ "$OK" != "true" ]]; then
    echo "Error in files.getUploadURLExternal: $RESULT" >&2
    exit 1
fi

if [[ -z "$UPLOAD_URL" || -z "$FILE_ID" ]]; then
    echo "Error: Upload URL or file_id not received" >&2
    exit 1
fi

UPLOAD_RESULT=$(
    curl --silent --fail --show-error \
        --max-time 60 \
        -L "${UPLOAD_URL}" \
        -H 'Content-Type: application/octet-stream' \
        --data-binary @"${SLACK_FILE}" 2>&1
) || {
    echo "Error uploading file: $UPLOAD_RESULT" >&2
    exit 1
}

if [[ "$UPLOAD_RESULT" =~ ^OK\ -\ [0-9]+$ ]]; then
    SEND_SIZE="${UPLOAD_RESULT#OK - }"
    if [[ "$SEND_SIZE" != "$FILE_SIZE" ]]; then
        echo "Warning: Sent size ($SEND_SIZE) differs from expected ($FILE_SIZE)" >&2
    fi
else
    echo "Warning: Unexpected upload response format: $UPLOAD_RESULT" >&2
    echo "Proceeding with upload completion anyway..." >&2
fi

FINAL_RESULT=$(
    curl --silent --fail --show-error \
        --max-time 30 \
        -L https://slack.com/api/files.completeUploadExternal \
        --data-urlencode "files=[{\"title\":\"error.txt\", \"id\":\"${FILE_ID}\"}]" \
        --data-urlencode "initial_comment=${SLACK_COMMENT}" \
        --data-urlencode "channel_id=${SLACK_CHANNEL}" \
        -H "Authorization: Bearer ${SLACK_TOKEN}" 2>&1
) || {
    echo "Error in files.completeUploadExternal: $FINAL_RESULT" >&2
    exit 1
}

if [[ "$(echo "$FINAL_RESULT" | jq -r '.ok')" != "true" ]]; then
    echo "Error completing upload: $FINAL_RESULT" >&2
    exit 1
fi

echo "File successfully sent to Slack"

