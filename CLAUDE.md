# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **documentation-focused DevOps learning playground** dedicated to interview preparation and scripting skill development. The repository does not contain production code, tests, or a build system. All content is educational material.

**Primary purpose:** Structured learning guide for UW-IT Software Engineer interview preparation, with emphasis on shell scripting, databases, WordPress hosting, and systems administration at scale (managing ~29,000 websites).

## Repository Structure

- **`docs/`** — Learning guides and interview preparation material
  - `start-from-here.md` — Initial reference: UW-IT Software Engineer role, responsibilities, required skills, and interview checklist
  - `INTERVIEW-PREP-16-HOURS.md` — Comprehensive 16-hour learning guide with hour-by-hour breakdown, practical exercises, real scenarios, and interview tips
- **`sample-data/`** — Realistic config files, logs, and scripts for hands-on practice
  - `PRACTICE-EXERCISES.md` — Guided exercises using the sample data
  - `access.log`, `error.log`, `backup.log` — Sample log files for grep/awk/sed practice
  - `php.ini`, `vhost.conf`, `backup.conf` — Config files for editing exercises
  - `wordpress.sql` — Sample SQL for database query practice
  - `sites-inventory.csv` — CSV data for scripting exercises
  - `deploy-sites.sh` — Sample deployment script
- **`.claude/`** — Claude Code project configuration (committed to share settings across sessions)
  - `settings.json` — Shared project settings (model, permissions, hooks, sandbox)
  - `settings.local.json` — Personal overrides (git-ignored)
  - `SETTINGS-GUIDE.md` — Documentation for the settings configuration

## When Adding Documentation

1. **Keep guides practical:** Include real command examples, code snippets, and hands-on exercises. Readers should be able to copy/paste and run commands.

2. **Use scenario-based learning:** Frame concepts around realistic operational problems (e.g., "Site returns 503 errors—how do you diagnose?") rather than abstract concepts.

3. **Include concrete references:** When mentioning tools or commands, provide the actual syntax and common flags. Example: Don't just say "use grep"—show `grep -E "(ERROR|FATAL)" logfile`.

4. **Add interview-specific context:** Label content with relevance to interview preparation (e.g., "**Interview talking point:**", "**Scenario to practice:**").

5. **Document for time-boxed learning:** Segment content into specific hour blocks or sections with clear learning objectives.

## Key Topics This Repository Covers

- Shell scripting (grep, sed, awk)
- SQL and database operations (MySQL, PostgreSQL, WordPress)
- WordPress hosting and LAMP stack administration
- Linux system administration and troubleshooting
- Incident response and operational reliability
- Automation and deployment practices
- Interview storytelling and communication skills

## Claude Code Configuration

The `.claude/` directory is version-controlled to share project settings across sessions. Key points:

- **`settings.json`** is the shared config — edit it to change model, permissions, hooks, or sandbox rules for the project.
- **`settings.local.json`** is for personal overrides and is git-ignored.
- A **PreToolUse hook** logs all Bash tool invocations (with timestamps) to `.claude/hooks.log`. This file is git-ignored via the `*.log` pattern.
- The sandbox restricts filesystem writes and network access. See `.claude/SETTINGS-GUIDE.md` for details.

## For Future Contributors

- **Keep exercises runnable:** All code examples should be copy-paste ready
- **Include expected output:** Show what correct execution looks like
- **Reference the job description:** Tie learning content back to the actual role requirements in `start-from-here.md`
- **Use `sample-data/` for practice files:** Add realistic configs, logs, or scripts there rather than creating ad-hoc files elsewhere
- **Update memory if discovering new insights:** This repo was created to prepare for a specific interview; document any improvements to the learning approach in the Claude Code memory directory if they'd be useful for future sessions

## No Build/Test/Deployment Process

This repository is not a deployable application. All guidance assumes hands-on practice in isolated environments (local terminals, test servers, or Docker containers—not production systems).
