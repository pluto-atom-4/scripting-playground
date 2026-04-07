# Sample Data Files for Interview Practice

This directory contains realistic data files to support hands-on exercises from the 16-hour learning guide. All files are designed for copy-paste practice and real-world scenario simulation.

## Files Overview

### Log Files

- **`access.log`** — Apache/nginx access log in Common Log Format. Use for:
  - `grep` exercises: finding specific status codes, IPs, timestamps
  - `awk` exercises: parsing fields, counting requests, calculating statistics
  - Real scenario: "Find all 503 errors and identify top IPs"

- **`error.log`** — Apache error log with PHP, MySQL, and system errors. Use for:
  - Identifying error patterns and severity levels
  - Finding error causes in deployment scenarios
  - Practice: "Extract all database connection errors"

### Database

- **`wordpress.sql`** — WordPress database schema and sample data. Use for:
  - SQL practice (SELECT, JOIN, WHERE, GROUP BY)
  - WordPress table structure familiarity
  - Queries: listing published posts, finding users with most posts, checking spam comments
  - Practice: "Migrate site to new URL" (UPDATE wp_options)

### Configuration Files

- **`vhost.conf`** — Apache virtual host configuration. Use for:
  - Understanding WordPress hosting setup
  - Security headers and rewrite rules practice
  - Troubleshooting: "Enable mod_rewrite for WordPress" or "Add security headers"
  - `sed` exercises: changing domain names, paths, or module settings

- **`php.ini`** — PHP configuration sample. Use for:
  - Memory, timeout, and upload size settings practice
  - Troubleshooting: "Site memory exhausted" scenarios
  - `sed`/`grep` exercises: finding and modifying settings

- **`backup.conf`** — Backup configuration. Use for:
  - Automation script practice
  - Deployment scenario: "Design a backup system for 100 WordPress sites"
  - Parsing: extract configuration values with `grep`, `awk`, or `sed`

## Quick Practice Examples

### Using access.log
```bash
# Find all 503 errors
grep " 503 " sample-data/access.log

# Count requests by IP (top 5)
awk '{print $1}' sample-data/access.log | sort | uniq -c | sort -rn | head -5

# Find POST requests to wp-admin
grep "POST.*wp-admin" sample-data/access.log
```

### Using error.log
```bash
# Extract errors (skip warnings)
grep "\[error\]" sample-data/error.log

# Find database errors
grep -i "database\|mysql" sample-data/error.log

# Count errors by type
grep "\[error\]" sample-data/error.log | awk -F'] ' '{print $NF}' | sort | uniq -c | sort -rn
```

### Using wordpress.sql
```bash
# Load into SQLite for testing
sqlite3 wordpress_practice.db < sample-data/wordpress.sql

# List all published posts
sqlite3 wordpress_practice.db "SELECT post_title, post_author, post_date FROM wp_posts WHERE post_status = 'publish' ORDER BY post_date DESC;"
```

### Using config files
```bash
# Extract PHP memory limit
grep "memory_limit" sample-data/php.ini

# Find all security-related lines in vhost.conf
grep -i "security\|header\|ssl" sample-data/vhost.conf

# Extract database settings from backup.conf
grep -A 5 "\[database\]" sample-data/backup.conf
```

## Integration with Learning Guide

These files directly support exercises in `docs/INTERVIEW-PREP-16-HOURS.md`:

- **Hours 1–2 (Shell Scripting):** Use `access.log` and `error.log`
- **Hours 3–4 (SQL & Databases):** Use `wordpress.sql`
- **Hours 5–6 (WordPress Hosting):** Use `vhost.conf`, `php.ini`, and `wordpress.sql`
- **Hours 7–8 (Automation):** Use `backup.conf` and create scripts that parse these files

## Notes

- These are simplified versions of real logs/configs for learning purposes
- Add more realistic data as needed for specific practice scenarios
- All files are safe to modify—create backups before destructive operations like in-place editing
- Use these in isolated environments (local terminal, Docker containers, test servers—never production)

## Interview Talking Points

When practicing with these files, be ready to explain:
- What you're searching for and why
- How you'd scale this to thousands of websites
- What automation or monitoring you'd add
- How you'd integrate this into incident response workflow
