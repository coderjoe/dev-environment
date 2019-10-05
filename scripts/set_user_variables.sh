#!/bin/bash

VAR_FILENAME="playbooks/vars/user_variables.yml"

if [ -s "$VAR_FILENAME" ]; then
	exit 0
fi

read -p 'Git Name: ' git_username
read -p 'Git Email: ' git_email
read -p 'Git GPG Signing Key: ' git_signingkey
read -p 'Github Username: ' github_username
read -p 'Github API Token: ' github_token

echo '---' > "$VAR_FILENAME"
[[ ! -z "$git_username" ]] && echo "git_name: $git_username" >> "$VAR_FILENAME"
[[ ! -z "$git_email" ]] && echo "git_email: $git_email" >> "$VAR_FILENAME"
[[ ! -z "$git_signingkey" ]] && echo "git_signingkey: $git_signingkey" >> "$VAR_FILENAME"
[[ ! -z "$git_username" ]] && echo "github_username: $github_username" >> "$VAR_FILENAME"
[[ ! -z "$git_token" ]] && echo "github_token: $github_token" >> "$VAR_FILENAME"
