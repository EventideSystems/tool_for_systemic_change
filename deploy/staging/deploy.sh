#!/bin/bash

ansible-playbook -v $@ -i inventory ../ansible/server-deploy.yml
