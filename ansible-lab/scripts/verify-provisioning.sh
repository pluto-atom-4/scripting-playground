#!/bin/bash
# verify-provisioning.sh — Quick verification of full stack provisioning
# Location: ansible-lab/scripts/verify-provisioning.sh
# Usage: ./scripts/verify-provisioning.sh

set -e

echo "=== Checking Apache on Ovid ==="
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8080/
curl -s http://localhost:8080/ | grep -o "<title>.*</title>"

echo ""
echo "=== Checking MySQL on Vergil ==="
docker exec vergil mysql -u wp_admin -p'ChangeMe_2026!' -e "SELECT 'MySQL OK' AS status;" 2>/dev/null
docker exec vergil mysql -u wp_admin -p'ChangeMe_2026!' -e "SHOW DATABASES;" 2>/dev/null | grep wp_debian

echo ""
echo "=== Ansible inventory check ==="
ansible all -m ping
