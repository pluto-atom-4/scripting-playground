# Quick Practice Exercises

This file contains hands-on exercises using the sample data files. These are designed for rapid skill building—run them in order.

## Setup
```bash
cd /path/to/scripting-playground
ls sample-data/  # Verify all files are present
```

---

## Shell Scripting Exercises (Hours 1–2)

### Grep Drills
```bash
# 1. Find all 4xx and 5xx errors in access log
grep -E " [45][0-9]{2} " sample-data/access.log

# 2. Count how many times each IP appears
grep -oE "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" sample-data/access.log | sort | uniq -c | sort -rn

# 3. Find all POST requests
grep "POST" sample-data/access.log

# 4. Extract errors from error.log
grep "\[error\]" sample-data/error.log

# 5. Find all database connection errors (case-insensitive)
grep -i "database\|connection" sample-data/error.log
```

### Sed Exercises
```bash
# 1. Replace old domain with new domain (non-destructive)
sed 's/example.edu/newuniversity.edu/g' sample-data/vhost.conf

# 2. Extract just the hostnames from vhost.conf
sed -n 's/ServerName //p' sample-data/vhost.conf

# 3. Comment out all RewriteCond lines
sed 's/^RewriteCond/#RewriteCond/' sample-data/vhost.conf

# 4. Delete all warning lines from error.log
sed '/\[warn\]/d' sample-data/error.log

# 5. Extract line numbers for critical errors
sed -n '/\[crit\]/=' sample-data/error.log
```

### Awk Exercises
```bash
# 1. Extract IP and status code from access log
awk '{print $1, $9}' sample-data/access.log

# 2. Sum all bytes transferred (last field)
awk '{sum += $10} END {print "Total bytes transferred:", sum}' sample-data/access.log

# 3. Count requests by status code
awk '{print $9}' sample-data/access.log | sort | uniq -c | sort -rn

# 4. Find all requests over 2000 bytes
awk '$10 > 2000 {print $1, $4, $7, $10}' sample-data/access.log

# 5. Parse CSV sites inventory - list all active sites
awk -F',' '$7 == "active" {print $2 " (" $6 ")"}' sample-data/sites-inventory.csv
```

---

## Database Exercises (Hours 3–4)

### Using SQLite (lightweight practice)
```bash
# 1. Create database and load WordPress schema
sqlite3 wordpress_practice.db < sample-data/wordpress.sql

# 2. List all published posts
sqlite3 wordpress_practice.db \
  "SELECT post_title, user_login, post_date 
   FROM wp_posts 
   JOIN wp_users ON post_author = ID 
   WHERE post_status = 'publish' 
   ORDER BY post_date DESC;"

# 3. Find users with most posts
sqlite3 wordpress_practice.db \
  "SELECT user_login, COUNT(ID) as post_count 
   FROM wp_users LEFT JOIN wp_posts ON ID = post_author 
   GROUP BY user_login 
   ORDER BY post_count DESC;"

# 4. Check for spam comments
sqlite3 wordpress_practice.db \
  "SELECT comment_author, COUNT(*) as count 
   FROM wp_comments 
   WHERE comment_approved = '0' 
   GROUP BY comment_author 
   ORDER BY count DESC;"

# 5. Simulate migration - update site URL
sqlite3 wordpress_practice.db \
  "UPDATE wp_options 
   SET option_value = 'https://newsite.edu' 
   WHERE option_name = 'siteurl';"
sqlite3 wordpress_practice.db \
  "SELECT option_name, option_value FROM wp_options LIMIT 3;"
```

---

## Configuration & Automation Exercises (Hours 5–8)

### Analyzing CSV Inventory
```bash
# 1. Count sites by status
awk -F',' 'NR>1 {print $7}' sample-data/sites-inventory.csv | sort | uniq -c

# 2. Find all sites with expired SSL certificates
awk -F',' '$9 == "expired" {print $2}' sample-data/sites-inventory.csv

# 3. Calculate total disk usage across all active sites
awk -F',' '$7 == "active" {sum += $10} END {print "Total active disk usage:", sum " GB"}' sample-data/sites-inventory.csv

# 4. List sites with outdated backups (before April 1)
awk -F',' '$6 < "2026-04-01" {print $2 " (last backup: " $6 ")"}' sample-data/sites-inventory.csv

# 5. Generate upgrade priority list (outdated WP version)
awk -F',' '$5 < "6.4.0" {print $2 " (current: " $5 ")"}' sample-data/sites-inventory.csv
```

### Parsing Logs for Incidents
```bash
# 1. Find ERROR-level messages with count
grep "\[ERROR\]" sample-data/backup.log | wc -l

# 2. Extract warning messages
grep "WARNING" sample-data/backup.log

# 3. Find failed backup attempts (with retry info)
grep -A 1 "ERROR" sample-data/backup.log | grep -i "backup"

# 4. Calculate backup success rate from log
awk '
  /Backup complete:/ {complete++}
  /ERROR:/ {failed++}
  END {
    total = complete + failed
    if (total > 0) {
      pct = (complete/total)*100
      print "Success rate:", pct "%"
    }
  }' sample-data/backup.log

# 5. Summary report: find critical issues
grep "CRITICAL" sample-data/backup.log && echo "^-- ACTION REQUIRED"
```

---

## Challenge Scenarios

Try these realistic problems:

### Challenge 1: Incident Response
**Scenario:** "Site is down. Find error patterns in error.log and access.log that indicate the cause."

```bash
# Your approach:
# 1. What time did errors spike?
grep "\[error\]" sample-data/error.log | head -3

# 2. What's the most common error?
grep "\[error\]" sample-data/error.log | awk -F'] ' '{print $(NF-1), $NF}' | sort | uniq -c | sort -rn | head -1

# 3. Which IPs/users are affected?
grep " 503 \|error" sample-data/access.log sample-data/error.log | awk '{print $1}' | sort | uniq -c | sort -rn
```

### Challenge 2: Deployment Planning
**Scenario:** "You need to update WordPress on 50 sites. Identify which ones need backups first."

```bash
# Your approach:
# 1. Find active sites with stale backups
awk -F',' '$7 == "active" && $6 < "2026-03-31" {print $2}' sample-data/sites-inventory.csv

# 2. Identify sites at capacity (disk usage > 10GB)
awk -F',' '$7 == "active" && $10 > 10 {print $2 " (" $10 " GB)"}' sample-data/sites-inventory.csv

# 3. Check SSL certificate status
awk -F',' '$9 != "valid" {print $2 " - " $9}' sample-data/sites-inventory.csv
```

### Challenge 3: Configuration Review
**Scenario:** "Audit the Apache config for security issues. Identify missing headers or misconfigurations."

```bash
# Your approach:
# 1. Check if security headers are in place
grep -i "X-Frame-Options\|X-Content-Type\|X-XSS" sample-data/vhost.conf

# 2. Verify rewrite rules are present
grep "RewriteEngine" sample-data/vhost.conf

# 3. Check SSL protocol configuration
grep -i "ssl" sample-data/vhost.conf | grep -i "protocol\|cipher"
```

---

## Next Steps

After completing these exercises:
1. Modify the sample data to create new scenarios
2. Write your own bash scripts using sample data as input
3. Combine grep + awk + sed in multi-step pipelines
4. Time yourself on challenges to build speed
5. Practice explaining what each command does in interview context

## Tips

- Always preview data before using destructive operations (`-i` flag with sed)
- Use `head` and `tail` to examine log structure
- Count results to verify your filters are working: `| wc -l`
- Create variations: modify filenames, search patterns, field numbers
- Redirection is your friend: `> output.txt` or `>> append.txt`
