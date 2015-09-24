#!/bin/bash

ansible-playbook $@ -i inventory ../ansible/server-deploy.yml
