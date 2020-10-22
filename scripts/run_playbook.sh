#!/bin/bash

if [[ $SKIP_ANSIBLE_INSTALL && ${SKIP_ANSIBLE_INSTALL-x} ]]; then
	ansible-playbook --extra-vars "skip_ansible_install=true" --ask-become-pass playbooks/local.yml $@
else
	ansible-playbook --ask-become-pass playbooks/local.yml $@
fi
