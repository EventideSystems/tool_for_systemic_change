#!/bin/bash

ansible-playbook $@ -vvvv -s -u root -i inventory ../ansible/site.yml
