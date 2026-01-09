-- Migration: Add Conversation History Tables
-- Description: Tables to store chat sessions and conversation history for AI assistant
-- Created: 2026-01-07

-- --------------------------------------------------------
-- Table structure for table `chat_sessions`
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `chat_sessions` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY COMMENT 'Unique session identifier',
  `user_id` INT DEFAULT NULL COMMENT 'User who owns this session',
  `title` VARCHAR(255) NOT NULL COMMENT 'Session title (first query or custom name)',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `message_count` INT NOT NULL DEFAULT 0 COMMENT 'Total messages in this session',
  `is_active` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1: active, 0: archived',
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_is_active` (`is_active`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Chat sessions for conversation history';

-- --------------------------------------------------------
-- Table structure for table `conversation_messages`
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `conversation_messages` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `session_id` VARCHAR(50) NOT NULL COMMENT 'Reference to chat_sessions.id',
  `message_type` ENUM('user', 'assistant', 'system', 'error') NOT NULL COMMENT 'Type of message',
  `content` TEXT NOT NULL COMMENT 'Message content',
  `query` TEXT DEFAULT NULL COMMENT 'Original user query (for user messages)',
  `sql_query` TEXT DEFAULT NULL COMMENT 'Generated SQL query (for assistant messages)',
  `result_count` INT DEFAULT NULL COMMENT 'Number of results returned',
  `execution_time_ms` FLOAT DEFAULT NULL COMMENT 'Query execution time in milliseconds',
  `chart_config` JSON DEFAULT NULL COMMENT 'Chart configuration if applicable',
  `metadata` JSON DEFAULT NULL COMMENT 'Additional metadata (error details, etc.)',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_session_id` (`session_id`),
  INDEX `idx_message_type` (`message_type`),
  INDEX `idx_created_at` (`created_at`),
  FOREIGN KEY (`session_id`) REFERENCES `chat_sessions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Individual messages within chat sessions';

-- --------------------------------------------------------
-- Table structure for table `conversation_context`
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `conversation_context` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `session_id` VARCHAR(50) NOT NULL COMMENT 'Reference to chat_sessions.id',
  `context_key` VARCHAR(100) NOT NULL COMMENT 'Context key (e.g., last_user, last_department, last_workflow)',
  `context_value` TEXT NOT NULL COMMENT 'Context value',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_session_context` (`session_id`, `context_key`),
  INDEX `idx_session_id` (`session_id`),
  FOREIGN KEY (`session_id`) REFERENCES `chat_sessions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Contextual information extracted from conversations for better query understanding';

-- --------------------------------------------------------
-- Indexes for performance
-- --------------------------------------------------------

-- Composite index for fetching recent messages in a session
CREATE INDEX `idx_session_created` ON `conversation_messages` (`session_id`, `created_at` DESC);

-- Index for searching messages by content
CREATE FULLTEXT INDEX `idx_content_search` ON `conversation_messages` (`content`, `query`);

