#!/bin/bash

ansible-playbook $@ -vvvv -i inventory ../ansible/deploy.yml
