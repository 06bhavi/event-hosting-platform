#!/usr/bin/env bash
# One-command deployment: Terraform -> wait for SSH -> Ansible (web, Nagios, Puppet)
set -euo pipefail
cd "$(dirname "$0")"

KEY="$HOME/.ssh/event-platform-key"
NAGIOS_PASSWORD="${NAGIOS_PASSWORD:-Nagios@123}"

echo "==> [1/4] Creating infrastructure with Terraform"
terraform -chdir=terraform init -input=false
terraform -chdir=terraform apply -auto-approve -input=false

WEB_IP=$(terraform -chdir=terraform output -raw web_public_ip)
NAGIOS_IP=$(terraform -chdir=terraform output -raw nagios_public_ip)

echo "==> [2/4] Waiting for SSH on both servers"
for ip in "$WEB_IP" "$NAGIOS_IP"; do
  for i in $(seq 1 40); do
    if ssh -i "$KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o BatchMode=yes ubuntu@"$ip" true 2>/dev/null; then
      echo "    $ip is ready"
      break
    fi
    [ "$i" -eq 40 ] && { echo "SSH to $ip timed out"; exit 1; }
    sleep 5
  done
done

echo "==> [3/4] Configuring servers with Ansible (website, Nagios, Puppet)"
( cd ansible && ansible-playbook site.yml -e "nagios_password=${NAGIOS_PASSWORD}" )

echo "==> [4/4] Done"
echo "    Website : http://${WEB_IP}"
echo "    Nagios  : http://${NAGIOS_IP}/nagios4   (user: nagiosadmin)"
