# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **documentation-focused DevOps learning playground** dedicated to interview preparation and scripting skill development. The repository does not contain production code, tests, or a build system. All content is educational material.

**Primary purpose:** Structured learning guide for UW-IT Software Engineer interview preparation, with emphasis on shell scripting, databases, WordPress hosting, and systems administration at scale (managing ~29,000 websites).

## Repository Structure

- **`docs/start-from-here.md`** — Initial reference document summarizing the UW-IT Software Engineer role, key responsibilities, required skills, and interview checklist
- **`docs/INTERVIEW-PREP-16-HOURS.md`** — Comprehensive 16-hour learning guide with hour-by-hour breakdown, practical exercises, real scenarios, and interview preparation tips

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

## For Future Contributors

- **Keep exercises runnable:** All code examples should be copy-paste ready
- **Include expected output:** Show what correct execution looks like
- **Reference the job description:** Tie learning content back to the actual role requirements in `start-from-here.md`
- **Update memory if discovering new insights:** This repo was created to prepare for a specific interview; document any improvements to the learning approach in `/home/pluto-atom-4/.claude/projects/-home-pluto-atom-4-Documents-devops-scripting-playground/memory/` if they'd be useful for future sessions

## No Build/Test/Deployment Process

This repository is not a deployable application. All guidance assumes hands-on practice in isolated environments (local terminals, test servers, or Docker containers—not production systems).
