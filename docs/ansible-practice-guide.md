# Ansible Practice Guide: Provisioning Apache & MySQL for UW-IT Unix Managed Services

**Goal:** Learn to write Ansible playbooks that provision Apache and MySQL on hosts resembling UW-IT Unix managed services (Ovid, Vergil). Practice locally using rootless Docker containers as target nodes.

**Time estimate:** 3-4 hours hands-on

**Prerequisites:** A Linux workstation with a regular (non-root) user account, internet access, and basic familiarity with the terminal.

---

## Table of Contents

1. [Environment Overview](#1-environment-overview)
2. [Install Rootless Docker](#2-install-rootless-docker)
3. [Install Ansible](#3-install-ansible)
4. [Build Target Containers](#4-build-target-containers)
5. [Configure SSH Access](#5-configure-ssh-access)
6. [Set Up the Ansible Project](#6-set-up-the-ansible-project)
7. [Write the Apache Playbook](#7-write-the-apache-playbook)
8. [Write the MySQL Playbook](#8-write-the-mysql-playbook)
9. [Combined Playbook: Full LAMP Stack](#9-combined-playbook-full-lamp-stack)
10. [Verification & Testing](#10-verification--testing)
11. [Cleanup](#11-cleanup)
12. [Interview Talking Points](#12-interview-talking-points)

---

## 1. Environment Overview

The lab simulates two UW-IT Unix managed service hosts:

| Container name | Simulates | Role            | Exposed SSH port |
|----------------|-----------|-----------------|------------------|
| `ovid`         | Ovid      | Apache web host | 2201             |
| `vergil`       | Vergil    | MySQL db host   | 2202             |

Your local machine acts as the Ansible **control node**. The two Docker containers act as **managed nodes** that you connect to over SSH, just as you would with real servers.

```
 ┌──────────────────────────┐
 │   Local machine          │
 │   (Ansible control node) │
 │                          │
 │   ansible-playbook ──────┼──► ovid   (Apache)  :2201
 │                          │
 │                    ──────┼──► vergil (MySQL)    :2202
 └──────────────────────────┘
```

---

## 2. Install Rootless Docker

Rootless Docker runs the Docker daemon under your regular user account — no `sudo` required. This is safer for local practice and mirrors least-privilege principles used at UW-IT.

### Step 2.1 — Install prerequisites

```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install -y uidmap dbus-user-session fuse-overlayfs slirp4netns
```

### Step 2.2 — Install Docker Engine (if not already installed)

```bash
# Follow the official install script:
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Step 2.3 — Set up rootless mode

```bash
# Run the rootless setup script (as your regular user, NOT root)
dockerd-rootless-setuptool.sh install

# The script prints export lines — add them to your shell profile:
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> ~/.bashrc
source ~/.bashrc
```

### Step 2.4 — Verify rootless Docker works

```bash
docker info 2>/dev/null | grep -i "rootless"
# Expected output line: rootless

docker run --rm hello-world
# Expected: "Hello from Docker!" message
```

**Troubleshooting:**
- If `dockerd-rootless-setuptool.sh` is not found, install the `docker-ce-rootless-extras` package.
- If you see `systemd` errors, ensure `dbus-user-session` is installed and you have a running user session (not just an SSH shell without `loginctl enable-linger $USER`).

---

## 3. Install Ansible

### Step 3.1 — Create a Python virtual environment

Using `uv` provides fast, reliable virtual environment and dependency management. If `uv` is not installed, see the [uv documentation](https://docs.astral.sh/uv/getting-started/installation/).

```bash
# Navigate to the current scripting-playground directory
# (assumes you're in or cd into the scripting-playground repository)
cd ansible-lab

# Create a virtual environment with uv (pinned to Python 3.11 for stability)
uv venv --python 3.11 .venv

# Activate the virtual environment
source .venv/bin/activate
```

### Step 3.2 — Install Ansible via uv

```bash
# Install Ansible using uv
uv pip install ansible

# Verify
ansible --version
# Expected: ansible [core 2.x.x] with Python 3.11.x
```

### Step 3.3 — (Optional) Install the community.docker collection

Useful if you later want Ansible to manage Docker directly.

```bash
ansible-galaxy collection install community.docker
```

---

## 4. Build Target Containers

We need containers that behave like minimal Linux servers with SSH access. Standard Docker images don't include an SSH server, so we build a custom image.

### Step 4.1 — Create the Dockerfile

```bash
cd ansible-lab
```

Create the file `Dockerfile.target`:

```dockerfile
FROM debian:bookworm-slim

# Install SSH server + Python (Ansible requires Python on managed nodes)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        python3 \
        python3-apt \
        sudo \
        systemctl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir /var/run/sshd && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config && \
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config

# Create an ansible user with sudo privileges
RUN useradd -m -s /bin/bash ansible && \
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible

# Prepare SSH directory for the ansible user
RUN mkdir -p /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    chown ansible:ansible /home/ansible/.ssh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

### Step 4.2 — Build the image

```bash
docker build -f Dockerfile.target -t ansible-target .
```

Expected output ends with:

```
Successfully tagged ansible-target:latest
```

Verify the image was created:

```bash
docker images ansible-target
```

Expected output:

```
REPOSITORY        TAG       IMAGE ID       CREATED        SIZE
ansible-target    latest    <hash>         <timestamp>    <size>
```

### Step 4.3 — Launch the two containers

```bash
# Ovid — will host Apache
docker run -d --name ovid -p 2201:22 -p 8080:80 ansible-target

# Vergil — will host MySQL
docker run -d --name vergil -p 2202:22 -p 3307:3306 ansible-target
```

### Step 4.4 — Verify the containers are running

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Expected output:

```
NAMES    STATUS          PORTS
ovid     Up X seconds    0.0.0.0:2201->22/tcp, 0.0.0.0:8080->80/tcp
vergil   Up X seconds    0.0.0.0:2202->22/tcp, 0.0.0.0:3307->3306/tcp
```

---

## 5. Configure SSH Access

Ansible connects to managed nodes over SSH. We use key-based authentication (no passwords).

### Step 5.1 — Generate a dedicated SSH key pair

```bash
cd ansible-lab  # if not already in the directory

# Create a subdirectory for SSH keys
mkdir -p keys

# Generate the SSH key pair
ssh-keygen -t ed25519 -f ./keys/ansible_key -N "" -C "ansible-lab-key"
```

Verify the keys were created:

```bash
ls -la keys/
```

Expected output:

```
total 8
drwxr-xr-x  2 user user   4096 Apr 10 00:45 .
drwxr-xr-x 10 user user   4096 Apr 10 00:45 ..
-rw-------  1 user user   464 Apr 10 00:45 ansible_key
-rw-r--r--  1 user user   103 Apr 10 00:45 ansible_key.pub
```

This creates:
- `./keys/ansible_key` (private key, readable only by owner)
- `./keys/ansible_key.pub` (public key, readable by all)

### Step 5.2 — Copy the public key into each container

```bash
# Copy to ovid
docker cp ./keys/ansible_key.pub ovid:/home/ansible/.ssh/authorized_keys
docker exec ovid chown ansible:ansible /home/ansible/.ssh/authorized_keys
docker exec ovid chmod 600 /home/ansible/.ssh/authorized_keys

# Copy to vergil
docker cp ./keys/ansible_key.pub vergil:/home/ansible/.ssh/authorized_keys
docker exec vergil chown ansible:ansible /home/ansible/.ssh/authorized_keys
docker exec vergil chmod 600 /home/ansible/.ssh/authorized_keys
```

Verify the authorized_keys files were created with proper permissions:

```bash
# Check ovid
docker exec ovid ls -l /home/ansible/.ssh/authorized_keys

# Check vergil
docker exec vergil ls -l /home/ansible/.ssh/authorized_keys
```

Expected output (for both):

```
-rw------- 1 ansible ansible 103 Apr 10 00:45 /home/ansible/.ssh/authorized_keys
```

The `600` permissions (owner read/write only) are correct for SSH authorized_keys files.

### Step 5.3 — Test SSH connectivity

```bash
ssh -i ./keys/ansible_key -p 2201 -o StrictHostKeyChecking=no ansible@localhost "hostname && whoami"
# Expected: a container ID and "ansible"

ssh -i ./keys/ansible_key -p 2202 -o StrictHostKeyChecking=no ansible@localhost "hostname && whoami"
# Expected: a container ID and "ansible"
```

If both commands return successfully, SSH access is working.

---

## 6. Set Up the Ansible Project

### Step 6.1 — Create the directory structure

```bash
cd ansible-lab

mkdir -p inventory group_vars host_vars roles
```

Final layout (we will add files in the following steps):

```
ansible-lab/
├── ansible.cfg
├── inventory/
│   └── hosts.yml
├── group_vars/
│   ├── webservers.yml
│   └── dbservers.yml
├── host_vars/
│   ├── ovid.yml
│   └── vergil.yml
├── playbooks/
│   ├── apache.yml
│   ├── mysql.yml
│   └── site.yml
├── roles/                     (optional, for later refactoring)
│   └── .gitkeep
├── templates/
│   └── wp-config.php.j2
├── keys/
│   ├── ansible_key
│   └── ansible_key.pub
├── Dockerfile.target
├── requirements.yml
└── pyproject.toml
```

### Step 6.2 — Create `ansible.cfg`

```ini
[defaults]
inventory = inventory/hosts.yml
remote_user = ansible
private_key_file = ./keys/ansible_key
host_key_checking = False
retry_files_enabled = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
```

### Step 6.3 — Create the inventory file `inventory/hosts.yml`

```yaml
all:
  children:
    webservers:
      hosts:
        ovid:
          ansible_host: 127.0.0.1
          ansible_port: 2201
    dbservers:
      hosts:
        vergil:
          ansible_host: 127.0.0.1
          ansible_port: 2202
```

### Step 6.4 — Verify Ansible can reach both hosts

```bash
ansible all -m ping
```

Expected output:

```
ovid | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
vergil | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

**Troubleshooting:**
- `UNREACHABLE` — check that containers are running (`docker ps`) and SSH works (Step 5.3).
- `Permission denied` — verify the key was copied correctly and permissions are `600`.

---

## 7. Write the Apache Playbook

### Step 7.1 — Create group variables `group_vars/webservers.yml`

```yaml
---
# Apache configuration variables
apache_packages:
  - apache2
  - libapache2-mod-php
  - php
  - php-mysql

apache_service: apache2

# A simple index page to verify the install
site_title: "Debian Managed Host - Ovid"
```

### Step 7.2 — Create `playbooks/apache.yml`

```yaml
---
- name: Provision Apache web server (Ovid)
  hosts: webservers
  become: true

  tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install Apache and PHP packages
      ansible.builtin.apt:
        name: "{{ apache_packages }}"
        state: present

    - name: Enable Apache modules
      ansible.builtin.command:
        cmd: "a2enmod {{ item }}"
      loop:
        - rewrite
        - ssl
        - headers
      register: mod_result
      changed_when: "'already enabled' not in mod_result.stdout"

    - name: Create a test index page
      ansible.builtin.copy:
        dest: /var/www/html/index.html
        content: |
          <!DOCTYPE html>
          <html>
          <head><title>{{ site_title }}</title></head>
          <body>
            <h1>{{ site_title }}</h1>
            <p>Apache provisioned by Ansible.</p>
            <p>Server: {{ inventory_hostname }}</p>
          </body>
          </html>
        owner: www-data
        group: www-data
        mode: "0644"

    - name: Create PHP info page (for verification)
      ansible.builtin.copy:
        dest: /var/www/html/info.php
        content: |
          <?php phpinfo(); ?>
        owner: www-data
        group: www-data
        mode: "0644"

    - name: Ensure Apache is started
      ansible.builtin.service:
        name: "{{ apache_service }}"
        state: started
      # Note: in a container without systemd, you may need to start
      # Apache manually. See the troubleshooting section below.
```

### Step 7.3 — Run the Apache playbook

```bash
cd ansible-lab
ansible-playbook playbooks/apache.yml
```

Expected output:

```
PLAY [Provision Apache web server (Ovid)] *****************************

TASK [Gathering Facts] ************************************************
ok: [ovid]

TASK [Update apt cache] ***********************************************
ok: [ovid]

TASK [Install Apache and PHP packages] ********************************
changed: [ovid]

TASK [Enable Apache modules] ******************************************
changed: [ovid] => (item=rewrite)
ok: [ovid] => (item=ssl)
changed: [ovid] => (item=headers)

TASK [Create a test index page] ***************************************
changed: [ovid]

TASK [Create PHP info page (for verification)] ************************
changed: [ovid]

TASK [Ensure Apache is started] ***************************************
changed: [ovid]

TASK [Start Apache directly (container workaround)] ********************
changed: [ovid]

PLAY RECAP ************************************************************
ovid : ok=8    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

**Analysis:**
- ✅ 8 tasks executed successfully (Gathering Facts + 7 tasks)
- ✅ 6 tasks made changes (package install, module enables, pages, start services)
- ✅ 2 tasks reported `ok` (no changes needed: facts gathering, SSL module already enabled)

### Step 7.4 — Handle the container-without-systemd issue

Docker containers typically don't run systemd, so the `service` module may fail. The playbook includes a fallback task:

```yaml
    - name: Start Apache directly (container workaround)
      ansible.builtin.command:
        cmd: apachectl start
      changed_when: true
      when: ansible_virtualization_type == "docker"
```

This task ensures Apache starts even when systemd isn't available in the container.

### Step 7.4.1 — Inspect Apache running status

Verify that Apache is running in the container:

```bash
# Check if Apache process is running
docker exec ovid ps aux | grep apache2

# Expected output: Multiple apache2 processes
# www-data    12  0.1  0.2  12345  6789 ?        Ss   01:45   0:00 /usr/sbin/apache2 -k start
# www-data    15  0.0  0.1  10234  5678 ?        S    01:45   0:00 /usr/sbin/apache2 -k start
```

Check Apache configuration is valid:

```bash
docker exec ovid apache2ctl -t
# Expected: Syntax OK
```

**Best verification:** Test connectivity from your host (see Step 7.5 below). If Apache responds to HTTP requests, it's running correctly.

### Step 7.5 — Verify Apache is serving

```bash
curl http://localhost:8080/
# Expected: HTML page with "UW-IT Managed Host - Ovid"

curl http://localhost:8080/info.php
# Expected: PHP info page output (HTML)
```

---

## 8. Write the MySQL Playbook

### Step 8.1 — Create group variables `group_vars/dbservers.yml`

```yaml
---
# MySQL configuration variables
mysql_packages:
  - mariadb-server
  - mariadb-client
  - python3-mysqldb    # Required for Ansible mysql modules

mysql_service: mariadb

# Database and user to create
mysql_databases:
  - name: wp_debian
    encoding: utf8mb4
    collation: utf8mb4_unicode_ci

mysql_users:
  - name: wp_admin
    password: "ChangeMe_2026!"
    host: "%"
    priv: "wp_debian.*:ALL"
```

**Location:** Place this file in `ansible-lab/group_vars/dbservers.yml` (alongside `webservers.yml`)

**Note:** These group variables apply to the `dbservers` group (vergil container in `inventory/hosts.yml`).

### Step 8.2 — Create host-specific variables `host_vars/vergil.yml` (optional)

For host-specific overrides:

```yaml
---
# Override group variables for vergil (the database server)
mysql_service: mariadb
```

**Location:** Place this file in `ansible-lab/host_vars/vergil.yml` (alongside `ovid.yml`)

### Step 8.3 — Create `playbooks/mysql.yml`

```yaml
---
- name: Provision MySQL (MariaDB) database server (Vergil)
  hosts: dbservers
  become: true

  tasks:
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install MariaDB packages
      ansible.builtin.apt:
        name: "{{ mysql_packages }}"
        state: present

    - name: Ensure MariaDB data directory has correct ownership
      ansible.builtin.file:
        path: /var/lib/mysql
        owner: mysql
        group: mysql
        state: directory
        recurse: true

    - name: Initialize MariaDB (if needed)
      ansible.builtin.command:
        cmd: mariadb-install-db --user=mysql
        creates: /var/lib/mysql/mysql

    - name: Start MariaDB (container workaround)
      ansible.builtin.shell: |
        mariadbd-safe &
        sleep 3
      args:
        creates: /var/run/mysqld/mysqld.pid
      changed_when: true

    - name: Create application databases
      community.mysql.mysql_db:
        name: "{{ item.name }}"
        encoding: "{{ item.encoding }}"
        collation: "{{ item.collation }}"
        state: present
        login_unix_socket: /var/run/mysqld/mysqld.sock
      loop: "{{ mysql_databases }}"

    - name: Create application users
      community.mysql.mysql_user:
        name: "{{ item.name }}"
        password: "{{ item.password }}"
        host: "{{ item.host }}"
        priv: "{{ item.priv }}"
        state: present
        login_unix_socket: /var/run/mysqld/mysqld.sock
      loop: "{{ mysql_users }}"
      no_log: true   # Hide passwords from output

    # NOTE: wordpress.sql lives in ansible-lab/files/ on the control node.
    - name: Copy WordPress schema to target
      ansible.builtin.copy:
        src: ../files/wordpress.sql
        dest: /tmp/wordpress.sql
        mode: "0644"
      ignore_errors: true
      register: copy_result

    - name: Import WordPress schema into wp_debian
      ansible.builtin.shell: |
        mariadb -u root wp_debian < /tmp/wordpress.sql
      args:
        creates: /tmp/.wp_schema_imported
      when: copy_result is succeeded
      ignore_errors: true
      register: import_result

    - name: Mark schema as imported
      ansible.builtin.file:
        path: /tmp/.wp_schema_imported
        state: touch
      when: import_result is succeeded
```

### Step 8.3 — Install the community.mysql collection

The `mysql_db` and `mysql_user` modules live in a community collection:

```bash
ansible-galaxy collection install community.mysql
```

### Step 8.4 — Run the MySQL playbook

```bash
ansible-playbook playbooks/mysql.yml
```

Expected output (abbreviated):

```
PLAY [Provision MySQL (MariaDB) database server (Vergil)] *******************************************************************

TASK [Create application databases] *****************************************************************************************
[WARNING]: Support of mysqlcline/MySQLdb connector is deprecated. We'll stop testing against it in collection version 4.0.0 and remove the related code in 5.0.0. Use PyMySQL connector instead.
ok: [vergil] => (item={'name': 'wp_debian', 'encoding': 'utf8mb4', 'collation': 'utf8mb4_unicode_ci'})

TASK [Create application users] *********************************************************************************************
[WARNING]: Option column_case_sensitive is not provided. The default is now false, so the column's name will be uppercased. The default will be changed to true in community.mysql 4.0.0.
ok: [vergil] => (item=(censored due to no_log))

TASK [Copy WordPress schema to target] **************************************************************************************
changed: [vergil]

TASK [Import WordPress schema into wp_debian] *******************************************************************************
changed: [vergil]

TASK [Mark schema as imported] **********************************************************************************************
changed: [vergil]

PLAY RECAP ******************************************************************************************************************
vergil                     : ok=11   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```
Note: The two warnings (MySQLdb connector deprecated and column_case_sensitive) come from the community.mysql collection and are
   informational — they'll go away when the collection is updated to use PyMySQL. Not actionable for now.

### Step 8.5 — Verify MySQL is working

```bash
# Connect from the host through the mapped port
docker exec vergil mysql -u wp_admin -p'ChangeMe_2026!' -e "SHOW DATABASES;"
```

Expected output includes `wp_debian` in the database list.

```bash
# Verify the user privileges
docker exec vergil mysql -u wp_admin -p'ChangeMe_2026!' -e "SHOW GRANTS FOR 'wp_admin'@'%';"
```

---

## 9. Combined Playbook: Full LAMP Stack

### Step 9.1 — Create `playbooks/site.yml`

This is the **master playbook** that provisions the full stack in one run.

```yaml
---
# site.yml — Full stack provisioning for UW-IT managed hosts
#
# Usage:
#   ansible-playbook playbooks/site.yml              # Full run
#   ansible-playbook playbooks/site.yml --tags web    # Apache only
#   ansible-playbook playbooks/site.yml --tags db     # MySQL only

- name: Provision Apache on web servers
  import_playbook: apache.yml
  tags: web

- name: Provision MySQL on database servers
  import_playbook: mysql.yml
  tags: db
```

### Step 9.2 — Run the full stack

```bash
# Provision everything
ansible-playbook playbooks/site.yml

# Or target just one layer
ansible-playbook playbooks/site.yml --tags web
ansible-playbook playbooks/site.yml --tags db
```

### Step 9.3 — Run in check mode (dry run)

```bash
ansible-playbook playbooks/site.yml --check --diff
```

This shows what *would* change without modifying anything. **Interview talking point:** Always mention dry-run capability when discussing Ansible in production.

---

## 10. Verification & Testing

Run these checks to confirm everything is provisioned correctly.

### Quick verification script

```bash
#!/bin/bash
echo "=== Checking Apache on Ovid ==="
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8080/
curl -s http://localhost:8080/ | grep -o "<title>.*</title>"

echo ""
echo "=== Checking MySQL on Vergil ==="
docker exec vergil mysql -u wp_admin -p'ChangeMe_2026!' -e "SELECT 'MySQL OK' AS status;" 2>/dev/null
docker exec vergil mysql -u wp_admin -p'ChangeMe_2026!' -e "SHOW DATABASES;" 2>/dev/null | grep wp_uwit

echo ""
echo "=== Ansible inventory check ==="
ansible all -m ping
```

Expected output:

```
=== Checking Apache on Ovid ===
HTTP Status: 200
<title>UW-IT Managed Host - Ovid</title>

=== Checking MySQL on Vergil ===
+----------+
| status   |
+----------+
| MySQL OK |
+----------+
wp_uwit

=== Ansible inventory check ===
ovid | SUCCESS => { "ping": "pong" }
vergil | SUCCESS => { "ping": "pong" }
```

### Test idempotency

Run the playbook a second time — a well-written playbook should report `changed=0` on the second run (except for the container-specific service start workarounds):

```bash
ansible-playbook playbooks/site.yml
```

Look at the `PLAY RECAP` line. Ideally:

```
ovid   : ok=6  changed=0  unreachable=0  failed=0
vergil : ok=8  changed=0  unreachable=0  failed=0
```

---

## 11. Cleanup

When you're done practicing, remove the containers and clean up:

```bash
# Stop and remove containers
docker stop ovid vergil
docker rm ovid vergil

# Remove the custom image
docker rmi ansible-target

# (Optional) Deactivate the Python venv
deactivate

# (Optional) Remove the entire lab directory
# rm -rf ansible-lab
```

---

## 12. Interview Talking Points

Use this exercise to support these interview narratives:

### Configuration Management at Scale

> "I use Ansible to provision and maintain consistent configurations across hosts. For example, I set up a lab that mirrors UW-IT's Ovid and Vergil hosts — provisioning Apache on one and MariaDB on another — all driven by a single `site.yml` playbook. The inventory structure separates web servers from database servers, and group variables keep configuration DRY."

### Why Ansible?

Key points to mention:
- **Agentless** — uses SSH, no software to install on managed nodes (ideal for managed Unix services)
- **Idempotent** — safe to re-run; only changes what's needed
- **Declarative** — you describe the desired state, not the steps
- **YAML-based** — readable by sysadmins and developers alike

### Security Practices

- Used key-based SSH authentication (no passwords)
- `no_log: true` on tasks that handle credentials
- Variables for secrets can be moved to `ansible-vault` encrypted files in production
- Rootless Docker for local development reduces attack surface

### Scaling to 29,000 Sites

> "The same inventory + group_vars pattern scales to thousands of hosts. At UW-IT scale, I'd organize inventory by service tier or building, use `--limit` for targeted runs, and leverage Ansible Tower/AWX for scheduled runs, RBAC, and audit logging."

### Common Ansible Commands to Know

```bash
# Check connectivity
ansible all -m ping

# Run ad-hoc commands
ansible webservers -m shell -a "apache2ctl -S"
ansible dbservers -m shell -a "mysql -e 'SHOW STATUS'"

# Dry run
ansible-playbook site.yml --check --diff

# Limit to specific hosts
ansible-playbook site.yml --limit ovid

# Use tags
ansible-playbook site.yml --tags web

# Encrypt secrets
ansible-vault encrypt group_vars/dbservers.yml
ansible-playbook site.yml --ask-vault-pass

# List all tasks in a playbook
ansible-playbook site.yml --list-tasks
```

---

## Quick Reference: File Summary

| File                           | Purpose                                   |
|--------------------------------|-------------------------------------------|
| `Dockerfile.target`           | Builds SSH-enabled Debian containers       |
| `ansible.cfg`                 | Ansible project configuration              |
| `inventory/hosts.yml`         | Defines ovid and vergil hosts              |
| `group_vars/webservers.yml`   | Apache-related variables                   |
| `group_vars/dbservers.yml`    | MySQL-related variables                    |
| `playbooks/apache.yml`        | Installs and configures Apache + PHP       |
| `playbooks/mysql.yml`         | Installs and configures MariaDB + database |
| `playbooks/site.yml`          | Master playbook — runs both                |
| `ansible_key` / `.pub`        | SSH key pair for Ansible connections       |

---

**Next steps after this exercise:**
- Add an Ansible role for WordPress installation (`roles/wordpress/`)
- Use `ansible-vault` to encrypt the database passwords
- Try the `--limit` and `--forks` flags to understand parallel execution
- Explore Ansible Tower/AWX for a web UI and job scheduling
