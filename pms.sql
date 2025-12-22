-- phpMyAdmin SQL Dump
-- version 4.9.5deb2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 12, 2025 at 06:24 PM
-- Server version: 8.0.42-0ubuntu0.20.04.1
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pms_dev_nmg_90`
--

-- --------------------------------------------------------

--
-- Table structure for table `additional_works`
--

CREATE TABLE `additional_works` (
  `id` int UNSIGNED NOT NULL,
  `project_lead_id` int DEFAULT NULL COMMENT 'as user_id',
  `project_id` bigint DEFAULT NULL,
  `item_number` varchar(225) NOT NULL,
  `closure_status` bigint DEFAULT NULL COMMENT '1=>''Pending-PL'', 2=>''Pending-ST''',
  `work_type_id` bigint DEFAULT NULL COMMENT '1=>Proposed, 2=>Requested',
  `work_title` varchar(225) DEFAULT NULL,
  `estimated_hrs` double NOT NULL DEFAULT '0',
  `hourly_rate` double DEFAULT NULL,
  `currency_id` bigint UNSIGNED NOT NULL DEFAULT '1' COMMENT 'References id in currencies table',
  `total_amount` decimal(15,3) NOT NULL DEFAULT '0.000' COMMENT 'hourly_rate * estimated_hrs',
  `final_approved_amount` decimal(15,3) DEFAULT NULL,
  `reason` text COMMENT 'Reason for approval or rejection',
  `item_details` varchar(225) DEFAULT NULL,
  `approved_from_client` bigint DEFAULT NULL COMMENT '''1=>Approved'',''2=>Rejected''',
  `on_hold` tinyint NOT NULL DEFAULT '0' COMMENT '0 = No, 1 = Yes',
  `on_hold_date` date DEFAULT NULL COMMENT 'Date when the work was put on hold',
  `additional_note` text,
  `milestone_planned` enum('yes','no') DEFAULT NULL,
  `milestone_shared` enum('yes','no') DEFAULT NULL,
  `production_capacity_sheet_check` enum('yes','no') DEFAULT NULL,
  `invoice_date` date DEFAULT NULL COMMENT 'Invoice raised By PL',
  `invoice_date_finance` date DEFAULT NULL COMMENT 'Invoice raised by finance',
  `invoice_approved` enum('yes','no') DEFAULT NULL COMMENT 'Approved by finance',
  `resolution_date` date DEFAULT NULL,
  `closure_comment` varchar(225) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT 'closure comment by PL',
  `closure_date` date DEFAULT NULL COMMENT 'closure date by PL',
  `closure_comment_ST` varchar(225) DEFAULT NULL COMMENT 'closure comment by ST',
  `closure_date_ST` date DEFAULT NULL COMMENT 'closure date by ST',
  `client_pulse` bigint DEFAULT NULL COMMENT '1=>''Positive'', 2=>''Negative'',3=>''Neutral''',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `additional_work_email_replies`
--

CREATE TABLE `additional_work_email_replies` (
  `id` bigint UNSIGNED NOT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `user_id` int UNSIGNED DEFAULT NULL,
  `mail_from` varchar(225) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_file` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `assign_tester_tasks`
--

CREATE TABLE `assign_tester_tasks` (
  `id` int NOT NULL,
  `assign_by` int NOT NULL,
  `assign_to` int NOT NULL,
  `task_id` int NOT NULL,
  `hours` int DEFAULT NULL,
  `acceptance_status` int DEFAULT NULL,
  `status` tinyint NOT NULL COMMENT '1=>Accepted, 2=>Rejected,',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `acceptance_date` datetime DEFAULT NULL,
  `done_status` int DEFAULT NULL,
  `completion_date` datetime DEFAULT NULL,
  `hold_status` int DEFAULT NULL,
  `hold_resume_date` datetime DEFAULT NULL,
  `total_worked_minute` double(7,2) DEFAULT NULL,
  `reject_status` int DEFAULT NULL,
  `reject_reason` varchar(255) DEFAULT NULL COMMENT 'Rejection reason',
  `is_latest` tinyint NOT NULL DEFAULT '0' COMMENT '0:no, 1:yes'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `attendance_email_replies`
--

CREATE TABLE `attendance_email_replies` (
  `id` int NOT NULL,
  `parent_id` int UNSIGNED NOT NULL COMMENT 'employee id',
  `commented_person_id` int UNSIGNED NOT NULL,
  `to_send_person_id` int UNSIGNED NOT NULL,
  `type` tinyint NOT NULL DEFAULT '1' COMMENT '''Attendance List'' => 1, ''Attendance Details'' => 2',
  `date` date DEFAULT NULL,
  `subject` varchar(225) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendance_email_replies_1`
--

CREATE TABLE `attendance_email_replies_1` (
  `id` int NOT NULL,
  `parent_id` int NOT NULL COMMENT 'employee id',
  `commented_person_id` int NOT NULL,
  `to_send_person_id` int NOT NULL,
  `type` tinyint NOT NULL DEFAULT '1' COMMENT '''Attendance List'' => 1, ''Attendance Details'' => 2',
  `date` date DEFAULT NULL,
  `subject` varchar(225) NOT NULL,
  `content` text NOT NULL,
  `uploaded_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `flag` bigint NOT NULL DEFAULT '1' COMMENT '0= private 1= public',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `biometric_histories`
--

CREATE TABLE `biometric_histories` (
  `id` bigint NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `in_time` time NOT NULL,
  `out_time` time NOT NULL,
  `time_duration` time NOT NULL,
  `atten_date` date NOT NULL,
  `employee_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `biometric_histories_1`
--

CREATE TABLE `biometric_histories_1` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `in_time` time NOT NULL,
  `out_time` time NOT NULL,
  `time_duration` time NOT NULL,
  `atten_date` date NOT NULL,
  `employee_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `boards`
--

CREATE TABLE `boards` (
  `id` int NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `board_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `board_id` int NOT NULL,
  `project_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `board_webhooks`
--

CREATE TABLE `board_webhooks` (
  `id` bigint UNSIGNED NOT NULL,
  `webhook_id` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `board_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `callback_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `boms`
--

CREATE TABLE `boms` (
  `id` bigint UNSIGNED NOT NULL,
  `ims_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_product_id` bigint UNSIGNED NOT NULL COMMENT 'Finished product',
  `unit_production_quantity` decimal(10,4) NOT NULL,
  `status` tinyint NOT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `component_ims_id` bigint UNSIGNED NOT NULL COMMENT 'Component Ims',
  `component_warehouse_id` bigint UNSIGNED NOT NULL COMMENT 'Component Ims Warehouse',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bom_components`
--

CREATE TABLE `bom_components` (
  `id` bigint UNSIGNED NOT NULL,
  `bom_id` bigint UNSIGNED NOT NULL,
  `bom_final_product_stage_id` bigint UNSIGNED DEFAULT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `required_quantity` decimal(10,2) NOT NULL,
  `wastage_percent` decimal(5,2) NOT NULL DEFAULT '0.00',
  `cost_per_unit` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bom_final_products`
--

CREATE TABLE `bom_final_products` (
  `id` bigint UNSIGNED NOT NULL,
  `parent_product_ims_id` bigint UNSIGNED NOT NULL COMMENT 'Finished product IMS',
  `bom_id` bigint UNSIGNED NOT NULL COMMENT 'BOM ID',
  `parent_product_id` bigint UNSIGNED NOT NULL COMMENT 'Finished product',
  `unit_production_quantity` decimal(10,4) NOT NULL,
  `status` tinyint NOT NULL,
  `production_type` enum('single','multi') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'single',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `component_ims_id` bigint UNSIGNED NOT NULL COMMENT 'Component Ims',
  `component_warehouse_id` bigint UNSIGNED NOT NULL COMMENT 'Component Ims Warehouse',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bom_final_product_stages`
--

CREATE TABLE `bom_final_product_stages` (
  `id` bigint UNSIGNED NOT NULL,
  `bom_final_product_id` bigint UNSIGNED DEFAULT NULL,
  `bom_stage_id` bigint UNSIGNED DEFAULT NULL,
  `stage_order` int NOT NULL DEFAULT '1',
  `ims_id` bigint UNSIGNED DEFAULT NULL,
  `warehouse_id` bigint UNSIGNED DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bom_import_logs`
--

CREATE TABLE `bom_import_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'csv',
  `ims_id` bigint UNSIGNED NOT NULL,
  `total_boms` int NOT NULL DEFAULT '0',
  `uploaded_boms` int NOT NULL DEFAULT '0',
  `rejected_boms` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1=Processing, 2=Completed, 3=Failed',
  `uploaded_by` bigint UNSIGNED DEFAULT NULL,
  `error_details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bom_stages`
--

CREATE TABLE `bom_stages` (
  `id` bigint UNSIGNED NOT NULL,
  `bom_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `order` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `category_departments`
--

CREATE TABLE `category_departments` (
  `id` bigint UNSIGNED NOT NULL,
  `category_masters_id` bigint NOT NULL,
  `department_id` bigint NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `category_masters`
--

CREATE TABLE `category_masters` (
  `id` int UNSIGNED NOT NULL,
  `category_name` varchar(255) NOT NULL,
  `category_uid` varchar(255) DEFAULT NULL,
  `status` int UNSIGNED NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` timestamp NOT NULL,
  `deleted_at` varchar(100) DEFAULT NULL,
  `created_by` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chat_task_feedback`
--

CREATE TABLE `chat_task_feedback` (
  `id` int NOT NULL,
  `taskId` int NOT NULL,
  `created_by` int NOT NULL,
  `content` text NOT NULL,
  `attachment` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `chat_with_organizations`
--

CREATE TABLE `chat_with_organizations` (
  `id` bigint NOT NULL,
  `sender` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Organization id or superadmin',
  `receiver` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Organization id or superadmin',
  `issue_id` int NOT NULL,
  `images` varchar(255) DEFAULT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `checklist_type_masters`
--

CREATE TABLE `checklist_type_masters` (
  `id` bigint NOT NULL,
  `parent_id` bigint DEFAULT NULL,
  `slug` varchar(45) DEFAULT NULL,
  `type_name` varchar(23) DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_goals`
--

CREATE TABLE `company_goals` (
  `id` bigint UNSIGNED NOT NULL,
  `created_by` bigint NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_marked_completed` tinyint NOT NULL DEFAULT '0' COMMENT '0:no, 1:yes',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '0:in-active, 1:active',
  `period` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '1:quarterly, 2: Yearly, 3: Custom date range',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `goal_owner_dept` bigint NOT NULL,
  `goal_owner_id` bigint NOT NULL,
  `goal_co_owner_id` bigint DEFAULT NULL,
  `proof_per_task` tinyint NOT NULL DEFAULT '0' COMMENT '1:required, 0:not required',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_goal_chat_task_feedback`
--

CREATE TABLE `company_goal_chat_task_feedback` (
  `id` bigint UNSIGNED NOT NULL,
  `company_goal_task_id` bigint UNSIGNED NOT NULL,
  `created_by` bigint UNSIGNED NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `attachment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_goal_co_owners`
--

CREATE TABLE `company_goal_co_owners` (
  `id` bigint UNSIGNED NOT NULL,
  `company_goal_id` bigint DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_goal_tasks`
--

CREATE TABLE `company_goal_tasks` (
  `id` bigint UNSIGNED NOT NULL,
  `company_goal_id` bigint NOT NULL,
  `created_by` bigint NOT NULL,
  `task_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resolution_date` date DEFAULT NULL,
  `task_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department_id` bigint NOT NULL,
  `assignee` bigint NOT NULL,
  `reviewer_id` bigint NOT NULL,
  `status` tinyint NOT NULL COMMENT '1:Accept, 2:Reject, 3:Pause/resume, 4:Done, 5:Rework, 6:Approved',
  `acceptance_date` date DEFAULT NULL,
  `completion_date` date DEFAULT NULL,
  `hold_resume_date` date DEFAULT NULL,
  `reviewer_status` tinyint DEFAULT NULL COMMENT '1: Approve 2: Reject',
  `reviewer_status_date` date DEFAULT NULL,
  `reviewer_rejection_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `doer_submission_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cron_department_wise_details`
--

CREATE TABLE `cron_department_wise_details` (
  `id` int NOT NULL,
  `dpt_id` bigint NOT NULL,
  `creation_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `currencies`
--

CREATE TABLE `currencies` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `symbol` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '0 = Inactive, 1 = Active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dashboard_permissions`
--

CREATE TABLE `dashboard_permissions` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `deleted_by` bigint UNSIGNED DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delegations`
--

CREATE TABLE `delegations` (
  `id` int NOT NULL,
  `md_user_id` int NOT NULL,
  `ea_user_id` int NOT NULL,
  `status` int NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delegation_boards`
--

CREATE TABLE `delegation_boards` (
  `id` bigint UNSIGNED NOT NULL,
  `md_user_id` int NOT NULL,
  `ex_user_id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `emp_attach_status` tinyint DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delegation_revision_histories`
--

CREATE TABLE `delegation_revision_histories` (
  `id` bigint UNSIGNED NOT NULL,
  `delegation_task_id` bigint UNSIGNED DEFAULT NULL,
  `employee_id` bigint UNSIGNED DEFAULT NULL,
  `revision_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `delegation_tasks`
--

CREATE TABLE `delegation_tasks` (
  `id` bigint UNSIGNED NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delegation_board_id` bigint UNSIGNED NOT NULL,
  `employee_id` bigint UNSIGNED DEFAULT NULL,
  `voice_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voice_note_duration` int DEFAULT NULL,
  `file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `deligation_email_replies`
--

CREATE TABLE `deligation_email_replies` (
  `id` int NOT NULL,
  `deligation_task_id` int NOT NULL COMMENT 'deligation task id',
  `commented_person_id` int NOT NULL,
  `to_send_person_id` int NOT NULL,
  `date` date DEFAULT NULL,
  `subject` varchar(225) NOT NULL,
  `content` text NOT NULL,
  `uploaded_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `voice_note` varchar(255) DEFAULT NULL,
  `voice_note_duration` int NOT NULL DEFAULT '0' COMMENT 'in seconds',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `deligation_tasks`
--

CREATE TABLE `deligation_tasks` (
  `id` int NOT NULL,
  `creator_id` int NOT NULL,
  `assignee_id` int NOT NULL,
  `task_name` varchar(255) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` int NOT NULL COMMENT '''Accept'' => 1, Reject'' => 2, ''Pause/Resume'' => 3, ''Done'' => 4, ''Rework'' => 5',
  `acceptance_date` varchar(255) NOT NULL,
  `completion_date` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `deo_status`
--

CREATE TABLE `deo_status` (
  `id` bigint UNSIGNED NOT NULL,
  `module_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_required` tinyint NOT NULL DEFAULT '1' COMMENT '0:No, 1:Yes',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` bigint UNSIGNED NOT NULL,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `team_lead_id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'functional/reporting manager id',
  `Isexternal` int NOT NULL DEFAULT '0' COMMENT 'Internal =>0,External =>1',
  `template` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `recurring_task_check` int NOT NULL,
  `is_functional` tinyint NOT NULL DEFAULT '1' COMMENT '1: functional, 0: non-functional',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `department_managers`
--

CREATE TABLE `department_managers` (
  `id` bigint UNSIGNED NOT NULL,
  `department_id` bigint UNSIGNED NOT NULL,
  `designation_id` int DEFAULT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `designations`
--

CREATE TABLE `designations` (
  `id` bigint UNSIGNED NOT NULL,
  `department_id` bigint UNSIGNED NOT NULL,
  `department_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `email_templates`
--

CREATE TABLE `email_templates` (
  `id` int UNSIGNED NOT NULL,
  `email_type_id` int UNSIGNED NOT NULL,
  `locale` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `created_by` int NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `email_templates_backup28thMar25`
--

CREATE TABLE `email_templates_backup28thMar25` (
  `id` int UNSIGNED NOT NULL,
  `email_type_id` int UNSIGNED NOT NULL,
  `locale` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` tinyint UNSIGNED NOT NULL DEFAULT '1',
  `created_by` int NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `email_types`
--

CREATE TABLE `email_types` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `email_types_backup28thMar25`
--

CREATE TABLE `email_types_backup28thMar25` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `id` bigint UNSIGNED NOT NULL,
  `emp_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `emp_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `designation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `pms_designation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `epics`
--

CREATE TABLE `epics` (
  `id` int NOT NULL,
  `jira_epic_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `project_id` int NOT NULL COMMENT 'id from projects',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `error_logs`
--

CREATE TABLE `error_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `line` smallint UNSIGNED DEFAULT NULL,
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referer` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `event_histories`
--

CREATE TABLE `event_histories` (
  `id` int NOT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `time` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `repository_name` varchar(255) DEFAULT NULL,
  `commit_id` varchar(255) DEFAULT NULL,
  `branch_name` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ew_mappings`
--

CREATE TABLE `ew_mappings` (
  `id` int NOT NULL,
  `project_manager` int DEFAULT NULL,
  `userRole` int DEFAULT NULL,
  `extra_work` varchar(255) DEFAULT NULL,
  `relevent_option` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `ewdate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `comment` text,
  `status` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fcm_tokens`
--

CREATE TABLE `fcm_tokens` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `device_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fcm_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voip_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_checklist_permissions`
--

CREATE TABLE `fms_checklist_permissions` (
  `id` bigint NOT NULL,
  `fms_checklist_id` bigint DEFAULT NULL,
  `department_id` bigint DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_checklist_sections`
--

CREATE TABLE `fms_checklist_sections` (
  `id` bigint NOT NULL,
  `fms_step_id` bigint NOT NULL,
  `section_name` varchar(255) NOT NULL,
  `index` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_deos`
--

CREATE TABLE `fms_deos` (
  `id` bigint NOT NULL,
  `fms_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `status` tinyint DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_dynamic_data_sources`
--

CREATE TABLE `fms_dynamic_data_sources` (
  `id` bigint UNSIGNED NOT NULL,
  `source_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'User-friendly display name for external data sources',
  `is_external_data` tinyint NOT NULL DEFAULT '0' COMMENT '0 for system data, 1 for external/custom data',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_dynamic_data_source_values`
--

CREATE TABLE `fms_dynamic_data_source_values` (
  `id` bigint UNSIGNED NOT NULL,
  `data_source_id` bigint UNSIGNED DEFAULT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'The actual value to be stored/used',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '0 for inactive, 1 for active',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entries`
--

CREATE TABLE `fms_entries` (
  `id` bigint NOT NULL,
  `external_uid` varchar(255) DEFAULT NULL,
  `unique_entry_name` varchar(50) DEFAULT NULL,
  `parent_entry_id` bigint DEFAULT NULL,
  `parent_entry_progress_id` bigint DEFAULT NULL,
  `parent_entry_show_along_checklist_ids` varchar(45) DEFAULT NULL,
  `parent_entry_step_zero_checklist_ids` varchar(45) DEFAULT NULL,
  `parent_entry_progress_checklist_ids` varchar(45) DEFAULT NULL,
  `captured_entry_item_submission_ids` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `title_checklist_id` bigint DEFAULT NULL,
  `split_target_step_id` bigint DEFAULT NULL,
  `identifier_checklist_submission_id` varchar(45) DEFAULT NULL,
  `fms_id` bigint NOT NULL,
  `entry_title` varchar(255) DEFAULT NULL,
  `created_by` bigint DEFAULT NULL,
  `start_date` timestamp NOT NULL,
  `split_type` enum('loop','stagger','direct') DEFAULT NULL,
  `split_match_id` bigint DEFAULT NULL,
  `step_checklist_match_id` bigint DEFAULT NULL,
  `split_status` enum('awaited','completed') DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_checklists`
--

CREATE TABLE `fms_entry_checklists` (
  `id` bigint NOT NULL,
  `fms_id` bigint NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `type` bigint DEFAULT NULL,
  `subtype_id` bigint DEFAULT NULL,
  `show_along_entry` tinyint NOT NULL DEFAULT '0',
  `batch_entry_checklist` tinyint DEFAULT '0',
  `checklist_editable_for_item` tinyint NOT NULL DEFAULT '0',
  `is_title` tinyint DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_checklist_submissions`
--

CREATE TABLE `fms_entry_checklist_submissions` (
  `id` bigint NOT NULL,
  `fms_entry_id` bigint NOT NULL,
  `checklist_id` varchar(255) NOT NULL,
  `version` tinyint NOT NULL DEFAULT '1',
  `parent_id` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_checklist_submission_values`
--

CREATE TABLE `fms_entry_checklist_submission_values` (
  `id` bigint NOT NULL,
  `fms_entry_checklist_submission_id` bigint NOT NULL,
  `filled_value` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_checklist_values`
--

CREATE TABLE `fms_entry_checklist_values` (
  `id` bigint NOT NULL,
  `fms_entry_checklist_id` bigint DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_email_notification_templates`
--

CREATE TABLE `fms_entry_email_notification_templates` (
  `id` bigint NOT NULL,
  `fms_id` bigint NOT NULL,
  `client_email_field` varchar(255) DEFAULT NULL,
  `team_email_address` varchar(255) DEFAULT NULL,
  `cc_email` varchar(255) DEFAULT NULL,
  `client_email_subject` varchar(255) DEFAULT NULL,
  `team_email_subject` varchar(255) DEFAULT NULL,
  `client_message` varchar(511) DEFAULT NULL,
  `team_message` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_email_replies`
--

CREATE TABLE `fms_entry_email_replies` (
  `id` bigint NOT NULL,
  `fms_entry_data_id` bigint NOT NULL,
  `type` enum('entry','entry-step','entry-step-zero') DEFAULT NULL,
  `user_id` bigint NOT NULL,
  `mail_from` varchar(100) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `content` text NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `uploaded_file` varchar(255) NOT NULL,
  `voice_note` varchar(255) DEFAULT NULL,
  `voice_note_duration` int NOT NULL DEFAULT '0' COMMENT 'Duration in seconds',
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_items`
--

CREATE TABLE `fms_entry_items` (
  `id` bigint NOT NULL,
  `fms_entry_id` bigint NOT NULL,
  `is_valid` tinyint DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_item_checklist_submissions`
--

CREATE TABLE `fms_entry_item_checklist_submissions` (
  `id` bigint NOT NULL,
  `fms_entry_item_id` bigint NOT NULL,
  `checklist_id` bigint NOT NULL,
  `filled_value` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_item_submissions`
--

CREATE TABLE `fms_entry_item_submissions` (
  `id` bigint NOT NULL,
  `fms_entry_item_id` bigint NOT NULL,
  `fms_entry_checklist_submission_id` bigint NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_progress`
--

CREATE TABLE `fms_entry_progress` (
  `id` bigint NOT NULL,
  `fms_entry_id` bigint NOT NULL,
  `fms_step_id` bigint NOT NULL,
  `step_activation_date` timestamp NULL DEFAULT NULL,
  `planned_date` timestamp NULL DEFAULT NULL,
  `actual_date` timestamp NULL DEFAULT NULL,
  `is_active` tinyint DEFAULT NULL,
  `skipped` tinyint DEFAULT '0',
  `not_applicable` tinyint DEFAULT '0',
  `progress_percentage` decimal(10,0) DEFAULT NULL,
  `reminder_sent_count` tinyint NOT NULL DEFAULT '0',
  `last_reminder_sent_at` timestamp NULL DEFAULT NULL,
  `assignee` bigint DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1' COMMENT '1:not started, 2:WIP, 3:pause, 4:done, 5:reject	',
  `acceptance_date` timestamp NULL DEFAULT NULL,
  `hold_resume_date` timestamp NULL DEFAULT NULL,
  `done_date` timestamp NULL DEFAULT NULL,
  `total_worked_minute` varchar(50) DEFAULT NULL COMMENT 'total time taken in minute',
  `completion_date` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_progress_activation_date_logs`
--

CREATE TABLE `fms_entry_progress_activation_date_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `fms_entry_progress_id` bigint UNSIGNED NOT NULL,
  `step_activation_date` timestamp NULL DEFAULT NULL,
  `changed_by` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_progress_planned_date_logs`
--

CREATE TABLE `fms_entry_progress_planned_date_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `fms_entry_progress_id` bigint UNSIGNED NOT NULL,
  `planned_date` timestamp NULL DEFAULT NULL,
  `changed_by` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_step_checklists`
--

CREATE TABLE `fms_entry_step_checklists` (
  `id` bigint NOT NULL,
  `fms_entry_progress_id` bigint NOT NULL,
  `fms_step_checklist_id` bigint NOT NULL,
  `filled_value` varchar(255) DEFAULT NULL,
  `parent_id` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_entry_step_checklist_submissions`
--

CREATE TABLE `fms_entry_step_checklist_submissions` (
  `id` bigint NOT NULL,
  `fms_entry_step_checklist_id` bigint DEFAULT NULL,
  `filled_value` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_favourites`
--

CREATE TABLE `fms_favourites` (
  `id` bigint NOT NULL,
  `fms_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `status` tinyint DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_masters`
--

CREATE TABLE `fms_masters` (
  `id` bigint NOT NULL,
  `unique_target_name` varchar(50) DEFAULT NULL,
  `organization_id` bigint DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `sop_link` varchar(255) DEFAULT NULL,
  `process_coordinator_id` bigint DEFAULT NULL,
  `step_zero_name` varchar(45) DEFAULT NULL,
  `created_by` bigint NOT NULL,
  `status` tinyint DEFAULT '1',
  `max_efficiency` double DEFAULT '0',
  `is_conditional` tinyint DEFAULT '0' COMMENT 'Boolean 1,0 values',
  `performance_measurement_frequency` enum('daily','number_of_days','weekly','fortnightly','monthly') DEFAULT NULL,
  `performance_measurement_number_of_days` int DEFAULT NULL,
  `who_can_fill_checklist` tinyint DEFAULT NULL COMMENT '1 = Data Entry Operators Only, 2 = Data Entry Operators and Step Assigned Users',
  `tat_calculation_method` tinyint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_splits`
--

CREATE TABLE `fms_splits` (
  `id` bigint NOT NULL,
  `split_type` enum('direct','loop','stagger') DEFAULT NULL,
  `previous_fms_sequence_id` bigint DEFAULT NULL,
  `fms_id` bigint DEFAULT NULL,
  `fms_step_id` bigint DEFAULT NULL,
  `fms_step_checklist_id` bigint DEFAULT NULL,
  `show_along_entry_stepzero_checklist` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `split_checklist_step_zero` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `split_step_zero` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `step_zero_checklist` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `entry_title_checklist_id` bigint DEFAULT NULL,
  `checklist_id_for_entry_generation` bigint DEFAULT NULL,
  `action_type` enum('lt','gt','eq') DEFAULT NULL,
  `match_value` varchar(23) DEFAULT NULL,
  `show_along_entry_steps` varchar(255) DEFAULT NULL,
  `show_along_entry_step_checklists` varchar(255) DEFAULT NULL,
  `split_inherited_steps` varchar(255) DEFAULT NULL,
  `split_inherited_step_checklists` varchar(255) DEFAULT NULL,
  `split_entry_title_step` bigint DEFAULT NULL,
  `split_entry_title_step_checklist` bigint DEFAULT NULL,
  `stagger_receive_step_checklist` bigint DEFAULT NULL,
  `stagger_receive_step_checklist_match_value` bigint DEFAULT NULL,
  `created_by` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_stakeholder_departments`
--

CREATE TABLE `fms_stakeholder_departments` (
  `id` bigint NOT NULL,
  `fms_id` bigint DEFAULT NULL,
  `department_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_stakeholder_users`
--

CREATE TABLE `fms_stakeholder_users` (
  `id` bigint NOT NULL,
  `fms_id` bigint DEFAULT NULL,
  `user_id` bigint DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_steps`
--

CREATE TABLE `fms_steps` (
  `id` bigint NOT NULL,
  `fms_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `index` tinyint DEFAULT NULL,
  `checklist_type` tinyint NOT NULL DEFAULT '1' COMMENT '1=no checklist, 2= checklist, 3= condiitional/section based',
  `is_optional` tinyint DEFAULT '0',
  `conditional_doer_type` tinyint NOT NULL DEFAULT '1' COMMENT '1 = Single Doer, 2 = Multiple Doers',
  `assignment_type` tinyint NOT NULL DEFAULT '1' COMMENT '1 = Random, 2 = Manual, 3 = Sequence',
  `department` bigint DEFAULT NULL,
  `assignee` bigint DEFAULT NULL,
  `planned_date_basis_type` tinyint DEFAULT NULL COMMENT '1 for Planned-to-Planned, 2 for Actual-to-Actual => This step ''s planned date will be calculated based on previous step''s planned date or actual date',
  `plan_time_measure` enum('day','hour','minute') DEFAULT NULL,
  `plan_time` varchar(7) DEFAULT NULL,
  `tat_type` enum('step-zero','step') DEFAULT NULL,
  `tat_step_id` bigint DEFAULT NULL,
  `tat_checklist_id` bigint DEFAULT NULL,
  `dd_fms_id` bigint DEFAULT NULL,
  `dd_fms_entry_id` bigint DEFAULT NULL,
  `dd_fms_entry_checklist_id` varchar(45) DEFAULT NULL,
  `dd_fms_entry_checklist_submission_id` varchar(45) DEFAULT NULL,
  `dd_fms_step_id` bigint DEFAULT NULL,
  `dd_fms_step_checklist_id` bigint DEFAULT NULL,
  `dd_fms_step_checklist_match_type` enum('eq','lt','gt') DEFAULT NULL,
  `dd_fms_step_checklist_match_value` varchar(45) DEFAULT NULL,
  `dd_type` tinyint DEFAULT NULL,
  `to_assign_doer_from_dapartment` varchar(45) DEFAULT NULL,
  `to_assign_doer_for_step` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_step_assignees`
--

CREATE TABLE `fms_step_assignees` (
  `id` bigint UNSIGNED NOT NULL,
  `fms_step_id` bigint UNSIGNED NOT NULL,
  `assignee` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_step_checklists`
--

CREATE TABLE `fms_step_checklists` (
  `id` bigint NOT NULL,
  `fms_step_id` bigint DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `index` tinyint DEFAULT NULL,
  `type` bigint NOT NULL,
  `dynamic_data_source_type_id` bigint UNSIGNED DEFAULT NULL,
  `subtype_id` bigint DEFAULT NULL,
  `is_private` tinyint DEFAULT '0',
  `allow_list_of_values` tinyint DEFAULT '0',
  `is_required` tinyint NOT NULL DEFAULT '1' COMMENT '0:no, 1:yes',
  `show_along_entry` tinyint NOT NULL DEFAULT '0',
  `batch_entry_checklist` tinyint DEFAULT '0',
  `checklist_editable_for_item` tinyint NOT NULL DEFAULT '0',
  `is_title` tinyint DEFAULT '0',
  `fms_checklist_section_id` bigint DEFAULT NULL,
  `match_type` varchar(7) DEFAULT NULL,
  `skip_step_id` varchar(255) DEFAULT NULL,
  `section_match_type` varchar(45) DEFAULT NULL,
  `section_match_value` varchar(45) DEFAULT NULL,
  `next_section_id` bigint DEFAULT NULL,
  `step_act_match_type` varchar(45) DEFAULT NULL,
  `step_act_match_value` varchar(45) DEFAULT NULL,
  `step_act_id` varchar(255) DEFAULT NULL,
  `match_value` varchar(7) DEFAULT NULL,
  `fms_entry_item_match_type` varchar(7) DEFAULT NULL,
  `fms_entry_item_match_value` varchar(45) DEFAULT NULL,
  `make_fms_entry_item` tinyint DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_step_checklist_values`
--

CREATE TABLE `fms_step_checklist_values` (
  `id` bigint NOT NULL,
  `fms_step_checklist_id` bigint DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `section` tinyint DEFAULT NULL,
  `match_type` varchar(7) DEFAULT NULL,
  `skip_step_id` varchar(255) DEFAULT NULL,
  `section_match_type` varchar(45) DEFAULT NULL,
  `section_match_value` varchar(45) DEFAULT NULL,
  `next_section_id` bigint DEFAULT NULL,
  `step_act_match_type` varchar(45) DEFAULT NULL,
  `step_act_match_value` varchar(45) DEFAULT NULL,
  `step_act_id` varchar(255) DEFAULT NULL,
  `match_value` varchar(7) DEFAULT NULL,
  `fms_entry_item_match_type` varchar(7) DEFAULT NULL,
  `fms_entry_item_match_value` varchar(45) DEFAULT NULL,
  `make_fms_entry_item` tinyint DEFAULT '0',
  `capture_item_info_section` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_step_departments`
--

CREATE TABLE `fms_step_departments` (
  `id` bigint UNSIGNED NOT NULL,
  `fms_step_id` bigint UNSIGNED NOT NULL,
  `department_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_step_email_notification_templates`
--

CREATE TABLE `fms_step_email_notification_templates` (
  `id` bigint NOT NULL,
  `fms_step_id` bigint NOT NULL,
  `client_email_field` varchar(255) DEFAULT NULL,
  `team_email_address` varchar(255) DEFAULT NULL,
  `cc_email` varchar(255) DEFAULT NULL,
  `client_email_subject` varchar(255) DEFAULT NULL,
  `team_email_subject` varchar(255) DEFAULT NULL,
  `client_message` text,
  `team_message` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fms_user_entry_views`
--

CREATE TABLE `fms_user_entry_views` (
  `id` bigint NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `view_id` bigint DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `force_updates`
--

CREATE TABLE `force_updates` (
  `id` bigint UNSIGNED NOT NULL,
  `latest_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `min_required_version` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `update_type` enum('1','2') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '1:force, 2:optional',
  `android_store_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ios_store_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `form_fields`
--

CREATE TABLE `form_fields` (
  `id` int NOT NULL,
  `label` text NOT NULL,
  `type` text NOT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '0',
  `is_in_index` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `is_mandatory` tinyint(1) NOT NULL DEFAULT '0',
  `is_draggable` tinyint NOT NULL DEFAULT '1',
  `field_order` tinyint NOT NULL,
  `options` text,
  `original_label` text,
  `updated_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `form_fields1`
--

CREATE TABLE `form_fields1` (
  `id` int NOT NULL,
  `label` text NOT NULL,
  `type` text NOT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '0',
  `is_in_index` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '0',
  `is_mandatory` tinyint(1) NOT NULL DEFAULT '0',
  `is_draggable` tinyint(1) DEFAULT '1',
  `field_order` tinyint NOT NULL,
  `options` text,
  `original_label` text,
  `updated_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_progress_report_settings`
--

CREATE TABLE `global_progress_report_settings` (
  `id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reportslug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_option` enum('all','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department_option` enum('all','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `schedule_period` enum('daily','weekly','Immediate','weeklydigest') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `days` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `schedule_time` time NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_project_master`
--

CREATE TABLE `global_project_master` (
  `id` int NOT NULL,
  `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('1','0') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_settings`
--

CREATE TABLE `global_settings` (
  `id` bigint UNSIGNED NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `datatype` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1=>Active, 0=>Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `global_sitesettings`
--

CREATE TABLE `global_sitesettings` (
  `id` int UNSIGNED NOT NULL,
  `primary_color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `secondary_color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `button_primary_color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `button_secondary_color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `logo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `favicon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `font_family` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_format` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Y-m-d',
  `time_zone` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'UTC',
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USD',
  `send_global_mail` tinyint NOT NULL DEFAULT '1' COMMENT '1 = enabled, 0 = disabled',
  `show_jira_trello` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'Show jira and trello option while creating user.',
  `capture_recurring_uid_per_task_field` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'Capture recurring UID per task.',
  `enable_custom_fms_tat_calculation` tinyint NOT NULL DEFAULT '0',
  `enable_process_step_change_planned_due_date` tinyint NOT NULL DEFAULT '0',
  `enable_process_entry_bulk_done_from_file` tinyint NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `goals`
--

CREATE TABLE `goals` (
  `id` int NOT NULL,
  `organization_id` int NOT NULL,
  `created_by` int DEFAULT NULL,
  `owner_id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `desc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `period` varchar(255) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_marked_completed` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL COMMENT '''Public''=>0,''Private''=>1',
  `proof_per_task` tinyint NOT NULL DEFAULT '0' COMMENT '1: required, 0: not required',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `goals_co_owners`
--

CREATE TABLE `goals_co_owners` (
  `id` bigint NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `goal_id` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `goals_permissions`
--

CREATE TABLE `goals_permissions` (
  `id` bigint NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `department_id` bigint DEFAULT NULL,
  `designation_id` bigint DEFAULT NULL,
  `permitted_dept_id` bigint DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `goal_chat_task_feedback`
--

CREATE TABLE `goal_chat_task_feedback` (
  `id` int NOT NULL,
  `goal_task_id` int NOT NULL,
  `created_by` int NOT NULL,
  `content` text NOT NULL,
  `attachment` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `goal_tasks`
--

CREATE TABLE `goal_tasks` (
  `id` int NOT NULL,
  `goal_id` int NOT NULL,
  `task_name` varchar(255) NOT NULL,
  `task_description` text,
  `department_id` int NOT NULL,
  `assignee` int NOT NULL,
  `reviewer_id` int NOT NULL,
  `date` date NOT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `task_status` int NOT NULL COMMENT '''Accept'' => 1, Reject'' => 2, ''Pause/Resume'' => 3, ''Done'' => 4, ''Rework'' => 5',
  `acceptance_date` varchar(255) NOT NULL,
  `completion_date` varchar(255) NOT NULL,
  `hold_resume_date` varchar(255) NOT NULL,
  `total_worked_minute` varchar(255) NOT NULL,
  `reviewer_status` int NOT NULL COMMENT '1= Approve 2= Reject',
  `reviewer_status_date` timestamp NULL DEFAULT NULL,
  `reviewer_rejection_reason` varchar(255) DEFAULT NULL,
  `doer_submission_date` date DEFAULT NULL COMMENT 'actual doer submission date',
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `google_sheet_event_last_id`
--

CREATE TABLE `google_sheet_event_last_id` (
  `id` int NOT NULL,
  `last_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `helping_departments`
--

CREATE TABLE `helping_departments` (
  `id` int NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hitticket_email_histories`
--

CREATE TABLE `hitticket_email_histories` (
  `id` int NOT NULL,
  `ticket_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `to_mail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cc_mail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `mail_from` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hit_tickets`
--

CREATE TABLE `hit_tickets` (
  `id` int NOT NULL,
  `hitticket_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  `who_can_perform` tinyint NOT NULL DEFAULT '0' COMMENT '1=>Deo,2=>Deo/Assignee',
  `deo_id` int UNSIGNED NOT NULL DEFAULT '0',
  `pc_id` int NOT NULL DEFAULT '0',
  `hdepartment_id` int NOT NULL,
  `helping_person_id` int NOT NULL,
  `who_reassigned` bigint UNSIGNED DEFAULT NULL COMMENT 'user_id who reassigned their assigned ticket',
  `issue_type` int DEFAULT '0',
  `taskPriority` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pref_res_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `res_date_buffer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reviewer_id` int NOT NULL,
  `reporting_manager_id` int NOT NULL DEFAULT '0',
  `uploaded_file` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `hours` double NOT NULL DEFAULT '0',
  `acceptance_status` int DEFAULT NULL,
  `acceptance_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_inprogress` tinyint NOT NULL DEFAULT '0' COMMENT '0 - Not Inprogress, 1 - Inprogress',
  `inprogress_date` timestamp NULL DEFAULT NULL,
  `done_status` int DEFAULT NULL,
  `not_done_status` tinyint DEFAULT NULL,
  `not_done_date` timestamp NULL DEFAULT NULL,
  `completion_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hold_status` int DEFAULT NULL,
  `hold_resume_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_worked_minute` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rework` tinyint DEFAULT NULL,
  `rework_duration` int DEFAULT NULL COMMENT 'minute format',
  `rework_reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reject_status` tinyint NOT NULL,
  `reviewer_status` int DEFAULT NULL,
  `reviewer_status_date` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reviewer_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tl_id` int DEFAULT NULL,
  `other_issue_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mail_report_status` tinyint NOT NULL,
  `dept_mail_report_status` tinyint NOT NULL,
  `dont_know_ticket` bigint NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Is_import_excel` int NOT NULL,
  `is_visited` bigint NOT NULL DEFAULT '0',
  `archive` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=>Not Archived, 1=>Archived',
  `archive_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Reason for archiving the ticket',
  `is_escalated` tinyint(1) DEFAULT '0',
  `proof_per_task` tinyint NOT NULL DEFAULT '0',
  `help_audio` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `help_audio_duration` int DEFAULT NULL,
  `comment_mark_as_done` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hit_ticket_action_logs`
--

CREATE TABLE `hit_ticket_action_logs` (
  `id` bigint NOT NULL,
  `task_id` bigint NOT NULL,
  `task_status_id` bigint NOT NULL,
  `work_interval` tinyint NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hit_ticket_custom_fields`
--

CREATE TABLE `hit_ticket_custom_fields` (
  `id` int NOT NULL,
  `hit_ticket_id` int NOT NULL,
  `form_field_id` int NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hit_ticket_email_replies`
--

CREATE TABLE `hit_ticket_email_replies` (
  `id` int NOT NULL,
  `parent_id` int NOT NULL,
  `user_id` int NOT NULL,
  `to_mail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cc_mail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `mail_from` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_file` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `voice_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voice_duration` int NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hit_ticket_files`
--

CREATE TABLE `hit_ticket_files` (
  `id` bigint UNSIGNED NOT NULL,
  `hit_ticket_id` bigint UNSIGNED NOT NULL,
  `type` enum('image','video','doc') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hit_ticket_manager_assigns`
--

CREATE TABLE `hit_ticket_manager_assigns` (
  `id` int NOT NULL,
  `hitticket_id` bigint NOT NULL,
  `helping_person_id` int NOT NULL,
  `manager_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `holiday_calenders`
--

CREATE TABLE `holiday_calenders` (
  `id` int NOT NULL,
  `holiday_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `holiday_date` date NOT NULL,
  `day` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `holiday_type` int NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `holiday_types`
--

CREATE TABLE `holiday_types` (
  `id` int NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `hr_recruiter_reports`
--

CREATE TABLE `hr_recruiter_reports` (
  `id` bigint UNSIGNED NOT NULL,
  `recruiter_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `recruiter_id` int NOT NULL DEFAULT '0',
  `category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `report_date` date DEFAULT NULL,
  `day` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `daily_planned` int DEFAULT NULL,
  `daily_actual` int DEFAULT NULL,
  `deviation` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_synced_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ims`
--

CREATE TABLE `ims` (
  `id` bigint UNSIGNED NOT NULL,
  `ims_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1=Active, 0=Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ims_warehouses`
--

CREATE TABLE `ims_warehouses` (
  `id` bigint UNSIGNED NOT NULL,
  `ims_id` bigint UNSIGNED NOT NULL,
  `warehouse_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_transactions`
--

CREATE TABLE `inventory_transactions` (
  `id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `warehouse_id` bigint UNSIGNED NOT NULL,
  `quantity` decimal(10,4) NOT NULL,
  `transaction_type` enum('production_issue','production_receive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reference_id` bigint UNSIGNED DEFAULT NULL COMMENT 'ID of the source record (e.g., production_order_id)',
  `reference_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Model/table name of the source (e.g., ProductionOrder)',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `issue_departments`
--

CREATE TABLE `issue_departments` (
  `id` bigint UNSIGNED NOT NULL,
  `issue_type_id` bigint UNSIGNED NOT NULL,
  `department_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `issue_types`
--

CREATE TABLE `issue_types` (
  `id` bigint NOT NULL,
  `issue_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `created_by` bigint NOT NULL DEFAULT '1' COMMENT 'Created by user ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jira_employees`
--

CREATE TABLE `jira_employees` (
  `id` int NOT NULL,
  `emp_id` varchar(255) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jira_subtasks`
--

CREATE TABLE `jira_subtasks` (
  `id` int NOT NULL,
  `step1_responses_id` int NOT NULL,
  `jira_card_id` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `late_early_going_histories`
--

CREATE TABLE `late_early_going_histories` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `date` date NOT NULL,
  `late_coming_status` enum('1','2') DEFAULT NULL COMMENT '1:accepted, 2: not accepted',
  `late_coming_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `early_going_status` enum('1','2') DEFAULT NULL COMMENT '1:accepted, 2: not accepted',
  `early_going_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leave_attendance_histories`
--

CREATE TABLE `leave_attendance_histories` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `date` date NOT NULL,
  `leave_status` tinyint NOT NULL COMMENT ' "Leave full day" => 1, "Leave half day" => 2 ',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_fms_dynamic_columns`
--

CREATE TABLE `manage_fms_dynamic_columns` (
  `id` int NOT NULL,
  `value` varchar(225) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `check` bigint NOT NULL DEFAULT '1' COMMENT '1= show 0= hide',
  `status` bigint NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_helps`
--

CREATE TABLE `manage_helps` (
  `id` bigint NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `type` bigint NOT NULL DEFAULT '1' COMMENT '1= byIndividual 0= byDepartment',
  `slug` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_help_dynamic_columns`
--

CREATE TABLE `manage_help_dynamic_columns` (
  `id` bigint NOT NULL,
  `value` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `check` bigint NOT NULL DEFAULT '1' COMMENT '0=> hide, 1=> show',
  `status` bigint NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_help_tickets`
--

CREATE TABLE `manage_help_tickets` (
  `id` bigint NOT NULL,
  `department_id` int NOT NULL,
  `external_check` bigint NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_pms_dynamic_columns`
--

CREATE TABLE `manage_pms_dynamic_columns` (
  `id` int NOT NULL,
  `value` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `check` bigint NOT NULL DEFAULT '1' COMMENT '0=> hide, 1=> show',
  `status` bigint NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_recurring_dynamic_columns`
--

CREATE TABLE `manage_recurring_dynamic_columns` (
  `id` bigint NOT NULL,
  `value` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `check` bigint NOT NULL DEFAULT '1' COMMENT '0=> hide, 1=> show',
  `status` bigint NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_submissions`
--

CREATE TABLE `manage_submissions` (
  `id` bigint NOT NULL,
  `name` varchar(50) NOT NULL,
  `type` bigint NOT NULL DEFAULT '1' COMMENT '1=>Start,2=>Finish',
  `slug` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_unique_ids`
--

CREATE TABLE `manage_unique_ids` (
  `id` bigint NOT NULL,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `type` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manage_work_dynamic_columns`
--

CREATE TABLE `manage_work_dynamic_columns` (
  `id` bigint NOT NULL,
  `value` varchar(100) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `check` bigint NOT NULL DEFAULT '1' COMMENT '0=> hide, 1=> show',
  `status` bigint NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mandatory_work_days`
--

CREATE TABLE `mandatory_work_days` (
  `id` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `working_date` date NOT NULL,
  `day` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `meetings`
--

CREATE TABLE `meetings` (
  `id` int UNSIGNED NOT NULL,
  `meeting_agenda` varchar(225) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parent_id` int UNSIGNED NOT NULL DEFAULT '0',
  `project_id` int NOT NULL DEFAULT '0',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meeting_date` date DEFAULT NULL,
  `meeting_time` time DEFAULT NULL,
  `meeting_end_time` time DEFAULT NULL,
  `meeting_invite` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `organiser` bigint DEFAULT NULL,
  `external_meeting_invite` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meeting_description` enum('online','offline','onlineOffline') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meeting_link` varchar(225) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meeting_location` varchar(225) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meeting_request` tinyint NOT NULL DEFAULT '0',
  `attendees_updated` bigint NOT NULL DEFAULT '0' COMMENT '1=>Attendees updated',
  `meeting_status` tinyint NOT NULL DEFAULT '0' COMMENT '0:not yet started, 1:started, 2:ended',
  `meeting_started_time` datetime DEFAULT NULL COMMENT 'meeting started time',
  `meeting_ended_time` datetime DEFAULT NULL COMMENT 'meeting ended time',
  `total_meeting_duration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'seconds',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '0:no, 1:yes',
  `members_notified` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1' COMMENT '0:no, 1:yes',
  `delete_reason` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Delete reason',
  `delete_date` date DEFAULT NULL COMMENT 'Meeting deleted date',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `meeting_location`
--

CREATE TABLE `meeting_location` (
  `id` int NOT NULL,
  `location` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `meeting_records`
--

CREATE TABLE `meeting_records` (
  `id` int UNSIGNED NOT NULL,
  `meeting_id` int DEFAULT NULL,
  `user_id` varchar(100) DEFAULT NULL,
  `attendees` bigint NOT NULL DEFAULT '0' COMMENT '1=> Attended, 0=> Missed',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` bigint NOT NULL,
  `message_thread_id` bigint NOT NULL,
  `message_from_userid` bigint NOT NULL,
  `message_from_id` varchar(500) NOT NULL,
  `message_to_id` varchar(500) NOT NULL,
  `message_cc_id` varchar(500) NOT NULL,
  `message_datetime` datetime NOT NULL,
  `content` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `message_board_permissions`
--

CREATE TABLE `message_board_permissions` (
  `id` bigint NOT NULL,
  `name` varchar(50) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `public` bigint NOT NULL DEFAULT '0',
  `private` bigint NOT NULL DEFAULT '0',
  `goal_owner` bigint NOT NULL DEFAULT '0',
  `co_owner` bigint NOT NULL DEFAULT '0',
  `doer` bigint NOT NULL DEFAULT '0',
  `creator` bigint NOT NULL DEFAULT '0',
  `reviewer` bigint NOT NULL DEFAULT '0',
  `doer_fm` bigint NOT NULL DEFAULT '0',
  `doer_rm` bigint NOT NULL DEFAULT '0',
  `director` bigint NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `message_threads`
--

CREATE TABLE `message_threads` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `project_id` bigint NOT NULL,
  `category_id` int NOT NULL,
  `message_from` bigint NOT NULL,
  `message_to` varchar(255) NOT NULL,
  `message_cc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `subject` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mis_admin_settings`
--

CREATE TABLE `mis_admin_settings` (
  `id` bigint NOT NULL,
  `module_name` varchar(100) NOT NULL,
  `status` enum('0','1') NOT NULL DEFAULT '0' COMMENT '1:active, 0:in-active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mis_doer_benchmarks`
--

CREATE TABLE `mis_doer_benchmarks` (
  `id` int NOT NULL,
  `department_id` int NOT NULL,
  `task_type` enum('1','2','3','4') NOT NULL COMMENT '1:pms, 2:hit, 3:recurring, 4:fms',
  `all_work_done` text NOT NULL,
  `all_work_done_on_time` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mis_doer_commitments`
--

CREATE TABLE `mis_doer_commitments` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `task_type` enum('1','2','3','4') NOT NULL COMMENT '1:pms, 2:hit, 3:recurring, 4:fms',
  `week_range` varchar(100) NOT NULL,
  `commitment` int DEFAULT NULL COMMENT 'commitment for work not done',
  `commitment2` int DEFAULT NULL COMMENT 'commitment for work not done on time',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `modules`
--

CREATE TABLE `modules` (
  `id` int UNSIGNED NOT NULL,
  `sort_order` smallint DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `parent_id` int UNSIGNED DEFAULT NULL,
  `controller` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_class` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_display_menu` tinyint NOT NULL DEFAULT '0',
  `status` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT '1=>Active, 0=>Inactive',
  `is_visible_in_app` tinyint NOT NULL DEFAULT '0',
  `is_visible_in_admin` tinyint NOT NULL DEFAULT '1' COMMENT '0: No, 1: Yes',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` int DEFAULT NULL,
  `is_deleted` int NOT NULL DEFAULT '0',
  `icon_img` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `modules_per_plans`
--

CREATE TABLE `modules_per_plans` (
  `id` int NOT NULL,
  `subscription_id` int NOT NULL COMMENT 'id from pms_subscription table',
  `module_id` int NOT NULL COMMENT 'id from modules table',
  `parent_id` int NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notes`
--

CREATE TABLE `notes` (
  `id` int UNSIGNED NOT NULL,
  `add_notes` varchar(225) DEFAULT NULL,
  `meeting_id` int DEFAULT NULL,
  `responsible` varchar(100) DEFAULT NULL COMMENT 'user_id',
  `task_type` enum('1','2','3') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '1= Hit, 2= Goal, 3=Note',
  `priority` enum('High','Medium','Low','') DEFAULT NULL,
  `resolution_date` date DEFAULT NULL,
  `uploaded_file` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint UNSIGNED NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `body` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sender_id` bigint UNSIGNED DEFAULT NULL,
  `receiver_id` bigint UNSIGNED NOT NULL,
  `data` json DEFAULT NULL,
  `is_read_at` timestamp NULL DEFAULT NULL,
  `is_read` tinyint NOT NULL DEFAULT '0' COMMENT '0: unread, 1: read',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notification_toggles`
--

CREATE TABLE `notification_toggles` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `is_enabled` tinyint(1) NOT NULL DEFAULT '1' COMMENT '0 = false, 1 = true',
  `is_email_enabled` tinyint NOT NULL DEFAULT '1' COMMENT '0 = disabled, 1 = enabled',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oauth_access_tokens`
--

CREATE TABLE `oauth_access_tokens` (
  `id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `client_id` int UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scopes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oauth_auth_codes`
--

CREATE TABLE `oauth_auth_codes` (
  `id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint NOT NULL,
  `client_id` int UNSIGNED NOT NULL,
  `scopes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oauth_clients`
--

CREATE TABLE `oauth_clients` (
  `id` int UNSIGNED NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `secret` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `redirect` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `personal_access_client` tinyint(1) NOT NULL,
  `password_client` tinyint(1) NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oauth_personal_access_clients`
--

CREATE TABLE `oauth_personal_access_clients` (
  `id` int UNSIGNED NOT NULL,
  `client_id` int UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oauth_refresh_tokens`
--

CREATE TABLE `oauth_refresh_tokens` (
  `id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_token_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `organizations`
--

CREATE TABLE `organizations` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `status` int NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `organization_module_permissions`
--

CREATE TABLE `organization_module_permissions` (
  `id` int NOT NULL,
  `pms_organization_id` int NOT NULL,
  `module_id` int NOT NULL,
  `parent_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` int UNSIGNED NOT NULL,
  `role_id` int UNSIGNED DEFAULT NULL COMMENT 'role_id is admin_role_id from admin_role table',
  `role_access_id` int DEFAULT NULL COMMENT 'id from role_access table',
  `department_id` bigint UNSIGNED NOT NULL,
  `designation_id` bigint UNSIGNED NOT NULL,
  `module_id` int UNSIGNED NOT NULL,
  `module_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dashboard_permission` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `show` enum('yes','no') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create` enum('yes','no') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `update` enum('yes','no') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delete` enum('yes','no') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint UNSIGNED DEFAULT NULL COMMENT '1=>Active, 0=>Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint UNSIGNED DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pms_communication_and_supports`
--

CREATE TABLE `pms_communication_and_supports` (
  `id` int NOT NULL,
  `organization_id` int NOT NULL,
  `problem_title` varchar(150) NOT NULL,
  `problem_description` text NOT NULL,
  `problem_image` varchar(255) DEFAULT NULL,
  `status` enum('1','2') NOT NULL DEFAULT '1' COMMENT '1:pending, 2:resolved',
  `view_status` enum('1','2') NOT NULL DEFAULT '1' COMMENT '1:Not Viewed, 2:Viewed	',
  `superadmin_remark` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pms_organizations`
--

CREATE TABLE `pms_organizations` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `subdomain` varchar(45) DEFAULT NULL,
  `domain` varchar(255) NOT NULL,
  `admin_email` varchar(100) NOT NULL,
  `admin_password` varchar(255) NOT NULL,
  `status` enum('0','1') NOT NULL DEFAULT '1' COMMENT '0:inactive, 1:active',
  `address` text COMMENT 'organization address',
  `type` enum('1','2') NOT NULL DEFAULT '1' COMMENT '1:Monthy, 2: Yearly',
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `org_unique_code` varchar(50) DEFAULT NULL COMMENT 'unique code for organization',
  `maximum_users` int DEFAULT NULL COMMENT '0:infinite, else maximum capacity, null:No permission',
  `maximum_fms` int DEFAULT NULL COMMENT '0:infinite, else maximum capacity, null:No permission',
  `maximum_goals` int DEFAULT NULL COMMENT '0:infinite, else maximum capacity, null:No permission',
  `mobile_app` enum('0','1') NOT NULL DEFAULT '0' COMMENT '0:don''t want to use mobile app, 1:yes want to use mobile app',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pms_subscriptions`
--

CREATE TABLE `pms_subscriptions` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `price` bigint NOT NULL COMMENT 'Rupee',
  `description` text NOT NULL,
  `logo` varchar(100) DEFAULT NULL COMMENT 'plan logo',
  `status` enum('0','1') NOT NULL DEFAULT '1' COMMENT '0:inactive, 1: active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `process_connectors`
--

CREATE TABLE `process_connectors` (
  `id` bigint UNSIGNED NOT NULL,
  `process_id` bigint UNSIGNED NOT NULL,
  `ims_id` bigint UNSIGNED NOT NULL,
  `process_step` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_for_product_sku` bigint UNSIGNED DEFAULT NULL,
  `movement_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `process_field_product_sku` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_for_warehouse` bigint UNSIGNED DEFAULT NULL,
  `process_field_warehouse` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_for_product_quantity` bigint UNSIGNED DEFAULT NULL,
  `process_field_product_quantity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_for_vendor` bigint UNSIGNED DEFAULT NULL,
  `process_field_vendor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `step_for_transaction_id` bigint UNSIGNED DEFAULT NULL,
  `process_field_transaction_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `production_orders`
--

CREATE TABLE `production_orders` (
  `id` bigint UNSIGNED NOT NULL,
  `bom_id` bigint UNSIGNED NOT NULL,
  `bom_final_product_id` bigint UNSIGNED DEFAULT NULL,
  `parent_product_id` bigint UNSIGNED NOT NULL,
  `production_quantity` decimal(10,4) NOT NULL,
  `warehouse_id` bigint UNSIGNED NOT NULL,
  `stage_progress` json DEFAULT NULL COMMENT 'JSON tracking progress for each stage',
  `status` enum('draft','in_progress','completed','cancelled','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `planned_start_date` timestamp NULL DEFAULT NULL,
  `planned_end_date` timestamp NULL DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `production_order_components`
--

CREATE TABLE `production_order_components` (
  `id` bigint UNSIGNED NOT NULL,
  `production_order_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `bom_final_product_stage_id` bigint UNSIGNED DEFAULT NULL COMMENT 'Links component to specific stage for multi-stage production',
  `warehouse_id` bigint UNSIGNED DEFAULT NULL COMMENT 'Warehouse where component is sourced from',
  `required_quantity` decimal(10,4) DEFAULT '0.0000',
  `consumed_quantity` decimal(10,4) DEFAULT '0.0000',
  `expected_wastage_quantity` decimal(10,4) DEFAULT '0.0000',
  `actual_wastage_quantity` decimal(10,4) DEFAULT '0.0000',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `production_order_outputs`
--

CREATE TABLE `production_order_outputs` (
  `id` bigint UNSIGNED NOT NULL,
  `production_order_id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `produced_quantity` decimal(8,2) NOT NULL,
  `warehouse_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `production_order_status_logs`
--

CREATE TABLE `production_order_status_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `production_order_id` bigint UNSIGNED NOT NULL,
  `status` enum('draft','in_progress','completed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint UNSIGNED NOT NULL,
  `ims_id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sku` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `lowest_price` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `highest_price` decimal(15,4) NOT NULL DEFAULT '0.0000',
  `primary_unit_id` bigint UNSIGNED NOT NULL,
  `alternate_unit_1_id` bigint UNSIGNED DEFAULT NULL,
  `alternate_unit_2_id` bigint UNSIGNED DEFAULT NULL,
  `unit_ratio_1` decimal(10,4) DEFAULT NULL,
  `unit_ratio_2` decimal(10,4) DEFAULT NULL,
  `min_order_quantity` int NOT NULL DEFAULT '0',
  `opening_stock_quantity` int NOT NULL DEFAULT '0',
  `safety_level` int NOT NULL DEFAULT '0',
  `lead_time` int NOT NULL DEFAULT '0',
  `seasonal` tinyint NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `exclude_notification` tinyint NOT NULL DEFAULT '0',
  `created_by` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_import_logs`
--

CREATE TABLE `product_import_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'csv',
  `ims_id` bigint UNSIGNED NOT NULL,
  `total_products` int NOT NULL DEFAULT '0',
  `uploaded_products` int NOT NULL DEFAULT '0',
  `rejected_products` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1=Processing,2=Completed,3=Failed',
  `uploaded_by` bigint UNSIGNED DEFAULT NULL,
  `error_details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product_warehouse_stocks`
--

CREATE TABLE `product_warehouse_stocks` (
  `id` bigint UNSIGNED NOT NULL,
  `product_id` bigint UNSIGNED NOT NULL,
  `warehouse_id` bigint UNSIGNED NOT NULL,
  `stock_quantity` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` bigint NOT NULL,
  `project_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'jira-> key of project, trello-> board id',
  `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  `project_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estimate_efforts` bigint DEFAULT NULL,
  `additional_hour` int NOT NULL DEFAULT '0',
  `dept_hours` json DEFAULT NULL,
  `hourly_rate` bigint DEFAULT NULL,
  `company_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warranty` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `client_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `project_manager` bigint DEFAULT NULL,
  `business_developer` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `emailid_add_for_teams` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pre_sale_team` bigint DEFAULT NULL,
  `project_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `project_development_type` smallint NOT NULL DEFAULT '1' COMMENT '	1: development, 2: maintaince',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '1:deleted, 0:not deleted',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `project_management`
--

CREATE TABLE `project_management` (
  `id` bigint NOT NULL,
  `project_name` varchar(255) NOT NULL,
  `project_value` varchar(255) NOT NULL,
  `estimate_efforts` bigint NOT NULL,
  `hourly_rate` bigint NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `warranty` varchar(255) NOT NULL,
  `client_name` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `project_manager` bigint NOT NULL,
  `business_developer` varchar(50) NOT NULL,
  `emailid_add_for_teams` varchar(255) NOT NULL,
  `pre_sale_team` bigint NOT NULL,
  `project_type` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `project_types`
--

CREATE TABLE `project_types` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` tinyint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `proof_of_docs`
--

CREATE TABLE `proof_of_docs` (
  `id` bigint UNSIGNED NOT NULL,
  `mt_id` varchar(255) DEFAULT NULL COMMENT 'master task id',
  `slug` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `module_type` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '1:Help ticket, 2:Recurring',
  `is_required` enum('1','2') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '1:required, 2:not required',
  `type` tinyint NOT NULL DEFAULT '0' COMMENT '1 = All, 2 = Per task',
  `who_can_create` enum('1','2','3') DEFAULT NULL COMMENT '1:Admin, 2:User, 3:Both',
  `can_submit_not_done_tasks` tinyint NOT NULL DEFAULT '0' COMMENT '1=Yes,0=No',
  `comment_mark_as_done` tinyint NOT NULL DEFAULT '0' COMMENT '1=>Yes, 0=>No',
  `fix_pc` bigint DEFAULT NULL COMMENT 'if this is set then this pc user will be assigned by default',
  `review_required` tinyint NOT NULL DEFAULT '0' COMMENT '0:no, 1:yes',
  `need_master_task_id` tinyint NOT NULL DEFAULT '0' COMMENT '0:no, 1:yes',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_files`
--

CREATE TABLE `recurring_files` (
  `id` int UNSIGNED NOT NULL,
  `filename` varchar(225) DEFAULT NULL,
  `user_id` int NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_labels`
--

CREATE TABLE `recurring_labels` (
  `id` int NOT NULL,
  `recurring_master_id` int DEFAULT NULL,
  `label` varchar(225) DEFAULT NULL,
  `value` varchar(225) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_master_tasks`
--

CREATE TABLE `recurring_master_tasks` (
  `id` int NOT NULL,
  `mt_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'master task id',
  `raiser_id` int NOT NULL,
  `raiser_department_id` int NOT NULL,
  `helper_id` int DEFAULT NULL,
  `helper_department_id` int DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `reviewer_id` int DEFAULT '0',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hours` double NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `task_priority` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_frequency_id` int NOT NULL,
  `archieve` bigint NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `category_master_id` int UNSIGNED NOT NULL,
  `pc_id` bigint DEFAULT NULL,
  `deo_id` bigint DEFAULT NULL,
  `who_can_perform_task` tinyint DEFAULT NULL COMMENT '1 = deo only , 2 = deo and task assignee both',
  `daily_excluded_days` json DEFAULT NULL,
  `proof_per_task` tinyint NOT NULL DEFAULT '0',
  `on_saturday` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'create on staurday for daily task',
  `on_sunday` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'create on sunday for daily task',
  `before_time` tinyint NOT NULL DEFAULT '0' COMMENT '1=>Cannot submit before time,O => can submit anytime',
  `category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_master_tasks_22Jan25`
--

CREATE TABLE `recurring_master_tasks_22Jan25` (
  `id` int NOT NULL,
  `raiser_id` int NOT NULL,
  `raiser_department_id` int NOT NULL,
  `helper_id` int DEFAULT NULL,
  `helper_department_id` int DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `reviewer_id` int DEFAULT '0',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hours` double NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `task_priority` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_frequency_id` int NOT NULL,
  `acceptance_status` int DEFAULT NULL,
  `acceptance_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `done_status` int DEFAULT NULL,
  `completion_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hold_status` int DEFAULT NULL,
  `hold_resume_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_worked_minute` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reject_status` tinyint NOT NULL,
  `review_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `archieve` bigint NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `category_master_id` int UNSIGNED NOT NULL,
  `category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_master_task_email_replies`
--

CREATE TABLE `recurring_master_task_email_replies` (
  `id` int NOT NULL,
  `parent_id` int NOT NULL,
  `user_id` int NOT NULL,
  `mail_from` varchar(100) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `content` text NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `uploaded_file` varchar(255) NOT NULL,
  `voice_note` varchar(255) DEFAULT NULL,
  `voice_note_duration` int NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_tasks`
--

CREATE TABLE `recurring_tasks` (
  `id` int NOT NULL,
  `recurring_task_id` int DEFAULT NULL,
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sequence_number` int UNSIGNED DEFAULT NULL,
  `raiser_id` int NOT NULL,
  `raiser_department_id` int NOT NULL,
  `helper_id` int NOT NULL,
  `helper_department_id` int NOT NULL,
  `project_id` int NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hours` double NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `assigned_on` date DEFAULT NULL,
  `days` varchar(225) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_priority` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_frequency_id` int NOT NULL,
  `acceptance_status` int DEFAULT NULL,
  `acceptance_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `done_status` int DEFAULT NULL,
  `completion_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hold_status` int DEFAULT NULL,
  `hold_resume_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_worked_minute` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reject_status` tinyint NOT NULL,
  `review_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `category_master_id` int UNSIGNED NOT NULL,
  `reviewer_id` int NOT NULL DEFAULT '0',
  `reviewer_status` int NOT NULL COMMENT 'Approved=>1, Rejected=>2',
  `reviewer_status_date` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rework` tinyint NOT NULL,
  `rework_duration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_tasks_22Jan25`
--

CREATE TABLE `recurring_tasks_22Jan25` (
  `id` int NOT NULL,
  `recurring_task_id` int DEFAULT NULL,
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `raiser_id` int NOT NULL,
  `raiser_department_id` int NOT NULL,
  `helper_id` int NOT NULL,
  `helper_department_id` int NOT NULL,
  `project_id` int NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hours` double NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `assigned_on` date DEFAULT NULL,
  `days` varchar(225) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_priority` enum('High','Medium','Low') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_frequency_id` int NOT NULL,
  `acceptance_status` int DEFAULT NULL,
  `acceptance_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `done_status` int DEFAULT NULL,
  `completion_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hold_status` int DEFAULT NULL,
  `hold_resume_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_worked_minute` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reject_status` tinyint NOT NULL,
  `review_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `category_master_id` int UNSIGNED NOT NULL,
  `reviewer_id` int NOT NULL DEFAULT '0',
  `reviewer_status` int NOT NULL COMMENT 'Approved=>1, Rejected=>2',
  `reviewer_status_date` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rework` tinyint NOT NULL,
  `rework_duration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_task_action_logs`
--

CREATE TABLE `recurring_task_action_logs` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `task_status_id` tinyint NOT NULL,
  `work_interval` tinyint NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_task_assignees`
--

CREATE TABLE `recurring_task_assignees` (
  `id` bigint UNSIGNED NOT NULL,
  `recurring_master_task_id` int NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `end_date` date DEFAULT NULL COMMENT 'recurring task end date',
  `create_upcoming_date` date DEFAULT NULL COMMENT 'next upcomming task date that should be created using cron',
  `recurring_task_uid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Unique identifier for the recurring task',
  `master_sequence_number` bigint DEFAULT NULL COMMENT 'while cloning',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `archive` tinyint(1) DEFAULT NULL,
  `reviewer_id` int DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `unassigned_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_task_email_replies`
--

CREATE TABLE `recurring_task_email_replies` (
  `id` int NOT NULL,
  `parent_id` int NOT NULL,
  `user_id` int NOT NULL,
  `to_mail` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cc_mail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `mail_from` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_file` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `voice_note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voice_note_duration` int NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `recurring_task_trackings`
--

CREATE TABLE `recurring_task_trackings` (
  `id` bigint UNSIGNED NOT NULL,
  `recurring_task_id` int NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `completed_by` bigint UNSIGNED DEFAULT NULL,
  `not_done_at` timestamp NULL DEFAULT NULL,
  `not_done_by` bigint UNSIGNED DEFAULT NULL,
  `comment_mark_as_done` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `uploaded_file` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `reviewer_status` tinyint DEFAULT NULL COMMENT '1: approved, 2: rejected',
  `reviewer_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `rework_count` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Only "unique" value accepted',
  `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_super_admin` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT '1=>Yes, 0=>No',
  `status` tinyint UNSIGNED NOT NULL DEFAULT '1' COMMENT '1=>Active, 0=>Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `role_accesses`
--

CREATE TABLE `role_accesses` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `status` enum('0','1') NOT NULL DEFAULT '1' COMMENT '1:active, 0:in-active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `saved_filters`
--

CREATE TABLE `saved_filters` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `module` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tab_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `filter_data` json NOT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shift_timings`
--

CREATE TABLE `shift_timings` (
  `id` bigint NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `break_duration` int DEFAULT '0' COMMENT 'Break duration in minutes',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `smtp_settings`
--

CREATE TABLE `smtp_settings` (
  `id` bigint UNSIGNED NOT NULL,
  `driver` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `host` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `port` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `encryption` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sprints`
--

CREATE TABLE `sprints` (
  `id` bigint NOT NULL,
  `project_id` int NOT NULL DEFAULT '0' COMMENT 'id from projects table',
  `jira_origin_board_id` int NOT NULL,
  `jira_sprint_id` int NOT NULL,
  `goal` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `sprint_name` varchar(100) NOT NULL,
  `state` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `static_pages`
--

CREATE TABLE `static_pages` (
  `id` int UNSIGNED NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `url` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` tinyint UNSIGNED NOT NULL DEFAULT '0' COMMENT '1=>Active, 0=>Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `step1_responses`
--

CREATE TABLE `step1_responses` (
  `id` bigint UNSIGNED NOT NULL,
  `parent_id` bigint DEFAULT NULL,
  `jira_epic_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sprint_id` int DEFAULT NULL COMMENT '	id from sprints table',
  `story_id` int DEFAULT NULL COMMENT 'id from stories table',
  `task_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `project_id` bigint DEFAULT NULL,
  `task_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_source` enum('jira','trello','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unique_gen_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `trello_card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jira_card_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trello_emp_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jira_account_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_allotment_user_id` int DEFAULT NULL,
  `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `milestone` enum('billable','non-billable','warranty') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hours` double NOT NULL,
  `acceptance_status` int DEFAULT NULL,
  `acceptance_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `done_status` int DEFAULT NULL,
  `completion_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hold_status` int DEFAULT NULL,
  `hold_resume_date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_worked_minute` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rework` tinyint(1) DEFAULT NULL,
  `rework_duration` int DEFAULT NULL,
  `reject_status` tinyint NOT NULL,
  `assignee` bigint DEFAULT NULL,
  `creator` bigint DEFAULT NULL,
  `review_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `taskpriority` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `critical_level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` int NOT NULL,
  `reviewer_id` int NOT NULL,
  `Iscritical` enum('yes','no') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'no',
  `Ishelper` enum('yes','no') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'no',
  `helper_department_id` int NOT NULL,
  `helper_employee_id` int NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `user_rejection_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `reviewer_status` int NOT NULL COMMENT '0:Not reviewed, 1:approved, 2:rejected, 3: sent for testing',
  `reviewer_status_date` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `testing_required` tinyint NOT NULL DEFAULT '0' COMMENT '0:no, 1:yes ',
  `meeting_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `step1_responses1`
--

CREATE TABLE `step1_responses1` (
  `id` bigint UNSIGNED NOT NULL,
  `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `project_task_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'trello_task',
  `hubspot` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `othertaskname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bugherd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jira` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tasktype` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `assign_to` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `assignby` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `hours` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `milestone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `document` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assignto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sheet_id` int DEFAULT NULL,
  `acceptance_url` int DEFAULT NULL,
  `acceptance_date` date DEFAULT NULL,
  `done_url` int DEFAULT NULL,
  `completion_date` date DEFAULT NULL,
  `hold_url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `resume_url` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `delay_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unique_gen_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updateonsheet` int NOT NULL DEFAULT '0',
  `task_category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rework` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stories`
--

CREATE TABLE `stories` (
  `id` int NOT NULL,
  `jira_epic_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Jira key from epics table',
  `jira_story_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `project_id` int NOT NULL,
  `summary` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by` int NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `submitted_proof_docs`
--

CREATE TABLE `submitted_proof_docs` (
  `id` bigint UNSIGNED NOT NULL,
  `module_type` tinyint NOT NULL COMMENT '1:Help, 2:recurring',
  `task_id` bigint NOT NULL,
  `uploaded_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_action_logs`
--

CREATE TABLE `task_action_logs` (
  `id` bigint NOT NULL,
  `task_id` bigint DEFAULT NULL,
  `task_status_id` bigint DEFAULT NULL,
  `work_interval` tinyint DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_frequency_masters`
--

CREATE TABLE `task_frequency_masters` (
  `id` int NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_labels`
--

CREATE TABLE `task_labels` (
  `id` bigint NOT NULL,
  `task_id` bigint DEFAULT NULL,
  `label` varchar(64) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_logs`
--

CREATE TABLE `task_logs` (
  `id` int NOT NULL,
  `sheet_id` bigint NOT NULL,
  `task_id` varchar(50) DEFAULT NULL,
  `user_id` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `status` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `task_message_read_receipts`
--

CREATE TABLE `task_message_read_receipts` (
  `id` bigint UNSIGNED NOT NULL,
  `message_id` bigint UNSIGNED NOT NULL,
  `created_for` bigint UNSIGNED NOT NULL,
  `is_read` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_planning_logs`
--

CREATE TABLE `task_planning_logs` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `manager_id` int NOT NULL,
  `department_id` int NOT NULL,
  `date` date NOT NULL,
  `userid` int NOT NULL,
  `planning_days` int NOT NULL,
  `missing_days` int NOT NULL,
  `global_days` int NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_rejection_reasons`
--

CREATE TABLE `task_rejection_reasons` (
  `id` bigint UNSIGNED NOT NULL,
  `module_id` tinyint NOT NULL COMMENT '1:PMS, 2:Help, 3:Recurring, 4:Goal, 5:Company Goal',
  `module_slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `task_id` int NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_rejection_reason_logs`
--

CREATE TABLE `task_rejection_reason_logs` (
  `id` int NOT NULL,
  `done_by_user_id` int NOT NULL,
  `reviewer_id` int NOT NULL,
  `task_id` int NOT NULL,
  `rejection_reason` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_statuses`
--

CREATE TABLE `task_statuses` (
  `id` bigint NOT NULL,
  `name` varchar(32) DEFAULT NULL,
  `action_required` tinyint(1) DEFAULT NULL,
  `color` varchar(32) DEFAULT NULL,
  `color_code` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_status_actions`
--

CREATE TABLE `task_status_actions` (
  `id` bigint NOT NULL,
  `status_id` bigint DEFAULT NULL,
  `name` varchar(32) DEFAULT NULL,
  `conversion_status_id` bigint DEFAULT NULL,
  `color` varchar(24) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_type_masters`
--

CREATE TABLE `task_type_masters` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` bigint NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `testing_cycle_modules`
--

CREATE TABLE `testing_cycle_modules` (
  `id` bigint UNSIGNED NOT NULL,
  `project_id` bigint UNSIGNED NOT NULL,
  `module_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `test_webhook`
--

CREATE TABLE `test_webhook` (
  `id` int NOT NULL,
  `data` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ticket_status_masters`
--

CREATE TABLE `ticket_status_masters` (
  `id` int NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('1','0') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trello_employees`
--

CREATE TABLE `trello_employees` (
  `id` int NOT NULL,
  `emp_id` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `units`
--

CREATE TABLE `units` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `abbreviation` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1: Active, 0: Inactive',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `role_id` int UNSIGNED DEFAULT NULL,
  `role_access_id` int DEFAULT NULL COMMENT 'id from role_access table',
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `designation_id` int DEFAULT NULL,
  `designation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qa_role_id` int DEFAULT NULL COMMENT 'QA Testing Role For User Task',
  `country_id` smallint UNSIGNED DEFAULT NULL,
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'mobile phone',
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `middle_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trello_emp_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jira_account_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pm_id` bigint DEFAULT NULL,
  `tl_id` bigint DEFAULT NULL,
  `status` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_password_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` timestamp NULL DEFAULT NULL,
  `verification_otp` smallint DEFAULT NULL,
  `verification_otp_sent_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `logged_at` timestamp NOT NULL,
  `logged_out` timestamp NOT NULL,
  `employee_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `work_status` enum('wfo','wfh') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'wfo',
  `Is_external` enum('internal','external') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'internal',
  `is_pc` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'Is process co-ordinator, 1:yes, 0:no',
  `is_deo` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT 'Is deo, 1:yes, 0:no',
  `is_ea` enum('0','1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT '0:no, 1:yes',
  `shift` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role_type` tinyint DEFAULT NULL COMMENT '1 => ''MD'', 2 => ''RM'', 3 => ''Executive''',
  `max_limits` json DEFAULT NULL COMMENT 'Maximum number allowed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_28-05-2024`
--

CREATE TABLE `users_28-05-2024` (
  `id` bigint UNSIGNED NOT NULL,
  `role_id` int UNSIGNED DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `designation_id` int DEFAULT NULL,
  `designation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qa_role_id` int DEFAULT NULL COMMENT 'QA Testing Role For User Task',
  `country_id` smallint UNSIGNED DEFAULT NULL,
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `middle_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trello_emp_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jira_account_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pm_id` bigint DEFAULT NULL,
  `tl_id` bigint DEFAULT NULL,
  `status` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_password_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` timestamp NULL DEFAULT NULL,
  `verification_otp` smallint DEFAULT NULL,
  `verification_otp_sent_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `logged_at` timestamp NOT NULL,
  `employee_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `work_status` enum('wfo','wfh') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'wfo'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users_old`
--

CREATE TABLE `users_old` (
  `id` bigint UNSIGNED NOT NULL,
  `role_id` int UNSIGNED DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `designation_id` int DEFAULT NULL,
  `designation` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qa_role_id` int DEFAULT NULL COMMENT 'QA Testing Role For User Task',
  `country_id` smallint UNSIGNED DEFAULT NULL,
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `middle_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trello_emp_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `jira_account_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pm_id` bigint DEFAULT NULL,
  `tl_id` bigint DEFAULT NULL,
  `status` tinyint UNSIGNED NOT NULL DEFAULT '0',
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_password_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` timestamp NULL DEFAULT NULL,
  `verification_otp` smallint DEFAULT NULL,
  `verification_otp_sent_at` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `logged_at` timestamp NOT NULL,
  `employee_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `work_status` enum('wfo','wfh') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_activity_logs`
--

CREATE TABLE `user_activity_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `device` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_avatars`
--

CREATE TABLE `user_avatars` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `avatar` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `width` smallint UNSIGNED DEFAULT NULL,
  `height` smallint UNSIGNED DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_extrawork`
--

CREATE TABLE `user_extrawork` (
  `id` int NOT NULL,
  `userId` int NOT NULL,
  `employeeCode` int NOT NULL,
  `extraWork` varchar(20) NOT NULL,
  `ewDate` date NOT NULL,
  `status` int NOT NULL,
  `approvedBy` int NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_hit_chat_details`
--

CREATE TABLE `user_hit_chat_details` (
  `id` bigint UNSIGNED NOT NULL,
  `ticket_id` bigint UNSIGNED NOT NULL COMMENT 'id from hit_tickets',
  `user_id` bigint UNSIGNED NOT NULL,
  `last_seen_reply_id` bigint UNSIGNED DEFAULT NULL COMMENT 'id from hit_ticket_email_replies',
  `last_seen_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_logs`
--

CREATE TABLE `user_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `sign_in_at` timestamp NULL DEFAULT NULL,
  `sign_in_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plateform` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_managers`
--

CREATE TABLE `user_managers` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `manager_id` bigint NOT NULL,
  `manager_type` enum('functional','reporting','qa_tl') DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions`
--

CREATE TABLE `user_permissions` (
  `id` bigint UNSIGNED NOT NULL,
  `role_id` int UNSIGNED DEFAULT NULL COMMENT 'role_id is admin_role_id from admin_role table',
  `user_id` bigint UNSIGNED NOT NULL,
  `module_id` int UNSIGNED NOT NULL,
  `module_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dashboard_permission` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `show` enum('yes','now') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  `create` enum('yes','now') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  `update` enum('yes','now') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  `delete` enum('yes','now') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  `status` tinyint UNSIGNED DEFAULT NULL COMMENT '1=>Active, 0=>Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_permissions_old`
--

CREATE TABLE `user_permissions_old` (
  `id` bigint UNSIGNED NOT NULL,
  `role_id` int UNSIGNED DEFAULT NULL COMMENT 'role_id is admin_role_id from admin_role table',
  `user_id` bigint UNSIGNED NOT NULL,
  `module_id` int UNSIGNED NOT NULL,
  `module_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dashboard_permission` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `show` enum('yes','now') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  `create` enum('yes','now') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  `update` enum('yes','now') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  `delete` enum('yes','now') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  `status` tinyint UNSIGNED DEFAULT NULL COMMENT '1=>Active, 0=>Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_recurring_chat_details`
--

CREATE TABLE `user_recurring_chat_details` (
  `id` bigint UNSIGNED NOT NULL,
  `recurring_task_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `last_seen_reply_id` bigint UNSIGNED DEFAULT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_recurring_master_chat_details`
--

CREATE TABLE `user_recurring_master_chat_details` (
  `id` bigint UNSIGNED NOT NULL,
  `recurring_master_task_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `last_seen_reply_id` bigint UNSIGNED DEFAULT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vendors`
--

CREATE TABLE `vendors` (
  `id` bigint UNSIGNED NOT NULL,
  `vendor_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `credit_point` int NOT NULL DEFAULT '0',
  `preferred_rating` tinyint NOT NULL DEFAULT '0' COMMENT '1 to 5',
  `lead_time` int NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1=Active, 0=Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `warehouses`
--

CREATE TABLE `warehouses` (
  `id` bigint UNSIGNED NOT NULL,
  `warehouse_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1=Active, 0=Inactive',
  `created_by` bigint UNSIGNED DEFAULT NULL,
  `updated_by` bigint UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `weekend_settings`
--

CREATE TABLE `weekend_settings` (
  `id` bigint NOT NULL,
  `day_of_week` tinyint NOT NULL COMMENT '1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday, 7=Sunday',
  `is_off_day` tinyint(1) DEFAULT '1',
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `whatsapp_settings`
--

CREATE TABLE `whatsapp_settings` (
  `id` bigint UNSIGNED NOT NULL,
  `access_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `from_phone_number_id` varchar(31) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `locale_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'en_US' COMMENT 'Locale code for WhatsApp messages',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1=Active, 0=Inactive',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `worksnap_attendance_histories`
--

CREATE TABLE `worksnap_attendance_histories` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `in_time` time NOT NULL,
  `out_time` time NOT NULL,
  `time_duration` time NOT NULL,
  `atten_date` date NOT NULL,
  `created_at` timestamp NOT NULL,
  `updated_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `work_snap_activity_histories`
--

CREATE TABLE `work_snap_activity_histories` (
  `id` int NOT NULL,
  `work_snap_historie_id` int NOT NULL,
  `user_id` int NOT NULL,
  `time` time NOT NULL,
  `date` varchar(255) NOT NULL,
  `keyboard` int NOT NULL,
  `mouse` int NOT NULL,
  `application` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `work_snap_histories`
--

CREATE TABLE `work_snap_histories` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `task_type` tinyint NOT NULL COMMENT '''No task'' => 0, ''Task Analysis'' => 1,''Help Ticket'' => 2, ''Goal'' => 3, ''Recurring'' => 4, ''FMS'' => 5',
  `task_id` int DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `active_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `image` varchar(255) NOT NULL,
  `time_range` varchar(255) NOT NULL,
  `status` tinyint NOT NULL COMMENT 'Notblocked =false, Blocked =true',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `additional_works`
--
ALTER TABLE `additional_works`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `additional_work_email_replies`
--
ALTER TABLE `additional_work_email_replies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `assign_tester_tasks`
--
ALTER TABLE `assign_tester_tasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `attendance_email_replies`
--
ALTER TABLE `attendance_email_replies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `attendance_email_replies_1`
--
ALTER TABLE `attendance_email_replies_1`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `biometric_histories`
--
ALTER TABLE `biometric_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee_code_atten_date` (`employee_code`,`atten_date`),
  ADD KEY `idx_user_id_atten_date` (`user_id`,`atten_date`);

--
-- Indexes for table `biometric_histories_1`
--
ALTER TABLE `biometric_histories_1`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee_code_atten_date` (`employee_code`,`atten_date`),
  ADD KEY `idx_user_id_atten_date` (`user_id`,`atten_date`);

--
-- Indexes for table `boards`
--
ALTER TABLE `boards`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `board_webhooks`
--
ALTER TABLE `board_webhooks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `boms`
--
ALTER TABLE `boms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bom_parent` (`parent_product_id`),
  ADD KEY `idx_bom_status` (`status`);

--
-- Indexes for table `bom_components`
--
ALTER TABLE `bom_components`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bom_components_bom_final_product_stage_id_index` (`bom_final_product_stage_id`);

--
-- Indexes for table `bom_final_products`
--
ALTER TABLE `bom_final_products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bom_parent` (`parent_product_id`),
  ADD KEY `idx_bom_status` (`status`),
  ADD KEY `bom_final_products_production_type_index` (`production_type`);

--
-- Indexes for table `bom_final_product_stages`
--
ALTER TABLE `bom_final_product_stages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bom_final_product_stages_bom_final_product_id_stage_order_index` (`bom_final_product_id`,`stage_order`);

--
-- Indexes for table `bom_import_logs`
--
ALTER TABLE `bom_import_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bom_stages`
--
ALTER TABLE `bom_stages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `category_departments`
--
ALTER TABLE `category_departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `category_masters`
--
ALTER TABLE `category_masters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `chat_task_feedback`
--
ALTER TABLE `chat_task_feedback`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `chat_with_organizations`
--
ALTER TABLE `chat_with_organizations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `checklist_type_masters`
--
ALTER TABLE `checklist_type_masters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `company_goals`
--
ALTER TABLE `company_goals`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `company_goal_chat_task_feedback`
--
ALTER TABLE `company_goal_chat_task_feedback`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `company_goal_co_owners`
--
ALTER TABLE `company_goal_co_owners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `company_goal_tasks`
--
ALTER TABLE `company_goal_tasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cron_department_wise_details`
--
ALTER TABLE `cron_department_wise_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `currencies_code_unique` (`code`);

--
-- Indexes for table `dashboard_permissions`
--
ALTER TABLE `dashboard_permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delegations`
--
ALTER TABLE `delegations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delegation_boards`
--
ALTER TABLE `delegation_boards`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delegation_revision_histories`
--
ALTER TABLE `delegation_revision_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delegation_tasks`
--
ALTER TABLE `delegation_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tasks_board_id_foreign` (`delegation_board_id`),
  ADD KEY `tasks_employee_id_foreign` (`employee_id`);

--
-- Indexes for table `deligation_email_replies`
--
ALTER TABLE `deligation_email_replies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `deligation_tasks`
--
ALTER TABLE `deligation_tasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `deo_status`
--
ALTER TABLE `deo_status`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `department_managers`
--
ALTER TABLE `department_managers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `department_managers_user_id_foreign` (`user_id`);

--
-- Indexes for table `designations`
--
ALTER TABLE `designations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `designations_department_id_foreign` (`department_id`);

--
-- Indexes for table `email_templates`
--
ALTER TABLE `email_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email_templates_email_types_id_unique` (`email_type_id`),
  ADD KEY `subject` (`subject`);

--
-- Indexes for table `email_templates_backup28thMar25`
--
ALTER TABLE `email_templates_backup28thMar25`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email_templates_email_types_id_unique` (`email_type_id`),
  ADD KEY `subject` (`subject`);

--
-- Indexes for table `email_types`
--
ALTER TABLE `email_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `email_types_backup28thMar25`
--
ALTER TABLE `email_types_backup28thMar25`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `epics`
--
ALTER TABLE `epics`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `error_logs`
--
ALTER TABLE `error_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_histories`
--
ALTER TABLE `event_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ew_mappings`
--
ALTER TABLE `ew_mappings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `fcm_tokens`
--
ALTER TABLE `fcm_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `fms_checklist_permissions`
--
ALTER TABLE `fms_checklist_permissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `checklist_id` (`fms_checklist_id`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `fms_checklist_sections`
--
ALTER TABLE `fms_checklist_sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_deos`
--
ALTER TABLE `fms_deos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_dynamic_data_sources`
--
ALTER TABLE `fms_dynamic_data_sources`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_dynamic_data_source_values`
--
ALTER TABLE `fms_dynamic_data_source_values`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entries`
--
ALTER TABLE `fms_entries`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_checklists`
--
ALTER TABLE `fms_entry_checklists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_checklist_submissions`
--
ALTER TABLE `fms_entry_checklist_submissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_checklist_submission_values`
--
ALTER TABLE `fms_entry_checklist_submission_values`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_checklist_values`
--
ALTER TABLE `fms_entry_checklist_values`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_email_notification_templates`
--
ALTER TABLE `fms_entry_email_notification_templates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_email_replies`
--
ALTER TABLE `fms_entry_email_replies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_items`
--
ALTER TABLE `fms_entry_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_item_checklist_submissions`
--
ALTER TABLE `fms_entry_item_checklist_submissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_item_submissions`
--
ALTER TABLE `fms_entry_item_submissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_progress`
--
ALTER TABLE `fms_entry_progress`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_progress_activation_date_logs`
--
ALTER TABLE `fms_entry_progress_activation_date_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_entry_progress_id` (`fms_entry_progress_id`),
  ADD KEY `idx_changed_by` (`changed_by`);

--
-- Indexes for table `fms_entry_progress_planned_date_logs`
--
ALTER TABLE `fms_entry_progress_planned_date_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_entry_progress_id` (`fms_entry_progress_id`),
  ADD KEY `idx_changed_by` (`changed_by`);

--
-- Indexes for table `fms_entry_step_checklists`
--
ALTER TABLE `fms_entry_step_checklists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_entry_step_checklist_submissions`
--
ALTER TABLE `fms_entry_step_checklist_submissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_favourites`
--
ALTER TABLE `fms_favourites`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_masters`
--
ALTER TABLE `fms_masters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_splits`
--
ALTER TABLE `fms_splits`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_stakeholder_departments`
--
ALTER TABLE `fms_stakeholder_departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_stakeholder_users`
--
ALTER TABLE `fms_stakeholder_users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_steps`
--
ALTER TABLE `fms_steps`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_step_assignees`
--
ALTER TABLE `fms_step_assignees`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fms_step_assignees_fms_step_id_index` (`fms_step_id`),
  ADD KEY `fms_step_assignees_assignee_index` (`assignee`),
  ADD KEY `fms_step_assignees_fms_step_id_assignee_index` (`fms_step_id`,`assignee`);

--
-- Indexes for table `fms_step_checklists`
--
ALTER TABLE `fms_step_checklists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_step_checklist_values`
--
ALTER TABLE `fms_step_checklist_values`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_step_departments`
--
ALTER TABLE `fms_step_departments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fms_step_departments_fms_step_id_index` (`fms_step_id`),
  ADD KEY `fms_step_departments_department_id_index` (`department_id`),
  ADD KEY `fms_step_departments_fms_step_id_department_id_index` (`fms_step_id`,`department_id`);

--
-- Indexes for table `fms_step_email_notification_templates`
--
ALTER TABLE `fms_step_email_notification_templates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `fms_user_entry_views`
--
ALTER TABLE `fms_user_entry_views`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `force_updates`
--
ALTER TABLE `force_updates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `form_fields`
--
ALTER TABLE `form_fields`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `form_fields1`
--
ALTER TABLE `form_fields1`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `global_progress_report_settings`
--
ALTER TABLE `global_progress_report_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `global_project_master`
--
ALTER TABLE `global_project_master`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `global_settings`
--
ALTER TABLE `global_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `global_sitesettings`
--
ALTER TABLE `global_sitesettings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `goals`
--
ALTER TABLE `goals`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `goals_co_owners`
--
ALTER TABLE `goals_co_owners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `goals_permissions`
--
ALTER TABLE `goals_permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `goal_tasks`
--
ALTER TABLE `goal_tasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `google_sheet_event_last_id`
--
ALTER TABLE `google_sheet_event_last_id`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `helping_departments`
--
ALTER TABLE `helping_departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hitticket_email_histories`
--
ALTER TABLE `hitticket_email_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hit_tickets`
--
ALTER TABLE `hit_tickets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hitticket_id` (`hitticket_id`);

--
-- Indexes for table `hit_ticket_action_logs`
--
ALTER TABLE `hit_ticket_action_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hit_ticket_custom_fields`
--
ALTER TABLE `hit_ticket_custom_fields`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_htcf_hit_ticket` (`hit_ticket_id`),
  ADD KEY `fk_htcf_form_field` (`form_field_id`);

--
-- Indexes for table `hit_ticket_email_replies`
--
ALTER TABLE `hit_ticket_email_replies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hit_ticket_files`
--
ALTER TABLE `hit_ticket_files`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hit_ticket_manager_assigns`
--
ALTER TABLE `hit_ticket_manager_assigns`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `holiday_calenders`
--
ALTER TABLE `holiday_calenders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `holiday_types`
--
ALTER TABLE `holiday_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hr_recruiter_reports`
--
ALTER TABLE `hr_recruiter_reports`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ims`
--
ALTER TABLE `ims`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ims_ims_name_unique` (`ims_name`);

--
-- Indexes for table `ims_warehouses`
--
ALTER TABLE `ims_warehouses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ims_warehouse_unique` (`ims_id`,`warehouse_id`),
  ADD KEY `ims_warehouses_ims_id_index` (`ims_id`),
  ADD KEY `ims_warehouses_warehouse_id_index` (`warehouse_id`);

--
-- Indexes for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `issue_departments`
--
ALTER TABLE `issue_departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `issue_types`
--
ALTER TABLE `issue_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jira_employees`
--
ALTER TABLE `jira_employees`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jira_subtasks`
--
ALTER TABLE `jira_subtasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `late_early_going_histories`
--
ALTER TABLE `late_early_going_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `leave_attendance_histories`
--
ALTER TABLE `leave_attendance_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `manage_fms_dynamic_columns`
--
ALTER TABLE `manage_fms_dynamic_columns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `manage_helps`
--
ALTER TABLE `manage_helps`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `manage_help_dynamic_columns`
--
ALTER TABLE `manage_help_dynamic_columns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `manage_help_tickets`
--
ALTER TABLE `manage_help_tickets`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `manage_pms_dynamic_columns`
--
ALTER TABLE `manage_pms_dynamic_columns`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `manage_recurring_dynamic_columns`
--
ALTER TABLE `manage_recurring_dynamic_columns`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `manage_submissions`
--
ALTER TABLE `manage_submissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `manage_unique_ids`
--
ALTER TABLE `manage_unique_ids`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `manage_work_dynamic_columns`
--
ALTER TABLE `manage_work_dynamic_columns`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mandatory_work_days`
--
ALTER TABLE `mandatory_work_days`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `meetings`
--
ALTER TABLE `meetings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `meeting_location`
--
ALTER TABLE `meeting_location`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `meeting_records`
--
ALTER TABLE `meeting_records`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `message_board_permissions`
--
ALTER TABLE `message_board_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `message_threads`
--
ALTER TABLE `message_threads`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mis_admin_settings`
--
ALTER TABLE `mis_admin_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mis_doer_benchmarks`
--
ALTER TABLE `mis_doer_benchmarks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mis_doer_commitments`
--
ALTER TABLE `mis_doer_commitments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `modules`
--
ALTER TABLE `modules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`slug`),
  ADD KEY `fk_parent_id` (`parent_id`);

--
-- Indexes for table `modules_per_plans`
--
ALTER TABLE `modules_per_plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `subscription_id` (`subscription_id`);

--
-- Indexes for table `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notification_toggles`
--
ALTER TABLE `notification_toggles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `oauth_access_tokens`
--
ALTER TABLE `oauth_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_access_tokens_user_id_index` (`user_id`);

--
-- Indexes for table `oauth_auth_codes`
--
ALTER TABLE `oauth_auth_codes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `oauth_clients`
--
ALTER TABLE `oauth_clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_clients_user_id_index` (`user_id`);

--
-- Indexes for table `oauth_personal_access_clients`
--
ALTER TABLE `oauth_personal_access_clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_personal_access_clients_client_id_index` (`client_id`);

--
-- Indexes for table `oauth_refresh_tokens`
--
ALTER TABLE `oauth_refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_refresh_tokens_access_token_id_index` (`access_token_id`);

--
-- Indexes for table `organizations`
--
ALTER TABLE `organizations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `organization_module_permissions`
--
ALTER TABLE `organization_module_permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `email` (`email`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `permissions_role_id_foreign` (`role_id`),
  ADD KEY `permissions_module_id_foreign` (`module_id`),
  ADD KEY `fk_permissions_department` (`department_id`),
  ADD KEY `fk_permissions_designation` (`designation_id`);

--
-- Indexes for table `pms_communication_and_supports`
--
ALTER TABLE `pms_communication_and_supports`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pms_organizations`
--
ALTER TABLE `pms_organizations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `domain` (`domain`),
  ADD UNIQUE KEY `admin_email` (`admin_email`);

--
-- Indexes for table `pms_subscriptions`
--
ALTER TABLE `pms_subscriptions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `process_connectors`
--
ALTER TABLE `process_connectors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `production_orders`
--
ALTER TABLE `production_orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `production_order_components`
--
ALTER TABLE `production_order_components`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `production_order_outputs`
--
ALTER TABLE `production_order_outputs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `production_order_status_logs`
--
ALTER TABLE `production_order_status_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_import_logs`
--
ALTER TABLE `product_import_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_warehouse_stocks`
--
ALTER TABLE `product_warehouse_stocks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_product_warehouse_product` (`product_id`),
  ADD KEY `idx_product_warehouse_warehouse` (`warehouse_id`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `project_key_UNIQUE` (`project_key`);

--
-- Indexes for table `project_management`
--
ALTER TABLE `project_management`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `project_types`
--
ALTER TABLE `project_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `proof_of_docs`
--
ALTER TABLE `proof_of_docs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recurring_files`
--
ALTER TABLE `recurring_files`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recurring_labels`
--
ALTER TABLE `recurring_labels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recurring_master_tasks`
--
ALTER TABLE `recurring_master_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `raiser_id` (`raiser_id`,`raiser_department_id`,`helper_id`,`helper_department_id`,`project_id`,`start_date`,`end_date`),
  ADD KEY `idx_raiser_dates` (`raiser_id`,`start_date`,`end_date`),
  ADD KEY `idx_department_priority` (`raiser_department_id`,`task_priority`),
  ADD KEY `idx_active_tasks` (`archieve`,`start_date`,`end_date`),
  ADD KEY `idx_user_status` (`raiser_id`);

--
-- Indexes for table `recurring_master_tasks_22Jan25`
--
ALTER TABLE `recurring_master_tasks_22Jan25`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recurring_master_task_email_replies`
--
ALTER TABLE `recurring_master_task_email_replies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recurring_tasks`
--
ALTER TABLE `recurring_tasks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `task_id` (`task_id`),
  ADD KEY `idx_raiser_user` (`raiser_id`,`start_date`,`end_date`),
  ADD KEY `idx_helper_user` (`helper_id`,`start_date`,`end_date`),
  ADD KEY `idx_reviewer_tasks` (`reviewer_id`,`reviewer_status`,`start_date`),
  ADD KEY `idx_raiser_department` (`raiser_department_id`,`task_priority`,`start_date`),
  ADD KEY `idx_helper_department` (`helper_department_id`,`acceptance_status`,`start_date`),
  ADD KEY `idx_acceptance_status` (`acceptance_status`,`start_date`,`raiser_id`),
  ADD KEY `idx_completion_status` (`done_status`,`completion_date`,`helper_id`),
  ADD KEY `idx_review_status` (`reviewer_status`,`reviewer_id`,`start_date`),
  ADD KEY `idx_hold_status` (`hold_status`,`hold_resume_date`,`helper_id`),
  ADD KEY `idx_date_range` (`start_date`,`end_date`,`task_priority`),
  ADD KEY `idx_assigned_date` (`assigned_on`,`helper_id`,`acceptance_status`),
  ADD KEY `idx_project_tasks` (`project_id`,`start_date`,`done_status`),
  ADD KEY `idx_project_priority` (`project_id`,`task_priority`,`helper_id`),
  ADD KEY `idx_category_tasks` (`category_master_id`,`start_date`,`acceptance_status`),
  ADD KEY `idx_recurring_pattern` (`recurring_task_id`,`task_frequency_id`,`start_date`),
  ADD KEY `idx_hours_calculation` (`helper_id`,`done_status`,`hours`),
  ADD KEY `idx_priority_workload` (`task_priority`,`start_date`,`helper_id`),
  ADD KEY `idx_overdue_tasks` (`end_date`,`done_status`,`helper_id`),
  ADD KEY `idx_urgent_pending` (`task_priority`,`acceptance_status`,`start_date`),
  ADD KEY `idx_rework_tracking` (`rework`,`helper_id`,`start_date`),
  ADD KEY `idx_rework_duration` (`rework_duration`,`reviewer_id`,`done_status`),
  ADD KEY `idx_user_status_date` (`helper_id`,`acceptance_status`,`done_status`,`start_date`,`end_date`),
  ADD KEY `idx_project_management` (`project_id`,`helper_id`,`done_status`,`start_date`),
  ADD KEY `idx_review_workflow` (`reviewer_id`,`reviewer_status`,`task_priority`,`start_date`),
  ADD KEY `idx_workload_analysis` (`helper_department_id`,`helper_id`,`start_date`,`end_date`),
  ADD KEY `description_index` (`description`(255)),
  ADD KEY `idx_raiser_assigned` (`raiser_id`,`assigned_on`);

--
-- Indexes for table `recurring_tasks_22Jan25`
--
ALTER TABLE `recurring_tasks_22Jan25`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `task_id` (`task_id`);

--
-- Indexes for table `recurring_task_action_logs`
--
ALTER TABLE `recurring_task_action_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recurring_task_assignees`
--
ALTER TABLE `recurring_task_assignees`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recurring_task_email_replies`
--
ALTER TABLE `recurring_task_email_replies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recurring_task_trackings`
--
ALTER TABLE `recurring_task_trackings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `role_accesses`
--
ALTER TABLE `role_accesses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `saved_filters`
--
ALTER TABLE `saved_filters`
  ADD PRIMARY KEY (`id`),
  ADD KEY `saved_filters_user_id_index` (`user_id`),
  ADD KEY `saved_filters_module_index` (`module`),
  ADD KEY `saved_filters_tab_index` (`tab_name`),
  ADD KEY `saved_filters_default_index` (`user_id`,`tab_name`,`is_default`);

--
-- Indexes for table `shift_timings`
--
ALTER TABLE `shift_timings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `smtp_settings`
--
ALTER TABLE `smtp_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sprints`
--
ALTER TABLE `sprints`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `static_pages`
--
ALTER TABLE `static_pages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `meta_title` (`meta_title`);

--
-- Indexes for table `step1_responses`
--
ALTER TABLE `step1_responses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `step1_responses1`
--
ALTER TABLE `step1_responses1`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stories`
--
ALTER TABLE `stories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `submitted_proof_docs`
--
ALTER TABLE `submitted_proof_docs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_action_logs`
--
ALTER TABLE `task_action_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_frequency_masters`
--
ALTER TABLE `task_frequency_masters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_labels`
--
ALTER TABLE `task_labels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_logs`
--
ALTER TABLE `task_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sheet_id` (`sheet_id`);

--
-- Indexes for table `task_message_read_receipts`
--
ALTER TABLE `task_message_read_receipts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_planning_logs`
--
ALTER TABLE `task_planning_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_rejection_reasons`
--
ALTER TABLE `task_rejection_reasons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_rejection_reason_logs`
--
ALTER TABLE `task_rejection_reason_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_statuses`
--
ALTER TABLE `task_statuses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_status_actions`
--
ALTER TABLE `task_status_actions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `testing_cycle_modules`
--
ALTER TABLE `testing_cycle_modules`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `test_webhook`
--
ALTER TABLE `test_webhook`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ticket_status_masters`
--
ALTER TABLE `ticket_status_masters`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `trello_employees`
--
ALTER TABLE `trello_employees`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `units`
--
ALTER TABLE `units`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users_28-05-2024`
--
ALTER TABLE `users_28-05-2024`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_role_id_foreign` (`role_id`);

--
-- Indexes for table `users_old`
--
ALTER TABLE `users_old`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_role_id_foreign` (`role_id`);

--
-- Indexes for table `user_activity_logs`
--
ALTER TABLE `user_activity_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_avatars`
--
ALTER TABLE `user_avatars`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `user_extrawork`
--
ALTER TABLE `user_extrawork`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_hit_chat_details`
--
ALTER TABLE `user_hit_chat_details`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_ticket_user` (`ticket_id`,`user_id`);

--
-- Indexes for table `user_logs`
--
ALTER TABLE `user_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `user_managers`
--
ALTER TABLE `user_managers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_permissions_user_id_foreign` (`user_id`),
  ADD KEY `user_permissions_role_id_foreign` (`role_id`),
  ADD KEY `user_permissions_module_id_foreign` (`module_id`);

--
-- Indexes for table `user_permissions_old`
--
ALTER TABLE `user_permissions_old`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_permissions_user_id_foreign` (`user_id`),
  ADD KEY `user_permissions_role_id_foreign` (`role_id`),
  ADD KEY `user_permissions_module_id_foreign` (`module_id`);

--
-- Indexes for table `user_recurring_chat_details`
--
ALTER TABLE `user_recurring_chat_details`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_recurring_user` (`recurring_task_id`,`user_id`);

--
-- Indexes for table `user_recurring_master_chat_details`
--
ALTER TABLE `user_recurring_master_chat_details`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_recurring_user` (`recurring_master_task_id`,`user_id`);

--
-- Indexes for table `vendors`
--
ALTER TABLE `vendors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `warehouses`
--
ALTER TABLE `warehouses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `weekend_settings`
--
ALTER TABLE `weekend_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `whatsapp_settings`
--
ALTER TABLE `whatsapp_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `worksnap_attendance_histories`
--
ALTER TABLE `worksnap_attendance_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `work_snap_activity_histories`
--
ALTER TABLE `work_snap_activity_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `work_snap_histories`
--
ALTER TABLE `work_snap_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id_created_at` (`user_id`,`created_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `additional_works`
--
ALTER TABLE `additional_works`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `additional_work_email_replies`
--
ALTER TABLE `additional_work_email_replies`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `assign_tester_tasks`
--
ALTER TABLE `assign_tester_tasks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `attendance_email_replies`
--
ALTER TABLE `attendance_email_replies`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `biometric_histories`
--
ALTER TABLE `biometric_histories`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `boards`
--
ALTER TABLE `boards`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `board_webhooks`
--
ALTER TABLE `board_webhooks`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `boms`
--
ALTER TABLE `boms`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bom_components`
--
ALTER TABLE `bom_components`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bom_final_products`
--
ALTER TABLE `bom_final_products`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bom_final_product_stages`
--
ALTER TABLE `bom_final_product_stages`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bom_import_logs`
--
ALTER TABLE `bom_import_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bom_stages`
--
ALTER TABLE `bom_stages`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `category_departments`
--
ALTER TABLE `category_departments`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `category_masters`
--
ALTER TABLE `category_masters`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chat_task_feedback`
--
ALTER TABLE `chat_task_feedback`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chat_with_organizations`
--
ALTER TABLE `chat_with_organizations`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `checklist_type_masters`
--
ALTER TABLE `checklist_type_masters`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_goals`
--
ALTER TABLE `company_goals`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_goal_chat_task_feedback`
--
ALTER TABLE `company_goal_chat_task_feedback`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_goal_co_owners`
--
ALTER TABLE `company_goal_co_owners`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company_goal_tasks`
--
ALTER TABLE `company_goal_tasks`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cron_department_wise_details`
--
ALTER TABLE `cron_department_wise_details`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `currencies`
--
ALTER TABLE `currencies`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dashboard_permissions`
--
ALTER TABLE `dashboard_permissions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delegations`
--
ALTER TABLE `delegations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delegation_boards`
--
ALTER TABLE `delegation_boards`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delegation_revision_histories`
--
ALTER TABLE `delegation_revision_histories`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `delegation_tasks`
--
ALTER TABLE `delegation_tasks`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deligation_email_replies`
--
ALTER TABLE `deligation_email_replies`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deligation_tasks`
--
ALTER TABLE `deligation_tasks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deo_status`
--
ALTER TABLE `deo_status`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `department_managers`
--
ALTER TABLE `department_managers`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `designations`
--
ALTER TABLE `designations`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_templates`
--
ALTER TABLE `email_templates`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_templates_backup28thMar25`
--
ALTER TABLE `email_templates_backup28thMar25`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_types`
--
ALTER TABLE `email_types`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_types_backup28thMar25`
--
ALTER TABLE `email_types_backup28thMar25`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `epics`
--
ALTER TABLE `epics`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `error_logs`
--
ALTER TABLE `error_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `event_histories`
--
ALTER TABLE `event_histories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ew_mappings`
--
ALTER TABLE `ew_mappings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fcm_tokens`
--
ALTER TABLE `fcm_tokens`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_checklist_permissions`
--
ALTER TABLE `fms_checklist_permissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_checklist_sections`
--
ALTER TABLE `fms_checklist_sections`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_deos`
--
ALTER TABLE `fms_deos`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_dynamic_data_sources`
--
ALTER TABLE `fms_dynamic_data_sources`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_dynamic_data_source_values`
--
ALTER TABLE `fms_dynamic_data_source_values`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entries`
--
ALTER TABLE `fms_entries`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_checklists`
--
ALTER TABLE `fms_entry_checklists`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_checklist_submissions`
--
ALTER TABLE `fms_entry_checklist_submissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_checklist_submission_values`
--
ALTER TABLE `fms_entry_checklist_submission_values`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_checklist_values`
--
ALTER TABLE `fms_entry_checklist_values`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_email_notification_templates`
--
ALTER TABLE `fms_entry_email_notification_templates`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_email_replies`
--
ALTER TABLE `fms_entry_email_replies`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_items`
--
ALTER TABLE `fms_entry_items`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_item_checklist_submissions`
--
ALTER TABLE `fms_entry_item_checklist_submissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_item_submissions`
--
ALTER TABLE `fms_entry_item_submissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_progress`
--
ALTER TABLE `fms_entry_progress`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_progress_activation_date_logs`
--
ALTER TABLE `fms_entry_progress_activation_date_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_progress_planned_date_logs`
--
ALTER TABLE `fms_entry_progress_planned_date_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_step_checklists`
--
ALTER TABLE `fms_entry_step_checklists`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_entry_step_checklist_submissions`
--
ALTER TABLE `fms_entry_step_checklist_submissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_favourites`
--
ALTER TABLE `fms_favourites`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_masters`
--
ALTER TABLE `fms_masters`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_splits`
--
ALTER TABLE `fms_splits`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_stakeholder_departments`
--
ALTER TABLE `fms_stakeholder_departments`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_stakeholder_users`
--
ALTER TABLE `fms_stakeholder_users`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_steps`
--
ALTER TABLE `fms_steps`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_step_assignees`
--
ALTER TABLE `fms_step_assignees`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_step_checklists`
--
ALTER TABLE `fms_step_checklists`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_step_checklist_values`
--
ALTER TABLE `fms_step_checklist_values`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_step_departments`
--
ALTER TABLE `fms_step_departments`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_step_email_notification_templates`
--
ALTER TABLE `fms_step_email_notification_templates`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fms_user_entry_views`
--
ALTER TABLE `fms_user_entry_views`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `force_updates`
--
ALTER TABLE `force_updates`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `form_fields`
--
ALTER TABLE `form_fields`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `form_fields1`
--
ALTER TABLE `form_fields1`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `global_progress_report_settings`
--
ALTER TABLE `global_progress_report_settings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `global_project_master`
--
ALTER TABLE `global_project_master`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `global_settings`
--
ALTER TABLE `global_settings`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `goals`
--
ALTER TABLE `goals`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `goals_co_owners`
--
ALTER TABLE `goals_co_owners`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `goals_permissions`
--
ALTER TABLE `goals_permissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `goal_tasks`
--
ALTER TABLE `goal_tasks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `google_sheet_event_last_id`
--
ALTER TABLE `google_sheet_event_last_id`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `helping_departments`
--
ALTER TABLE `helping_departments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hitticket_email_histories`
--
ALTER TABLE `hitticket_email_histories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hit_tickets`
--
ALTER TABLE `hit_tickets`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hit_ticket_action_logs`
--
ALTER TABLE `hit_ticket_action_logs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hit_ticket_custom_fields`
--
ALTER TABLE `hit_ticket_custom_fields`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hit_ticket_email_replies`
--
ALTER TABLE `hit_ticket_email_replies`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hit_ticket_files`
--
ALTER TABLE `hit_ticket_files`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hit_ticket_manager_assigns`
--
ALTER TABLE `hit_ticket_manager_assigns`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `holiday_calenders`
--
ALTER TABLE `holiday_calenders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `holiday_types`
--
ALTER TABLE `holiday_types`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hr_recruiter_reports`
--
ALTER TABLE `hr_recruiter_reports`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ims`
--
ALTER TABLE `ims`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ims_warehouses`
--
ALTER TABLE `ims_warehouses`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `issue_departments`
--
ALTER TABLE `issue_departments`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `issue_types`
--
ALTER TABLE `issue_types`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jira_employees`
--
ALTER TABLE `jira_employees`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jira_subtasks`
--
ALTER TABLE `jira_subtasks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `late_early_going_histories`
--
ALTER TABLE `late_early_going_histories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_attendance_histories`
--
ALTER TABLE `leave_attendance_histories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_fms_dynamic_columns`
--
ALTER TABLE `manage_fms_dynamic_columns`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_helps`
--
ALTER TABLE `manage_helps`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_help_dynamic_columns`
--
ALTER TABLE `manage_help_dynamic_columns`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_help_tickets`
--
ALTER TABLE `manage_help_tickets`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_pms_dynamic_columns`
--
ALTER TABLE `manage_pms_dynamic_columns`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_recurring_dynamic_columns`
--
ALTER TABLE `manage_recurring_dynamic_columns`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_submissions`
--
ALTER TABLE `manage_submissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_unique_ids`
--
ALTER TABLE `manage_unique_ids`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `manage_work_dynamic_columns`
--
ALTER TABLE `manage_work_dynamic_columns`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mandatory_work_days`
--
ALTER TABLE `mandatory_work_days`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `meetings`
--
ALTER TABLE `meetings`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `meeting_location`
--
ALTER TABLE `meeting_location`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `meeting_records`
--
ALTER TABLE `meeting_records`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `message_board_permissions`
--
ALTER TABLE `message_board_permissions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `message_threads`
--
ALTER TABLE `message_threads`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mis_admin_settings`
--
ALTER TABLE `mis_admin_settings`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mis_doer_benchmarks`
--
ALTER TABLE `mis_doer_benchmarks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mis_doer_commitments`
--
ALTER TABLE `mis_doer_commitments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `modules`
--
ALTER TABLE `modules`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `modules_per_plans`
--
ALTER TABLE `modules_per_plans`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notes`
--
ALTER TABLE `notes`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification_toggles`
--
ALTER TABLE `notification_toggles`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `oauth_clients`
--
ALTER TABLE `oauth_clients`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `oauth_personal_access_clients`
--
ALTER TABLE `oauth_personal_access_clients`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `organizations`
--
ALTER TABLE `organizations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `organization_module_permissions`
--
ALTER TABLE `organization_module_permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pms_communication_and_supports`
--
ALTER TABLE `pms_communication_and_supports`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pms_organizations`
--
ALTER TABLE `pms_organizations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pms_subscriptions`
--
ALTER TABLE `pms_subscriptions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `process_connectors`
--
ALTER TABLE `process_connectors`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `production_orders`
--
ALTER TABLE `production_orders`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `production_order_components`
--
ALTER TABLE `production_order_components`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `production_order_outputs`
--
ALTER TABLE `production_order_outputs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `production_order_status_logs`
--
ALTER TABLE `production_order_status_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_import_logs`
--
ALTER TABLE `product_import_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product_warehouse_stocks`
--
ALTER TABLE `product_warehouse_stocks`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `project_management`
--
ALTER TABLE `project_management`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `project_types`
--
ALTER TABLE `project_types`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `proof_of_docs`
--
ALTER TABLE `proof_of_docs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_files`
--
ALTER TABLE `recurring_files`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_labels`
--
ALTER TABLE `recurring_labels`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_master_tasks`
--
ALTER TABLE `recurring_master_tasks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_master_tasks_22Jan25`
--
ALTER TABLE `recurring_master_tasks_22Jan25`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_master_task_email_replies`
--
ALTER TABLE `recurring_master_task_email_replies`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_tasks`
--
ALTER TABLE `recurring_tasks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_tasks_22Jan25`
--
ALTER TABLE `recurring_tasks_22Jan25`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_task_action_logs`
--
ALTER TABLE `recurring_task_action_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_task_assignees`
--
ALTER TABLE `recurring_task_assignees`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_task_email_replies`
--
ALTER TABLE `recurring_task_email_replies`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `recurring_task_trackings`
--
ALTER TABLE `recurring_task_trackings`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `role_accesses`
--
ALTER TABLE `role_accesses`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `saved_filters`
--
ALTER TABLE `saved_filters`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `shift_timings`
--
ALTER TABLE `shift_timings`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `smtp_settings`
--
ALTER TABLE `smtp_settings`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sprints`
--
ALTER TABLE `sprints`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `static_pages`
--
ALTER TABLE `static_pages`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `step1_responses`
--
ALTER TABLE `step1_responses`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `step1_responses1`
--
ALTER TABLE `step1_responses1`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stories`
--
ALTER TABLE `stories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `submitted_proof_docs`
--
ALTER TABLE `submitted_proof_docs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_action_logs`
--
ALTER TABLE `task_action_logs`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_frequency_masters`
--
ALTER TABLE `task_frequency_masters`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_labels`
--
ALTER TABLE `task_labels`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_logs`
--
ALTER TABLE `task_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_message_read_receipts`
--
ALTER TABLE `task_message_read_receipts`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_planning_logs`
--
ALTER TABLE `task_planning_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_rejection_reasons`
--
ALTER TABLE `task_rejection_reasons`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_rejection_reason_logs`
--
ALTER TABLE `task_rejection_reason_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_statuses`
--
ALTER TABLE `task_statuses`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_status_actions`
--
ALTER TABLE `task_status_actions`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `testing_cycle_modules`
--
ALTER TABLE `testing_cycle_modules`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `test_webhook`
--
ALTER TABLE `test_webhook`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ticket_status_masters`
--
ALTER TABLE `ticket_status_masters`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trello_employees`
--
ALTER TABLE `trello_employees`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `units`
--
ALTER TABLE `units`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_28-05-2024`
--
ALTER TABLE `users_28-05-2024`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users_old`
--
ALTER TABLE `users_old`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_activity_logs`
--
ALTER TABLE `user_activity_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_avatars`
--
ALTER TABLE `user_avatars`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_extrawork`
--
ALTER TABLE `user_extrawork`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_hit_chat_details`
--
ALTER TABLE `user_hit_chat_details`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_logs`
--
ALTER TABLE `user_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_managers`
--
ALTER TABLE `user_managers`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_permissions`
--
ALTER TABLE `user_permissions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_permissions_old`
--
ALTER TABLE `user_permissions_old`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_recurring_chat_details`
--
ALTER TABLE `user_recurring_chat_details`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_recurring_master_chat_details`
--
ALTER TABLE `user_recurring_master_chat_details`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vendors`
--
ALTER TABLE `vendors`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `warehouses`
--
ALTER TABLE `warehouses`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `weekend_settings`
--
ALTER TABLE `weekend_settings`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `whatsapp_settings`
--
ALTER TABLE `whatsapp_settings`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `worksnap_attendance_histories`
--
ALTER TABLE `worksnap_attendance_histories`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `work_snap_activity_histories`
--
ALTER TABLE `work_snap_activity_histories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `work_snap_histories`
--
ALTER TABLE `work_snap_histories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `delegation_tasks`
--
ALTER TABLE `delegation_tasks`
  ADD CONSTRAINT `tasks_board_id_foreign` FOREIGN KEY (`delegation_board_id`) REFERENCES `delegation_boards` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `tasks_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `department_managers`
--
ALTER TABLE `department_managers`
  ADD CONSTRAINT `department_managers_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `designations`
--
ALTER TABLE `designations`
  ADD CONSTRAINT `designations_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `email_templates_backup28thMar25`
--
ALTER TABLE `email_templates_backup28thMar25`
  ADD CONSTRAINT `email_templates_email_types_id_foreign` FOREIGN KEY (`email_type_id`) REFERENCES `email_types_backup28thMar25` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `hit_ticket_custom_fields`
--
ALTER TABLE `hit_ticket_custom_fields`
  ADD CONSTRAINT `fk_htcf_hit_ticket` FOREIGN KEY (`hit_ticket_id`) REFERENCES `hit_tickets` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `modules_per_plans`
--
ALTER TABLE `modules_per_plans`
  ADD CONSTRAINT `modules_per_plans_ibfk_1` FOREIGN KEY (`subscription_id`) REFERENCES `pms_subscriptions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users_old`
--
ALTER TABLE `users_old`
  ADD CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `user_avatars`
--
ALTER TABLE `user_avatars`
  ADD CONSTRAINT `user_avatars_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users_old` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `user_logs`
--
ALTER TABLE `user_logs`
  ADD CONSTRAINT `user_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users_old` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `user_permissions`
--
ALTER TABLE `user_permissions`
  ADD CONSTRAINT `user_permissions_module_id_foreign` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`),
  ADD CONSTRAINT `user_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  ADD CONSTRAINT `user_permissions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users_old` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;