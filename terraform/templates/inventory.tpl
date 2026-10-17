[web]
web-server ansible_host=${web_ip} private_ip=${web_private_ip}

[monitoring]
nagios-server ansible_host=${nagios_ip}

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/event-platform-key
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
