create database healthcare_analysis;
use healthcare_analysis;
select * from patients;
select * from appointments;
select * from doctors;
select * from prescriptions;
select * from feedback;

-- Patient Demographics & Behavior
-- Total patient count
select distinct patientID from patients;

-- Gender Distribution 
select count(patientID) AS total_patient from patients group by gender ;

-- Age group distribution 
select Age, 
case when Age > 60 then 'Senior Citizen'
     when Age between 46 and 60 then 'Senior Adults'
     when Age between 36 and 45 then 'middle-Aged Adults'
     when Age between 20 and 35 then 'Young Adults'
     when Age between 10 and 19 then 'Adolescent'
     when Age between 0 and 9 then 'Child'
     end AS Age
FROM patients;

-- Average age of patient 
select avg(age) AS average_patient_age from patients;

-- Appointment & Operational Metrics
-- Number of appointments per patient
select patientID, count(appointmentID) AS TotalAppointment 
from appointments 
group by patientID
order by TotalAppointment DESC ;

-- No-show rate
select (sum(case when status = 'No-Show' then 1 else 0 end) * 100)/count(*) AS no_show_rate_percentage from appointments;

-- Cancellation rate
select (sum(case when status = 'Cancelled' then 1 or 0 end) * 100)/count(*) AS Cancelled_appointment_ratio from appointments;

-- Average number of departments visited per patient
select patientID, count(distinct department) AS dept from appointments group by patientID order by patientID DESC;

-- Most busy department
select department, count(patientID) AS PatientCount from appointments group by department order by PatientCount DESC ;

-- Frequency of visits (monthly) 
select 
date_format(AppointmentDate, '%M-%Y') AS Month,
count(AppointmentID) AS TotalAppointments from appointments
group by date_format(AppointmentDate, '%M-%Y') order by Month ;

-- Frequency of visits  (quarterly)
SELECT  
  CONCAT(YEAR(AppointmentDate), '-Q', QUARTER(AppointmentDate)),
  COUNT(AppointmentID) AS TotalAppointments
FROM appointments
GROUP BY CONCAT(YEAR(AppointmentDate), '-Q', QUARTER(AppointmentDate))
ORDER BY MIN(AppointmentDate)
LIMIT 0, 5000;

-- Frequency of visits  (yearly trends)
select 
Year(appointmentDate) AS Year,
count(appointmentID) AS Totalapponitments from appointments
group by Year(AppointmentDate) order by Year ;

-- Department-wise appointment volume
SELECT Department, COUNT(AppointmentID) AS TotalAppointments
FROM Appointments GROUP BY Department ORDER BY TotalAppointments DESC;

-- Peak days (weekdays) with highest bookings
select dayname(appointmentDate) AS DayOfWeek, count(AppointmentID) AS totalAppointments
from appointments group by dayname(appointmentDate) order by totalAppointments DESC;

-- A. No-Show Rate per Doctor 
SELECT DoctorID,
  COUNT(AppointmentID) AS TotalAppointments,
  SUM(CASE WHEN Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShows,
  ROUND((SUM(CASE WHEN Status = 'No-Show' THEN 1 ELSE 0 END) * 100.0) / COUNT(AppointmentID), 2) AS NoShowRate
FROM Appointments
GROUP BY DoctorID
ORDER BY NoShowRate DESC;

-- B. Cancellation Rate per Doctor
SELECT DoctorID,
  COUNT(AppointmentID) AS TotalAppointments,
  SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancellations,
  ROUND((SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(AppointmentID), 2) AS CancellationRate
FROM Appointments
GROUP BY DoctorID
ORDER BY CancellationRate DESC;

-- C. No-Show Rate per Department
SELECT Department,
  COUNT(AppointmentID) AS TotalAppointments,
  SUM(CASE WHEN Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShows,
  ROUND((SUM(CASE WHEN Status = 'No-Show' THEN 1 ELSE 0 END) * 100.0) / COUNT(AppointmentID), 2) AS NoShowRate
FROM Appointments
GROUP BY Department
ORDER BY  NoShowRate DESC;

-- D. Identify Doctors with No-Show Rate ≥ 20%
SELECT DoctorID,
  ROUND((SUM(CASE WHEN Status = 'No-Show' THEN 1 ELSE 0 END) * 100.0) / COUNT(AppointmentID), 2) AS NoShowRate
FROM Appointments
GROUP BY DoctorID
HAVING NoShowRate >= 20
ORDER BY NoShowRate DESC;

-- E. Total Appointment Volume by Doctor and Department
SELECT DoctorID, Department,
  COUNT(AppointmentID) AS TotalAppointments
FROM Appointments
GROUP BY DoctorID, Department
ORDER BY TotalAppointments DESC;

-- ADAVANCE QUERIES

-- A. No-Show & Cancellation Report per Doctor and Department
SELECT d.DoctorName, a.DoctorID, a.Department,
  COUNT(a.AppointmentID) AS TotalAppointments,
  SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShows,
  SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancellations,
  ROUND((SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) * 100.0) / COUNT(a.AppointmentID), 2) AS NoShowRate,
  ROUND((SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(a.AppointmentID), 2) AS CancellationRate
FROM Appointments a
JOIN Doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.DoctorName, a.DoctorID, a.Department
ORDER BY NoShowRate DESC;

-- B. Identify High No-Show Doctors (≥ 20%)
SELECT d.DoctorName, a.DoctorID,
  ROUND((SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) * 100.0) / COUNT(a.AppointmentID), 2) AS NoShowRate
FROM Appointments a
JOIN Doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.DoctorName, a.DoctorID
HAVING NoShowRate >= 20 ORDER BY NoShowRate DESC;
  
-- C. Department-wise Appointment Load
SELECT Department, COUNT(AppointmentID) AS TotalAppointments
FROM Appointments GROUP BY Department ORDER BY TotalAppointments DESC;

-- D. Doctor-wise Total Appointments
SELECT d.DoctorName, a.DoctorID,
  COUNT(a.AppointmentID) AS TotalAppointments
FROM  Appointments a JOIN Doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.DoctorName, a.DoctorID
ORDER BY TotalAppointments DESC;

--  Total Appointments per Department
select * from appointments ;
select department, count(appointmentID) AS totalAppointment from appointments group by department order by totalAppointment DESC;

-- No-Show & Cancellation Impact on Workload per Doctor
SELECT 
  d.DoctorName,
  a.DoctorID,
  COUNT(a.AppointmentID) AS TotalAppointments,
  SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShows,
  SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancellations,
  ROUND((SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) * 100.0) / COUNT(a.AppointmentID), 2) AS NoShowRate,
  ROUND((SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(a.AppointmentID), 2) AS CancellationRate
FROM Appointments a JOIN Doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.DoctorName, a.DoctorID ORDER BY TotalAppointments DESC;

-- Busiest days
select appointmentDate, count(appointmentID) as totalAppointments
from appointments group by appointmentDate order by totalAppointments DESC ;

-- Build a View for Doctor Workload Summary
CREATE VIEW DoctorWorkloadSummary AS
SELECT d.DoctorName, a.DoctorID,
  COUNT(a.AppointmentID) AS TotalAppointments,
  SUM(CASE WHEN a.Status = 'No-Show' THEN 1 ELSE 0 END) AS NoShows,
  SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancellations
FROM Appointments a
JOIN Doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.DoctorName, a.DoctorID;

select * from DoctorWorkloadSummary ;

-- Determined doctor-wise appointment volumes and balanced workloads by flagging over/underbooked physicians.
select * from appointments;
select * from doctors;
select d.doctorname, a.doctorID, count(appointmentID) as totalappointments,
case when count(a.appointmentID) > 25 then 'Overbooked'
     when count(a.appointmentID) < 10 then 'Underbooked'
     else 'Balanced'
     end AS Workloadstatus
from appointments a join doctors d ON a.doctorID = d.doctorID
group by d.doctorname, a.doctorID order by totalappointments DESC ;

-- Prescription & Medicine Usage
-- Analyzed top prescribed medications by department and demographic group, enabling inventory optimization.
select * from prescriptions;
select Medicine, count(prescriptionID) as totalprescriptions from prescriptions group by Medicine order by totalprescriptions DESC;

-- Billing & Revenue Analysis
-- Computed department-wise revenue contribution based on appointment billing records.

-- Patient Feedback & Satisfaction
select rating, count(patientID) as feedbackcount from feedback group by rating order by rating DESC;

-- Operational & Capacity Insights
-- Measured average patient waiting time between registration and first appointment.
select * from appointments;
select * from patients;
select AVG(datediff(AppointmentDate, registrationDate)) AS avgwaitingtime from appointments a
join patients p on a.patientID = p.patientID;

-- Average waiting time per department
select a.department,
round(avg(datediff(a.appointmentDate, p.registrationDate))/30, 2)AS AvgWaitTimeInMonth
from appointments a
join patients p on a.patientID = p.patientID
group by a.department order by AvgWaitTimeInMonth DESC;
