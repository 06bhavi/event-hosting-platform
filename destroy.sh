#!/usr/bin/env bash
# Remove all AWS resources to avoid charges
set -euo pipefail
cd "$(dirname "$0")"
terraform -chdir=terraform destroy -auto-approve
