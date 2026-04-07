#!/bin/bash
# deploy-sites.sh - Sample deployment script for practice
# Practice using: grep, sed, awk, and bash scripting

set -e

# Configuration
SITES_CSV="sample-data/sites-inventory.csv"
BACKUP_DIR="/backups"
LOG_FILE="/var/log/deploy.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Parse CSV and extract active sites
# Usage: get_active_sites
get_active_sites() {
    grep ",active," "$SITES_CSV" | cut -d',' -f2 | grep -v "site_name"
}

# Get site URL from CSV by name
# Usage: get_site_url "site_name"
get_site_url() {
    local site_name=$1
    grep ",$site_name," "$SITES_CSV" | cut -d',' -f3
}

# Get WordPress version for a site
# Usage: get_wp_version "site_name"
get_wp_version() {
    local site_name=$1
    grep ",$site_name," "$SITES_CSV" | cut -d',' -f5
}

# Check if backup is recent (within 3 days)
# Usage: backup_is_recent "2026-04-01"
backup_is_recent() {
    local backup_date=$1
    local current_date=$(date +%s)
    local backup_timestamp=$(date -d "$backup_date" +%s 2>/dev/null || echo 0)
    local days_old=$(( ($current_date - $backup_timestamp) / 86400 ))
    
    if [ $days_old -lt 3 ]; then
        return 0
    else
        return 1
    fi
}

# Main function
main() {
    log "Starting deployment check..."
    
    # Count total sites
    local total_sites=$(grep -c "," "$SITES_CSV" || echo 0)
    log "Total sites in inventory: $total_sites"
    
    # Get active sites count
    local active_sites=$(get_active_sites | wc -l)
    log "Active sites: $active_sites"
    
    # Check for outdated backups
    log "Checking backup status..."
    while IFS=',' read -r site_id site_name site_url admin_email wp_version last_backup status php_version ssl cert disk_usage; do
        if [ "$status" = "active" ]; then
            if ! backup_is_recent "$last_backup"; then
                warning "Site '$site_name' has stale backup (from $last_backup)"
            fi
        fi
    done < "$SITES_CSV"
    
    log "Deployment check complete"
}

# Run main function if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main
fi
