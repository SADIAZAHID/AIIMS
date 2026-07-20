# AIIMS — AI-Based Institute Management System

AIIMS is a comprehensive, multi-portal academic management platform powered by artificial intelligence. It bridges administration, faculty, students, and parents into a single, unified ecosystem to optimize scheduling, track attendance, manage academic records, and deliver real-time AI assistance.

---

## 🌟 Key Features

* **Role-Based Portals**: Tailored interfaces and secure authentication flows for four distinct user types:
  * **Admin Portal**: Full system access, institutional controls, user management, and AI timetable optimization.
  * **Faculty Portal**: Course management, digital attendance logging, online gradebooks, and AI lesson/quiz generation.
  * **Student Portal**: Course tracking, real-time attendance, fee status monitoring, and an interactive AI study tutor.
  * **Parent Portal**: Academic progress tracking for guardians, attendance logs, and invoice/fee management.
* **AI-Powered Modules**: 
  * Automated timetable scheduling and conflict resolution[cite: 1].
  * Intelligent classroom capacity and resource optimization[cite: 1].
  * Built-in AI assistants for grading reviews, lesson planning, and student homework guidance[cite: 2, 8, 10].
* **Responsive Dashboard Interface**: Clean components featuring dynamic statistics widgets, interactive data tables, live search, and modal workflows[cite: 1].

---

## 📂 Project Structure

```text
AIIMS/
├── index.html           # Main landing page for role selection
├── style.css            # Global design system, color themes, and layout styles
├── login.css            # Authentication views style sheet
├── login-admin.html     # Admin sign-in screen
├── login-faculty.html   # Faculty sign-in screen
├── login-student.html   # Student sign-in screen
├── login-parent.html    # Parent sign-in screen
├── admin.html           # Administrative control center & AI scheduler dashboard
├── faculty.html         # Faculty classroom & attendance manager
├── student.html         # Student academic profile & AI tutor assistant
└── parent.html          # Parent child progress & invoice management
