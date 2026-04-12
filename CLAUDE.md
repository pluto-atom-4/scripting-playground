# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **documentation-focused DevOps learning playground** dedicated to interview preparation and scripting skill development. The repository does not contain production code, tests, or a build system. All content is educational material.

**Primary purpose:** Structured learning guide for UW-IT Software Engineer interview preparation, with emphasis on shell scripting, databases, WordPress hosting, and systems administration at scale (managing ~29,000 websites).

## Repository Structure

- **`docs/`** — Learning guides and interview preparation material
  - `start-from-here.md` — Initial reference: UW-IT Software Engineer role, responsibilities, required skills, and interview checklist
  - `INTERVIEW-PREP-16-HOURS.md` — Comprehensive 16-hour learning guide with hour-by-hour breakdown, practical exercises, real scenarios, and interview tips
  - `kubernetes-practice.md` — Step-by-step Kubernetes practice guide covering cluster setup, workload deployment, and 3 CLI tools (K9s, kubectx+kubens, Stern)
- **`sample-data/`** — Realistic config files, logs, and scripts for hands-on practice
  - `PRACTICE-EXERCISES.md` — Guided exercises using the sample data
  - `access.log`, `error.log`, `backup.log` — Sample log files for grep/awk/sed practice
  - `php.ini`, `vhost.conf`, `backup.conf` — Config files for editing exercises
  - `wordpress.sql` — Sample SQL for database query practice
  - `sites-inventory.csv` — CSV data for scripting exercises
  - `deploy-sites.sh` — Sample deployment script
- **`ansible-lab/`** — Hands-on Ansible practice environment (provisioning Apache & MySQL)
  - Managed with `uv` and `pyproject.toml`, pinned to Python 3.11
  - `inventory/hosts.yml` — Two target hosts: ovid (webserver) and vergil (dbserver)
  - `group_vars/` — Shared variables per host group (webservers, dbservers)
  - `host_vars/` — Per-host overrides for ovid and vergil
  - `playbooks/` — Ansible playbooks:
    - `site.yml` — Master playbook (runs common + apache + mysql, supports `--tags`)
    - `common.yml` — Baseline packages, timezone, hostname
    - `apache.yml` — Apache + PHP provisioning
    - `mysql.yml` — MariaDB + database/user creation
    - `wordpress.yml` — Full WordPress deployment with templated wp-config
    - `security.yml` — SSH hardening, fail2ban, unattended-upgrades
    - `backup.yml` — Nightly MySQL dump + web content backup via cron
    - `monitoring.yml` — Health checks for disk, memory, load, Apache, MySQL
    - `check-connectivity.yml` — Verify SSH access and display host facts
  - `templates/wp-config.php.j2` — Jinja2 template for WordPress configuration
  - `Dockerfile.target` — SSH-enabled Debian container used as Ansible target node
  - `requirements.yml` — Ansible Galaxy collection dependencies
  - `ansible.cfg` — Project-level Ansible configuration
  - See `docs/ansible-practice-guide.md` for the full step-by-step walkthrough
- **`kubernetes-lab/`** — Hands-on Kubernetes practice environment (local cluster with kind)
  - `kind-config.yml` — Multi-node kind cluster configuration (1 control-plane + 2 workers)
  - `manifests/` — Kubernetes manifest files for exercises:
    - `01-namespaces.yml` — Practice namespaces (dev, staging, prod)
    - `02-deployment-nginx.yml` — Basic nginx Deployment with 3 replicas
    - `03-service-nginx.yml` — ClusterIP and NodePort Service examples
    - `04-configmap.yml` — ConfigMap with key-values and embedded nginx config
    - `05-secret.yml` — Secret with base64-encoded database credentials
    - `06-deployment-with-config.yml` — Deployment consuming ConfigMap and Secret
    - `07-probes.yml` — Liveness, readiness, and startup probe examples
    - `08-statefulset.yml` — MySQL StatefulSet with PVC (Deployment vs StatefulSet)
    - `09-multi-pod-logging.yml` — Multi-Deployment setup for Stern log tailing practice
  - `scripts/install-tools.sh` — Installs kubectl, kind, K9s, kubectx+kubens, and Stern
  - See `docs/kubernetes-practice.md` for the full step-by-step walkthrough
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
- Automation and deployment practices (Ansible, configuration management)
- Kubernetes cluster operations, workload management, and CLI tooling
- Interview storytelling and communication skills

## Ansible Lab

The `ansible-lab/` directory is a self-contained Ansible project for practicing infrastructure provisioning against local Docker containers. Key points:

- **Python environment:** Managed by `uv` with `pyproject.toml`, pinned to Python 3.11 (widely used at UW, fewest dependency conflicts with Ansible).
- **Target nodes:** Two rootless Docker containers (`ovid` for Apache, `vergil` for MariaDB) built from `Dockerfile.target`.
- **Setup:** Run `cd ansible-lab && uv sync && ansible-galaxy install -r requirements.yml` to bootstrap.
- **Running playbooks:** `uv run ansible-playbook playbooks/site.yml` (or activate the venv first with `source .venv/bin/activate`).
- **Local-only values:** Host vars use `.local` domains and `admin@localhost` — no real UW addresses.
- **Guide:** `docs/ansible-practice-guide.md` has the full step-by-step walkthrough from Docker setup through verification.

## Kubernetes Lab

The `kubernetes-lab/` directory is a self-contained Kubernetes practice environment using kind (Kubernetes in Docker). Key points:

- **Cluster:** A 3-node kind cluster (1 control-plane + 2 workers) defined in `kind-config.yml` with port mappings for NodePort and Ingress access.
- **Manifests:** Numbered YAML files in `manifests/` covering namespaces, Deployments, Services, ConfigMaps, Secrets, probes, StatefulSets, and multi-pod logging.
- **CLI tools:** The guide focuses on 3 popular helpers — K9s (terminal dashboard), kubectx + kubens (context/namespace switching), and Stern (multi-pod log tailing).
- **Setup:** Run `chmod +x scripts/install-tools.sh && ./scripts/install-tools.sh` to install all tools, then `kind create cluster --config kind-config.yml --name k8s-lab` to create the cluster.
- **Guide:** `docs/kubernetes-practice.md` has the full step-by-step walkthrough from installation through troubleshooting exercises.

## Claude Code Configuration

The `.claude/` directory is version-controlled to share project settings across sessions. Key points:

- **`settings.json`** is the shared config — edit it to change model, permissions, hooks, or sandbox rules for the project.
  - **Model:** Currently set to `claude-haiku-4-5-20251001` (Haiku 4.5) for cost efficiency on documentation and learning materials. For complex implementation tasks, use faster/more capable models by updating this field or via `/model` in the CLI.
- **`settings.local.json`** is for personal overrides and is git-ignored.
- A **PreToolUse hook** logs all Bash tool invocations (with timestamps) to `.claude/hooks.log`. This file is git-ignored via the `*.log` pattern.
- The sandbox restricts filesystem writes and network access. See `.claude/SETTINGS-GUIDE.md` for details.

## For Future Contributors

- **Keep exercises runnable:** All code examples should be copy-paste ready
- **Include expected output:** Show what correct execution looks like
- **Reference the job description:** Tie learning content back to the actual role requirements in `start-from-here.md`
- **Use `sample-data/` for practice files:** Add realistic configs, logs, or scripts there rather than creating ad-hoc files elsewhere
- **Keep ansible-lab self-contained:** Playbooks, templates, and inventory stay within `ansible-lab/`. Use `host_vars/` for per-host overrides, `group_vars/` for group-wide defaults. Use `.local` domains and dummy credentials — never real UW addresses.
- **Keep kubernetes-lab self-contained:** Manifests and scripts stay within `kubernetes-lab/`. Number manifest files for clear exercise ordering. Use dummy credentials in Secrets — never real passwords or tokens.
- **Update memory if discovering new insights:** This repo was created to prepare for a specific interview; document any improvements to the learning approach in the Claude Code memory directory if they'd be useful for future sessions

## No Build/Test/Deployment Process

This repository is not a deployable application. All guidance assumes hands-on practice in isolated environments (local terminals, test servers, or Docker containers—not production systems).
