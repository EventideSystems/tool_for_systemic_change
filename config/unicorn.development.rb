# Ansible managed: /Users/tom/Projects/Eventide/wicked_software/deploy/ansible/roles/unicorn/templates/unicorn.rb.j2 modified on 2015-09-08 21:25:14 by tom on Toms-MacBook-Pro.local

working_directory '/wicked_software'

pid '/wicked_software/tmp/unicorn.development.pid'

stderr_path '/wicked_software/log/unicorn.err.log'
stdout_path '/wicked_software/log/unicorn.log'

listen '/tmp/unicorn.development.sock'

worker_processes 2

timeout 30
