#!/usr/bin/env bash
set -e

if [[ -z $1 || -z $2 || "$1" == '-h' || "$1" == '--help' ]]; then
    printf "Generate a GPG master and encryption subkey\n\n"
    printf "Usage: generate-master.sh NAME EMAIL [SECUREDIR]\n"
    exit 1
fi

function log {
    local msg="\e[34m${1}%s\e[0m\n"
    shift
    # shellcheck disable=SC2059
    printf "$msg" "$@"
}

key_name=$1
key_email=$2
SECUREDIR=${3:-secure}

if [[ ! -d $SECUREDIR ]]; then
    printf "\`%s' does not exist\n" "$SECUREDIR"
    exit 1
fi

export GNUPGHOME="$SECUREDIR/gnupg-home"
(umask 077; mkdir -p "$GNUPGHOME")

log 'Generating master key and encryption subkey for "%s" <%s>' "$key_name" "$key_email"
gpg_output=$(gpg --command-fd 0 --status-fd 2 --no-tty \
    --gen-key --batch 2>&1 << EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Key-Usage: ,
Name-Real: $key_name
Name-Email: $key_email
Expire-Date: 1y
Subkey-Type: RSA
Subkey-Length: 2048
Subkey-Usage: encrypt
%commit
EOF
)
key_id=$(sed -n 's/^\[GNUPG:\] KEY_CREATED [PB] \([A-F0-9]\{40\}\)$/\1/p' <<<"$gpg_output")
log "Key ID is %s" "$key_id"
