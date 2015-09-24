#!/bin/bash

ansible-playbook $@ -s -u root -i inventory ../ansible/server-site.yml
