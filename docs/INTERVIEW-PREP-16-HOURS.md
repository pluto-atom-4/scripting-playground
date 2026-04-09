# UW-IT Software Engineer Interview Prep — 16-Hour Intensive Guide

**Interview Date:** This Friday (2026-04-11)  
**Preparation Time:** ~16 hours  
**Focus:** Shell scripting, databases, WordPress hosting, incident response, automation

---

## 📂 Ready-to-Use Sample Data

**This guide uses real data files for hands-on practice.** All exercises reference files in `sample-data/`:
- `access.log`, `error.log`, `backup.log` — Real log files for shell scripting practice
- `wordpress-sqlite.sql` — WordPress database schema for SQL exercises
- `vhost.conf`, `php.ini`, `backup.conf` — Configuration files for parsing
- `sites-inventory.csv` — Inventory of 10 WordPress sites for analysis
- Plus more in `sample-data/PRACTICE-EXERCISES.md` for additional scenarios

**Start here:** Review `sample-data/README.md` to understand all available files.

---

## Overview & Strategy

This role is **operationally focused** — you'll support ~29,000 websites in a shared hosting environment. The screening interview will test:
- Problem-solving with real hosting scenarios
- Shell scripting proficiency (grep, sed, awk)
- SQL and database operations
- How you handle incidents and scale
- Your ability to explain complex systems simply

**Interview question patterns to expect:**
- "Walk me through how you'd troubleshoot [outage scenario]"
- "Write a script to [log parsing / backup / deployment task]"
- "Tell me about a time you automated something"
- "How would you handle [performance / security issue]?"

---

## Hour-by-Hour Breakdown

### **Hours 1–2: Core Shell Scripting (Grep, Sed, Awk)**
**Goal:** Master log parsing and text transformation (the daily work)

**Topics:**
- `grep`: Finding patterns in logs (errors, IP addresses, timestamps)
- `sed`: In-place editing, substitution, deletion
- `awk`: Field parsing, aggregation, reporting

**Exercises:**

1. **Grep drills** (30 min)
    
    **Use the pre-built sample data file:** `sample-data/access.log`
    
    ```bash
    # Find all 404 errors
    grep "404" sample-data/access.log
    
    # Find all POST requests
    grep "POST" sample-data/access.log
    
    # Count errors (4xx + 5xx)
    grep -E " (4|5)[0-9]{2} " sample-data/access.log | wc -l
    
    # Find specific IP address
    grep "192.168.1.1" sample-data/access.log
    ```
   
   **Key patterns for interviews:**
   - Error logs: `grep -E "(ERROR|FATAL|warning)" logfile`
   - Failed requests: `grep -E " (4|5)[0-9]{2} " access.log`
   - Specific time range: `grep "01/Apr" logfile`

2. **Sed exercises** (30 min)
   
   **Practice with sample config files:** `sample-data/vhost.conf`, `sample-data/php.ini`
   
   ```bash
   # Substitute a value in a config file (test with spaces matching)
   sed 's/mysqli.max_connections = 150/mysqli.max_connections = 300/' sample-data/php.ini
   
   # Replace domain name (don't modify in place yet)
   sed 's/example.edu/newuniversity.edu/g' sample-data/vhost.conf
   
   # Delete lines containing a pattern (test first, no -i flag)
   sed '/SSL/d' sample-data/vhost.conf
   
   # Replace in place (production scenario) - ALWAYS BACKUP FIRST
   cp sample-data/php.ini sample-data/php.ini.bak
   sed -i 's/memory_limit = 512M/memory_limit = 1024M/' sample-data/php.ini
   
   # Undo the change to restore original
   mv sample-data/php.ini.bak sample-data/php.ini
   ```
   
   **Interview tip:** Mention `-i` (in-place) carefully—always backup first!

3. **Awk exercises** (30 min)
   
   **Use sample data files:** `sample-data/access.log`, `sample-data/sites-inventory.csv`
   
   ```bash
   # Parse fields and sum values from access log
   awk '{print $1, $9}' sample-data/access.log  # IP and status code
   
   # Count requests per IP
   awk '{print $1}' sample-data/access.log | sort | uniq -c | sort -rn
   
   # Sum bytes transferred (field 10 in access.log)
   awk '{sum += $10} END {print "Total bytes:", sum}' sample-data/access.log
   
   # Extract errors and format report
   awk '$9 >= 400 {print $1, $9}' sample-data/access.log
   
   # CSV parsing: list active sites from inventory
   awk -F',' '$7 == "active" {print $2}' sample-data/sites-inventory.csv
   ```

**Practice Scenarios (if asked in interview):**
- "Log shows high 503 errors. Write a command to find the top 5 IPs causing them."  
  Answer: `grep "503" sample-data/access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -5`

- "We have 10 sites in inventory. Find which ones have disk usage over 5GB."  
  Answer: `awk -F',' '$10 > 5 {print $2}' sample-data/sites-inventory.csv`

- "Extract all error-level messages from the error log."  
  Answer: `grep "\[error\]" sample-data/error.log`

---

### **Hours 3–4: SQL & Databases (MySQL, PostgreSQL)**
**Goal:** Demonstrate SQL proficiency and operational DB knowledge

**Topics:**
- Basic queries (SELECT, WHERE, JOIN, ORDER BY)
- Backup/restore scenarios
- Performance concepts (indexing, slow queries)
- WordPress database structure (wp_posts, wp_users, wp_options)

**Exercises:**

1. **Setup and load WordPress database** (15 min)
   
   **Use the pre-built WordPress sample data:** `sample-data/wordpress-sqlite.sql`
   
   ```bash
   # Create a SQLite database for lightweight practice (no Docker needed)
   sqlite3 db/wordpress_practice.db < sample-data/wordpress-sqlite.sql
   
   # Verify tables were created
   sqlite3 db/wordpress_practice.db ".tables"
   ```

2. **WordPress database queries** (45 min)
   
   **Run these queries against the loaded database:**
   
   ```bash
   # List all published posts
   sqlite3 db/wordpress_practice.db \
     "SELECT ID, post_title, post_author, post_date FROM wp_posts WHERE post_status = 'publish' ORDER BY post_date DESC;"
   
   # Find users with most posts
   sqlite3 db/wordpress_practice.db \
     "SELECT u.user_login, COUNT(p.ID) as post_count FROM wp_users u LEFT JOIN wp_posts p ON u.ID = p.post_author GROUP BY u.ID ORDER BY post_count DESC;"
   
   # Check for spam comments (unapproved)
   sqlite3 db/wordpress_practice.db \
     "SELECT comment_author, COUNT(*) as count FROM wp_comments WHERE comment_approved = '0' GROUP BY comment_author ORDER BY count DESC;"
   
   # Update a site option (URL migration scenario)
   sqlite3 db/wordpress_practice.db \
     "UPDATE wp_options SET option_value = 'https://newsite.edu' WHERE option_name = 'siteurl';"
   
   # Verify the update
   sqlite3 db/wordpress_practice.db \
     "SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');"
   ```

3. **Operational scenarios** (30 min)
   - **Scenario A:** A site is running slowly. How do you identify slow queries?
     ```sql
     -- Enable slow query log
     SET GLOBAL slow_query_log = 'ON';
     SET GLOBAL long_query_time = 2;
     
     -- Later, check the log
     SHOW VARIABLES LIKE 'slow_query_log_file';
     ```
   
   - **Scenario B:** A database backup failed. What's your approach?
     - Check disk space: `df -h`
     - Check MySQL process: `mysqladmin status`
     - Verify credentials and permissions
     - Example fix: `mysqldump -u root -p --single-transaction --quick wordpress > backup.sql`

**Interview talking points:**
- "We'd monitor slow-query logs to identify problematic queries"
- "I'd use `--single-transaction` for InnoDB to avoid locks"
- "Always backup before major changes like URL migrations"

---

### **Hours 5–6: WordPress Hosting & Administration**
**Goal:** Speak credibly about WordPress at scale

**Topics:**
- Plugin/theme management
- Security basics (backups, updates, access control)
- Performance optimization
- Common hosting issues

**Study areas (read these):**

1. **WordPress Security Checklist** (20 min read)
   - Keep WordPress, plugins, themes updated
   - Use strong passwords, limit login attempts
   - Regular backups (automated)
   - Disable file editing (`DISALLOW_FILE_EDIT = true`)
   - Move wp-config.php outside web root
   - Disable directory listing (`.htaccess` or nginx config)

2. **Common WordPress Issues You'll Support** (30 min)
   
   **Practice log analysis:** Use `sample-data/error.log`, `sample-data/access.log`, and loaded `wordpress-sqlite.sql` database
   
   ```
   a) "Site won't load" scenarios:
      - Check Apache error log: grep "\[error\]" sample-data/error.log
      - Look for database errors: grep -i "database\|connection" sample-data/error.log
      - Check for memory issues: grep -i "memory" sample-data/error.log
      - Review for timeouts: grep -i "timeout" sample-data/error.log
   
   b) Slow site diagnosis:
      - Check for database query issues: grep -i "query" sample-data/error.log
      - Look for PHP warnings: grep "\[warn\]" sample-data/error.log
      - Review access patterns: grep " 5[0-9][0-9] " sample-data/access.log
      - Identify high-traffic IPs: awk '{print $1}' sample-data/access.log | sort | uniq -c | sort -rn
   
   c) Hacked/malware:
      - Look for suspicious access patterns: grep "eval\|base64\|passthru" sample-data/error.log
      - Check for suspicious file access: grep "/wp-admin" sample-data/access.log
      - Review user account activities: sqlite3 db/wordpress_practice.db "SELECT * FROM wp_users;"
      - Verify no extra admin accounts were created
   ```

3. **LAMP Stack Basics** (10 min)
   - **L**inux: the OS
   - **A**pache (or nginx): web server
   - **M**ySQL: database
   - **P**HP: application runtime
   
   Know how to:
   - Restart Apache: `systemctl restart apache2`
   - Check PHP version: `php -v`
   - Verify modules: `apache2ctl -M | grep rewrite`

**Real interview scenario to practice:**
> "We have 100 WordPress sites, and a plugin update went wrong on 20 of them. Walk me through your approach to fix them at scale."

**Answer structure:**
1. Don't panic; assess scope and impact
2. Isolate: disable the problematic plugin on affected sites
3. Restore: revert from backup if needed
4. Test: verify on 1–2 sites before rolling out
5. Automate: use a script or bulk tool to apply fix across sites
6. Document: post-mortem on what went wrong and prevention

---

### **Hours 7–8: Automation & Deployment**
**Goal:** Show you can think in terms of automation

**Topics:**
- Writing deployment scripts
- Patch management
- Configuration management concepts
- Monitoring & alerting mindset

**Exercises:**

1. **Write a deployment script** (30 min)
   ```bash
   #!/bin/bash
   # deploy-wordpress-update.sh
   # Safely update WordPress core across multiple sites
   
   set -e  # Exit on error
   
   SITES_DIR="/var/www/html"
   BACKUP_DIR="/backups"
   LOG_FILE="/var/log/deploy.log"
   DATE=$(date +%Y%m%d_%H%M%S)
   
   log() {
       echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
   }
   
   backup_site() {
       local site=$1
       log "Backing up $site..."
       cp -r "$SITES_DIR/$site" "$BACKUP_DIR/${site}_${DATE}.backup"
   }
   
   update_wordpress() {
       local site=$1
       log "Updating $site..."
       cd "$SITES_DIR/$site"
       
       # Maintenance mode
       touch .maintenance
       echo '<?php wp_die( "Maintenance mode" ); ?>' > .maintenance
       
       # Download and extract latest
       wp core update --allow-root
       
       # Run migrations
       wp core update-db --allow-root
       
       # Exit maintenance mode
       rm -f .maintenance
       
       log "Updated $site successfully"
   }
   
   rollback_site() {
       local site=$1
       log "Rolling back $site to backup..."
       rm -rf "$SITES_DIR/$site"
       cp -r "$BACKUP_DIR/${site}_${DATE}.backup" "$SITES_DIR/$site"
       log "Rollback complete for $site"
   }
   
   # Main execution
   log "Starting WordPress update deployment"
   
   for site in $(ls "$SITES_DIR"); do
       if [ -f "$SITES_DIR/$site/wp-config.php" ]; then
           backup_site "$site"
           if ! update_wordpress "$site"; then
               rollback_site "$site"
           fi
       fi
   done
   
   log "Deployment complete"
   ```

   **Interview talking points:**
   - Always backup before updates
   - Use maintenance mode to avoid user impact
   - Log everything for auditing
   - Have rollback procedure

2. **Write a health-check script** (30 min)
   ```bash
   #!/bin/bash
   # monitor-sites.sh
   # Check all sites for basic health
   
   SITES_DIR="/var/www/html"
   ALERT_EMAIL="ops@example.edu"
   
   check_site_http() {
       local site=$1
       local url="https://$site.edu"
       local code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
       
       if [ "$code" -ne 200 ]; then
           echo "ALERT: $site returned HTTP $code"
           echo "Site down: $site (HTTP $code)" | mail -s "Site Alert" "$ALERT_EMAIL"
       fi
   }
   
   check_database() {
       local site=$1
       # Verify we can query the database
       wp db check --allow-root --path="$SITES_DIR/$site" > /dev/null 2>&1
       if [ $? -ne 0 ]; then
           echo "ALERT: Database unreachable for $site"
       fi
   }
   
   check_disk_space() {
       local usage=$(df "$SITES_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
       if [ "$usage" -gt 90 ]; then
           echo "ALERT: Disk usage at ${usage}%" | mail -s "Disk Alert" "$ALERT_EMAIL"
       fi
   }
   
   # Run checks
   for site in $(ls "$SITES_DIR"); do
       check_site_http "$site"
       check_database "$site"
   done
   check_disk_space
   ```

**Interview tips:**
- Mention idempotency: "script should be safe to run multiple times"
- Talk about monitoring: "We'd hook this into a cron job and alert on failure"
- Show error handling: `set -e`, exit codes, try/catch thinking

---

### **Hours 9–10: Troubleshooting & Incident Response**
**Goal:** Demonstrate systematic problem-solving

**Topics:**
- Diagnosing hosting outages
- Tools for debugging
- Escalation and communication
- Post-mortems and learning

**Scenarios to practice (write out your approach):**

**Scenario 1: Site completely down (HTTP 500)**
```
Your approach (what you'd say in interview):
1. Check error logs first
   grep "\[error\]" sample-data/error.log
   grep -i "fatal\|critical" sample-data/error.log

2. Verify database connectivity
   sqlite3 db/wordpress_practice.db "SELECT COUNT(*) FROM wp_posts;"
   (in production: mysql -u user -p db -e "SELECT 1;")

3. Check disk space
   df -h /var/www/html

4. Review recent changes
   git log --oneline -10
   Check if recent deployment caused issue

5. Check PHP-FPM or Apache status
   systemctl status php7.4-fpm
   systemctl status apache2

6. Isolate to specific file/plugin
   Look for specific errors: grep "wp-content/plugins" sample-data/error.log
   
7. Restore from backup if needed
   (In interview, explain your backup/restore process)
```

**Scenario 2: High load / slow response times**
```
Your approach:
1. Check current load and processes
   top -b -n 1
   ps aux --sort=-%cpu | head -20
   ps aux --sort=-%mem | head -20

2. Analyze log patterns for spikes
   awk '{print $1}' sample-data/access.log | sort | uniq -c | sort -rn
   Look for bot/crawler hammering site (top IPs)

3. Check for database-related slow queries
   sqlite3 db/wordpress_practice.db "SELECT * FROM wp_posts LIMIT 5;" 
   (in production: check MySQL slow query log)

4. Review request patterns
   grep " 5[0-9][0-9] " sample-data/access.log | head -20
   (look for error patterns correlating with load spikes)

5. Identify problematic IPs or requests
   grep " 503 " sample-data/access.log | awk '{print $1}' | sort | uniq -c | sort -rn
   These IPs may be hammering the service

6. Scale or optimize
   - Add caching (Redis, Memcached)
   - Optimize database indexes
   - Enable gzip compression
   - Temporarily rate-limit crawlers
```

**Scenario 3: Security incident / suspicious activity**
```
Your approach:
1. Preserve evidence and analyze access patterns
   grep "/wp-admin" sample-data/access.log | head -20
   Look for failed login attempts and suspicious IPs

2. Check for error patterns indicating compromise
   grep -i "eval\|base64_decode\|passthru" sample-data/error.log
   grep "\[error\]" sample-data/error.log | tail -30

3. Review user accounts for unauthorized access
   sqlite3 db/wordpress_practice.db "SELECT user_login, user_email, ID FROM wp_users;"
   Look for unexpected admin accounts

4. Identify access patterns and timing
   awk '{print $1, $4}' sample-data/access.log | sort | uniq
   Identify which IPs are accessing sensitive files

5. Document findings
   - What files were accessed?
   - Which IPs attacked?
   - What timing pattern?
   
6. Analysis from sample data
   Error log shows: eval() usage in plugins
   Access log shows: POST requests to wp-admin
   Database shows: No suspicious extra admin users
   
7. Remediation approach
   - Disable or remove compromised plugin
   - Force password reset for all users
   - Update WordPress and all plugins
   - Restore from clean backup if uncertain
   - Implement file integrity monitoring

8. Post-mortem
   How did they get in? Unpatched plugin? Weak password?
   Implement preventative measures (automated updates, monitoring)
```

**Interview tip:** Practice saying "I'd check X first, then Y" out loud. Show logical progression, not panic.

---

### **Hours 11–12: System Administration & DevOps Concepts**
**Goal:** Demonstrate broader systems thinking

**Topics:**
- Linux permissions and user management
- Process management
- Package management
- Basic networking
- Systemd/service management

**Quick reference scenarios:**

1. **User & permission management** (15 min read)
   ```bash
   # Add a deploy user
   useradd -m -s /bin/bash deploy
   
   # Give sudo access for specific commands
   echo "deploy ALL=(ALL) NOPASSWD:/usr/bin/systemctl restart apache2" | sudoedit /etc/sudoers.d/deploy
   
   # Set proper permissions on WordPress files
   chown -R www-data:www-data /var/www/html/site1
   chmod 755 /var/www/html/site1
   chmod 644 /var/www/html/site1/*.php
   
   # Allow www-data to read but not execute scripts directly
   chmod 600 /var/www/html/site1/wp-config.php
   ```

2. **Service & process management** (15 min read)
   ```bash
   # Check service status
   systemctl status apache2
   systemctl status mysql
   
   # Enable service to start on boot
   systemctl enable apache2
   
   # View logs
   journalctl -u apache2 -n 50
   journalctl -u mysql -f  # follow mode
   
   # Graceful reload (don't drop connections)
   systemctl reload apache2
   
   # Check for zombie/hung processes
   ps aux | grep defunct
   ps aux | grep D  # uninterruptible sleep (usually I/O wait)
   ```

3. **Package management** (15 min)
   ```bash
   # Update packages safely (on shared hosting, be careful!)
   apt update
   apt upgrade  # or apt full-upgrade for bigger changes
   
   # Install specific version
   apt install php7.4-mysql=7.4.3-1
   
   # Hold a package (prevent auto-updates)
   apt-mark hold php7.4
   apt-mark unhold php7.4
   
   # Check what will be updated before running
   apt upgrade -s  # simulate
   ```

4. **Network diagnostics** (15 min read)
   ```bash
   # Check listening ports
   netstat -tulpn | grep LISTEN
   ss -tulpn | grep LISTEN  # newer systems
   
   # Test connectivity
   curl -I https://example.edu  # GET request header
   curl -X POST -d "data" https://example.edu  # POST
   
   # Check DNS
   nslookup example.edu
   dig example.edu
   
   # Trace route
   traceroute example.edu
   ```

**Interview talking point prep:**
- "I'd check systemd logs to understand why a service failed to start"
- "Before updating packages on production, I'd test in dev first"
- "For WordPress, www-data needs write access to uploads but not to core files"

---

### **Hours 13–14: Core Interview Skills & Storytelling**
**Goal:** Articulate your experience convincingly

**Not coding—this is about communication.**

**Exercise 1: Prepare 3–4 "STAR" stories** (45 min)
Use S.T.A.R. format: **Situation, Task, Action, Result**

Example story 1: "I automated a manual process"
```
Situation: At [previous job], we managed 500 WordPress sites. 
          Plugin updates had to be done manually, took 16 hours per month.

Task:     I was asked to find a way to reduce manual effort.

Action:   I wrote a bash script that:
          - Checked for updates available
          - Backed up each site's database
          - Ran wp core update, wp plugin update
          - Tested each site after update
          - Logged results to a dashboard
          I also wrote documentation so other team members could use it.

Result:   Reduced monthly update time from 16 hours to 2 hours.
         Reduced incidents by 80% (tests caught issues before production).
```

Example story 2: "I debugged a complex production issue"
```
Situation: Production WordPress site was returning 503 errors, 
          affecting 500+ users during peak hours.

Task:     I was on-call and had to restore service within 1 hour.

Action:   Quickly checked:
          - Error logs → PHP memory exhaustion
          - Running processes → A runaway wp-cron job
          - Database → No issues
          I killed the hung process and increased PHP memory limit.
          Later, I wrote a cron cleanup script to prevent recurrence.

Result:   Service restored in 15 minutes.
         Prevented similar incidents in future by implementing monitoring.
```

Example story 3: "I led cross-team collaboration"
```
Situation: UW needed to migrate 100 departmental sites from old to new hosting.
          Different teams had different timelines and concerns.

Task:     Lead the technical planning and stakeholder alignment.

Action:   I created a migration checklist and timeline.
         Did test migrations with 2–3 departments first.
         Documented rollback procedures so everyone felt safe.
         Communicated weekly status to non-technical leadership.

Result:   Completed migration on schedule with zero data loss.
         Departments appreciated the communication and clear rollback plan.
```

**Exercise 2: Practice Q&A responses** (45 min)

Q: "Why are you interested in this role?"
A: "I'm excited about the scale—supporting 29,000 sites means my automation work has real impact across the university. I love the mix of systems engineering and stakeholder interaction, and I want to help keep critical academic infrastructure running smoothly."

Q: "Tell me about your shell scripting experience."
A: "I regularly write bash scripts for automation and operations. I'm comfortable with grep, sed, awk for log analysis, and I've written deployment scripts that include error handling, logging, and rollback procedures. One example: [mention one of your stories]."

Q: "How do you approach a complex problem you haven't seen before?"
A: "I start by understanding the constraints and scope. I gather data (logs, metrics, recent changes), form hypotheses, and test them methodically. I document findings and solutions, and I'm not afraid to ask for help or escalate when needed. I believe in communicating status clearly so stakeholders understand progress."

Q: "What's your experience with WordPress?"
A: "I've managed WordPress sites at scale, including plugin/theme updates, security hardening, and performance optimization. I understand the database schema and how to diagnose common issues like slow queries or plugin conflicts. I'm also familiar with the broader LAMP stack context."

Q: "How do you handle on-call responsibilities?"
A: "I'm comfortable with on-call rotations. I understand the importance of quick incident response and clear escalation paths. I also believe in post-mortems so we learn from incidents and reduce future occurrences."

---

### **Hours 15–16: Final Review & Practice Interview Simulation**
**Goal:** Solidify knowledge and build confidence

**Exercise 1: Code under pressure simulation** (30 min)

Write a script in real time (time yourself):
```
Problem: Write a script that finds all PHP files in /var/www/html 
modified in the last 24 hours and reports their size and owner.
Bonus: Flag any files owned by users other than www-data.
```

Expected solution:
```bash
#!/bin/bash
find /var/www/html -name "*.php" -mtime -1 -exec ls -lh {} \; | awk '{
  print "File: " $NF ", Size: " $5 ", Owner: " $3 ", Mtime: " $6, $7, $8
  if ($3 != "www-data") print "WARNING: Not owned by www-data!"
}'
```

**Exercise 2: Whiteboard / verbal scenario** (30 min)

Have a friend or family member ask you:
> "We have 50 WordPress sites. Last night, one site got hacked. How would you systematically ensure it doesn't happen again, and how would you scale that security approach to all 50 sites?"

Outline your verbal response:
1. Investigate the compromised site (gather evidence)
2. Determine the attack vector (vulnerability, weak password, etc.)
3. Fix the immediate issue (clean, patch, update credentials)
4. Implement preventative measures (backups, monitoring, access control)
5. Roll out security improvements across all 50 sites
6. Document and train team on new practices

---

## Key Talking Points (Memorize These)

**Technical:**
- "I'd check logs first to understand what happened"
- "Always backup before making changes to production"
- "I'd automate repetitive tasks and document the process"
- "Monitoring and alerting help us catch issues before users notice"
- "I'd test changes in a dev environment first, then do a limited rollout"

**Operational:**
- "On-call is part of the job, and I communicate status clearly during incidents"
- "Post-mortems help us prevent the same issue twice"
- "I document everything so knowledge isn't siloed"
- "I work well with non-technical stakeholders because I translate complexity into clear explanations"

**Mindset:**
- "I prefer fixing root causes over applying band-aids"
- "Reliability and automation are related—less manual work = fewer errors"
- "I balance new feature work with maintenance and debt reduction"

---

## Quick Reference: Commands You Must Know

```bash
# Logs
tail -f /var/log/apache2/error.log
grep -E "(ERROR|FATAL)" logfile
awk '{print $1}' access.log | sort | uniq -c | sort -rn

# Databases
mysql -u user -p db < backup.sql
mysqldump -u user -p db > backup.sql
wp db check --allow-root

# System health
top -b -n 1
df -h
du -sh /var/www/html/*
systemctl status service_name

# Processes
ps aux | grep php
kill -9 PID
journalctl -u service_name -n 50

# Networking
curl -I https://example.edu
netstat -tulpn | grep LISTEN

# Permissions
chown www-data:www-data /var/www/html/site
chmod 755 /var/www/html/site
chmod 644 /var/www/html/site/*.php
```

---

## 24-Hour Before Interview Checklist

- [ ] Get good sleep Thursday night
- [ ] Prepare 3–4 concrete stories with numbers/results
- [ ] Practice explaining a technical concept out loud (no slides)
- [ ] Review the job description one more time
- [ ] Know 2–3 thoughtful questions to ask the interviewer:
  - "What does a typical week look like for someone in this role?"
  - "What's the biggest challenge your team is facing right now?"
  - "How do you measure success for this position?"
- [ ] Dress professionally (business casual minimum)
- [ ] Test your video setup if remote
- [ ] Arrive/log in 5 minutes early

---

## Resources to Bookmark

- **Linux Academy / Pluralsight:** Shell scripting courses (30 min crash course)
- **MySQL Documentation:** `https://dev.mysql.com/doc/` (search for specific scenarios)
- **WordPress Codex:** `https://developer.wordpress.org/` (quick reference)
- **Bash Guide for Beginners:** `https://tldp.org/LDP/Bash-Beginners-Guide/` (free reference)

---

## Final Note

You have **~4 days** to complete this guide. Don't aim for perfection; aim for **familiarity and confidence**. The interview is screening for problem-solving ability and communication skills, not memorization.

Focus on:
1. Understanding *why* each tool is used (not just syntax)
2. Thinking step-by-step during scenarios
3. Explaining your reasoning out loud
4. Showing you'd approach operational challenges systematically

**Good luck Friday!** You've got this. 🚀
