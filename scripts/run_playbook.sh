#!/bin/bash

ansible-playbook --ask-become-pass playbooks/local.yml $@
