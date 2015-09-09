#!/bin/bash

ansible-playbook $@ -s -u ubuntu -i inventory ../ansible/site.yml
