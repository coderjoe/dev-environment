#!/bin/bash

echo "Detecting installed ansible..."
command -v ansible-playbook > /dev/null
if [ $? -eq 1 ]; then
	echo "You don't seem to have ansible installed."
	read -n 1 -p "Would you like to install it? (Y/n): " $install_ansible
	install_ansible=${install_ansible:-y}
	if [[ $install_ansible =~ ^[Yy] ]]; then
		echo "Installing the system ansible..."
		sudo apt install ansible
	else
		"Ok. Quitting."
		exit 1
	fi
fi

echo "Upgrading to the latest stable ansible..."
ansible-playbook --ask-become-pass playbooks/install_ansible.yml
