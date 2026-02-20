-- ============================================
-- SIMPLIFIED SCHOOL MANAGEMENT DATABASE
-- 6 Entities: Students, Teachers, Classes, 
-- Schedules, Enrollments, Grades
-- ============================================

CREATE DATABASE IF NOT EXISTS school_management;
USE school_management;

-- ============================================
-- 1. STUDENTS TABLE
-- ============================================
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    grade_level INT NOT NULL,
    status ENUM('active', 'inactive', 'graduated') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. TEACHERS TABLE
-- ============================================
CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    subject_specialization VARCHAR(100),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. CLASSES TABLE
-- Combines: Subject, Teacher, Room, and Group info
-- ============================================
CREATE TABLE classes (
    class_id INT PRIMARY KEY AUTO_INCREMENT,
    class_name VARCHAR(100) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    teacher_id INT NOT NULL,
    room_number VARCHAR(20),
    grade_level INT NOT NULL,
    capacity INT DEFAULT 30,
    academic_year VARCHAR(20) NOT NULL,
    semester ENUM('1', '2') NOT NULL,
    status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE CASCADE
);

-- ============================================
-- 4. SCHEDULES TABLE
-- ============================================
CREATE TABLE schedules (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    class_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    CHECK (end_time > start_time)
);

-- ============================================
-- 5. ENROLLMENTS TABLE
-- ============================================
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    status ENUM('active', 'dropped', 'completed') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, class_id)
);

-- ============================================
-- 6. GRADES TABLE
-- ============================================
CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT NOT NULL,
    grade_type ENUM('quiz', 'midterm', 'final', 'assignment', 'project') NOT NULL,
    score DECIMAL(5, 2) NOT NULL,
    max_score DECIMAL(5, 2) NOT NULL DEFAULT 100.00,
    grade_date DATE NOT NULL,
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    CHECK (score >= 0 AND score <= max_score)
);

-- ============================================
-- INDEXES FOR BETTER PERFORMANCE
-- ============================================

-- Students indexes
CREATE INDEX idx_student_grade_level ON students(grade_level);
CREATE INDEX idx_student_status ON students(status);
CREATE INDEX idx_student_name ON students(last_name, first_name);

-- Teachers indexes
CREATE INDEX idx_teacher_specialization ON teachers(subject_specialization);
CREATE INDEX idx_teacher_status ON teachers(status);

-- Classes indexes
CREATE INDEX idx_class_subject ON classes(subject);
CREATE INDEX idx_class_grade_level ON classes(grade_level);
CREATE INDEX idx_class_academic_year ON classes(academic_year);
CREATE INDEX idx_class_teacher ON classes(teacher_id);

-- Schedules indexes
CREATE INDEX idx_schedule_day ON schedules(day_of_week);
CREATE INDEX idx_schedule_class ON schedules(class_id);

-- Enrollments indexes
CREATE INDEX idx_enrollment_student ON enrollments(student_id);
CREATE INDEX idx_enrollment_class ON enrollments(class_id);
CREATE INDEX idx_enrollment_status ON enrollments(status);

-- Grades indexes
CREATE INDEX idx_grade_enrollment ON grades(enrollment_id);
CREATE INDEX idx_grade_type ON grades(grade_type);
CREATE INDEX idx_grade_date ON grades(grade_date);

-- ============================================
-- SAMPLE DATA
-- ============================================

-- Insert Teachers
INSERT INTO teachers (first_name, last_name, email, phone, subject_specialization) VALUES
('John', 'Smith', 'john.smith@school.edu', '555-0101', 'Mathematics'),
('Sarah', 'Johnson', 'sarah.johnson@school.edu', '555-0102', 'English'),
('Michael', 'Brown', 'michael.brown@school.edu', '555-0103', 'Science'),
('Emily', 'Davis', 'emily.davis@school.edu', '555-0104', 'History'),
('David', 'Wilson', 'david.wilson@school.edu', '555-0105', 'Computer Science'),
('Lisa', 'Martinez', 'lisa.martinez@school.edu', '555-0106', 'Art');

-- Insert Students
INSERT INTO students (first_name, last_name, email, phone, grade_level) VALUES
('Alice', 'Anderson', 'alice.anderson@student.edu', '555-1001', 10),
('Bob', 'Baker', 'bob.baker@student.edu', '555-1002', 10),
('Charlie', 'Cooper', 'charlie.cooper@student.edu', '555-1003', 10),
('Diana', 'Dixon', 'diana.dixon@student.edu', '555-1004', 11),
('Ethan', 'Evans', 'ethan.evans@student.edu', '555-1005', 11),
('Fiona', 'Foster', 'fiona.foster@student.edu', '555-1006', 12),
('George', 'Green', 'george.green@student.edu', '555-1007', 12),
('Hannah', 'Harris', 'hannah.harris@student.edu', '555-1008', 10);

-- Insert Classes
INSERT INTO classes (class_name, subject, teacher_id, room_number, grade_level, academic_year, semester) VALUES
('Algebra I - Section A', 'Mathematics', 1, 'A101', 10, '2024-2025', '1'),
('Algebra I - Section B', 'Mathematics', 1, 'A102', 10, '2024-2025', '1'),
('English Literature 10', 'English', 2, 'B201', 10, '2024-2025', '1'),
('Biology I', 'Science', 3, 'C301', 10, '2024-2025', '1'),
('Algebra II', 'Mathematics', 1, 'A101', 11, '2024-2025', '1'),
('Chemistry I', 'Science', 3, 'C302', 11, '2024-2025', '1'),
('World History', 'History', 4, 'B202', 11, '2024-2025', '1'),
('Calculus', 'Mathematics', 1, 'A103', 12, '2024-2025', '1'),
('Advanced English', 'English', 2, 'B203', 12, '2024-2025', '1'),
('Computer Science I', 'Computer Science', 5, 'D101', 10, '2024-2025', '1'),
('Art Fundamentals', 'Art', 6, 'E101', 10, '2024-2025', '1');

-- Insert Schedules
INSERT INTO schedules (class_id, day_of_week, start_time, end_time) VALUES
-- Algebra I - Section A
(1, 'Monday', '08:00:00', '09:00:00'),
(1, 'Wednesday', '08:00:00', '09:00:00'),
(1, 'Friday', '08:00:00', '09:00:00'),
-- Algebra I - Section B
(2, 'Tuesday', '08:00:00', '09:00:00'),
(2, 'Thursday', '08:00:00', '09:00:00'),
-- English Literature 10
(3, 'Monday', '09:15:00', '10:15:00'),
(3, 'Wednesday', '09:15:00', '10:15:00'),
(3, 'Friday', '09:15:00', '10:15:00'),
-- Biology I
(4, 'Tuesday', '09:15:00', '10:15:00'),
(4, 'Thursday', '09:15:00', '10:15:00'),
-- Algebra II
(5, 'Monday', '10:30:00', '11:30:00'),
(5, 'Wednesday', '10:30:00', '11:30:00'),
(5, 'Friday', '10:30:00', '11:30:00'),
-- Chemistry I
(6, 'Tuesday', '10:30:00', '11:30:00'),
(6, 'Thursday', '10:30:00', '11:30:00'),
-- World History
(7, 'Monday', '13:00:00', '14:00:00'),
(7, 'Thursday', '13:00:00', '14:00:00'),
-- Calculus
(8, 'Tuesday', '13:00:00', '14:00:00'),
(8, 'Friday', '13:00:00', '14:00:00'),
-- Advanced English
(9, 'Monday', '14:15:00', '15:15:00'),
(9, 'Wednesday', '14:15:00', '15:15:00'),
-- Computer Science I
(10, 'Tuesday', '14:15:00', '15:45:00'),
(10, 'Thursday', '14:15:00', '15:45:00'),
-- Art Fundamentals
(11, 'Friday', '14:15:00', '16:15:00');

-- Insert Enrollments
INSERT INTO enrollments (student_id, class_id, enrollment_date) VALUES
-- Grade 10 students (Alice, Bob, Charlie, Hannah)
(1, 1, '2024-08-15'), (1, 3, '2024-08-15'), (1, 4, '2024-08-15'), (1, 10, '2024-08-15'),
(2, 1, '2024-08-15'), (2, 3, '2024-08-15'), (2, 4, '2024-08-15'), (2, 11, '2024-08-15'),
(3, 2, '2024-08-15'), (3, 3, '2024-08-15'), (3, 4, '2024-08-15'), (3, 10, '2024-08-15'),
(8, 2, '2024-08-15'), (8, 3, '2024-08-15'), (8, 4, '2024-08-15'),
-- Grade 11 students (Diana, Ethan)
(4, 5, '2024-08-15'), (4, 6, '2024-08-15'), (4, 7, '2024-08-15'),
(5, 5, '2024-08-15'), (5, 6, '2024-08-15'), (5, 7, '2024-08-15'),
-- Grade 12 students (Fiona, George)
(6, 8, '2024-08-15'), (6, 9, '2024-08-15'),
(7, 8, '2024-08-15'), (7, 9, '2024-08-15');

-- Insert Grades
INSERT INTO grades (enrollment_id, grade_type, score, max_score, grade_date, comments) VALUES
-- Alice's grades
(1, 'quiz', 85.00, 100.00, '2024-09-15', 'Good understanding of algebra basics'),
(1, 'midterm', 78.50, 100.00, '2024-10-20', 'Needs improvement in quadratic equations'),
(2, 'assignment', 92.00, 100.00, '2024-09-18', 'Excellent essay on Shakespeare'),
(3, 'quiz', 88.00, 100.00, '2024-09-16', 'Strong grasp of cellular biology'),
-- Bob's grades
(5, 'quiz', 75.00, 100.00, '2024-09-15', 'Review factoring techniques'),
(6, 'assignment', 95.00, 100.00, '2024-09-18', 'Outstanding literary analysis'),
-- Charlie's grades
(9, 'quiz', 90.00, 100.00, '2024-09-15', 'Excellent work'),
(10, 'midterm', 82.00, 100.00, '2024-10-20', 'Good progress'),
-- Diana's grades
(13, 'quiz', 88.00, 100.00, '2024-09-16', 'Strong performance'),
(14, 'quiz', 91.00, 100.00, '2024-09-17', 'Excellent lab work'),
-- Ethan's grades
(16, 'assignment', 85.00, 100.00, '2024-09-20', 'Good problem solving'),
-- Fiona's grades
(19, 'quiz', 95.00, 100.00, '2024-09-18', 'Outstanding calculus skills'),
(19, 'midterm', 92.00, 100.00, '2024-10-22', 'Excellent understanding of derivatives'),
(20, 'assignment', 89.00, 100.00, '2024-09-19', 'Insightful literary critique');

-- ============================================
-- END OF SCHEMA
-- ============================================
