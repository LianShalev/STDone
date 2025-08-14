CREATE TABLE `users` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `email` varchar(190) UNIQUE,
  `password_h` varchar(255),
  `full_name` varchar(120),
  `role` enum(admin,user) DEFAULT 'user',
  `status` enum(active,banned) DEFAULT 'active',
  `created_at` datetime,
  `last_login_at` datetime
);

CREATE TABLE `profiles` (
  `user_id` int PRIMARY KEY,
  `plan` enum(free,premium) DEFAULT 'free',
  `plan_expires_at` datetime,
  `tests_per_day` int COMMENT 'free=3, premium=null (=unlimited)',
  `history_limit` int COMMENT 'free=10, premium=null (=unlimited)',
  `settings_json` json
);

CREATE TABLE `sessions` (
  `id` char(36) PRIMARY KEY COMMENT 'UUID',
  `user_id` int COMMENT 'NULL = guest',
  `is_guest` boolean DEFAULT true,
  `ip_hash` char(64),
  `user_agent` varchar(255),
  `created_at` datetime,
  `last_seen_at` datetime
);

CREATE TABLE `usage_counters` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `day` date,
  `user_id` int,
  `session_id` char(36),
  `tests_used` int DEFAULT 0
);

CREATE TABLE `plans` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `code` varchar(40) UNIQUE COMMENT 'free, premium',
  `name` varchar(80),
  `price_usd` decimal(10,2),
  `features_json` json
);

CREATE TABLE `subscriptions` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int,
  `plan_id` int,
  `status` enum(active,canceled,expired,past_due),
  `started_at` datetime,
  `expires_at` datetime,
  `canceled_at` datetime,
  `provider` enum(paypal),
  `provider_agreement_id` varchar(128)
);

CREATE TABLE `payments` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int,
  `plan_id` int,
  `provider` enum(paypal),
  `amount_usd` decimal(10,2),
  `currency` char(3),
  `status` enum(succeeded,failed,pending),
  `provider_txn_id` varchar(128),
  `created_at` datetime
);

CREATE TABLE `folders` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int,
  `name` varchar(120),
  `created_at` datetime
);

CREATE TABLE `std_templates` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int COMMENT 'NULL=system template',
  `name` varchar(120),
  `description` text,
  `is_default` boolean DEFAULT false,
  `version` int DEFAULT 1,
  `created_at` datetime
);

CREATE TABLE `template_fields` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `template_id` int,
  `name` varchar(120),
  `key` varchar(120) COMMENT 'slug, unique per template',
  `type` enum(text,longtext,number,bool,date,time,select,multiselect,url,json),
  `required` boolean DEFAULT false,
  `order_index` int,
  `default_val` text,
  `options_json` json,
  `ai_hint` text COMMENT 'עזרה ל-AI איך למלא שדה זה (מילים נרדפות, דוגמאות)'
);

CREATE TABLE `analysis_sessions` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `session_id` char(36),
  `user_id` int,
  `status` enum(uploaded,processing,done,error),
  `video_url` varchar(255),
  `rrweb_url` varchar(255),
  `har_url` varchar(255),
  `transcript_url` varchar(255),
  `duration_sec` int,
  `error_message` text,
  `created_at` datetime,
  `completed_at` datetime
);

CREATE TABLE `std_documents` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `owner_user_id` int,
  `session_id` char(36),
  `template_id` int,
  `folder_id` int,
  `title` varchar(160),
  `project_name` varchar(160),
  `status` enum(draft,final) DEFAULT 'final',
  `generated_at` datetime,
  `purge_at` datetime COMMENT 'למחיקה אוטומטית לאחר 30 יום ללא מנוי',
  `markdown_url` varchar(255),
  `pdf_url` varchar(255),
  `docx_url` varchar(255),
  `metadata_json` json COMMENT 'scope, risks, environments, acceptance'
);

CREATE TABLE `test_case_rows` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `document_id` int,
  `row_index` int
);

CREATE TABLE `test_case_values` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `row_id` int,
  `field_id` int,
  `value_text` longtext,
  `value_num` decimal(18,6),
  `value_json` json
);

CREATE TABLE `events` (
  `id` bigint PRIMARY KEY AUTO_INCREMENT,
  `session_id` char(36),
  `user_id` int,
  `type` enum(visit,login,signup,upload,generate,payment,error),
  `payload_json` json,
  `occurred_at` datetime
);

CREATE TABLE `ban_logs` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int,
  `by_admin_id` int,
  `reason` text,
  `created_at` datetime
);

CREATE TABLE `contact_preferences` (
  `user_id` int PRIMARY KEY,
  `email_marketing_consent` boolean DEFAULT false,
  `sms_marketing_consent` boolean DEFAULT false,
  `preferred_channel` enum(email,sms,none) DEFAULT 'email',
  `consent_ts` datetime,
  `consent_source` varchar(160) COMMENT 'e.g., signup checkbox, settings page',
  `policy_version` varchar(20),
  `revoked_ts` datetime
);

CREATE TABLE `consents_history` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `user_id` int,
  `channel` enum(email,sms),
  `action` enum(consented,revoked,updated),
  `policy_version` varchar(20),
  `source` varchar(160),
  `ip_hash` char(64),
  `user_agent` varchar(255),
  `occurred_at` datetime
);

CREATE TABLE `marketing_suppression_list` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `contact` varchar(190) UNIQUE COMMENT 'email or phone in normalized form',
  `reason` enum(unsubscribed,bounced,complaint,blocked,manual),
  `provider` varchar(60),
  `created_at` datetime
);

CREATE TABLE `marketing_campaigns` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(160),
  `channel` enum(email,sms) DEFAULT 'email',
  `status` enum(draft,scheduled,sending,paused,completed) DEFAULT 'draft',
  `subject` varchar(190),
  `body_html` longtext,
  `body_text` longtext,
  `from_name` varchar(120),
  `from_email` varchar(190),
  `send_at` datetime,
  `created_by` int,
  `created_at` datetime
);

CREATE TABLE `marketing_segments` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(160),
  `definition_json` json COMMENT 'rules for selecting recipients',
  `created_by` int,
  `created_at` datetime
);

CREATE TABLE `marketing_recipients` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `campaign_id` int,
  `user_id` int,
  `email` varchar(190),
  `status` enum(queued,skipped,sent,failed,suppressed) DEFAULT 'queued',
  `reason` text,
  `sent_at` datetime
);

CREATE TABLE `marketing_events` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `campaign_id` int,
  `recipient_id` int,
  `user_id` int,
  `type` enum(delivered,open,click,bounce,complaint,unsubscribe),
  `meta_json` json,
  `occurred_at` datetime
);

CREATE UNIQUE INDEX `usage_counters_index_0` ON `usage_counters` (`day`, `user_id`);

CREATE UNIQUE INDEX `usage_counters_index_1` ON `usage_counters` (`day`, `session_id`);

CREATE UNIQUE INDEX `marketing_recipients_index_2` ON `marketing_recipients` (`campaign_id`, `user_id`);

ALTER TABLE `profiles` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `sessions` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `usage_counters` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `usage_counters` ADD FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`);

ALTER TABLE `subscriptions` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `subscriptions` ADD FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`);

ALTER TABLE `payments` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `payments` ADD FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`);

ALTER TABLE `folders` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `std_templates` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `template_fields` ADD FOREIGN KEY (`template_id`) REFERENCES `std_templates` (`id`);

ALTER TABLE `analysis_sessions` ADD FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`);

ALTER TABLE `analysis_sessions` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `std_documents` ADD FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`);

ALTER TABLE `std_documents` ADD FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`);

ALTER TABLE `std_documents` ADD FOREIGN KEY (`template_id`) REFERENCES `std_templates` (`id`);

ALTER TABLE `std_documents` ADD FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`);

ALTER TABLE `test_case_rows` ADD FOREIGN KEY (`document_id`) REFERENCES `std_documents` (`id`);

ALTER TABLE `test_case_values` ADD FOREIGN KEY (`row_id`) REFERENCES `test_case_rows` (`id`);

ALTER TABLE `test_case_values` ADD FOREIGN KEY (`field_id`) REFERENCES `template_fields` (`id`);

ALTER TABLE `events` ADD FOREIGN KEY (`session_id`) REFERENCES `sessions` (`id`);

ALTER TABLE `events` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `ban_logs` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `ban_logs` ADD FOREIGN KEY (`by_admin_id`) REFERENCES `users` (`id`);

ALTER TABLE `contact_preferences` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `consents_history` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `marketing_campaigns` ADD FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

ALTER TABLE `marketing_segments` ADD FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

ALTER TABLE `marketing_recipients` ADD FOREIGN KEY (`campaign_id`) REFERENCES `marketing_campaigns` (`id`);

ALTER TABLE `marketing_recipients` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `marketing_events` ADD FOREIGN KEY (`campaign_id`) REFERENCES `marketing_campaigns` (`id`);

ALTER TABLE `marketing_events` ADD FOREIGN KEY (`recipient_id`) REFERENCES `marketing_recipients` (`id`);

ALTER TABLE `marketing_events` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
