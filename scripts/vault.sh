#!/bin/bash
set -e
set -u
set -o pipefail

VAULT_PASSWORD_BASE="vault-password"

do_help() {
	echo "Usage: $(basename $0) [-r <gpg id>] [-l] [-u]"
	echo ""
	echo "Options:"
	echo "   -c <gpg id>   Create a new vault with a new password and encrypt"
	echo "                 it for the given GPG ID"
	echo "   -r <gpg id>   Rekey the ansible vault with a new password and"
	echo "                 encrypt it for the given GPG ID"
	echo "   -u            Unlock the ansible vault"
	echo "   -l            Lock the ansible vault"
	echo "   -h            Print this help"
}

verify_prerequisits() {
	if ! [ -x "$(command -v pwgen)" ]; then
		echo 'Error: Cannot generate a random password.'
		echo "Please install the 'pwgen' tool"
		exit 1
	fi
}

plaintext_file() {
	local base_file="${1:-$VAULT_PASSWORD_BASE}"
	echo ".$base_file"
}

encrypted_file() {
	local base_file="${1:-$VAULT_PASSWORD_BASE}"
	echo "${base_file}.gpg"
}

password_is_unlocked() {
	local base_file="$1"
	if ! [ -f "$(plaintext_file $base_file)" ]; then
		return 1
	fi
	return 0
}

password_exists() {
	local base_file="$1"
	if [ -f "$(encrypted_file $base_file)" ]; then
		return 0
	fi
	return 1
}

generate_new_password() {
	local base_file="$1"
	local gpg_id="$2"

	local encrypted_file="$(encrypted_file $base_file)"
	local password_file="$(plaintext_file $base_file)"

	if password_exists "$base_file"; then
		echo "An existing vault password already exists. Aborting!"
		return 1
	fi

	if (pwgen -s -C 80 1 > "$password_file"); then
		if cat "$password_file" | gpg --armor --recipient "$gpg_id" -e -o "$encrypted_file"; then
			echo "New password generated and encrypted for $gpg_id at $encrypted_file"
			unlock_vault "$base_file"
			return 0
		else
			echo "Password was generated, but encryption failed! Aborting!"
			return 1
		fi
	else
		echo "Unexpected error durring password generation! Aborting!"
		return 1
	fi
}

unlock_vault() {
	local base_file="$1"
	local encrypted_file="$(encrypted_file $base_file)"
	local password_file="$(plaintext_file $base_file)"

	if ! password_is_unlocked "$base_file"; then
		if ! gpg --batch --use-agent --decrypt "$encrypted_file" > "$password_file"; then
			echo "Password unlock of $encrypted_file failed. Aborting!"
			return 1
		fi
	fi

	return 0
}

do_vault_create() {
	local base_file="$VAULT_PASSWORD_BASE"
	local gpg_id="$1"
	generate_new_password "$base_file" "$gpg_id"
	echo "Your vault is unlocked, lock it when you are done!"
	exit 0
}

do_vault_rekey() {
	local gpg_id="$1"
	local old_base_file="$VAULT_PASSWORD_BASE"
	local new_base_file="new-$old_base_file"

	if ! password_exists "$old_base_file"; then
		echo "No password exists yet! Create one first!"
		exit 1
	fi

	if ! password_is_unlocked "$old_base_file"; then
		echo "Please unlock the vault first!"
		exit 1
	fi

	generate_new_password "$new_base_file" "$gpg_id"

	echo "Rekeying files..."
	while read -r filename ; do
		echo "   ${filename}"
		ansible-vault --new-vault-password-file="$(plaintext_file "$new_base_file")" rekey "${filename}"
	done < <(grep -rl '^$ANSIBLE_VAULT.*' .)

	echo "Removing old key..."
	mv "$(encrypted_file "$new_base_file")" "$(encrypted_file "$old_base_file")"
	mv "$(plaintext_file "$new_base_file")" "$(plaintext_file "$old_base_file")"

	echo "... rekey complete!"
}

do_vault_unlock() {
	local base_file="$VAULT_PASSWORD_BASE"
	if password_exists "$base_file"; then
		if unlock_vault "$base_file"; then
			echo "Your vault is unlocked, lock it when you are done!"
			exit 0
		fi
	else
		echo "No password found. Nothing to unlock!"
		exit 1
	fi
}

do_vault_lock() {
	local base_file="$VAULT_PASSWORD_BASE"
	if password_is_unlocked "$base_file"; then
		rm "$(plaintext_file "$base_file")"
		echo "Vault is locked."
		exit 0
	else
		echo "Vault is already locked!"
		exit 1
	fi
}

if [[ $# -eq 0 ]]; then
	do_help
	exit 1
fi

verify_prerequisits

while getopts 'c:r:ulh' OPTION; do
	case "$OPTION" in
		c)
			do_vault_create $OPTARG
			;;
		r)
			do_vault_rekey $OPTARG
			;;
		u)
			do_vault_unlock
			;;
		l)
			do_vault_lock
			;;
		h)
			do_help
			;;
		?)
			echo "Unknown option '$OPTION'"
			do_help
	esac
done
shift "$(($OPTIND -1))"
