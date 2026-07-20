-- ============================================================
-- AIMS (AI-Based Institute Management System)
-- File: seed.sql
-- ============================================================

USE aims_db;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Roles & Permissions
INSERT INTO roles (role_id, role_name, description) VALUES
(1, 'Super Admin', 'Full Access Across System'),
(2, 'Teacher', 'Academic Operations & Marking'),
(3, 'Student', 'Portal Access & Course View'),
(4, 'Parent', 'View Dependent Progress and Fees');

INSERT INTO permissions (permission_id, permission_name, module) VALUES
(1, 'manage_users', 'Identity'),
(2, 'mark_attendance', 'Academics'),
(3, 'enter_marks', 'Exams'),
(4, 'view_fee_vouchers', 'Finance');

INSERT INTO role_permissions (role_id, permission_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),
(2, 2), (2, 3),
(3, 4),
(4, 4);

-- 2. Users
INSERT INTO users (user_id, email, password_hash, role_id, is_active) VALUES
(1, 'admin@aims.edu.pk', '$2b$12$e/c93E0N0f...hash1', 1, TRUE),
(2, 'teacher1@aims.edu.pk', '$2b$12$e/c93E0N0f...hash2', 2, TRUE),
(3, 'teacher2@aims.edu.pk', '$2b$12$e/c93E0N0f...hash3', 2, TRUE),
(4, 'student1@aims.edu.pk', '$2b$12$e/c93E0N0f...hash4', 3, TRUE),
(5, 'student2@aims.edu.pk', '$2b$12$e/c93E0N0f...hash5', 3, TRUE),
(6, 'parent1@aims.edu.pk', '$2b$12$e/c93E0N0f...hash6', 4, TRUE);

-- 3. Departments
INSERT INTO departments (department_id, department_name, head_employee_id) VALUES
(1, 'Computer Science', NULL),
(2, 'Electrical Engineering', NULL);

-- 4. Programs, Batches, Sections, Semesters
INSERT INTO programs (program_id, department_id, program_name, duration_semesters) VALUES
(1, 1, 'BS Computer Science', 8),
(2, 2, 'BS Electrical Engineering', 8);

INSERT INTO batches (batch_id, program_id, batch_name, start_year, end_year) VALUES
(1, 1, 'BSCS 2023-2027', 2023, 2027),
(2, 2, 'BSEE 2023-2027', 2023, 2027);

INSERT INTO sections (section_id, batch_id, section_name, capacity) VALUES
(1, 1, 'CS-A', 40),
(2, 2, 'EE-A', 40);

INSERT INTO semesters (semester_id, program_id, semester_number, start_date, end_date) VALUES
(1, 1, 1, '2023-09-01', '2024-01-15'),
(2, 2, 1, '2023-09-01', '2024-01-15');

-- 5. Subjects & Classrooms
INSERT INTO subjects (subject_id, subject_code, subject_name, credit_hours, semester_id, prerequisite_subject_id) VALUES
(1, 'CS-101', 'Programming Fundamentals', 4, 1, NULL),
(2, 'EE-101', 'Circuit Analysis', 3, 2, NULL);

INSERT INTO classrooms (classroom_id, room_name, building, capacity) VALUES
(1, 'Lab 1', 'Block A', 50),
(2, 'Room 202', 'Block B', 60);

-- 6. Employees & Teachers
INSERT INTO employees (employee_id, user_id, employee_code, first_name, last_name, department_id, designation, basic_salary, hire_date) VALUES
(1, 1, 'EMP-001', 'Dr. Ali', 'Khan', 1, 'HOD CS', 250000.00, '2020-01-01'),
(2, 2, 'EMP-002', 'Usman', 'Tariq', 1, 'Assistant Professor', 150000.00, '2021-08-15'),
(3, 3, 'EMP-003', 'Sara', 'Ahmed', 2, 'Lecturer', 120000.00, '2022-02-01');

UPDATE departments SET head_employee_id = 1 WHERE department_id = 1;

INSERT INTO teachers (teacher_id, employee_id, specialization) VALUES
(1, 2, 'Software Engineering'),
(2, 3, 'Power Systems');

-- 7. Timetables & Teacher Subjects
INSERT INTO timetables (timetable_id, subject_id, section_id, teacher_id, classroom_id, day_of_week, start_time, end_time) VALUES
(1, 1, 1, 1, 1, 'Monday', '09:00:00', '10:30:00'),
(2, 2, 2, 2, 2, 'Tuesday', '11:00:00', '12:30:00');

INSERT INTO teacher_subjects (teacher_id, subject_id, batch_id) VALUES
(1, 1, 1),
(2, 2, 2);

INSERT INTO teacher_attendance (teacher_attendance_id, employee_id, att_date, check_in, check_out, status) VALUES
(1, 2, '2026-03-01', '08:55:00', '16:05:00', 'Present'),
(2, 3, '2026-03-01', '09:02:00', '16:00:00', 'Present');

INSERT INTO payroll (payroll_id, employee_id, month, basic_salary, allowances, deductions, net_salary) VALUES
(1, 2, '2026-02', 150000.00, 10000.00, 5000.00, 155000.00),
(2, 3, '2026-02', 120000.00, 8000.00, 3000.00, 125000.00);

INSERT INTO employee_documents (doc_id, employee_id, doc_type, file_url, verified) VALUES
(1, 2, 'CNIC', 'https://aims.s3.amazonaws.com/docs/emp2_cnic.pdf', TRUE),
(2, 3, 'Degree', 'https://aims.s3.amazonaws.com/docs/emp3_degree.pdf', TRUE);

INSERT INTO performance_evaluations (evaluation_id, employee_id, evaluation_period, rating, remarks, evaluated_by) VALUES
(1, 2, 'Annual 2025', 'Excellent', 'Consistently good student evaluations.', 1),
(2, 3, 'Annual 2025', 'Good', 'Meets research performance standards.', 1);

INSERT INTO leave_requests (leave_id, user_id, leave_type, start_date, end_date, status, approved_by) VALUES
(1, 2, 'Casual', '2026-04-10', '2026-04-11', 'Approved', 1),
(2, 3, 'Medical', '2026-05-01', '2026-05-03', 'Pending', NULL);

-- 8. Students & Enrollments
INSERT INTO students (student_id, user_id, registration_number, first_name, last_name, cnic_bform, phone, dob, program_id, batch_id, section_id, academic_status) VALUES
(1, 4, '2023-CS-01', 'Hamza', 'Bilal', '37405-1234567-1', '03001234567', '2004-05-12', 1, 1, 1, 'Active'),
(2, 5, '2023-EE-01', 'Zainab', 'Fatima', '37405-7654321-2', '03007654321', '2005-01-20', 2, 2, 2, 'Active');

INSERT INTO enrollments (enrollment_id, student_id, subject_id, semester_id, enrollment_date, status) VALUES
(1, 1, 1, 1, '2023-09-02', 'Active'),
(2, 2, 2, 2, '2023-09-02', 'Active');

-- 9. Attendance
INSERT INTO attendance (attendance_id, student_id, subject_id, timetable_id, att_date, status, marked_by) VALUES
(1, 1, 1, 1, '2026-03-02', 'Present', 1),
(2, 2, 2, 2, '2026-03-03', 'Present', 2);

-- 10. Exams, Marks, Grades, Results
INSERT INTO exams (exam_id, exam_name, exam_type, semester_id, subject_id, exam_date, total_marks, classroom_id, invigilator_id) VALUES
(1, 'Midterm Exam CS-101', 'Mid-Term', 1, 1, '2023-11-10', 50, 1, 1),
(2, 'Midterm Exam EE-101', 'Mid-Term', 2, 2, '2023-11-11', 50, 2, 2);

INSERT INTO marks (mark_id, exam_id, student_id, obtained_marks, entered_by, verified_by, status) VALUES
(1, 1, 1, 42.50, 1, 1, 'Published'),
(2, 2, 2, 38.00, 2, 2, 'Published');

INSERT INTO grades (grade_id, grade_letter, min_percentage, max_percentage, grade_point) VALUES
(1, 'A', 85.00, 100.00, 4.00),
(2, 'B', 70.00, 84.99, 3.00),
(3, 'C', 50.00, 69.99, 2.00);

INSERT INTO results (result_id, student_id, semester_id, gpa, cgpa, published_at, status) VALUES
(1, 1, 1, 3.80, 3.80, '2024-01-20 10:00:00', 'Published'),
(2, 2, 2, 3.40, 3.40, '2024-01-20 10:00:00', 'Published');

-- 11. Finance
INSERT INTO fee_structures (fee_structure_id, program_id, semester_id, fee_category, amount) VALUES
(1, 1, 1, 'Tuition Fee', 85000.00),
(2, 2, 2, 'Tuition Fee', 90000.00);

INSERT INTO student_fees (student_fee_id, student_id, fee_structure_id, voucher_number, total_payable, due_date, status) VALUES
(1, 1, 1, 'VOUCH-CS-101', 85000.00, '2023-09-15', 'Paid'),
(2, 2, 2, 'VOUCH-EE-101', 90000.00, '2023-09-15', 'Unpaid');

INSERT INTO payments (payment_id, student_fee_id, amount_paid, payment_method, payment_date, receipt_number, recorded_by) VALUES
(1, 1, 85000.00, 'Bank Transfer', '2023-09-10', 'REC-9981', 1);

INSERT INTO scholarships (scholarship_id, student_id, semester_id, scholarship_type, discount_percentage, approved_by) VALUES
(1, 1, 1, 'Merit Scholarship', 25.00, 1);

-- 12. Parents & Communication
INSERT INTO parents (parent_id, user_id, first_name, last_name, phone, occupation) VALUES
(1, 6, 'Bilal', 'Ahmed', '03211234567', 'Business');

INSERT INTO student_guardians (student_id, parent_id, relationship) VALUES
(1, 1, 'Father');

INSERT INTO meeting_requests (request_id, parent_id, teacher_id, requested_date, status, notes) VALUES
(1, 1, 1, '2026-03-15 11:00:00', 'Pending', 'Discuss academic progress');

INSERT INTO announcements (announcement_id, title, content, target_role, posted_by) VALUES
(1, 'Midterm Schedule Announced', 'Please check the examination portal for dates.', 'Student', 1);

INSERT INTO notifications (notification_id, user_id, message, type, is_read) VALUES
(1, 4, 'Your result for CS-101 is published.', 'Academic', FALSE),
(2, 5, 'Fee Voucher for Fall 2023 generated.', 'Finance', FALSE);

-- 13. Library
INSERT INTO books (book_id, isbn, title, author, category, total_copies, available_copies) VALUES
(1, '978-0131103627', 'The C Programming Language', 'Kernighan & Ritchie', 'Computer Science', 5, 4),
(2, '978-0134484143', 'Electric Circuits', 'Nilsson & Riedel', 'Electrical Engineering', 3, 3);

INSERT INTO book_issues (issue_id, book_id, borrower_user_id, issue_date, due_date, return_date, fine_amount) VALUES
(1, 1, 4, '2026-02-01', '2026-02-15', '2026-02-14', 0.00);

-- 14. AI Predictions, Reports & Auditing
INSERT INTO ai_predictions (prediction_id, student_id, prediction_type, predicted_value, risk_level, confidence_score) VALUES
(1, 1, 'Performance', 3.85, 'Low', 92.50),
(2, 2, 'Attendance Risk', 72.00, 'Medium', 88.00);

INSERT INTO reports (report_id, report_type, generated_by, file_url, format) VALUES
(1, 'Semester Performance Summary', 1, 'https://aims.s3.amazonaws.com/reports/sem1_summary.pdf', 'PDF');

INSERT INTO dashboard_widgets (widget_id, role_id, widget_type, config_json) VALUES
(1, 1, 'Attendance Overview', '{"refreshRateSec": 30, "layout": "grid"}');

INSERT INTO audit_logs (log_id, user_id, action, module, entity_affected, ip_address) VALUES
(1, 1, 'PUBLISH_MARKS', 'Exams', 'Marks (Exam 1)', '192.168.1.100');

SET FOREIGN_KEY_CHECKS = 1;