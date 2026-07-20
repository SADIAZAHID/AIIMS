-- ============================================================
-- AIMS (AI-Based Institute Management System)
-- File: schema.sql
-- ============================================================

DROP DATABASE IF EXISTS aims_db;
CREATE DATABASE aims_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE aims_db;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. IDENTITY & SECURITY
CREATE TABLE roles (
  role_id      INT AUTO_INCREMENT PRIMARY KEY,
  role_name    VARCHAR(50)  NOT NULL UNIQUE,
  description  VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE permissions (
  permission_id    INT AUTO_INCREMENT PRIMARY KEY,
  permission_name  VARCHAR(100) NOT NULL,
  module           VARCHAR(50)  NOT NULL
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
  role_id        INT NOT NULL,
  permission_id  INT NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE users (
  user_id        INT AUTO_INCREMENT PRIMARY KEY,
  email          VARCHAR(255) NOT NULL UNIQUE,
  password_hash  VARCHAR(255) NOT NULL,
  role_id        INT NOT NULL,
  is_active      BOOLEAN DEFAULT TRUE,
  last_login     DATETIME NULL,
  is_deleted     BOOLEAN DEFAULT FALSE,
  created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2. ACADEMIC STRUCTURE
CREATE TABLE departments (
  department_id     INT AUTO_INCREMENT PRIMARY KEY,
  department_name   VARCHAR(100) NOT NULL UNIQUE,
  head_employee_id  INT NULL
) ENGINE=InnoDB;

CREATE TABLE programs (
  program_id          INT AUTO_INCREMENT PRIMARY KEY,
  department_id       INT NOT NULL,
  program_name        VARCHAR(150) NOT NULL,
  duration_semesters  INT NOT NULL,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE batches (
  batch_id    INT AUTO_INCREMENT PRIMARY KEY,
  program_id  INT NOT NULL,
  batch_name  VARCHAR(50) NOT NULL,
  start_year  YEAR NOT NULL,
  end_year    YEAR NOT NULL,
  FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE sections (
  section_id    INT AUTO_INCREMENT PRIMARY KEY,
  batch_id      INT NOT NULL,
  section_name  VARCHAR(10) NOT NULL,
  capacity      INT DEFAULT 40,
  FOREIGN KEY (batch_id) REFERENCES batches(batch_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE semesters (
  semester_id      INT AUTO_INCREMENT PRIMARY KEY,
  program_id       INT NOT NULL,
  semester_number  INT NOT NULL,
  start_date       DATE NOT NULL,
  end_date         DATE NOT NULL,
  is_archived      BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE subjects (
  subject_id               INT AUTO_INCREMENT PRIMARY KEY,
  subject_code             VARCHAR(20) NOT NULL UNIQUE,
  subject_name             VARCHAR(150) NOT NULL,
  credit_hours             INT NOT NULL,
  semester_id              INT NOT NULL,
  prerequisite_subject_id  INT NULL,
  FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (prerequisite_subject_id) REFERENCES subjects(subject_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE classrooms (
  classroom_id  INT AUTO_INCREMENT PRIMARY KEY,
  room_name     VARCHAR(50) NOT NULL,
  building      VARCHAR(50),
  capacity      INT NOT NULL
) ENGINE=InnoDB;

-- 3. HR / STAFF
CREATE TABLE employees (
  employee_id        INT AUTO_INCREMENT PRIMARY KEY,
  user_id            INT NOT NULL UNIQUE,
  employee_code      VARCHAR(20) NOT NULL UNIQUE,
  first_name         VARCHAR(100) NOT NULL,
  last_name          VARCHAR(100) NOT NULL,
  department_id      INT NOT NULL,
  designation        VARCHAR(100),
  basic_salary       DECIMAL(12,2) NOT NULL,
  hire_date          DATE NOT NULL,
  employment_status  ENUM('Active','On Leave','Terminated','Retired') DEFAULT 'Active',
  is_deleted         BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

ALTER TABLE departments
  ADD FOREIGN KEY (head_employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE teachers (
  teacher_id      INT AUTO_INCREMENT PRIMARY KEY,
  employee_id     INT NOT NULL UNIQUE,
  specialization  VARCHAR(150),
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE timetables (
  timetable_id  INT AUTO_INCREMENT PRIMARY KEY,
  subject_id    INT NOT NULL,
  section_id    INT NOT NULL,
  teacher_id    INT NOT NULL,
  classroom_id  INT NOT NULL,
  day_of_week   ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  start_time    TIME NOT NULL,
  end_time      TIME NOT NULL,
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (classroom_id) REFERENCES classrooms(classroom_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE teacher_subjects (
  teacher_id  INT NOT NULL,
  subject_id  INT NOT NULL,
  batch_id    INT NOT NULL,
  PRIMARY KEY (teacher_id, subject_id, batch_id),
  FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (batch_id) REFERENCES batches(batch_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE teacher_attendance (
  teacher_attendance_id  INT AUTO_INCREMENT PRIMARY KEY,
  employee_id            INT NOT NULL,
  att_date               DATE NOT NULL,
  check_in               TIME,
  check_out              TIME,
  status                 ENUM('Present','Absent','Late','Leave') DEFAULT 'Present',
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY uq_teacher_attendance_once (employee_id, att_date)
) ENGINE=InnoDB;

CREATE TABLE payroll (
  payroll_id    INT AUTO_INCREMENT PRIMARY KEY,
  employee_id   INT NOT NULL,
  month         CHAR(7) NOT NULL,
  basic_salary  DECIMAL(12,2) NOT NULL,
  allowances    DECIMAL(12,2) DEFAULT 0,
  deductions    DECIMAL(12,2) DEFAULT 0,
  net_salary    DECIMAL(12,2) NOT NULL,
  generated_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE employee_documents (
  doc_id       INT AUTO_INCREMENT PRIMARY KEY,
  employee_id  INT NOT NULL,
  doc_type     VARCHAR(50) NOT NULL,
  file_url     VARCHAR(255) NOT NULL,
  verified     BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE performance_evaluations (
  evaluation_id      INT AUTO_INCREMENT PRIMARY KEY,
  employee_id        INT NOT NULL,
  evaluation_period   VARCHAR(50) NOT NULL,
  rating             ENUM('Excellent','Good','Average','Poor') NOT NULL,
  remarks            VARCHAR(255),
  evaluated_by       INT NOT NULL,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (evaluated_by) REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE leave_requests (
  leave_id     INT AUTO_INCREMENT PRIMARY KEY,
  user_id      INT NOT NULL,
  leave_type   VARCHAR(50) NOT NULL,
  start_date   DATE NOT NULL,
  end_date     DATE NOT NULL,
  status       ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
  approved_by  INT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. STUDENTS & ENROLLMENT
CREATE TABLE students (
  student_id           INT AUTO_INCREMENT PRIMARY KEY,
  user_id              INT NULL UNIQUE,
  registration_number  VARCHAR(30) NOT NULL UNIQUE,
  first_name           VARCHAR(100) NOT NULL,
  last_name            VARCHAR(100) NOT NULL,
  cnic_bform           VARCHAR(20) NOT NULL UNIQUE,
  phone                VARCHAR(20),
  dob                  DATE,
  program_id           INT NOT NULL,
  batch_id             INT NOT NULL,
  section_id           INT NULL,
  academic_status      ENUM('Pending Verification','Active','Suspended','Withdrawn','Graduated','Alumni') DEFAULT 'Pending Verification',
  is_deleted           BOOLEAN DEFAULT FALSE,
  created_at           DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at           DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (batch_id) REFERENCES batches(batch_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE enrollments (
  enrollment_id    INT AUTO_INCREMENT PRIMARY KEY,
  student_id       INT NOT NULL,
  subject_id       INT NOT NULL,
  semester_id      INT NOT NULL,
  enrollment_date  DATE NOT NULL,
  status           ENUM('Active','Completed','Dropped') DEFAULT 'Active',
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. STUDENT ATTENDANCE
CREATE TABLE attendance (
  attendance_id  INT AUTO_INCREMENT PRIMARY KEY,
  student_id     INT NOT NULL,
  subject_id     INT NOT NULL,
  timetable_id   INT NOT NULL,
  att_date       DATE NOT NULL,
  status         ENUM('Present','Absent','Late','Leave','Holiday') NOT NULL,
  marked_by      INT NOT NULL,
  created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (timetable_id) REFERENCES timetables(timetable_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (marked_by) REFERENCES teachers(teacher_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY uq_attendance_once (student_id, timetable_id, att_date)
) ENGINE=InnoDB;

-- 6. EXAMS & RESULTS
CREATE TABLE exams (
  exam_id        INT AUTO_INCREMENT PRIMARY KEY,
  exam_name      VARCHAR(100) NOT NULL,
  exam_type      ENUM('Quiz','Assignment','Mid-Term','Final','Practical','Viva') NOT NULL,
  semester_id    INT NOT NULL,
  subject_id     INT NOT NULL,
  exam_date      DATE NOT NULL,
  total_marks    INT NOT NULL,
  classroom_id   INT NULL,
  invigilator_id INT NULL,
  FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (classroom_id) REFERENCES classrooms(classroom_id) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (invigilator_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE marks (
  mark_id         INT AUTO_INCREMENT PRIMARY KEY,
  exam_id         INT NOT NULL,
  student_id      INT NOT NULL,
  obtained_marks  DECIMAL(6,2) NOT NULL,
  entered_by      INT NOT NULL,
  verified_by     INT NULL,
  status          ENUM('Draft','Verified','Published') DEFAULT 'Draft',
  FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (entered_by) REFERENCES teachers(teacher_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (verified_by) REFERENCES teachers(teacher_id) ON DELETE SET NULL ON UPDATE CASCADE,
  UNIQUE KEY uq_marks_once (exam_id, student_id)
) ENGINE=InnoDB;

CREATE TABLE grades (
  grade_id        INT AUTO_INCREMENT PRIMARY KEY,
  grade_letter    VARCHAR(5) NOT NULL,
  min_percentage  DECIMAL(5,2) NOT NULL,
  max_percentage  DECIMAL(5,2) NOT NULL,
  grade_point     DECIMAL(3,2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE results (
  result_id     INT AUTO_INCREMENT PRIMARY KEY,
  student_id    INT NOT NULL,
  semester_id   INT NOT NULL,
  gpa           DECIMAL(3,2),
  cgpa          DECIMAL(3,2),
  published_at  DATETIME NULL,
  status        ENUM('Pending','Published') DEFAULT 'Pending',
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. FINANCE
CREATE TABLE fee_structures (
  fee_structure_id  INT AUTO_INCREMENT PRIMARY KEY,
  program_id        INT NOT NULL,
  semester_id       INT NOT NULL,
  fee_category      VARCHAR(50) NOT NULL,
  amount            DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_fees (
  student_fee_id    INT AUTO_INCREMENT PRIMARY KEY,
  student_id        INT NOT NULL,
  fee_structure_id  INT NOT NULL,
  voucher_number    VARCHAR(30) NOT NULL UNIQUE,
  total_payable     DECIMAL(12,2) NOT NULL,
  due_date          DATE NOT NULL,
  status            ENUM('Unpaid','Partially Paid','Paid','Overdue') DEFAULT 'Unpaid',
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (fee_structure_id) REFERENCES fee_structures(fee_structure_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE payments (
  payment_id       INT AUTO_INCREMENT PRIMARY KEY,
  student_fee_id   INT NOT NULL,
  amount_paid      DECIMAL(12,2) NOT NULL,
  payment_method   ENUM('Cash','Bank Transfer','Card','Mobile Wallet') NOT NULL,
  payment_date     DATE NOT NULL,
  receipt_number   VARCHAR(30) NOT NULL UNIQUE,
  recorded_by      INT NOT NULL,
  FOREIGN KEY (student_fee_id) REFERENCES student_fees(student_fee_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (recorded_by) REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE scholarships (
  scholarship_id       INT AUTO_INCREMENT PRIMARY KEY,
  student_id           INT NOT NULL,
  semester_id          INT NOT NULL,
  scholarship_type     VARCHAR(50) NOT NULL,
  discount_percentage  DECIMAL(5,2) NOT NULL,
  approved_by          INT NOT NULL,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (semester_id) REFERENCES semesters(semester_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (approved_by) REFERENCES employees(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8. PARENTS / ENGAGEMENT
CREATE TABLE parents (
  parent_id   INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL UNIQUE,
  first_name  VARCHAR(100) NOT NULL,
  last_name   VARCHAR(100) NOT NULL,
  phone       VARCHAR(20),
  occupation  VARCHAR(100),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_guardians (
  student_id    INT NOT NULL,
  parent_id     INT NOT NULL,
  relationship  ENUM('Father','Mother','Guardian') NOT NULL,
  PRIMARY KEY (student_id, parent_id),
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (parent_id) REFERENCES parents(parent_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE meeting_requests (
  request_id       INT AUTO_INCREMENT PRIMARY KEY,
  parent_id        INT NOT NULL,
  teacher_id       INT NOT NULL,
  requested_date   DATETIME NOT NULL,
  status           ENUM('Pending','Approved','Rejected','Completed') DEFAULT 'Pending',
  notes            VARCHAR(255),
  FOREIGN KEY (parent_id) REFERENCES parents(parent_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE announcements (
  announcement_id  INT AUTO_INCREMENT PRIMARY KEY,
  title            VARCHAR(150) NOT NULL,
  content          TEXT NOT NULL,
  target_role      VARCHAR(50) NOT NULL,
  posted_by        INT NOT NULL,
  created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (posted_by) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notifications (
  notification_id  INT AUTO_INCREMENT PRIMARY KEY,
  user_id          INT NOT NULL,
  message          VARCHAR(255) NOT NULL,
  type             VARCHAR(50) NOT NULL,
  is_read          BOOLEAN DEFAULT FALSE,
  created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 9. LIBRARY
CREATE TABLE books (
  book_id           INT AUTO_INCREMENT PRIMARY KEY,
  isbn              VARCHAR(20) NOT NULL UNIQUE,
  title             VARCHAR(200) NOT NULL,
  author            VARCHAR(150),
  category          VARCHAR(80),
  total_copies      INT NOT NULL DEFAULT 1,
  available_copies  INT NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE book_issues (
  issue_id          INT AUTO_INCREMENT PRIMARY KEY,
  book_id           INT NOT NULL,
  borrower_user_id  INT NOT NULL,
  issue_date        DATE NOT NULL,
  due_date          DATE NOT NULL,
  return_date       DATE NULL,
  fine_amount       DECIMAL(8,2) DEFAULT 0,
  FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (borrower_user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 10. AI & REPORTING
CREATE TABLE ai_predictions (
  prediction_id     INT AUTO_INCREMENT PRIMARY KEY,
  student_id        INT NOT NULL,
  prediction_type   ENUM('Performance','Fee Default','Attendance Risk') NOT NULL,
  predicted_value   DECIMAL(6,2),
  risk_level        ENUM('Low','Medium','High','Critical'),
  confidence_score  DECIMAL(5,2),
  generated_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reports (
  report_id     INT AUTO_INCREMENT PRIMARY KEY,
  report_type   VARCHAR(100) NOT NULL,
  generated_by  INT NOT NULL,
  generated_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  file_url      VARCHAR(255),
  format        ENUM('PDF','Excel','CSV') NOT NULL,
  FOREIGN KEY (generated_by) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE dashboard_widgets (
  widget_id    INT AUTO_INCREMENT PRIMARY KEY,
  role_id      INT NOT NULL,
  widget_type  VARCHAR(50) NOT NULL,
  config_json  JSON,
  FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
  log_id            INT AUTO_INCREMENT PRIMARY KEY,
  user_id           INT NOT NULL,
  action            VARCHAR(100) NOT NULL,
  module            VARCHAR(50) NOT NULL,
  entity_affected   VARCHAR(100),
  action_timestamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
  ip_address        VARCHAR(45),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;