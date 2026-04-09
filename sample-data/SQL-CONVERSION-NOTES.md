# SQL Schema Conversion Notes

## Overview
This directory contains both MySQL and SQLite versions of the WordPress database schema for practice purposes.

## Files

### `wordpress.sql` (MySQL)
- **Purpose:** Original MySQL/MariaDB schema for reference
- **Use case:** For students learning on MySQL/MariaDB servers (e.g., traditional LAMP stacks)
- **Compatibility:** MySQL 5.6+, MariaDB 10.0+
- **Data types:** Uses MySQL-specific types (bigint(20) UNSIGNED, longtext, varchar with size)

### `wordpress-sqlite.sql` (SQLite)
- **Purpose:** Lightweight SQLite version for local practice without Docker/databases
- **Use case:** Recommended for interview preparation and local testing
- **Compatibility:** SQLite 3.0+
- **Key differences from MySQL:**
  - `INTEGER PRIMARY KEY AUTOINCREMENT` instead of `bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT`
  - `TEXT` for all text types (replaces varchar, longtext)
  - `INTEGER` for numeric types

## Conversion Mapping

| MySQL | SQLite | Notes |
|-------|--------|-------|
| `bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY` | `INTEGER PRIMARY KEY AUTOINCREMENT` | SQLite doesn't support type parameters or UNSIGNED |
| `varchar(60)` | `TEXT` | SQLite doesn't enforce size limits |
| `longtext` | `TEXT` | SQLite treats all text the same |
| `int(11)` | `INTEGER` | SQLite doesn't support type parameters |
| `datetime` | `TEXT` | SQLite stores datetime as ISO 8601 strings |

## Data Consistency
Both schemas contain identical sample data:
- 4 WordPress users (admin, editor, author1, author2)
- 6 posts (mix of published, draft, future, page types)
- 5 comments (includes spam examples marked with `comment_approved = '0'`)
- 8 site options (siteurl, home, admin_email, blogname, etc.)

## Usage

### Load SQLite Database
```bash
sqlite3 db/wordpress_practice.db < sample-data/wordpress-sqlite.sql
```

### Load MySQL Database
```bash
mysql -u root -p wordpress_practice < sample-data/wordpress.sql
```

## Why Maintain Both?
1. **Educational value:** Shows schema differences between database systems
2. **Flexibility:** Supports learning on different platforms
3. **Interview preparation:** Students may encounter both MySQL and SQLite environments

## Query Compatibility
Most basic SQL queries work on both systems. Differences appear in:
- Date/time functions (NOW() vs datetime('now'))
- String functions (some MySQL functions don't exist in SQLite)
- Aggregate functions (compatible)
- JOIN operations (compatible)

## Recommendations
- **For this repository:** Use `wordpress-sqlite.sql` (no setup required, lightweight)
- **For production/hosting studies:** Use `wordpress.sql` with actual MySQL/MariaDB servers
- **For real WordPress:** Study actual WordPress database via `wp-cli` or phpMyAdmin on live sites
