-- ============================================================
-- AIMS (AI-Based Institute Management System)
-- File: constraints.sql
-- ============================================================

USE aims_db;

-- 1. Performance Indexes
CREATE INDEX idx_students_status        ON students(academic_status);
CREATE INDEX idx_students_name          ON students(first_name, last_name);
CREATE INDEX idx_employees_status       ON employees(employment_status);
CREATE INDEX idx_attendance_date        ON attendance(att_date);
CREATE INDEX idx_teacher_attendance_dt  ON teacher_attendance(att_date);
CREATE INDEX idx_exams_date             ON exams(exam_date);
CREATE INDEX idx_marks_status           ON marks(status);
CREATE INDEX idx_results_status         ON results(status);
CREATE INDEX idx_student_fees_status    ON student_fees(status);
CREATE INDEX idx_student_fees_due       ON student_fees(due_date);
CREATE INDEX idx_payments_date          ON payments(payment_date);
CREATE INDEX idx_leave_status           ON leave_requests(status);
CREATE INDEX idx_notifications_unread   ON notifications(user_id, is_read);
CREATE INDEX idx_announcements_role     ON announcements(target_role);
CREATE INDEX idx_audit_logs_time        ON audit_logs(action_timestamp);
CREATE INDEX idx_ai_predictions_risk    ON ai_predictions(risk_level);
CREATE INDEX idx_ai_predictions_type    ON ai_predictions(prediction_type);

-- 2. Domain Level Check Constraints
ALTER TABLE exams 
  ADD CONSTRAINT chk_exams_total_marks CHECK (total_marks > 0);

ALTER TABLE marks 
  ADD CONSTRAINT chk_marks_obtained CHECK (obtained_marks >= 0);

ALTER TABLE student_fees 
  ADD CONSTRAINT chk_fees_total_payable CHECK (total_payable >= 0);

ALTER TABLE payments 
  ADD CONSTRAINT chk_payments_amount CHECK (amount_paid > 0);

ALTER TABLE scholarships 
  ADD CONSTRAINT chk_scholarship_discount CHECK (discount_percentage > 0 AND discount_percentage <= 100);

ALTER TABLE books 
  ADD CONSTRAINT chk_books_total_copies CHECK (total_copies >= 0),
  ADD CONSTRAINT chk_books_available_copies CHECK (available_copies >= 0 AND available_copies <= total_copies);