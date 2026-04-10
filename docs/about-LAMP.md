# Apache & PHP in LAMP Environments

This guide covers Apache HTTP Server hardening, access control configuration, and PHP execution methods—key topics for UW-IT WordPress hosting and systems administration interviews.

> **Note:** This focuses on **Apache HTTP Server** (the web server), not Apache Spark or Tomcat.

---

## Apache Security: Defense-in-Depth Approach

### Hide Server Information (Reconnaissance Defense)

By default, Apache broadcasts its version and OS type in error pages and HTTP headers, which helps attackers find specific exploits. Reduce this fingerprint:

- **Disable Server Banners:** Set `ServerTokens Prod` and `ServerSignature Off` in your `httpd.conf` or `apache2.conf`. This limits HTTP headers to just `Server: Apache`.
- **Remove ETag Headers:** ETags can leak sensitive inode numbers from the file system. Use `FileETag None` to disable them.

### Restrict Web Features

Turn off features you don't explicitly need to reduce the "attack surface":

- **Disable Directory Listing:** Prevent visitors from seeing all files in a folder if there's no `index.html`. Use `Options -Indexes` in your directory settings.
- **Disable Unused Modules:** Apache often loads modules like `mod_info`, `mod_status`, or `mod_cgi` by default. Comment out `LoadModule` lines for anything you aren't using.
- **Disable TRACE Request:** The TRACE method can be used in Cross-Site Tracing (XST) attacks. Disable it with `TraceEnable off`.

### File and Access Control

- **Run as a Non-Privileged User:** Ensure Apache runs under a dedicated service account (e.g., `www-data` or `apache`), not `root`.
- **Restrict Root Directory:** Deny access to the entire file system by default, then selectively allow only your web root:

```apache
<Directory />
    AllowOverride None
    Require all denied
</Directory>
```

- **Use HTTPS (SSL/TLS):** Always encrypt traffic using Certbot for Let's Encrypt. Disable outdated protocols like SSL v2/v3 and TLS 1.0/1.1.

### Advanced Protection Modules

- **ModSecurity:** A Web Application Firewall (WAF) that filters traffic in real-time to block SQL injection and XSS.
- **mod_evasive:** Helps protect against DDoS and brute-force attacks by limiting the number of requests per IP.
- **Fail2ban:** An external tool that monitors Apache logs and bans IP addresses showing malicious behavior.

### Quick Configuration Checklist

| Directive      | Recommended Setting       | Purpose                     |
|----------------|---------------------------|-----------------------------|
| ServerTokens   | Prod                      | Hides version details       |
| ServerSignature| Off                       | Removes footer info         |
| Options        | -Indexes -Includes -ExecCGI | Disables risky features   |
| AllowOverride  | None                      | Prevents .htaccess overrides |
| TraceEnable    | Off                       | Blocks TRACE attacks        |

---

## Apache Access Control (2.4+)

In modern Apache (v2.4+), access control is primarily managed through the `Require` directive (part of `mod_authz_core` and `mod_authz_host` modules). This system is highly granular, allowing you to restrict access by IP, hostname, environment variables, or complex logical expressions.

### Basic IP and Host Restrictions

The most common approach is to whitelist specific sources:

- **Allow Specific IP/Network:**
  ```apache
  Require ip 192.168.1.100
  Require ip 10.0.0.0/24
  ```

- **Allow by Domain:**
  ```apache
  Require host example.com
  ```
  *(Requires working reverse DNS)*

- **Deny All (Best Practice):**
  ```apache
  Require all denied
  ```

### Password-Based Authentication

For a secondary defense layer, use HTTP Basic Authentication to challenge users for credentials.

**Step 1: Create a password file** using `htpasswd`:

```bash
sudo htpasswd -c /etc/apache2/.htpasswd myusername
```

**Step 2: Configure the directory:**

```apache
<Directory "/var/www/html/secure">
    AuthType Basic
    AuthName "Restricted Content"
    AuthUserFile /etc/apache2/.htpasswd
    Require valid-user
</Directory>
```

### Complex Logic: RequireAll & RequireAny

Combine multiple rules for advanced policies:

- **RequireAll:** All conditions must be met (e.g., user must be from a specific IP *and* have a valid password).
- **RequireAny:** Any one condition is enough (e.g., allow if on local network *or* if user has a password).

### Advanced Access Control with `<If>` Directives

Apache 2.4 introduced the `<If>` directive for dynamic control based on request headers, cookies, or environment variables:

**Block a specific User-Agent:**

```apache
<If "%{HTTP_USER_AGENT} == 'BadBot'">
    Require all denied
</If>
```

**Time-based access:** Use `mod_rewrite` to deny access during specific hours.

### ⚠️ Important: Deprecated Syntax (Apache 2.2)

Many older tutorials mention `Order`, `Allow`, and `Deny` directives. These are **deprecated in Apache 2.4** and only available via the compatibility module `mod_access_compat`. Always use the `Require` syntax for better performance and security.

---

## PHP Handlers: Execution Methods

The way PHP scripts are executed on a web server significantly impacts performance and security. The primary methods are CGI, FastCGI, PHP-FPM, and mod_php.

### CGI (Common Gateway Interface)

The oldest method. For each request, the web server starts a new PHP process, runs the script, then closes it.

**Pros:**
- Highly secure—each request is isolated
- Changes to `php.ini` take effect immediately without restart

**Cons:**
- Very slow and resource-heavy for high-traffic sites due to start-stop overhead

### FastCGI

FastCGI improves on CGI by keeping PHP processes persistent. Instead of starting/stopping for every request, it maintains a pool of waiting processes.

**Pros:**
- Much faster than CGI
- Keeps security isolation by running scripts as the file owner rather than the web server user

**Cons:**
- Can be complex to configure manually
- Lacks advanced management features found in newer options

### PHP-FPM (FastCGI Process Manager)

The modern standard and **most recommended method** for production sites today. It's a specialized FastCGI implementation designed specifically for PHP.

**Pros:**
- Extremely efficient at handling traffic spikes
- Advanced features: slow-log (logs scripts taking too long), emergency restart on crashes
- Shares a single opcode cache across processes to save memory

**Cons:**
- Slightly more complex to set up
- Requires dedicated RAM allocation

### mod_php (Apache Module)

Embeds PHP directly inside Apache. No separate process—Apache itself handles PHP execution.

**Pros:**
- Very fast for simple setups—no inter-process communication overhead

**Cons:**
- Inefficient memory usage (Apache loads PHP even for static files like images)
- Less secure—all scripts run as the same Apache user

### PHP Handler Comparison

| Method   | Speed   | Security         | Best For                          |
|----------|---------|------------------|-----------------------------------|
| CGI      | Slowest | High (Isolation) | Simple testing or legacy systems  |
| mod_php  | Fast    | Low (Shared)     | Legacy Apache setups              |
| FastCGI  | Fast    | High (Per-user)  | Specific shared hosting scenarios |
| PHP-FPM  | Fastest | High (Per-user)  | Modern high-traffic production    |

---

## Interview Talking Points

- **Security:** Explain why hiding Apache version details (`ServerTokens Prod`) and using `Require` directives is better than deprecated `Allow`/`Deny` rules.
- **Performance:** Discuss why PHP-FPM is preferred over mod_php for high-traffic WordPress sites (memory efficiency, isolation, scaling).
- **Access Control:** Demonstrate combining IP whitelist + password auth for protecting admin directories on shared LAMP stacks.
- **Defense-in-depth:** Show familiarity with layered approach: info hiding → feature restriction → access control → external tools (Fail2ban, ModSecurity).

## Scenarios to Practice

1. **Site returns 403 Forbidden:** Debug Apache directory permissions, `Require` rules, and `.htaccess` overrides.
2. **Performance tuning:** Assess whether a WordPress site should use PHP-FPM instead of mod_php and the steps to migrate.
3. **Securing an admin panel:** Set up IP whitelist + Basic Auth for `/wp-admin/` on a LAMP stack.
4. **DDoS mitigation:** Configure `mod_evasive` or Fail2ban to rate-limit malicious requests detected in Apache logs.
