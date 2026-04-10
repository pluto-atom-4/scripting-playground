-- WordPress core database schema (all 12 core tables)
-- Based on the official WordPress 6.x schema.
-- Safe to import into a fresh MariaDB database for Ansible lab practice.

SET default_storage_engine = InnoDB;

-- 1. wp_users
CREATE TABLE IF NOT EXISTS wp_users (
  ID bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  user_login varchar(60) NOT NULL DEFAULT '',
  user_pass varchar(255) NOT NULL DEFAULT '',
  user_nicename varchar(50) NOT NULL DEFAULT '',
  user_email varchar(100) NOT NULL DEFAULT '',
  user_url varchar(100) NOT NULL DEFAULT '',
  user_registered datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  user_activation_key varchar(255) NOT NULL DEFAULT '',
  user_status int(11) NOT NULL DEFAULT 0,
  display_name varchar(250) NOT NULL DEFAULT '',
  PRIMARY KEY (ID),
  KEY user_login_key (user_login),
  KEY user_nicename (user_nicename),
  KEY user_email (user_email)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. wp_usermeta
CREATE TABLE IF NOT EXISTS wp_usermeta (
  umeta_id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  meta_key varchar(255) DEFAULT NULL,
  meta_value longtext,
  PRIMARY KEY (umeta_id),
  KEY user_id (user_id),
  KEY meta_key (meta_key(191))
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 3. wp_posts
CREATE TABLE IF NOT EXISTS wp_posts (
  ID bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  post_author bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  post_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  post_date_gmt datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  post_content longtext NOT NULL,
  post_title text NOT NULL,
  post_excerpt text NOT NULL,
  post_status varchar(20) NOT NULL DEFAULT 'publish',
  comment_status varchar(20) NOT NULL DEFAULT 'open',
  ping_status varchar(20) NOT NULL DEFAULT 'open',
  post_password varchar(255) NOT NULL DEFAULT '',
  post_name varchar(200) NOT NULL DEFAULT '',
  to_ping text NOT NULL,
  pinged text NOT NULL,
  post_modified datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  post_modified_gmt datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  post_content_filtered longtext NOT NULL,
  post_parent bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  guid varchar(255) NOT NULL DEFAULT '',
  menu_order int(11) NOT NULL DEFAULT 0,
  post_type varchar(20) NOT NULL DEFAULT 'post',
  post_mime_type varchar(100) NOT NULL DEFAULT '',
  comment_count bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (ID),
  KEY post_name (post_name(191)),
  KEY type_status_date (post_type, post_status, post_date, ID),
  KEY post_parent (post_parent),
  KEY post_author (post_author)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 4. wp_postmeta
CREATE TABLE IF NOT EXISTS wp_postmeta (
  meta_id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  post_id bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  meta_key varchar(255) DEFAULT NULL,
  meta_value longtext,
  PRIMARY KEY (meta_id),
  KEY post_id (post_id),
  KEY meta_key (meta_key(191))
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 5. wp_comments
CREATE TABLE IF NOT EXISTS wp_comments (
  comment_ID bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  comment_post_ID bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  comment_author tinytext NOT NULL,
  comment_author_email varchar(100) NOT NULL DEFAULT '',
  comment_author_url varchar(200) NOT NULL DEFAULT '',
  comment_author_IP varchar(100) NOT NULL DEFAULT '',
  comment_date datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  comment_date_gmt datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  comment_content text NOT NULL,
  comment_karma int(11) NOT NULL DEFAULT 0,
  comment_approved varchar(20) NOT NULL DEFAULT '1',
  comment_agent varchar(255) NOT NULL DEFAULT '',
  comment_type varchar(20) NOT NULL DEFAULT 'comment',
  comment_parent bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  user_id bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (comment_ID),
  KEY comment_post_ID (comment_post_ID),
  KEY comment_approved_date_gmt (comment_approved, comment_date_gmt),
  KEY comment_date_gmt (comment_date_gmt),
  KEY comment_parent (comment_parent),
  KEY comment_author_email (comment_author_email(10))
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 6. wp_commentmeta
CREATE TABLE IF NOT EXISTS wp_commentmeta (
  meta_id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  comment_id bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  meta_key varchar(255) DEFAULT NULL,
  meta_value longtext,
  PRIMARY KEY (meta_id),
  KEY comment_id (comment_id),
  KEY meta_key (meta_key(191))
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 7. wp_terms
CREATE TABLE IF NOT EXISTS wp_terms (
  term_id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  name varchar(200) NOT NULL DEFAULT '',
  slug varchar(200) NOT NULL DEFAULT '',
  term_group bigint(10) NOT NULL DEFAULT 0,
  PRIMARY KEY (term_id),
  KEY slug (slug(191)),
  KEY name (name(191))
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 8. wp_term_taxonomy
CREATE TABLE IF NOT EXISTS wp_term_taxonomy (
  term_taxonomy_id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  term_id bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  taxonomy varchar(32) NOT NULL DEFAULT '',
  description longtext NOT NULL,
  parent bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  count bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (term_taxonomy_id),
  UNIQUE KEY term_id_taxonomy (term_id, taxonomy),
  KEY taxonomy (taxonomy)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 9. wp_term_relationships
CREATE TABLE IF NOT EXISTS wp_term_relationships (
  object_id bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  term_taxonomy_id bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  term_order int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (object_id, term_taxonomy_id),
  KEY term_taxonomy_id (term_taxonomy_id)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 10. wp_termmeta
CREATE TABLE IF NOT EXISTS wp_termmeta (
  meta_id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  term_id bigint(20) UNSIGNED NOT NULL DEFAULT 0,
  meta_key varchar(255) DEFAULT NULL,
  meta_value longtext,
  PRIMARY KEY (meta_id),
  KEY term_id (term_id),
  KEY meta_key (meta_key(191))
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 11. wp_options
CREATE TABLE IF NOT EXISTS wp_options (
  option_id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  option_name varchar(191) NOT NULL DEFAULT '',
  option_value longtext NOT NULL,
  autoload varchar(20) NOT NULL DEFAULT 'yes',
  PRIMARY KEY (option_id),
  UNIQUE KEY option_name (option_name),
  KEY autoload (autoload)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 12. wp_links
CREATE TABLE IF NOT EXISTS wp_links (
  link_id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  link_url varchar(255) NOT NULL DEFAULT '',
  link_name varchar(255) NOT NULL DEFAULT '',
  link_image varchar(255) NOT NULL DEFAULT '',
  link_target varchar(25) NOT NULL DEFAULT '',
  link_description varchar(255) NOT NULL DEFAULT '',
  link_visible varchar(20) NOT NULL DEFAULT 'Y',
  link_owner bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  link_rating int(11) NOT NULL DEFAULT 0,
  link_updated datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  link_rel varchar(255) NOT NULL DEFAULT '',
  link_notes mediumtext NOT NULL,
  link_rss varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (link_id),
  KEY link_visible (link_visible)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ============================================================
-- Sample data for practice
-- ============================================================

INSERT INTO wp_users (ID, user_login, user_pass, user_nicename, user_email, user_url, user_registered, display_name) VALUES
(1, 'admin', '$P$BfakehashedpasswordAdmin1', 'admin', 'admin@example.edu', '', '2026-01-01 12:00:00', 'Site Admin'),
(2, 'editor', '$P$BfakehashedpasswordEditor1', 'editor', 'editor@example.edu', '', '2026-01-15 08:30:00', 'Editor User'),
(3, 'author1', '$P$BfakehashedpasswordAuthor1', 'author1', 'author1@example.edu', '', '2026-02-01 10:15:00', 'Author One'),
(4, 'author2', '$P$BfakehashedpasswordAuthor2', 'author2', 'author2@example.edu', '', '2026-02-10 14:20:00', 'Author Two');

INSERT INTO wp_usermeta (umeta_id, user_id, meta_key, meta_value) VALUES
(1, 1, 'wp_capabilities', 'a:1:{s:13:\"administrator\";b:1;}'),
(2, 1, 'wp_user_level', '10'),
(3, 2, 'wp_capabilities', 'a:1:{s:6:\"editor\";b:1;}'),
(4, 2, 'wp_user_level', '7'),
(5, 3, 'wp_capabilities', 'a:1:{s:6:\"author\";b:1;}'),
(6, 3, 'wp_user_level', '2'),
(7, 4, 'wp_capabilities', 'a:1:{s:6:\"author\";b:1;}'),
(8, 4, 'wp_user_level', '2');

INSERT INTO wp_posts (ID, post_author, post_date, post_date_gmt, post_content, post_title, post_excerpt, post_status, post_name, to_ping, pinged, post_modified, post_modified_gmt, post_content_filtered, guid, post_type, comment_count) VALUES
(1, 1, '2026-03-01 09:00:00', '2026-03-01 17:00:00', 'This is the welcome post content.', 'Welcome to Our Site', '', 'publish', 'welcome-to-our-site', '', '', '2026-03-01 09:00:00', '2026-03-01 17:00:00', '', 'https://example.edu/?p=1', 'post', 2),
(2, 3, '2026-03-05 10:30:00', '2026-03-05 18:30:00', 'Here are some tips for getting started.', 'Getting Started with WordPress', '', 'publish', 'getting-started-wordpress', '', '', '2026-03-05 10:30:00', '2026-03-05 18:30:00', '', 'https://example.edu/?p=2', 'post', 2),
(3, 4, '2026-03-10 14:15:00', '2026-03-10 22:15:00', 'SEO best practices for your site.', 'Advanced SEO Tips', '', 'publish', 'advanced-seo-tips', '', '', '2026-03-10 14:15:00', '2026-03-10 22:15:00', '', 'https://example.edu/?p=3', 'post', 1),
(4, 3, '2026-03-12 11:45:00', '2026-03-12 19:45:00', 'This post is still being written.', 'Draft Post Not Yet Published', '', 'draft', 'draft-post-not-published', '', '', '2026-03-12 11:45:00', '2026-03-12 19:45:00', '', 'https://example.edu/?p=4', 'post', 0),
(5, 1, '2026-03-18 08:00:00', '2026-03-18 16:00:00', 'Learn about our organization.', 'About Our Organization', '', 'publish', 'about-us', '', '', '2026-03-18 08:00:00', '2026-03-18 16:00:00', '', 'https://example.edu/?p=5', 'page', 0);

INSERT INTO wp_comments (comment_ID, comment_post_ID, comment_author, comment_author_email, comment_author_url, comment_author_IP, comment_date, comment_date_gmt, comment_content, comment_approved, comment_agent, comment_type) VALUES
(1, 1, 'John Doe', 'john@example.com', '', '192.168.1.10', '2026-03-02 10:00:00', '2026-03-02 18:00:00', 'Great post! Very helpful.', '1', 'Mozilla/5.0', 'comment'),
(2, 1, 'Spammer', 'spam@fake.com', 'http://casino-spam.example', '10.0.0.99', '2026-03-03 15:30:00', '2026-03-03 23:30:00', 'Check out my casino website!!!', '0', 'SpamBot/1.0', 'comment'),
(3, 2, 'Jane Smith', 'jane@example.edu', '', '192.168.1.20', '2026-03-06 11:20:00', '2026-03-06 19:20:00', 'Excellent tips, thank you!', '1', 'Mozilla/5.0', 'comment'),
(4, 3, 'Hacker Attempt', 'hack@malicious.com', '', '10.0.0.66', '2026-03-11 22:15:00', '2026-03-12 06:15:00', 'eval(base64_decode($_POST["code"]));', '0', 'curl/7.88', 'comment'),
(5, 2, 'User Guest', 'guest@example.com', '', '192.168.1.30', '2026-03-16 09:45:00', '2026-03-16 17:45:00', 'Is this available in other languages?', '1', 'Mozilla/5.0', 'comment');

INSERT INTO wp_terms (term_id, name, slug) VALUES
(1, 'Uncategorized', 'uncategorized'),
(2, 'WordPress', 'wordpress'),
(3, 'SEO', 'seo');

INSERT INTO wp_term_taxonomy (term_taxonomy_id, term_id, taxonomy, description, count) VALUES
(1, 1, 'category', '', 1),
(2, 2, 'post_tag', '', 1),
(3, 3, 'post_tag', '', 1);

INSERT INTO wp_term_relationships (object_id, term_taxonomy_id) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO wp_options (option_id, option_name, option_value, autoload) VALUES
(1, 'siteurl', 'https://example.edu', 'yes'),
(2, 'home', 'https://example.edu', 'yes'),
(3, 'admin_email', 'admin@example.edu', 'yes'),
(4, 'blogname', 'University Learning Portal', 'yes'),
(5, 'blogdescription', 'Your source for campus news and resources', 'yes'),
(6, 'users_can_register', '0', 'yes'),
(7, 'posts_per_page', '10', 'yes'),
(8, 'blog_public', '1', 'yes');
