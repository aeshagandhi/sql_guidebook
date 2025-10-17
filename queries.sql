-- Student ID : A unique identifier assigned to each student.

-- Study Hours Per Day : Average number of hours in which a student spends time for studying daily.

-- Extracurricular Hours Per Day : spending time on extra-cocurricular activities such as clubs, arts,sports, or other hobbies.

-- Sleep Hours Per Day : Number of hours a student sleeps per day.

-- Social Hours Per Day : Time spent with friends, family, or social interactions.

-- Physical Activity Hours Per Day : Time spent in physical activities or exercise.

-- GPA : Grade Point Average representing academic performance.

-- Stress Level : Stress category of the student (Low, Moderate, High).

-- Create table to store student activities data 
CREATE TABLE students (
    StudentID INT PRIMARY KEY,
    StudyHoursPerDay FLOAT,
    ExtracurricularHoursPerDay FLOAT,
    SleepHoursPerDay FLOAT,
    SocialHoursPerDay FLOAT,
    PhysicalActivityHoursPerDay FLOAT,
    GPA FLOAT,
    StressLevel VARCHAR(10)
);

-- create a new table and make up sample data made up of 5 rows
CREATE TABLE students_age (
    StudentID INT PRIMARY KEY,
    Age INT
);
INSERT INTO students_age (StudentID, Age) VALUES
(1, 20),
(2, 21),
(3, 19),
(4, 22),
(5, 20);


/* 
Load csv data into new table by running in terminal:
sqlite3 my_database.db
sqlite> .mode csv
sqlite> .separator ","
sqlite> .import student_lifestyle_dataset.csv students
sqlite> SELECT * FROM students LIMIT 5;
Student_ID,Study_Hours_Per_Day,Extracurricular_Hours_Per_Day,Sleep_Hours_Per_Day,Social_Hours_Per_Day,Physical_Activity_Hours_Per_Day,GPA,Stress_Level
1,6.9,3.8,8.7,2.8,1.8,2.99,Moderate
2,5.3,3.5,8.0,4.2,3.0,2.75,Low
3,5.1,3.9,9.2,1.2,4.6,2.67,Low
4,6.5,2.1,7.2,1.7,6.5,2.88,Moderate
sqlite> .exit
*/



-- Verify successful creation of the table
SELECT * FROM students;


-- update study hours per day for a specific student
UPDATE students
SET StudyHoursPerDay = 14.0
WHERE StudentID = 1;

-- queries to do SELECT, FROM, WHERE, ORDER BY, GROUP BY, LIMIT, HAVING

-- Retrieve average stress of students who have a GPA greater than 3.0 grouped by stress level
-- What is the average GPA of students with a GPA greater than 3.0, grouped by their StressLevel, and limited to the top 3 stress levels with the highest average GPA?
SELECT StressLevel, AVG(GPA) AS AverageGPA
FROM students
WHERE GPA > 3.0
GROUP BY StressLevel
HAVING AVG(GPA) > 3.0
ORDER BY AverageGPA DESC
LIMIT 3;


-- example of joining with self join to compare students with similar study hours
-- Which pairs of students have the same StudyHoursPerDay, and what are their respective StudyHoursPerDay values?
SELECT s1.StudentID AS Student1_ID, s2.StudentID AS Student2_ID, s1.StudyHoursPerDay AS Student1_StudyHoursPerDay, s2.StudyHoursPerDay AS Student2_StudyHoursPerDay
FROM students s1
INNER JOIN students s2 ON s1.StudyHoursPerDay = s2.StudyHoursPerDay AND s1.StudentID != s2.StudentID
ORDER BY s1.StudyHoursPerDay ASC, s2.StudyHoursPerDay DESC;    

-- example of joining students table with students_age table to get age information
SELECT s.StudentID, s.StudyHoursPerDay, sa.Age
FROM students s
INNER JOIN students_age sa ON s.StudentID = sa.StudentID
ORDER BY sa.Age DESC;

-- data cleaning and transformation such as CASE WHEN statements
-- Categorize students based on their study hours per day
-- How can we categorize students into 'Low', 'Moderate', and 'High' study hours based on their StudyHoursPerDay?
SELECT StudentID,
         StudyHoursPerDay,
            CASE 
                WHEN StudyHoursPerDay < 4 THEN 'Low'
                WHEN StudyHoursPerDay BETWEEN 4 AND 8 THEN 'Moderate'
                ELSE 'High'
            END AS StudyCategory
FROM students;

-- Remove students that have invalid GPA values (less than 0 or greater than 4) that need to be removed from the dataset?
DELETE FROM students
WHERE GPA < 0 OR GPA > 4;


-- What is the GPA of each student along with the overall average GPA and their rank based on GPA?
-- window functions and use CTEs
WITH AverageGPA AS (
    SELECT StudentID, GPA,
           AVG(GPA) OVER () AS OverallAverageGPA
    FROM students
)
SELECT StudentID, GPA, OverallAverageGPA,
       RANK() OVER (ORDER BY GPA DESC) AS GPARank
FROM AverageGPA;


-- How can we update the ExtracurricularHoursPerDay column to replace null values with the average ExtracurricularHoursPerDay of all students?
-- use coalesce to handle null values
-- Replace null values in ExtracurricularHoursPerDay with the average of that column

SELECT 
    StudentID,
    ExtracurricularHoursPerDay,
    COALESCE(
        ExtracurricularHoursPerDay,
        (SELECT AVG(ExtracurricularHoursPerDay) FROM students)
    ) AS FilledExtracurricularHours
FROM students;
   


-- What is the GPA of each student along with the GPA of the next student in descending order of GPA?
-- use window function LEAD to compare each student's GPA with the next student's GPA
SELECT StudentID, GPA,
       LEAD(GPA) OVER (ORDER BY GPA DESC) AS NextStudentGPA
FROM students;



