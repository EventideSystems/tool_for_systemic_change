#!/bin/bash

ansible-playbook $@ -s -u root -i inventory ../ansible/site.yml
