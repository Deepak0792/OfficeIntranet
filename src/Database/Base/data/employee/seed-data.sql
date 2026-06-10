-- EMPLOYEE SCHEMA - Seed Data
-- Organization: MedCare India Pvt. Ltd. (India)
-- Dependencies: shared, time
-- All PKs are UNIQUEIDENTIFIER with no DEFAULT, so NEWID() is supplied on every INSERT.
-- EmployeeSkill.CreatedBy / LastUpdatedBy are INT (schema not yet migrated) - omitted.

-- ============================================================
-- MODULE 1: EMPLOYEE CORE DATA
-- ============================================================

PRINT 'Inserting System Employee...';
INSERT INTO employee.Employee (Id, EmployeeCode, FirstName, LastName, DisplayName, Email, MobileNumber, DesignationId, PreferredLanguage, PreferredTimeZoneId, DateOfJoining, AboutMe, IsSystemEmployee) VALUES
('32119FAA-D461-477F-868C-42793BEAE8F7', 'SYS000', 'System', 'User', 'System', 'system@internal.local', NULL, NULL, 'en', NULL, '2000-01-01', 'Internal system account used for automated operations. Do not modify or delete.', 1);

PRINT 'Inserting Employees...';
INSERT INTO employee.Employee (Id, EmployeeCode, FirstName, LastName, DisplayName, Email, MobileNumber, DesignationId, PreferredLanguage, PreferredTimeZoneId, DateOfJoining, EmploymentType, AboutMe) VALUES
-- Mumbai HQ
(NEWID(), 'EMP001', 'Rajesh',      'Sharma',     'Dr. Rajesh Sharma',      'rajesh.sharma@medcareindia.com',       '9810001001', (SELECT Id FROM time.Designation WHERE DesignationCode='CHMO'),          'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2012-01-15', 'FULL_TIME', 'Chief Medical Officer with 20+ years of healthcare leadership.'),
(NEWID(), 'EMP002', 'Priya',       'Nair',       'Dr. Priya Nair',         'priya.nair@medcareindia.com',          '9810001002', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),   'en', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-03-01', 'FULL_TIME', 'Medical Director specializing in hospital governance.'),
(NEWID(), 'EMP003', 'Arjun',       'Mehta',      'Dr. Arjun Mehta',        'arjun.mehta@medcareindia.com',         '9810001003', (SELECT Id FROM time.Designation WHERE DesignationCode='SRSURGEON'),     'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-06-10', 'FULL_TIME', 'Senior Cardiac Surgeon, MBBS, MS, MCh Cardiology.'),
(NEWID(), 'EMP004', 'Sunita',      'Pillai',     'Sunita Pillai',          'sunita.pillai@medcareindia.com',       '9810001004', (SELECT Id FROM time.Designation WHERE DesignationCode='CHFNURSE'),      'ml', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-08-20', 'FULL_TIME', 'Chief Nursing Officer, 18 years of nursing excellence.'),
(NEWID(), 'EMP005', 'Vikram',      'Gupta',      'Vikram Gupta',           'vikram.gupta@medcareindia.com',        '9810001005', (SELECT Id FROM time.Designation WHERE DesignationCode='HRMANAGER'),     'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-02-14', 'FULL_TIME', 'HR Manager handling all India HR operations.'),
(NEWID(), 'EMP006', 'Sneha',       'Desai',      'Sneha Desai',            'sneha.desai@medcareindia.com',         '9810001006', (SELECT Id FROM time.Designation WHERE DesignationCode='FINMANAGER'),    'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-09-01', 'FULL_TIME', 'Finance Manager overseeing hospital billing and payroll.'),
(NEWID(), 'EMP007', 'Ramesh',      'Iyer',       'Ramesh Iyer',            'ramesh.iyer@medcareindia.com',         '9810001007', (SELECT Id FROM time.Designation WHERE DesignationCode='ITMANAGER'),     'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-04-01', 'FULL_TIME', 'IT Manager managing EHR and hospital network infrastructure.'),
(NEWID(), 'EMP008', 'Kavitha',     'Rao',        'Dr. Kavitha Rao',        'kavitha.rao@medcareindia.com',         '9810001008', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),    'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-07-15', 'FULL_TIME', 'Consultant Physician, Internal Medicine.'),
(NEWID(), 'EMP009', 'Anil',        'Khanna',     'Dr. Anil Khanna',        'anil.khanna@medcareindia.com',         '9810001009', (SELECT Id FROM time.Designation WHERE DesignationCode='RESIDENTDR'),    'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-08-01', 'FULL_TIME', 'Resident Doctor, Cardiology rotation.'),
(NEWID(), 'EMP010', 'Meena',       'Joshi',      'Meena Joshi',            'meena.joshi@medcareindia.com',         '9810001010', (SELECT Id FROM time.Designation WHERE DesignationCode='SRNURSE'),       'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-03-10', 'FULL_TIME', 'Senior Staff Nurse, ICU specialist.'),
(NEWID(), 'EMP011', 'Deepak',      'Singh',      'Deepak Singh',           'deepak.singh@medcareindia.com',        '9810001011', (SELECT Id FROM time.Designation WHERE DesignationCode='STAFFNURSE'),    'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-06-15', 'FULL_TIME', 'Staff Nurse, General Ward.'),
(NEWID(), 'EMP012', 'Lalitha',     'Krishnan',   'Lalitha Krishnan',       'lalitha.krishnan@medcareindia.com',    '9810001012', (SELECT Id FROM time.Designation WHERE DesignationCode='CHIEFPHARM'),    'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-11-20', 'FULL_TIME', 'Chief Pharmacist managing central pharmacy operations.'),
(NEWID(), 'EMP013', 'Manoj',       'Verma',      'Manoj Verma',            'manoj.verma@medcareindia.com',         '9810001013', (SELECT Id FROM time.Designation WHERE DesignationCode='PHARMACIST'),    'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-01-10', 'FULL_TIME', 'Pharmacist, Outpatient Pharmacy.'),
(NEWID(), 'EMP014', 'Radha',       'Patel',      'Radha Patel',            'radha.patel@medcareindia.com',         '9810001014', (SELECT Id FROM time.Designation WHERE DesignationCode='ADMEXEC'),       'gu', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-09-01', 'FULL_TIME', 'Administrative Executive, patient records.'),
(NEWID(), 'EMP015', 'Suresh',      'Naidu',      'Suresh Naidu',           'suresh.naidu@medcareindia.com',        '9810001015', (SELECT Id FROM time.Designation WHERE DesignationCode='FRONTDESK'),     'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-02-01', 'FULL_TIME', 'Front Desk Executive, patient registration.'),
-- Delhi
(NEWID(), 'EMP016', 'Harpreet',    'Kaur',       'Dr. Harpreet Kaur',      'harpreet.kaur@medcareindia.com',       '9810002001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),   'pa', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-05-15', 'FULL_TIME', 'Medical Director, Delhi Super Specialty Hospital.'),
(NEWID(), 'EMP017', 'Nitin',       'Agarwal',    'Dr. Nitin Agarwal',      'nitin.agarwal@medcareindia.com',       '9810002002', (SELECT Id FROM time.Designation WHERE DesignationCode='SRSURGEON'),     'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-09-01', 'FULL_TIME', 'Senior Orthopedic Surgeon.'),
(NEWID(), 'EMP018', 'Pooja',       'Bhatt',      'Pooja Bhatt',            'pooja.bhatt@medcareindia.com',         '9810002003', (SELECT Id FROM time.Designation WHERE DesignationCode='SRNURSE'),       'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-03-20', 'FULL_TIME', 'Senior Staff Nurse, Delhi.'),
(NEWID(), 'EMP019', 'Kuldeep',     'Malhotra',   'Kuldeep Malhotra',       'kuldeep.malhotra@medcareindia.com',    '9810002004', (SELECT Id FROM time.Designation WHERE DesignationCode='HRBP'),          'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-07-01', 'FULL_TIME', 'HR Business Partner, North India.'),
(NEWID(), 'EMP020', 'Anita',       'Saxena',     'Dr. Anita Saxena',       'anita.saxena@medcareindia.com',        '9810002005', (SELECT Id FROM time.Designation WHERE DesignationCode='EMERPHYSICIAN'),  'hi', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-11-01', 'FULL_TIME', 'Emergency Medicine Physician, MBBS, MD Emergency.'),
-- Bengaluru
(NEWID(), 'EMP021', 'Subramaniam', 'Rajan',      'Dr. Subramaniam Rajan',  'subramaniam.rajan@medcareindia.com',   '9810003001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),   'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-01-10', 'FULL_TIME', 'Medical Director, Bengaluru Hospital.'),
(NEWID(), 'EMP022', 'Divya',       'Menon',      'Dr. Divya Menon',        'divya.menon@medcareindia.com',         '9810003002', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),    'ml', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-04-15', 'FULL_TIME', 'Consultant Neurologist.'),
(NEWID(), 'EMP023', 'Karthik',     'Sundaram',   'Karthik Sundaram',       'karthik.sundaram@medcareindia.com',    '9810003003', (SELECT Id FROM time.Designation WHERE DesignationCode='RADIOLOGIST'),   'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-06-01', 'FULL_TIME', 'Radiologist, CT & MRI specialist.'),
(NEWID(), 'EMP024', 'Ananya',      'Bose',       'Ananya Bose',            'ananya.bose@medcareindia.com',         '9810003004', (SELECT Id FROM time.Designation WHERE DesignationCode='LABTECH'),       'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-05-01', 'FULL_TIME', 'Laboratory Technician, Microbiology.'),
(NEWID(), 'EMP025', 'Prasad',      'Kulkarni',   'Prasad Kulkarni',        'prasad.kulkarni@medcareindia.com',     '9810003005', (SELECT Id FROM time.Designation WHERE DesignationCode='SYSADMIN'),      'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-10-01', 'FULL_TIME', 'Systems Administrator, EHR and network.'),
-- Chennai
(NEWID(), 'EMP026', 'Lakshmi',     'Venkatesh',  'Dr. Lakshmi Venkatesh',  'lakshmi.venkatesh@medcareindia.com',   '9810004001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),   'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2011-08-01', 'FULL_TIME', 'Medical Director, Chennai Hospital, Oncology specialist.'),
(NEWID(), 'EMP027', 'Balachandran','Kumar',       'Dr. Balachandran Kumar', 'balachandran.kumar@medcareindia.com',  '9810004002', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),    'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-02-01', 'FULL_TIME', 'Consultant Oncologist, MBBS, MD, DM Oncology.'),
(NEWID(), 'EMP028', 'Revathi',     'Suresh',     'Revathi Suresh',         'revathi.suresh@medcareindia.com',      '9810004003', (SELECT Id FROM time.Designation WHERE DesignationCode='STAFFNURSE'),    'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-01-10', 'FULL_TIME', 'Staff Nurse, Oncology ward.'),
(NEWID(), 'EMP029', 'Murali',      'Dharan',     'Murali Dharan',          'murali.dharan@medcareindia.com',       '9810004004', (SELECT Id FROM time.Designation WHERE DesignationCode='SRPHARM'),       'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-11-01', 'FULL_TIME', 'Senior Pharmacist, Oncology drug management.'),
(NEWID(), 'EMP030', 'Sangeetha',   'Arumugam',   'Sangeetha Arumugam',     'sangeetha.arumugam@medcareindia.com',  '9810004005', (SELECT Id FROM time.Designation WHERE DesignationCode='HREXEC'),        'ta', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-03-01', 'FULL_TIME', 'HR Executive, Chennai HR operations.'),
-- Hyderabad
(NEWID(), 'EMP031', 'Venkat',      'Reddy',      'Dr. Venkat Reddy',       'venkat.reddy@medcareindia.com',        '9810005001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),   'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-12-01', 'FULL_TIME', 'Medical Director, Hyderabad Hospital.'),
(NEWID(), 'EMP032', 'Bhavana',     'Rao',        'Dr. Bhavana Rao',        'bhavana.rao@medcareindia.com',         '9810005002', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),    'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-09-01', 'FULL_TIME', 'Consultant Pediatrician.'),
(NEWID(), 'EMP033', 'Ravi',        'Chandra',    'Ravi Chandra',           'ravi.chandra@medcareindia.com',        '9810005003', (SELECT Id FROM time.Designation WHERE DesignationCode='RADTECH'),       'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-06-01', 'FULL_TIME', 'Radiology Technician, X-Ray and Ultrasound.'),
(NEWID(), 'EMP034', 'Padma',       'Devi',       'Padma Devi',             'padma.devi@medcareindia.com',          '9810005004', (SELECT Id FROM time.Designation WHERE DesignationCode='JRNURSE'),       'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-01-15', 'FULL_TIME', 'Junior Staff Nurse, General Ward.'),
(NEWID(), 'EMP035', 'Sunil',       'Babu',       'Sunil Babu',             'sunil.babu@medcareindia.com',          '9810005005', (SELECT Id FROM time.Designation WHERE DesignationCode='ACCOUNTANT'),    'te', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-08-01', 'FULL_TIME', 'Accountant, hospital billing and insurance claims.'),
-- Kolkata
(NEWID(), 'EMP036', 'Debashish',   'Ghosh',      'Dr. Debashish Ghosh',    'debashish.ghosh@medcareindia.com',     '9810006001', (SELECT Id FROM time.Designation WHERE DesignationCode='MEDDIRECTOR'),   'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-07-01', 'FULL_TIME', 'Medical Director, Kolkata Hospital.'),
(NEWID(), 'EMP037', 'Ankita',      'Chatterjee', 'Dr. Ankita Chatterjee',  'ankita.chatterjee@medcareindia.com',   '9810006002', (SELECT Id FROM time.Designation WHERE DesignationCode='PATHOLOGIST'),   'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-10-01', 'FULL_TIME', 'Pathologist, MBBS, MD Pathology.'),
(NEWID(), 'EMP038', 'Soumya',      'Das',        'Soumya Das',             'soumya.das@medcareindia.com',          '9810006003', (SELECT Id FROM time.Designation WHERE DesignationCode='STAFFNURSE'),    'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-04-01', 'FULL_TIME', 'Staff Nurse, Pathology support.'),
(NEWID(), 'EMP039', 'Tapas',       'Banerjee',   'Tapas Banerjee',         'tapas.banerjee@medcareindia.com',      '9810006004', (SELECT Id FROM time.Designation WHERE DesignationCode='OPSMGR'),        'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-05-01', 'FULL_TIME', 'Operations Manager, Kolkata Hospital.'),
(NEWID(), 'EMP040', 'Rupa',        'Mondal',     'Rupa Mondal',            'rupa.mondal@medcareindia.com',         '9810006005', (SELECT Id FROM time.Designation WHERE DesignationCode='PARAMEDICOFF'),  'bn', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-09-01', 'FULL_TIME', 'Paramedic Officer, Emergency response.'),
-- Pune
(NEWID(), 'EMP041', 'Shyam',       'Kulkarni',   'Dr. Shyam Kulkarni',     'shyam.kulkarni@medcareindia.com',      '9810007001', (SELECT Id FROM time.Designation WHERE DesignationCode='HOPADMIN'),      'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-11-01', 'FULL_TIME', 'Hospital Administrator, Pune.'),
(NEWID(), 'EMP042', 'Namrata',     'Deshpande',  'Dr. Namrata Deshpande',  'namrata.deshpande@medcareindia.com',   '9810007002', (SELECT Id FROM time.Designation WHERE DesignationCode='CONSULTANT'),    'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-02-01', 'FULL_TIME', 'Consultant Cardiologist.'),
(NEWID(), 'EMP043', 'Rohit',       'Patil',      'Rohit Patil',            'rohit.patil@medcareindia.com',         '9810007003', (SELECT Id FROM time.Designation WHERE DesignationCode='JRRESIDENT'),    'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-08-01', 'FULL_TIME', 'Junior Resident, rotating departments.'),
(NEWID(), 'EMP044', 'Ashwini',     'More',       'Ashwini More',           'ashwini.more@medcareindia.com',        '9810007004', (SELECT Id FROM time.Designation WHERE DesignationCode='STAFFNURSE'),    'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-12-01', 'FULL_TIME', 'Staff Nurse, Cardiology Ward.'),
(NEWID(), 'EMP045', 'Ganesh',      'Shinde',     'Ganesh Shinde',          'ganesh.shinde@medcareindia.com',       '9810007005', (SELECT Id FROM time.Designation WHERE DesignationCode='WARDBOY'),       'mr', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-06-01', 'FULL_TIME', 'Ward Boy, Cardiology and General wards.');


-- ============================================================
-- MODULE 2: ORG ASSIGNMENTS
-- ============================================================

PRINT 'Inserting EmployeeLegalEntity...';
-- Mumbai / Pune - MEDCARE-IN
INSERT INTO employee.EmployeeLegalEntity (Id, EmployeeId, LegalEntityId, IsPrimaryLegalEntity, StartDate) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2012-01-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2014-03-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-06-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2013-08-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2016-02-14'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2017-04-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2018-07-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2021-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2019-03-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-06-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2014-11-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2021-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2022-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2019-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2023-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-12-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2022-06-01'),
-- Delhi / Kolkata - MEDCARE-NORTH
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2013-05-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2016-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2018-03-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2019-07-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2017-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2014-07-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2018-10-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2021-04-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2016-05-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2022-09-01'),
-- Bengaluru / Chennai / Hyderabad - MEDCARE-SOUTH
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2014-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2019-04-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2017-06-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2021-05-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2020-10-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2011-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2018-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2022-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2019-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2023-03-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2013-12-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2017-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2021-06-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2023-01-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2020-08-01');


PRINT 'Inserting EmployeeDepartment...';
INSERT INTO employee.EmployeeDepartment (Id, EmployeeId, DepartmentId, IsPrimaryDepartment, AllocationPercentage, StartDate) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2012-01-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-03-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2015-06-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2013-08-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, 100.00, '2016-02-14'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM time.Department WHERE DepartmentCode='FINANCE'),     1, 100.00, '2015-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),          1, 100.00, '2017-04-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2018-07-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2021-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM time.Department WHERE DepartmentCode='ICU'),         1, 100.00, '2019-03-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2020-06-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2014-11-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2021-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM time.Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2020-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM time.Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2022-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2013-05-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM time.Department WHERE DepartmentCode='ORTHOPEDICS'), 1, 100.00, '2016-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2018-03-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, 100.00, '2019-07-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM time.Department WHERE DepartmentCode='EMERGENCY'),   1, 100.00, '2017-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM time.Department WHERE DepartmentCode='NEUROLOGY'),   1, 100.00, '2019-04-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM time.Department WHERE DepartmentCode='RADIOLOGY'),   1, 100.00, '2017-06-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM time.Department WHERE DepartmentCode='PATHOLOGY'),   1, 100.00, '2021-05-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),          1, 100.00, '2020-10-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM time.Department WHERE DepartmentCode='ONCOLOGY'),    1, 100.00, '2011-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM time.Department WHERE DepartmentCode='ONCOLOGY'),    1, 100.00, '2018-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2022-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2019-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, 100.00, '2023-03-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2013-12-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM time.Department WHERE DepartmentCode='PEDIATRICS'),  1, 100.00, '2017-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM time.Department WHERE DepartmentCode='RADIOLOGY'),   1, 100.00, '2021-06-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2023-01-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM time.Department WHERE DepartmentCode='FINANCE'),     1, 100.00, '2020-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-07-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM time.Department WHERE DepartmentCode='PATHOLOGY'),   1, 100.00, '2018-10-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2021-04-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM time.Department WHERE DepartmentCode='OPERATIONS'),  1, 100.00, '2016-05-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM time.Department WHERE DepartmentCode='EMERGENCY'),   1, 100.00, '2022-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM time.Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2015-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2019-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2023-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2020-12-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM time.Department WHERE DepartmentCode='OPERATIONS'),  1, 100.00, '2022-06-01');


PRINT 'Inserting EmployeeLocation...';
INSERT INTO employee.EmployeeLocation (Id, EmployeeId, LocationId, IsPrimaryLocation, StartDate) VALUES
-- Mumbai (EMP001-015)
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2012-01-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2014-03-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2015-06-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2013-08-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2016-02-14'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2015-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2017-04-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2018-07-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2021-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2019-03-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2020-06-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2014-11-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2021-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2020-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2022-02-01'),
-- Delhi (EMP016-020)
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2013-05-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2016-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2018-03-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2019-07-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2017-11-01'),
-- Bengaluru (EMP021-025)
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2014-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2019-04-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2017-06-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2021-05-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2020-10-01'),
-- Chennai (EMP026-030)
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2011-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2018-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2022-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2019-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2023-03-01'),
-- Hyderabad (EMP031-035)
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2013-12-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2017-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2021-06-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2023-01-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2020-08-01'),
-- Kolkata (EMP036-040)
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2014-07-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2018-10-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2021-04-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2016-05-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2022-09-01'),
-- Pune (EMP041-045)
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2015-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2019-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2023-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2020-12-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2022-06-01');


PRINT 'Inserting EmployeeRelationship...';
INSERT INTO employee.EmployeeRelationship (Id, ParentEmployeeId, ChildEmployeeId, RelationshipType, DepartmentId, IsPrimaryRelationship, EffectiveFrom) VALUES
-- CMO - Medical Directors (nationwide)
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, '2014-03-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, '2013-05-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, '2014-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, '2011-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, '2013-12-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, '2014-07-01'),
-- Mumbai Medical Director - Consultants / Residents
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, '2015-06-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    1, '2018-07-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='CARDIOLOGY'),  1, '2021-08-01'),
-- CNO - Senior Nurses
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='ICU'),         1, '2019-03-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     1, '2020-06-15'),
-- Chief Pharmacist - Pharmacists
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='PHARMACY'),    1, '2021-01-10'),
-- HR Manager - HR team
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, '2019-07-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), 'DIRECT_MANAGER', (SELECT Id FROM time.Department WHERE DepartmentCode='HR'),          1, '2023-03-01');


PRINT 'Inserting EmployeeContact...';
INSERT INTO employee.EmployeeContact (Id, EmployeeId, ContactType, ContactValue, IsPrimaryContact) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), 'WORK_PHONE',     '+91-22-40001001',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), 'PERSONAL_EMAIL', 'rajesh.sharma.personal@gmail.com', 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), 'WORK_PHONE',     '+91-22-40001002',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), 'WORK_PHONE',     '+91-22-40001004',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'WORK_PHONE',     '+91-22-40001005',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), 'SLACK',          '@vikram.gupta',                    0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), 'WORK_PHONE',     '+91-22-40001007',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), 'SLACK',          '@ramesh.iyer.it',                  0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), 'WORK_PHONE',     '+91-11-40002001',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), 'WORK_PHONE',     '+91-80-40003001',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), 'WORK_PHONE',     '+91-44-40004001',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), 'WORK_PHONE',     '+91-40-40005001',                  1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), 'WORK_PHONE',     '+91-33-40006001',                  1);


-- ============================================================
-- MODULE 3: TEAM & SKILL
-- ============================================================

PRINT 'Inserting Skills...';
INSERT INTO employee.Skill (Id, SkillName, SkillCategory, Description) VALUES
(NEWID(), 'Cardiac Surgery',                 'Clinical',     'Open heart surgery and bypass procedures'),
(NEWID(), 'Emergency Medicine',              'Clinical',     'Triage, emergency interventions'),
(NEWID(), 'ICU / Critical Care',             'Clinical',     'Intensive care and life support management'),
(NEWID(), 'Internal Medicine',               'Clinical',     'General physician skills'),
(NEWID(), 'Orthopedic Surgery',              'Clinical',     'Bone and joint surgery'),
(NEWID(), 'Oncology Treatment',              'Clinical',     'Chemotherapy and radiation planning'),
(NEWID(), 'Neurology',                       'Clinical',     'Brain and CNS diagnosis and treatment'),
(NEWID(), 'Pediatric Care',                  'Clinical',     'Neonatal and child healthcare'),
(NEWID(), 'Patient Assessment',              'Nursing',      'Vital signs, patient evaluation'),
(NEWID(), 'Wound Care',                      'Nursing',      'Dressing, post-surgical wound management'),
(NEWID(), 'IV Therapy',                      'Nursing',      'Intravenous line management'),
(NEWID(), 'Ventilator Management',           'Nursing',      'ICU ventilator handling'),
(NEWID(), 'Drug Dispensing',                 'Pharmacy',     'Medication dispensing and counseling'),
(NEWID(), 'Chemotherapy Drug Handling',      'Pharmacy',     'Oncology drug preparation and safety'),
(NEWID(), 'MRI Operation',                   'Radiology',    'MRI machine operation and safety'),
(NEWID(), 'CT Scan Operation',               'Radiology',    'CT scan imaging'),
(NEWID(), 'X-Ray Imaging',                   'Radiology',    'Digital X-Ray imaging'),
(NEWID(), 'Histopathology',                  'Pathology',    'Tissue sample analysis'),
(NEWID(), 'Microbiology Testing',            'Pathology',    'Culture and sensitivity testing'),
(NEWID(), 'Hematology',                      'Pathology',    'Blood count and smear analysis'),
(NEWID(), 'EHR / EMR Systems',               'IT',           'Electronic Health Record management'),
(NEWID(), 'Hospital Network Administration', 'IT',           'LAN, Wi-Fi, server management'),
(NEWID(), 'Medical Billing & Coding',        'Finance',      'ICD-10, insurance claims'),
(NEWID(), 'HRMS Administration',             'HR',           'HR software management'),
(NEWID(), 'Patient Transport',               'Operations',   'Ambulance and in-hospital transport'),
(NEWID(), 'Infection Control',               'Clinical',     'Hospital-acquired infection prevention'),
(NEWID(), 'BLS / ACLS Certification',        'Clinical',     'Basic and Advanced Life Support');


PRINT 'Inserting EmployeeSkills...';
-- Note: EmployeeSkill.CreatedBy / LastUpdatedBy are INT in the current schema - omitted here.
INSERT INTO employee.EmployeeSkill (Id, EmployeeId, SkillId, SkillLevel, YearsOfExperience, IsPrimarySkill) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM employee.Skill WHERE SkillName='Cardiac Surgery'),               'Expert',        15.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM employee.Skill WHERE SkillName='BLS / ACLS Certification'),      'Expert',        15.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM employee.Skill WHERE SkillName='Internal Medicine'),             'Expert',        10.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM employee.Skill WHERE SkillName='Infection Control'),             'Advanced',       8.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM employee.Skill WHERE SkillName='Cardiac Surgery'),               'Intermediate',   3.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM employee.Skill WHERE SkillName='Patient Assessment'),            'Advanced',       3.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM employee.Skill WHERE SkillName='ICU / Critical Care'),           'Expert',        10.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM employee.Skill WHERE SkillName='Ventilator Management'),         'Expert',         9.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM employee.Skill WHERE SkillName='BLS / ACLS Certification'),     'Expert',        10.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM employee.Skill WHERE SkillName='Patient Assessment'),            'Advanced',       5.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM employee.Skill WHERE SkillName='Wound Care'),                    'Advanced',       5.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM employee.Skill WHERE SkillName='IV Therapy'),                    'Advanced',       5.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM employee.Skill WHERE SkillName='Drug Dispensing'),               'Expert',        14.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM employee.Skill WHERE SkillName='Drug Dispensing'),               'Intermediate',   4.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM employee.Skill WHERE SkillName='Orthopedic Surgery'),            'Expert',        12.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM employee.Skill WHERE SkillName='BLS / ACLS Certification'),     'Advanced',      12.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM employee.Skill WHERE SkillName='Emergency Medicine'),            'Expert',        11.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM employee.Skill WHERE SkillName='BLS / ACLS Certification'),     'Expert',        11.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM employee.Skill WHERE SkillName='Neurology'),                     'Expert',        10.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM employee.Skill WHERE SkillName='MRI Operation'),                 'Expert',        10.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM employee.Skill WHERE SkillName='CT Scan Operation'),             'Expert',        10.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM employee.Skill WHERE SkillName='Microbiology Testing'),          'Intermediate',   4.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM employee.Skill WHERE SkillName='EHR / EMR Systems'),             'Advanced',       6.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM employee.Skill WHERE SkillName='Hospital Network Administration'),'Advanced',      6.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM employee.Skill WHERE SkillName='Oncology Treatment'),            'Expert',         9.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM employee.Skill WHERE SkillName='Chemotherapy Drug Handling'),    'Advanced',       8.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM employee.Skill WHERE SkillName='X-Ray Imaging'),                 'Advanced',       5.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM employee.Skill WHERE SkillName='Histopathology'),                'Expert',         9.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM employee.Skill WHERE SkillName='Hematology'),                    'Expert',         9.00, 0),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM employee.Skill WHERE SkillName='Cardiac Surgery'),               'Advanced',       8.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM employee.Skill WHERE SkillName='EHR / EMR Systems'),             'Expert',        10.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM employee.Skill WHERE SkillName='Medical Billing & Coding'),      'Expert',        12.00, 1),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM employee.Skill WHERE SkillName='Medical Billing & Coding'),      'Advanced',       6.00, 1);


PRINT 'Inserting Teams...';
INSERT INTO employee.Team (Id, TeamCode, TeamName, TeamType, Description) VALUES
(NEWID(), 'TEAM-CARDIAC',    'Cardiac Care Team',        'Clinical',     'Cardiologists, cardiac surgeons, ICU nurses'),
(NEWID(), 'TEAM-EMERGENCY',  'Emergency Response Team',  'Clinical',     'Emergency physicians and paramedics'),
(NEWID(), 'TEAM-ONCOLOGY',   'Oncology Care Team',       'Clinical',     'Oncologists, chemo nurses, pharmacists'),
(NEWID(), 'TEAM-NEURO',      'Neurology Team',           'Clinical',     'Neurologists and neuro nurses'),
(NEWID(), 'TEAM-PEDS',       'Pediatric Care Team',      'Clinical',     'Pediatricians and child care nurses'),
(NEWID(), 'TEAM-RADPATH',    'Diagnostics Team',         'Diagnostics',  'Radiologists, pathologists, lab techs'),
(NEWID(), 'TEAM-PHARMCNTRL', 'Pharmacy Control Team',    'Support',      'Pharmacists and drug safety'),
(NEWID(), 'TEAM-ITOPS',      'IT Operations Team',       'Support',      'IT staff managing EHR and network'),
(NEWID(), 'TEAM-HROPS',      'HR Operations Team',       'Support',      'HR, recruitment, compliance'),
(NEWID(), 'TEAM-FINOPS',     'Finance & Billing Team',   'Support',      'Finance, billing, insurance claims');


PRINT 'Inserting EmployeeTeams...';
INSERT INTO employee.EmployeeTeam (Id, EmployeeId, TeamId, RoleInTeam, AllocationPercentage, StartDate) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-CARDIAC'),    'Lead Surgeon',          100.00, '2015-06-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-CARDIAC'),    'Resident',              100.00, '2021-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-CARDIAC'),    'ICU Nurse',             100.00, '2019-03-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-CARDIAC'),    'Consultant',            100.00, '2019-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-EMERGENCY'),  'Lead Physician',        100.00, '2017-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-EMERGENCY'),  'Paramedic',             100.00, '2022-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Medical Director',       50.00, '2011-08-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Consultant Oncologist', 100.00, '2018-02-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Nurse',                 100.00, '2022-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Pharmacist',            100.00, '2019-11-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-NEURO'),      'Lead Neurologist',      100.00, '2019-04-15'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-PEDS'),       'Lead Pediatrician',     100.00, '2017-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-RADPATH'),    'Radiologist',           100.00, '2017-06-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-RADPATH'),    'Radiology Tech',        100.00, '2021-06-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-RADPATH'),    'Pathologist',           100.00, '2018-10-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-RADPATH'),    'Lab Technician',        100.00, '2021-05-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-PHARMCNTRL'), 'Chief Pharmacist',      100.00, '2014-11-20'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-PHARMCNTRL'), 'Pharmacist',            100.00, '2021-01-10'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ITOPS'),      'IT Manager',            100.00, '2017-04-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-ITOPS'),      'Sysadmin',              100.00, '2020-10-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-HROPS'),      'HR Manager',            100.00, '2016-02-14'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-HROPS'),      'HRBP',                  100.00, '2019-07-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-HROPS'),      'HR Executive',          100.00, '2023-03-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-FINOPS'),     'Finance Manager',       100.00, '2015-09-01'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM employee.Team WHERE TeamCode='TEAM-FINOPS'),     'Accountant',            100.00, '2020-08-01');


PRINT 'Inserting EmployeeBiometricMapping...';
-- Table name: employee.EmployeeBiometricMapping (not BiometricEmployeeMapping)
INSERT INTO employee.EmployeeBiometricMapping (Id, EmployeeId, BiometricDeviceId, DeviceEmployeeCode) VALUES
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-001'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-002'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-003'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-004'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-005'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-006'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-007'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-008'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-009'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-010'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-011'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-012'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-013'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-014'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-015'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-016'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-017'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-018'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-019'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-DEL-02'), 'DEV-020'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-021'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-022'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-023'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-024'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-025'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-026'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-027'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-028'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-029'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-030'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-031'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-032'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-033'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-034'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-035'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-036'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-037'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-038'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-039'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-040'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-041'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-042'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-043'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-044'),
(NEWID(), (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM time.BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-045');


PRINT 'Employee core data inserted successfully.';
GO
