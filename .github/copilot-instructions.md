# Copilot Instructions for Scripting Playground

## Repository Purpose

This is an **educational, documentation-focused repository** for interview preparation. It contains no production code, tests, or build system. All content is learning material designed to prepare for a UW-IT Software Engineer role focused on managing ~29,000 websites at scale.

## Key Topics Covered

- **Shell scripting:** grep, sed, awk for log parsing and text processing
- **Databases:** MySQL, PostgreSQL, SQL backup/restore operations
- **WordPress hosting:** LAMP stack administration, PHP, themes/plugins
- **Linux systems administration:** Troubleshooting, incident response, automation
- **DevOps practices:** Deployment automation, configuration management, operational reliability

## Repository Structure

- **`docs/start-from-here.md`** — Overview of the UW-IT role, responsibilities, and skills required
- **`docs/INTERVIEW-PREP-16-HOURS.md`** — Comprehensive hour-by-hour learning guide with practical exercises, command examples, and scenario walkthroughs
- **`sample-data/`** — Realistic log files, configs, databases, and scripts for hands-on practice
  - `access.log`, `error.log` — HTTP/Apache logs for grep/sed/awk exercises
  - `wordpress.sql` — WordPress database schema and sample data for SQL practice
  - `vhost.conf`, `php.ini`, `backup.conf` — Configuration files for parsing and automation exercises
  - `sites-inventory.csv` — CSV inventory of sample WordPress sites for analysis
  - `deploy-sites.sh`, `backup.log` — Deployment/backup script and logs for scripting scenarios
  - `PRACTICE-EXERCISES.md` — 40+ structured exercises with solutions and challenge scenarios

## Contributing Guidelines

### For Documentation

1. **Make guides practical:** Include real, copy-paste-ready command examples. Readers should be able to run commands immediately.
   - ✓ `grep -E "(ERROR|FATAL)" logfile`
   - ✗ "Use grep to find errors"

2. **Use scenario-based learning:** Frame concepts around realistic operational problems (e.g., "Site returns 503 errors—how do you diagnose?") rather than abstract explanations.

3. **Include concrete references:** When mentioning tools or commands, provide actual syntax with common flags.

4. **Add interview context:** Label content with relevance to interview preparation:
   - **Interview talking point:** 
   - **Scenario to practice:**

5. **Show expected output:** Demonstrate what correct execution looks like, especially for scripts.

6. **Reference the job description:** Tie content back to actual role requirements in `start-from-here.md`.

7. **Time-box learning:** Segment content into specific hour blocks or sections with clear objectives, making progress trackable.

### What Not to Do

- Don't add generic development advice (e.g., "use meaningful variable names")
- Don't create step-by-step tutorials for well-known tools—assume reader familiarity
- Don't include exhaustive file/directory listings
- Don't write production-focused guidance (error handling, testing, deployment pipelines)

## Development Notes

- All code examples should be runnable in isolated environments (local terminal, test servers, or Docker)
- Never assume access to production systems
- When creating scripts as learning examples, document expected input/output and real-world context
- Update existing docs rather than creating new top-level guides; consolidation keeps the repo maintainable

## Working with Sample Data

The `sample-data/` directory contains realistic files for hands-on practice. When assisting users:

1. **Suggest relevant data files** for their learning goal (e.g., "Try grep exercises with `sample-data/access.log`")
2. **Provide copy-paste commands** that work immediately with these files
3. **Show expected output** so users verify correctness
4. **Encourage modification** — suggest creating variations (add more error lines, change domains, adjust timestamps)
5. **Reference PRACTICE-EXERCISES.md** for structured, progressive exercises

Example usage assistance:
```bash
# Good: includes the exact command
grep " 503 " sample-data/access.log

# Good: shows the exact path users should use
sqlite3 wordpress_practice.db < sample-data/wordpress.sql

# Less helpful: vague reference
# Use the error log to find database problems
```

When someone asks to add new data, evaluate against these criteria:
- **Realistic:** Mimics real logs/configs from actual WordPress/LAMP environments
- **Reusable:** Supports multiple exercise types, not just one specific lesson
- **Small:** Keeps repo lightweight (a few KB, not MB)
- **Documented:** Referenced in README.md and PRACTICE-EXERCISES.md

## File Organization

Keep documentation organized by topic in `docs/`. If a guide grows beyond 10,000 words, consider breaking it into sections (e.g., `docs/shell-scripting/grep-basics.md`, `docs/shell-scripting/sed-advanced.md`).

## Reuse from Existing Resources

This repository incorporates guidance from CLAUDE.md and adapts it for Copilot. Core principles from CLAUDE.md apply here—keep the repository focused on practical, scenario-based learning with emphasis on command-line proficiency and real-world problem-solving.
