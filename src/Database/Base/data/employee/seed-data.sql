-- EMPLOYEE SCHEMA - Seed Data
-- Organization: MedCare India Pvt. Ltd. (India)
-- Dependencies: shared, time

-- MODULE 1: EMPLOYEE CORE DATA
PRINT 'Inserting System Employee...';
INSERT INTO employee.Employee (EmployeeCode, FirstName, LastName, DisplayName, Email, MobileNumber, DesignationId, PreferredLanguage, PreferredTimeZoneId, DateOfJoining, AboutMe, CreatedBy, LastUpdatedBy, IsSystemEmployee) VALUES
('SYS000', 'System', 'User', 'System', 'system@internal.local', NULL, NULL, 'en', NULL, '2000-01-01', 'Internal system account used for automated operations. Do not modify or delete.', 0, 0, 1);

PRINT 'Inserting Employee...';
INSERT INTO employee.Employee (EmployeeCode, FirstName, LastName, DisplayName, Email, MobileNumber, DesignationId, PreferredLanguage, PreferredTimeZoneId, DateOfJoining, EmploymentType, AboutMe) VALUES
-- Mumbai HQ
('EMP001', 'Rajesh',      'Sharma',     'Dr. Rajesh Sharma',      'rajesh.sharma@medcareindia.com',       '9810001001', (SELECT Id FROM time.Designation WHERE DesignationCode='CHMO'),         'hi', (SELECT Id FROM  time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2012-01-15', 'FULL_TIME', 'Chief Medical Officer with 20+ years of healthcare leadership.'),
('EMP002', 'Priya',       'Nair',       'Dr. Priya Nair',         'priya.nair@medcareindia.com',          '9810001002', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),   'en', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-03-01', 'FULL_TIME', 'Medical Director specializing in hospital governance.'),
('EMP003', 'Arjun',       'Mehta',      'Dr. Arjun Mehta',        'arjun.mehta@medcareindia.com',         '9810001003', (SELECT Id FROM time.Designation WHERE DesignationCode='SRSURGEON'),     'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-06-10', 'FULL_TIME', 'Senior Cardiac Surgeon, MBBS, MS, MCh Cardiology.'),
('EMP004', 'Sunita',      'Pillai',     'Sunita Pillai',          'sunita.pillai@medcareindia.com',       '9810001004', (SELECT Id FROM time.Designation WHERE DesignationCode='CHFNURSE'),      'ml', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-08-20', 'FULL_TIME', 'Chief Nursing Officer, 18 years of nursing excellence.'),
('EMP005', 'Vikram',      'Gupta',      'Vikram Gupta',           'vikram.gupta@medcareindia.com',        '9810001005', (SELECT Id FROM time.Designation WHERE DesignationCode='HRMANAGER'),     'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-02-14', 'FULL_TIME', 'HR Manager handling all India HR operations.'),
('EMP006', 'Sneha',       'Desai',      'Sneha Desai',            'sneha.desai@medcareindia.com',         '9810001006', (SELECT Id FROM time.Designation WHERE DesignationCode='FINMANAGER'),    'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-09-01', 'FULL_TIME', 'Finance Manager overseeing hospital billing and payroll.'),
('EMP007', 'Ramesh',      'Iyer',       'Ramesh Iyer',            'ramesh.iyer@medcareindia.com',         '9810001007', (SELECT Id FROM time.Designation WHERE DesignationCode='ITMANAGER'),     'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-04-01', 'FULL_TIME', 'IT Manager managing EHR and hospital network infrastructure.'),
('EMP008', 'Kavitha',     'Rao',        'Dr. Kavitha Rao',        'kavitha.rao@medcareindia.com',         '9810001008', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),    'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-07-15', 'FULL_TIME', 'Consultant Physician, Internal Medicine.'),
('EMP009', 'Anil',        'Khanna',     'Dr. Anil Khanna',        'anil.khanna@medcareindia.com',         '9810001009', (SELECT Id FROM time.Designation WHERE DesignationCode='RESIDENTDR'),   'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-08-01', 'FULL_TIME', 'Resident Doctor, Cardiology rotation.'),
('EMP010', 'Meena',       'Joshi',      'Meena Joshi',            'meena.joshi@medcareindia.com',         '9810001010', (SELECT Id FROM time.Designation WHERE DesignationCode='SRNURSE'),      'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-03-10', 'FULL_TIME', 'Senior Staff Nurse, ICU specialist.'),
('EMP011', 'Deepak',      'Singh',      'Deepak Singh',           'deepak.singh@medcareindia.com',        '9810001011', (SELECT Id FROM time.Designation WHERE DesignationCode='STAFFNURSE'),   'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-06-15', 'FULL_TIME', 'Staff Nurse, General Ward.'),
('EMP012', 'Lalitha',     'Krishnan',   'Lalitha Krishnan',       'lalitha.krishnan@medcareindia.com',    '9810001012', (SELECT Id FROM time.Designation WHERE DesignationCode='CHIEFPHARM'),   'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-11-20', 'FULL_TIME', 'Chief Pharmacist managing central pharmacy operations.'),
('EMP013', 'Manoj',       'Verma',      'Manoj Verma',            'manoj.verma@medcareindia.com',         '9810001013', (SELECT Id FROM time.Designation WHERE DesignationCode='PHARMACIST'),   'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-01-10', 'FULL_TIME', 'Pharmacist, Outpatient Pharmacy.'),
('EMP014', 'Radha',       'Patel',      'Radha Patel',            'radha.patel@medcareindia.com',         '9810001014', (SELECT Id FROM time.Designation WHERE DesignationCode='ADMEXEC'),      'gu', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-09-01', 'FULL_TIME', 'Administrative Executive, patient records.'),
('EMP015', 'Suresh',      'Naidu',      'Suresh Naidu',           'suresh.naidu@medcareindia.com',        '9810001015', (SELECT Id FROM time.Designation WHERE DesignationCode='FRONTDESK'),    'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-02-01', 'FULL_TIME', 'Front Desk Executive, patient registration.'),
-- Delhitime.time.
('EMP016', 'Harpreet',    'Kaur',       'Dr. Harpreet Kaur',      'harpreet.kaur@medcareindia.com',       '9810002001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),  'pa', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-05-15', 'FULL_TIME', 'Medical Director, Delhi Super Specialty Hospital.'),
('EMP017', 'Nitin',       'Agarwal',    'Dr. Nitin Agarwal',      'nitin.agarwal@medcareindia.com',       '9810002002', (SELECT Id FROM time.Designation WHERE DesignationCode='SRSURGEON'),    'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-09-01', 'FULL_TIME', 'Senior Orthopedic Surgeon.'),
('EMP018', 'Pooja',       'Bhatt',      'Pooja Bhatt',            'pooja.bhatt@medcareindia.com',         '9810002003', (SELECT Id FROM time.Designation WHERE DesignationCode='SRNURSE'),      'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-03-20', 'FULL_TIME', 'Senior Staff Nurse, Delhi.'),
('EMP019', 'Kuldeep',     'Malhotra',   'Kuldeep Malhotra',       'kuldeep.malhotra@medcareindia.com',    '9810002004', (SELECT Id FROM time.Designation WHERE DesignationCode='HRBP'),         'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-07-01', 'FULL_TIME', 'HR Business Partner, North India.'),
('EMP020', 'Anita',       'Saxena',     'Dr. Anita Saxena',       'anita.saxena@medcareindia.com',        '9810002005', (SELECT Id FROM time.Designation WHERE DesignationCode='EMERPHYSICIAN'),'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-11-01', 'FULL_TIME', 'Emergency Medicine Physician, MBBS, MD Emergency.'),
-- Bengalurutime.time.
('EMP021', 'Subramaniam', 'Rajan',      'Dr. Subramaniam Rajan',  'subramaniam.rajan@medcareindia.com',   '9810003001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),  'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-01-10', 'FULL_TIME', 'Medical Director, Bengaluru Hospital.'),
('EMP022', 'Divya',       'Menon',      'Dr. Divya Menon',        'divya.menon@medcareindia.com',         '9810003002', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),   'ml', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-04-15', 'FULL_TIME', 'Consultant Neurologist.'),
('EMP023', 'Karthik',     'Sundaram',   'Karthik Sundaram',       'karthik.sundaram@medcareindia.com',    '9810003003', (SELECT Id FROM time.Designation WHERE DesignationCode='RADIOLOGIST'),  'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-06-01', 'FULL_TIME', 'Radiologist, CT & MRI specialist.'),
('EMP024', 'Ananya',      'Bose',       'Ananya Bose',            'ananya.bose@medcareindia.com',         '9810003004', (SELECT Id FROM time.Designation WHERE DesignationCode='LABTECH'),      'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-05-01', 'FULL_TIME', 'Laboratory Technician, Microbiology.'),
('EMP025', 'Prasad',      'Kulkarni',   'Prasad Kulkarni',        'prasad.kulkarni@medcareindia.com',     '9810003005', (SELECT Id FROM time.Designation WHERE DesignationCode='SYSADMIN'),     'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-10-01', 'FULL_TIME', 'Systems Administrator, EHR and network.'),
-- Chennaitime.time.
('EMP026', 'Lakshmi',     'Venkatesh',  'Dr. Lakshmi Venkatesh',  'lakshmi.venkatesh@medcareindia.com',   '9810004001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),  'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2011-08-01', 'FULL_TIME', 'Medical Director, Chennai Hospital, Oncology specialist.'),
('EMP027', 'Balachandran','Kumar',      'Dr. Balachandran Kumar', 'balachandran.kumar@medcareindia.com',  '9810004002', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),   'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-02-01', 'FULL_TIME', 'Consultant Oncologist, MBBS, MD, DM Oncology.'),
('EMP028', 'Revathi',     'Suresh',     'Revathi Suresh',         'revathi.suresh@medcareindia.com',      '9810004003', (SELECT Id FROM time.Designation WHERE DesignationCode='STAFFNURSE'),   'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-01-10', 'FULL_TIME', 'Staff Nurse, Oncology ward.'),
('EMP029', 'Murali',      'Dharan',     'Murali Dharan',          'murali.dharan@medcareindia.com',       '9810004004', (SELECT Id FROM time.Designation WHERE DesignationCode='SRPHARM'),      'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-11-01', 'FULL_TIME', 'Senior Pharmacist, Oncology drug management.'),
('EMP030', 'Sangeetha',   'Arumugam',   'Sangeetha Arumugam',     'sangeetha.arumugam@medcareindia.com',  '9810004005', (SELECT Id FROM time.Designation WHERE DesignationCode='HREXEC'),       'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-03-01', 'FULL_TIME', 'HR Executive, Chennai HR operations.'),
-- Hyderabadtime.time.
('EMP031', 'Venkat',      'Reddy',      'Dr. Venkat Reddy',       'venkat.reddy@medcareindia.com',        '9810005001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),  'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-12-01', 'FULL_TIME', 'Medical Director, Hyderabad Hospital.'),
('EMP032', 'Bhavana',     'Rao',        'Dr. Bhavana Rao',        'bhavana.rao@medcareindia.com',         '9810005002', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),   'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-09-01', 'FULL_TIME', 'Consultant Pediatrician.'),
('EMP033', 'Ravi',        'Chandra',    'Ravi Chandra',           'ravi.chandra@medcareindia.com',        '9810005003', (SELECT Id FROM time.Designation WHERE DesignationCode='RADTECH'),      'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-06-01', 'FULL_TIME', 'Radiology Technician, X-Ray and Ultrasound.'),
('EMP034', 'Padma',       'Devi',       'Padma Devi',             'padma.devi@medcareindia.com',          '9810005004', (SELECT Id FROM time.Designation WHERE DesignationCode='JRNURSE'),      'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-01-15', 'FULL_TIME', 'Junior Staff Nurse, General Ward.'),
('EMP035', 'Sunil',       'Babu',       'Sunil Babu',             'sunil.babu@medcareindia.com',          '9810005005', (SELECT Id FROM time.Designation WHERE DesignationCode='ACCOUNTANT'),   'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-08-01', 'FULL_TIME', 'Accountant, hospital billing and insurance claims.'),
-- Kolkatatime.time.
('EMP036', 'Debashish',   'Ghosh',      'Dr. Debashish Ghosh',    'debashish.ghosh@medcareindia.com',     '9810006001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),  'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-07-01', 'FULL_TIME', 'Medical Director, Kolkata Hospital.'),
('EMP037', 'Ankita',      'Chatterjee', 'Dr. Ankita Chatterjee',  'ankita.chatterjee@medcareindia.com',   '9810006002', (SELECT Id FROM time.Designation WHERE DesignationCode='PATHOLOGIST'),  'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-10-01', 'FULL_TIME', 'Pathologist, MBBS, MD Pathology.'),
('EMP038', 'Soumya',      'Das',        'Soumya Das',             'soumya.das@medcareindia.com',          '9810006003', (SELECT Id FROM time.Designation WHERE DesignationCode='STAFFNURSE'),   'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-04-01', 'FULL_TIME', 'Staff Nurse, Pathology support.'),
('EMP039', 'Tapas',       'Banerjee',   'Tapas Banerjee',         'tapas.banerjee@medcareindia.com',      '9810006004', (SELECT Id FROM time.Designation WHERE DesignationCode='OPSMGR'),       'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-05-01', 'FULL_TIME', 'Operations Manager, Kolkata Hospital.'),
('EMP040', 'Rupa',        'Mondal',     'Rupa Mondal',            'rupa.mondal@medcareindia.com',         '9810006005', (SELECT Id FROM time.Designation WHERE DesignationCode='PARAMEDICOFF'), 'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-09-01', 'FULL_TIME', 'Paramedic Officer, Emergency response.'),
-- Punetime.time.
('EMP041', 'Shyam',       'Kulkarni',   'Dr. Shyam Kulkarni',     'shyam.kulkarni@medcareindia.com',      '9810007001', (SELECT Id FROM time.Designation WHERE DesignationCode='HOPADMIN'),     'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-11-01', 'FULL_TIME', 'Hospital Administrator, Pune.'),
('EMP042', 'Namrata',     'Deshpande',  'Dr. Namrata Deshpande',  'namrata.deshpande@medcareindia.com',   '9810007002', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),   'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-02-01', 'FULL_TIME', 'Consultant Cardiologist.'),
('EMP043', 'Rohit',       'Patil',      'Rohit Patil',            'rohit.patil@medcareindia.com',         '9810007003', (SELECT Id FROM time.Designation WHERE DesignationCode='JRRESIDENT'),   'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-08-01', 'FULL_TIME', 'Junior Resident, rotating departments.'),
('EMP044', 'Ashwini',     'More',       'Ashwini More',           'ashwini.more@medcareindia.com',        '9810007004', (SELECT Id FROM time.Designation WHERE DesignationCode='STAFFNURSE'),   'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-12-01', 'FULL_TIME', 'Staff Nurse, Cardiology Ward.'),
('EMP045', 'Ganesh',      'Shinde',     'Ganesh Shinde',          'ganesh.shinde@medcareindia.com',       '9810007005', (SELECT Id FROM time.Designation WHERE DesignationCode='WARDBOY'),      'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-06-01', 'FULL_TIME', 'Ward Boy, Cardiology and General wards.');


PRINT 'Inserting EmployeeLegalEntity...';
-- Mumbai/Pune - MEDCARE-IN
INSERT INTO employee.EmployeeLegalEntity (EmployeeId, LegalEntityId, IsPrimary, StartDate) VALUES
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2012-01-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2014-03-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-06-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2013-08-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2016-02-14'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2017-04-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2018-07-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2021-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2019-03-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-06-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2014-11-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2021-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2022-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2019-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2023-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-12-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2022-06-01'),
-- Delhi/Kolkata - MEDCARE-NORTH
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2013-05-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2016-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2018-03-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2019-07-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2017-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2014-07-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2018-10-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2021-04-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2016-05-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2022-09-01'),
-- Bengaluru/Chennai/Hyderabad - MEDCARE-SOUTH
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2014-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2019-04-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2017-06-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2021-05-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2020-10-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2011-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2018-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2022-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2019-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2023-03-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2013-12-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2017-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2021-06-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2023-01-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2020-08-01');


PRINT 'Inserting EmployeeDepartment...';
INSERT INTO employee.EmployeeDepartment (EmployeeId, DepartmentId, IsPrimaryDepartment, AllocationPercentage, StartDate) VALUES
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2012-01-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-03-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2015-06-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2013-08-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, 100.00, '2016-02-14'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM time.Department WHERE DepartmentCode='FINANCE'),     1, 100.00, '2015-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),          1, 100.00, '2017-04-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2018-07-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2021-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM time.Department WHERE DepartmentCode='ICU'),         1, 100.00, '2019-03-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2020-06-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2014-11-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2021-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM time.Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2020-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM time.Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2022-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2013-05-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM time.Department WHERE DepartmentCode='ORTHOPEDICS'), 1, 100.00, '2016-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2018-03-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, 100.00, '2019-07-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM time.Department WHERE DepartmentCode='EMERGENCY'),   1, 100.00, '2017-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM time.Department WHERE DepartmentCode='NEUROLOGY'),   1, 100.00, '2019-04-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM time.Department WHERE DepartmentCode='RADIOLOGY'),   1, 100.00, '2017-06-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM time.Department WHERE DepartmentCode='PATHOLOGY'),   1, 100.00, '2021-05-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),          1, 100.00, '2020-10-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM time.Department WHERE DepartmentCode='ONCOLOGY'),    1, 100.00, '2011-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM time.Department WHERE DepartmentCode='ONCOLOGY'),    1, 100.00, '2018-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2022-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2019-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, 100.00, '2023-03-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2013-12-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM time.Department WHERE DepartmentCode='PEDIATRICS'),  1, 100.00, '2017-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM time.Department WHERE DepartmentCode='RADIOLOGY'),   1, 100.00, '2021-06-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2023-01-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM time.Department WHERE DepartmentCode='FINANCE'),     1, 100.00, '2020-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-07-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM time.Department WHERE DepartmentCode='PATHOLOGY'),   1, 100.00, '2018-10-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2021-04-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM time.Department WHERE DepartmentCode='OPERATIONS'),  1, 100.00, '2016-05-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM time.Department WHERE DepartmentCode='EMERGENCY'),   1, 100.00, '2022-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM time.Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2015-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2019-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2023-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2020-12-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM time.Department WHERE DepartmentCode='OPERATIONS'),  1, 100.00, '2022-06-01');


PRINT 'Inserting EmployeeLocation...';
INSERT INTO employee.EmployeeLocation (EmployeeId, LocationId, IsPrimaryLocation, StartDate) VALUES
-- Mumbai (EMP001-015)
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2012-01-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2014-03-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2015-06-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2013-08-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2016-02-14'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2015-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2017-04-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2018-07-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2021-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2019-03-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2020-06-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2014-11-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2021-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2020-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2022-02-01'),
-- Delhi (EMP016-020)time.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2013-05-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2016-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2018-03-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2019-07-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2017-11-01'),
-- Bengaluru (EMP021-025)time.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2014-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2019-04-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2017-06-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2021-05-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2020-10-01'),
-- Chennai (EMP026-030)time.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2011-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2018-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2022-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2019-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2023-03-01'),
-- Hyderabad (EMP031-035)time.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2013-12-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2017-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2021-06-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2023-01-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2020-08-01'),
-- Kolkata (EMP036-040)time.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2014-07-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2018-10-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2021-04-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2016-05-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2022-09-01'),
-- Pune (EMP041-045)time.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2015-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2019-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2023-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2020-12-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2022-06-01');


PRINT 'Inserting EmployeeRelationship...';
INSERT INTO employee.EmployeeRelationship (ParentEmployeeId, ChildEmployeeId, RelationshipType, DepartmentId, IsPrimaryRelationship, EffectiveFrom) VALUES
-- CMO - Medical Directors (nationwide)
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'), 1, '2014-03-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'), 1, '2013-05-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'), 1, '2014-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'), 1, '2011-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'), 1, '2013-12-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'), 1, '2014-07-01'),
-- Mumbai Medical Director - Consultants/Residentsemployee.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, '2015-06-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, '2018-07-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, '2021-08-01'),
-- CNO - Senior Nursesemployee.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='ICU'),         1, '2019-03-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, '2020-06-15'),
-- Chief Pharmacist - Pharmacistsemployee.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    1, '2021-01-10'),
-- HR Manager - HR teamemployee.
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, '2019-07-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, '2023-03-01');


PRINT 'Inserting EmployeeContact...';
INSERT INTO employee.EmployeeContact (EmployeeId, ContactType, ContactValue, IsPrimary) VALUES
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), 'WORK_PHONE',           '+91-22-40001001',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), 'PERSONAL_EMAIL',       'rajesh.sharma.personal@gmail.com',     0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), 'WORK_PHONE',           '+91-22-40001002',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), 'WORK_PHONE',           '+91-22-40001004',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'WORK_PHONE',           '+91-22-40001005',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'SLACK',                '@vikram.gupta',                        0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), 'WORK_PHONE',           '+91-22-40001007',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), 'SLACK',                '@ramesh.iyer.it',                      0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), 'WORK_PHONE',           '+91-11-40002001',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), 'WORK_PHONE',           '+91-80-40003001',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), 'WORK_PHONE',           '+91-44-40004001',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), 'WORK_PHONE',           '+91-40-40005001',                      1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), 'WORK_PHONE',           '+91-33-40006001',                      1);



-- MODULE 3: TEAM & SKILL

PRINT 'Inserting Skill...';
INSERT INTO employee.Skill (SkillName, SkillCategory, Description) VALUES
('Cardiac Surgery',                 'Clinical',     'Open heart surgery and bypass procedures'),
('Emergency Medicine',              'Clinical',     'Triage, emergency interventions'),
('ICU / Critical Care',             'Clinical',     'Intensive care and life support management'),
('Internal Medicine',               'Clinical',     'General physician skills'),
('Orthopedic Surgery',              'Clinical',     'Bone and joint surgery'),
('Oncology Treatment',              'Clinical',     'Chemotherapy and radiation planning'),
('Neurology',                       'Clinical',     'Brain and CNS diagnosis and treatment'),
('Pediatric Care',                  'Clinical',     'Neonatal and child healthcare'),
('Patient Assessment',              'Nursing',      'Vital signs, patient evaluation'),
('Wound Care',                      'Nursing',      'Dressing, post-surgical wound management'),
('IV Therapy',                      'Nursing',      'Intravenous line management'),
('Ventilator Management',           'Nursing',      'ICU ventilator handling'),
('Drug Dispensing',                 'Pharmacy',     'Medication dispensing and counseling'),
('Chemotherapy Drug Handling',      'Pharmacy',     'Oncology drug preparation and safety'),
('MRI Operation',                   'Radiology',    'MRI machine operation and safety'),
('CT Scan Operation',               'Radiology',    'CT scan imaging'),
('X-Ray Imaging',                   'Radiology',    'Digital X-Ray imaging'),
('Histopathology',                  'Pathology',    'Tissue sample analysis'),
('Microbiology Testing',            'Pathology',    'Culture and sensitivity testing'),
('Hematology',                      'Pathology',    'Blood count and smear analysis'),
('EHR / EMR Systems',               'IT',           'Electronic Health Record management'),
('Hospital Network Administration', 'IT',           'LAN, Wi-Fi, server management'),
('Medical Billing & Coding',        'Finance',      'ICD-10, insurance claims'),
('HRMS Administration',             'HR',           'HR software management'),
('Patient Transport',               'Operations',   'Ambulance and in-hospital transport'),
('Infection Control',               'Clinical',     'Hospital-acquired infection prevention'),
('BLS / ACLS Certification',        'Clinical',     'Basic and Advanced Life Support');



PRINT 'Inserting EmployeeSkill...';
INSERT INTO employee.EmployeeSkill (EmployeeId, SkillId, SkillLevel, YearsOfExperience, IsPrimarySkill) VALUES
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM employee.Skill WHERE SkillName='Cardiac Surgery'),              'Expert',       15.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM employee.Skill WHERE SkillName='BLS / ACLS Certification'),     'Expert',       15.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM employee.Skill WHERE SkillName='Internal Medicine'),            'Expert',       10.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM employee.Skill WHERE SkillName='Infection Control'),            'Advanced',      8.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM employee.Skill WHERE SkillName='Cardiac Surgery'),              'Intermediate',  3.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM employee.Skill WHERE SkillName='Patient Assessment'),           'Advanced',      3.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM employee.Skill WHERE SkillName='ICU / Critical Care'),          'Expert',       10.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM employee.Skill WHERE SkillName='Ventilator Management'),        'Expert',        9.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM employee.Skill WHERE SkillName='BLS / ACLS Certification'),    'Expert',       10.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM employee.Skill WHERE SkillName='Patient Assessment'),           'Advanced',      5.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM employee.Skill WHERE SkillName='Wound Care'),                   'Advanced',      5.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM employee.Skill WHERE SkillName='IV Therapy'),                   'Advanced',      5.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM employee.Skill WHERE SkillName='Drug Dispensing'),              'Expert',       14.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM employee.Skill WHERE SkillName='Drug Dispensing'),              'Intermediate',  4.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM employee.Skill WHERE SkillName='Orthopedic Surgery'),           'Expert',       12.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM employee.Skill WHERE SkillName='BLS / ACLS Certification'),    'Advanced',     12.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM employee.Skill WHERE SkillName='Emergency Medicine'),           'Expert',       11.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM employee.Skill WHERE SkillName='BLS / ACLS Certification'),    'Expert',       11.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM employee.Skill WHERE SkillName='Neurology'),                    'Expert',       10.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM employee.Skill WHERE SkillName='MRI Operation'),                'Expert',       10.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM employee.Skill WHERE SkillName='CT Scan Operation'),            'Expert',       10.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM employee.Skill WHERE SkillName='Microbiology Testing'),         'Intermediate',  4.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM employee.Skill WHERE SkillName='EHR / EMR Systems'),            'Advanced',      6.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM employee.Skill WHERE SkillName='Hospital Network Administration'),'Advanced',    6.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM employee.Skill WHERE SkillName='Oncology Treatment'),           'Expert',        9.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM employee.Skill WHERE SkillName='Chemotherapy Drug Handling'),   'Advanced',      8.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM employee.Skill WHERE SkillName='X-Ray Imaging'),                'Advanced',      5.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM employee.Skill WHERE SkillName='Histopathology'),               'Expert',        9.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM employee.Skill WHERE SkillName='Hematology'),                   'Expert',        9.00, 0),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM employee.Skill WHERE SkillName='Cardiac Surgery'),              'Advanced',      8.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM employee.Skill WHERE SkillName='EHR / EMR Systems'),            'Expert',       10.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM employee.Skill WHERE SkillName='Medical Billing & Coding'),     'Expert',       12.00, 1),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM employee.Skill WHERE SkillName='Medical Billing & Coding'),     'Advanced',      6.00, 1);



PRINT 'Inserting Team...';
INSERT INTO employee.Team (TeamCode, TeamName, TeamType, Description) VALUES
('TEAM-CARDIAC',    'Cardiac Care Team',            'Clinical',     'Cardiologists, cardiac surgeons, ICU nurses'),
('TEAM-EMERGENCY',  'Emergency Response Team',      'Clinical',     'Emergency physicians and paramedics'),
('TEAM-ONCOLOGY',   'Oncology Care Team',           'Clinical',     'Oncologists, chemo nurses, pharmacists'),
('TEAM-NEURO',      'Neurology Team',               'Clinical',     'Neurologists and neuro nurses'),
('TEAM-PEDS',       'Pediatric Care Team',           'Clinical',     'Pediatricians and child care nurses'),
('TEAM-RADPATH',    'Diagnostics Team',             'Diagnostics',  'Radiologists, pathologists, lab techs'),
('TEAM-PHARMCNTRL', 'Pharmacy Control Team',        'Support',      'Pharmacists and drug safety'),
('TEAM-ITOPS',      'IT Operations Team',           'Support',      'IT staff managing EHR and network'),
('TEAM-HROPS',      'HR Operations Team',           'Support',      'HR, recruitment, compliance'),
('TEAM-FINOPS',     'Finance & Billing Team',       'Support',      'Finance, billing, insurance claims');


PRINT 'Inserting EmployeeTeam...';
INSERT INTO employee.EmployeeTeam (EmployeeId, TeamId, RoleInTeam, AllocationPercentage, StartDate) VALUES
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-CARDIAC'),    'Lead Surgeon',         100.00, '2015-06-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-CARDIAC'),    'Resident',             100.00, '2021-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-CARDIAC'),    'ICU Nurse',            100.00, '2019-03-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-CARDIAC'),    'Consultant',           100.00, '2019-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-EMERGENCY'),  'Lead Physician',       100.00, '2017-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-EMERGENCY'),  'Paramedic',            100.00, '2022-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Medical Director',      50.00, '2011-08-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Consultant Oncologist',100.00, '2018-02-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Nurse',                100.00, '2022-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Pharmacist',           100.00, '2019-11-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-NEURO'),      'Lead Neurologist',     100.00, '2019-04-15'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-PEDS'),       'Lead Pediatrician',    100.00, '2017-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-RADPATH'),    'Radiologist',          100.00, '2017-06-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-RADPATH'),    'Radiology Tech',       100.00, '2021-06-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-RADPATH'),    'Pathologist',          100.00, '2018-10-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-RADPATH'),    'Lab Technician',       100.00, '2021-05-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-PHARMCNTRL'), 'Chief Pharmacist',     100.00, '2014-11-20'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-PHARMCNTRL'), 'Pharmacist',           100.00, '2021-01-10'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ITOPS'),      'IT Manager',           100.00, '2017-04-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ITOPS'),      'Sysadmin',             100.00, '2020-10-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-HROPS'),      'HR Manager',           100.00, '2016-02-14'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-HROPS'),      'HRBP',                 100.00, '2019-07-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-HROPS'),      'HR Executive',         100.00, '2023-03-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-FINOPS'),     'Finance Manager',      100.00, '2015-09-01'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-FINOPS'),     'Accountant',           100.00, '2020-08-01');



PRINT 'Inserting BiometricEmployeeMapping...';
INSERT INTO employee.BiometricEmployeeMapping (EmployeeId, BiometricDeviceId, DeviceEmployeeCode) VALUES
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-001'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-002'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-003'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-004'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-005'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-006'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-007'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-008'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-009'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-010'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-011'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-012'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-013'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-014'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-015'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-016'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-017'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-018'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-019'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-02'), 'DEV-020'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-021'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-022'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-023'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-024'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-025'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-026'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-027'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-028'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-029'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-030'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-031'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-032'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-033'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-034'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-035'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-036'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-037'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-038'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-039'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-040'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-041'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-042'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-043'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-044'),
((SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-045');


PRINT 'Employee core data inserted successfully.';
GO