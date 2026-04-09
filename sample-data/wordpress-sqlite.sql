-- WordPress sample database schema for SQLite practice
-- Converted from MySQL syntax to SQLite-compatible syntax

-- wp_users table
CREATE TABLE wp_users (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  user_login TEXT NOT NULL,
  user_pass TEXT NOT NULL,
  user_email TEXT NOT NULL,
  user_registered TEXT NOT NULL,
  user_status INTEGER DEFAULT 0
);

INSERT INTO wp_users (ID, user_login, user_pass, user_email, user_registered, user_status) VALUES
(1, 'admin', 'hashed_password_here', 'admin@example.edu', '2026-01-01 12:00:00', 0),
(2, 'editor', 'hashed_password_here', 'editor@example.edu', '2026-01-15 08:30:00', 0),
(3, 'author1', 'hashed_password_here', 'author1@example.edu', '2026-02-01 10:15:00', 0),
(4, 'author2', 'hashed_password_here', 'author2@example.edu', '2026-02-10 14:20:00', 0);

-- wp_posts table
CREATE TABLE wp_posts (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  post_author INTEGER NOT NULL,
  post_date TEXT NOT NULL,
  post_title TEXT NOT NULL,
  post_content TEXT NOT NULL,
  post_status TEXT DEFAULT 'draft',
  post_type TEXT DEFAULT 'post',
  post_name TEXT
);

INSERT INTO wp_posts (ID, post_author, post_date, post_title, post_content, post_status, post_type, post_name) VALUES
(1, 1, '2026-03-01 09:00:00', 'Welcome to Our Site', 'This is the welcome post content...', 'publish', 'post', 'welcome-to-our-site'),
(2, 3, '2026-03-05 10:30:00', 'Getting Started with WordPress', 'Here are some tips for getting started...', 'publish', 'post', 'getting-started-wordpress'),
(3, 4, '2026-03-10 14:15:00', 'Advanced SEO Tips', 'SEO best practices for your site...', 'publish', 'post', 'advanced-seo-tips'),
(4, 3, '2026-03-12 11:45:00', 'Draft Post Not Yet Published', 'This post is still being written...', 'draft', 'post', 'draft-post-not-published'),
(5, 2, '2026-03-15 16:20:00', 'Scheduled Future Post', 'This post will be published later...', 'future', 'post', 'scheduled-post'),
(6, 1, '2026-03-18 08:00:00', 'About Our Organization', 'Learn about our organization...', 'publish', 'page', 'about-us');

-- wp_comments table
CREATE TABLE wp_comments (
  comment_ID INTEGER PRIMARY KEY AUTOINCREMENT,
  comment_post_ID INTEGER NOT NULL,
  comment_author TEXT NOT NULL,
  comment_author_email TEXT NOT NULL,
  comment_date TEXT NOT NULL,
  comment_content TEXT NOT NULL,
  comment_approved TEXT DEFAULT '1'
);

INSERT INTO wp_comments (comment_ID, comment_post_ID, comment_author, comment_author_email, comment_date, comment_content, comment_approved) VALUES
(1, 1, 'John Doe', 'john@example.com', '2026-03-02 10:00:00', 'Great post! Very helpful.', '1'),
(2, 1, 'Spammer', 'spam@fake.com', '2026-03-03 15:30:00', 'Check out my casino website!!!', '0'),
(3, 2, 'Jane Smith', 'jane@example.edu', '2026-03-06 11:20:00', 'Excellent tips, thank you!', '1'),
(4, 3, 'Hacker Attempt', 'hack@malicious.com', '2026-03-11 22:15:00', 'eval(base64_decode($_POST["code"]));', '0'),
(5, 2, 'User Guest', 'guest@example.com', '2026-03-16 09:45:00', 'Is this available in other languages?', '1');

-- wp_options table (site configuration)
CREATE TABLE wp_options (
  option_id INTEGER PRIMARY KEY AUTOINCREMENT,
  option_name TEXT NOT NULL,
  option_value TEXT NOT NULL
);

INSERT INTO wp_options (option_id, option_name, option_value) VALUES
(1, 'siteurl', 'https://example.edu'),
(2, 'home', 'https://example.edu'),
(3, 'admin_email', 'admin@example.edu'),
(4, 'blogname', 'University Learning Portal'),
(5, 'blogdescription', 'Your source for campus news and resources'),
(6, 'users_can_register', '0'),
(7, 'posts_per_page', '10'),
(8, 'blog_public', '1');

-- Sample practice queries:
-- List all published posts
-- SELECT ID, post_title, post_author, post_date FROM wp_posts WHERE post_type = 'post' AND post_status = 'publish' ORDER BY post_date DESC;

-- Find users with most posts
-- SELECT u.user_login, COUNT(p.ID) as post_count FROM wp_users u LEFT JOIN wp_posts p ON u.ID = p.post_author WHERE p.post_type = 'post' AND p.post_status = 'publish' GROUP BY u.ID ORDER BY post_count DESC;

-- Check for unapproved (spam) comments
-- SELECT comment_author, COUNT(*) as count FROM wp_comments WHERE comment_approved = '0' GROUP BY comment_author ORDER BY count DESC;

-- Get site URL and admin email
-- SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl', 'admin_email');
