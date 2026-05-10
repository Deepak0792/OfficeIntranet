-- =============================================================================================================
-- HEALTHCARE ORGANIZATION - INDIA SEED DATA
-- Enterprise HRMS / Employee Directory - Global HR Platform
-- =============================================================================================================
-- Organization  : MedCare India Pvt. Ltd.
-- Country       : India
-- Cities        : Mumbai, Delhi, Bengaluru, Chennai, Hyderabad, Pune, Kolkata
-- Departments   : Clinical, Nursing, Pharmacy, Radiology, Pathology, Administration,
--                 HR, IT, Finance, Emergency, Operations
-- Shifts        : General (9:00-18:00), Morning (7:00-15:00), Afternoon (14:00-22:00),
--                 Night (22:00-06:00), Emergency (12 hr rotations)
-- =============================================================================================================
-- Run Order:
--   Module 1  → Master Data
--   Module 2  → Employee Core
--   Module 3  → Team & Skill
--   Module 4  → Scope (already seeded in schema, shown for reference)
--   Module 5  → Work Week Policy
--   Module 6  → Shift Management
--   Module 7  → Rotation Shift
--   Module 8  → Employee Roster (sample)
--   Module 9  → Holiday Management
--   Module 10 → Attendance
--   Module 11 → Leave Management
--   Module 12 → Comp-Off
--   Module 13 → Payroll
--   Module 14 → Biometric & Geo-Fence
-- =============================================================================================================

SET NOCOUNT ON;
BEGIN TRANSACTION;

-- =============================================================================================================
-- MODULE 1: MASTER DATA
-- =============================================================================================================
PRINT 'Inserting ScopeType...';
INSERT INTO ScopeType (ScopeCode, ScopeName, HierarchyLevel) VALUES
('GLOBAL',       'Global',       1),
('COUNTRY',      'Country',      2),
('REGION',       'Region',       3),
('LEGAL_ENTITY', 'Legal Entity', 4),
('OFFICE',       'Office',       5),
('DEPARTMENT',   'Department',   6),
('TEAM',         'Team',         7),
('EMPLOYEE',     'Employee',     8);

PRINT 'Inserting Designation...';
INSERT INTO Designation (DesignationCode, DesignationName, Grade) VALUES
('CHMO',        'Chief Medical Officer',                'L10'),
('MEDDIRECTOR', 'Medical Director',                     'L9'),
('SRSURGEON',   'Senior Consultant Surgeon',            'L8'),
('CONSULTANT',  'Consultant Physician',                 'L7'),
('RESIDENTDR',  'Resident Doctor',                      'L5'),
('JRRESIDENT',  'Junior Resident',                      'L4'),
('CHFNURSE',    'Chief Nursing Officer',                'L8'),
('SRNURSE',     'Senior Staff Nurse',                   'L5'),
('STAFFNURSE',  'Staff Nurse',                          'L4'),
('JRNURSE',     'Junior Staff Nurse',                   'L3'),
('CHIEFPHARM',  'Chief Pharmacist',                     'L7'),
('SRPHARM',     'Senior Pharmacist',                    'L5'),
('PHARMACIST',  'Pharmacist',                           'L4'),
('RADIOLOGIST', 'Radiologist',                          'L7'),
('RADTECH',     'Radiology Technician',                 'L4'),
('PATHOLOGIST', 'Pathologist',                          'L7'),
('LABTECH',     'Laboratory Technician',                'L4'),
('HOPADMIN',    'Hospital Administrator',               'L8'),
('ADMEXEC',     'Administrative Executive',             'L4'),
('FRONTDESK',   'Front Desk Executive',                 'L3'),
('HRMANAGER',   'HR Manager',                           'L7'),
('HRBP',        'HR Business Partner',                  'L5'),
('HREXEC',      'HR Executive',                         'L4'),
('ITMANAGER',   'IT Manager',                           'L7'),
('SRSYSADMIN',  'Senior Systems Administrator',         'L5'),
('SYSADMIN',    'Systems Administrator',                'L4'),
('FINMANAGER',  'Finance Manager',                      'L7'),
('ACCOUNTANT',  'Accountant',                           'L4'),
('OPSMGR',      'Operations Manager',                   'L7'),
('OPSEXEC',     'Operations Executive',                 'L4'),
('EMERPHYSICIAN','Emergency Medicine Physician',        'L7'),
('PARAMEDICOFF','Paramedic Officer',                    'L4'),
('WARDBOY',     'Ward Boy / Patient Attendant',         'L2'),
('HOUSEKEEPING','Housekeeping Supervisor',              'L3'),
('AMBULANCEDRV','Ambulance Driver',                     'L2');


PRINT 'Inserting TimeZoneMaster...';
INSERT INTO TimeZoneMaster (TimeZoneCode, TimeZoneName, UtcOffset, OffsetMinutes, SupportsDaylightSaving, WindowsTimeZoneId, IanaTimeZoneId, CountryCode) VALUES
('IST', 'India Standard Time', '+05:30', 330, 0, 'India Standard Time', 'Asia/Kolkata', 'IN');


PRINT 'Inserting Country...';
INSERT INTO Country (CountryCode, CountryName, CurrencyCode, TimeZoneId) VALUES
('IN', 'India', 'INR', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode = 'IST'));


PRINT 'Inserting LegalEntity...';
INSERT INTO LegalEntity (EntityCode, EntityName, CountryId, TaxIdentificationNumber, RegistrationNumber, CurrencyCode) VALUES
('MEDCARE-IN',      'MedCare India Pvt. Ltd.',              (SELECT Id FROM Country WHERE CountryCode='IN'), 'AABCM1234A',    'U85110MH2005PTC154321', 'INR'),
('MEDCARE-NORTH',   'MedCare North India Healthcare Ltd.',  (SELECT Id FROM Country WHERE CountryCode='IN'), 'AABCM5678B',    'U85110DL2010PTC199876', 'INR'),
('MEDCARE-SOUTH',   'MedCare South India Hospitals Pvt. Ltd.', (SELECT Id FROM Country WHERE CountryCode='IN'), 'AABCM9012C', 'U85110KA2012PTC234567', 'INR');


PRINT 'Inserting Region...';
-- States
INSERT INTO Region (CountryId, RegionName, RegionType, ParentRegionId) VALUES
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Maharashtra',      'State', NULL),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Delhi',            'State', NULL),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Karnataka',        'State', NULL),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Tamil Nadu',       'State', NULL),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Telangana',        'State', NULL),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'West Bengal',      'State', NULL);

-- Cities
INSERT INTO Region (CountryId, RegionName, RegionType, ParentRegionId) VALUES
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Mumbai',       'City', (SELECT Id FROM Region WHERE RegionName='Maharashtra')),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Pune',         'City', (SELECT Id FROM Region WHERE RegionName='Maharashtra')),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'New Delhi',    'City', (SELECT Id FROM Region WHERE RegionName='Delhi')),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Bengaluru',    'City', (SELECT Id FROM Region WHERE RegionName='Karnataka')),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Chennai',      'City', (SELECT Id FROM Region WHERE RegionName='Tamil Nadu')),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Hyderabad',    'City', (SELECT Id FROM Region WHERE RegionName='Telangana')),
((SELECT Id FROM Country WHERE CountryCode='IN'), 'Kolkata',      'City', (SELECT Id FROM Region WHERE RegionName='West Bengal'));


PRINT 'Inserting OfficeLocation...';
INSERT INTO OfficeLocation (LegalEntityId, CountryId, RegionId, LocationCode, LocationName, BuildingName, AddressLine1, City, StateProvince, PostalCode, Latitude, Longitude, TimeZoneId, IsHeadOffice) VALUES
(
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'),
    (SELECT Id FROM Country WHERE CountryCode='IN'),
    (SELECT Id FROM Region WHERE RegionName='Mumbai'),
    'LOC-MUM-HQ', 'MedCare Mumbai HQ & Hospital', 'MedCare Tower',
    'Plot 14, Bandra Kurla Complex', 'Mumbai', 'Maharashtra', '400051',
    19.0659600, 72.8684700,
    (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), 1
),
(
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'),
    (SELECT Id FROM Country WHERE CountryCode='IN'),
    (SELECT Id FROM Region WHERE RegionName='Pune'),
    'LOC-PUN-01', 'MedCare Pune Hospital', 'Koregaon Medical Complex',
    'Survey No. 55, Koregaon Park', 'Pune', 'Maharashtra', '411001',
    18.5314100, 73.8936400,
    (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'),
    (SELECT Id FROM Country WHERE CountryCode='IN'),
    (SELECT Id FROM Region WHERE RegionName='New Delhi'),
    'LOC-DEL-01', 'MedCare Delhi Super Specialty Hospital', 'MedCare Delhi Block',
    'A-12, Sector 62, Noida Adjacent', 'New Delhi', 'Delhi', '110001',
    28.6270100, 77.2186000,
    (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    (SELECT Id FROM Country WHERE CountryCode='IN'),
    (SELECT Id FROM Region WHERE RegionName='Bengaluru'),
    'LOC-BLR-01', 'MedCare Bengaluru Hospital', 'Whitefield Medical Hub',
    '48, EPIP Zone, Whitefield', 'Bengaluru', 'Karnataka', '560066',
    12.9716000, 77.5946000,
    (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    (SELECT Id FROM Country WHERE CountryCode='IN'),
    (SELECT Id FROM Region WHERE RegionName='Chennai'),
    'LOC-CHN-01', 'MedCare Chennai Multi-Specialty Hospital', 'Perambur Health City',
    '22, Anna Salai, Perambur', 'Chennai', 'Tamil Nadu', '600011',
    13.0827400, 80.2707200,
    (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    (SELECT Id FROM Country WHERE CountryCode='IN'),
    (SELECT Id FROM Region WHERE RegionName='Hyderabad'),
    'LOC-HYD-01', 'MedCare Hyderabad Hospital', 'HITEC Health Park',
    '8-2-268/A, Road No. 3, Banjara Hills', 'Hyderabad', 'Telangana', '500034',
    17.3850000, 78.4867000,
    (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'),
    (SELECT Id FROM Country WHERE CountryCode='IN'),
    (SELECT Id FROM Region WHERE RegionName='Kolkata'),
    'LOC-KOL-01', 'MedCare Kolkata Diagnostic & Hospital', 'Salt Lake Medical Tower',
    'Block CD-52, Sector 1, Salt Lake City', 'Kolkata', 'West Bengal', '700064',
    22.5726000, 88.3639000,
    (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), 0
);


PRINT 'Inserting Department...';
INSERT INTO Department (DepartmentCode, DepartmentName, ParentDepartmentId, Description) VALUES
('CLINICAL',    'Clinical Services',        NULL, 'All clinical and patient-care departments'),
('NURSING',     'Nursing Services',         NULL, 'Nursing operations and ward management'),
('PHARMACY',    'Pharmacy',                 NULL, 'Drug dispensing and management'),
('DIAGNOSTICS', 'Diagnostics',              NULL, 'Radiology, Pathology and Lab Services'),
('EMERGENCY',   'Emergency & Trauma',       NULL, 'Emergency medicine and trauma care'),
('ADMIN',       'Administration',           NULL, 'Hospital administration and front desk'),
('HR',          'Human Resources',          NULL, 'HR operations, recruitment and compliance'),
('IT',          'Information Technology',   NULL, 'Hospital IT systems, EHR, network'),
('FINANCE',     'Finance & Accounts',       NULL, 'Billing, payroll, financial control'),
('OPERATIONS',  'Operations',               NULL, 'Housekeeping, facilities, transport'),
('SURGERY',     'Surgery',                  NULL, 'General and specialized surgical services')
-- Sub-departments
INSERT INTO Department (DepartmentCode, DepartmentName, ParentDepartmentId, Description) VALUES
('CARDIOLOGY',  'Cardiology',       (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),   'Heart and cardiovascular services'),
('ORTHOPEDICS', 'Orthopedics',      (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),   'Bone, joint and musculoskeletal care'),
('PEDIATRICS',  'Pediatrics',       (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),   'Child and neonatal care'),
('ONCOLOGY',    'Oncology',         (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),   'Cancer diagnosis and treatment'),
('NEUROLOGY',   'Neurology',        (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),   'Brain and nervous system care'),
('RADIOLOGY',   'Radiology',        (SELECT Id FROM Department WHERE DepartmentCode='DIAGNOSTICS'),'X-Ray, MRI, CT Scan services'),
('PATHOLOGY',   'Pathology & Lab',  (SELECT Id FROM Department WHERE DepartmentCode='DIAGNOSTICS'),'Blood tests, biopsies, cultures'),
('ICU',         'Intensive Care Unit', (SELECT Id FROM Department WHERE DepartmentCode='NURSING'), 'Critical care nursing');


PRINT 'Inserting RelationshipType...';
INSERT INTO RelationshipType (RelationshipName, Description) VALUES
('Direct Manager',       'Primary reporting manager'),
('Dotted-Line Manager',  'Secondary or matrix reporting manager'),
('Department Head',      'Head of department oversight'),
('Mentor',               'Professional mentorship relationship'),
('HOD',                  'Head of Department');


PRINT 'Inserting DocumentType...';
INSERT INTO DocumentType (DocumentTypeCode, DocumentTypeName, Description, IsMandatory) VALUES
('AADHAAR',     'Aadhaar Card',                 'Government-issued biometric identity card',     1),
('PAN',         'PAN Card',                     'Permanent Account Number for taxation',         1),
('PASSPORT',    'Passport',                     'International travel document',                 0),
('MEDLICENSE',  'Medical License / MCI Reg.',   'Medical Council of India registration',         1),
('NURSINGREG',  'Nursing Council Registration', 'State/National Nursing Council certificate',   1),
('PHARMLICENSE','Pharmacy License',             'State Pharmacy Council registration',           1),
('OFFLETTER',   'Offer Letter',                 'Signed employment offer letter',               1),
('JOININGFORM', 'Joining Form',                 'Employee joining and declaration form',         1),
('EDUCATIONCERT','Educational Certificates',   'Degree/diploma certificates',                  1),
('PREVEXPLETT', 'Previous Experience Letter',   'Relieving/experience letter from prior employer', 0),
('BANKDETAILS', 'Bank Account Details',         'Cancelled cheque or bank passbook',            1),
('COVIDVACC',   'COVID-19 Vaccination Certificate', 'Full vaccination proof',                   1);


-- =============================================================================================================
-- MODULE 2: EMPLOYEE CORE
-- =============================================================================================================

PRINT 'Inserting Employee...';
INSERT INTO Employee (EmployeeCode, FirstName, LastName, DisplayName, Email, MobileNumber, DesignationId, PreferredLanguage, PreferredTimeZoneId, DateOfJoining, EmploymentType, AboutMe) VALUES
-- Mumbai HQ
('EMP001', 'Rajesh',      'Sharma',     'Dr. Rajesh Sharma',      'rajesh.sharma@medcareindia.com',       '9810001001', (SELECT Id FROM Designation WHERE DesignationCode='CHMO'),         'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2012-01-15', 'Full-Time', 'Chief Medical Officer with 20+ years of healthcare leadership.'),
('EMP002', 'Priya',       'Nair',       'Dr. Priya Nair',         'priya.nair@medcareindia.com',          '9810001002', (SELECT Id FROM Designation WHERE DesignationCode='MEDDIRECTOR'),   'en', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-03-01', 'Full-Time', 'Medical Director specializing in hospital governance.'),
('EMP003', 'Arjun',       'Mehta',      'Dr. Arjun Mehta',        'arjun.mehta@medcareindia.com',         '9810001003', (SELECT Id FROM Designation WHERE DesignationCode='SRSURGEON'),     'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-06-10', 'Full-Time', 'Senior Cardiac Surgeon, MBBS, MS, MCh Cardiology.'),
('EMP004', 'Sunita',      'Pillai',     'Sunita Pillai',          'sunita.pillai@medcareindia.com',       '9810001004', (SELECT Id FROM Designation WHERE DesignationCode='CHFNURSE'),      'ml', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-08-20', 'Full-Time', 'Chief Nursing Officer, 18 years of nursing excellence.'),
('EMP005', 'Vikram',      'Gupta',      'Vikram Gupta',           'vikram.gupta@medcareindia.com',        '9810001005', (SELECT Id FROM Designation WHERE DesignationCode='HRMANAGER'),     'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-02-14', 'Full-Time', 'HR Manager handling all India HR operations.'),
('EMP006', 'Sneha',       'Desai',      'Sneha Desai',            'sneha.desai@medcareindia.com',         '9810001006', (SELECT Id FROM Designation WHERE DesignationCode='FINMANAGER'),    'mr', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-09-01', 'Full-Time', 'Finance Manager overseeing hospital billing and payroll.'),
('EMP007', 'Ramesh',      'Iyer',       'Ramesh Iyer',            'ramesh.iyer@medcareindia.com',         '9810001007', (SELECT Id FROM Designation WHERE DesignationCode='ITMANAGER'),     'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-04-01', 'Full-Time', 'IT Manager managing EHR and hospital network infrastructure.'),
('EMP008', 'Kavitha',     'Rao',        'Dr. Kavitha Rao',        'kavitha.rao@medcareindia.com',         '9810001008', (SELECT Id FROM Designation WHERE DesignationCode='CONSULTANT'),    'te', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-07-15', 'Full-Time', 'Consultant Physician, Internal Medicine.'),
('EMP009', 'Anil',        'Khanna',     'Dr. Anil Khanna',        'anil.khanna@medcareindia.com',         '9810001009', (SELECT Id FROM Designation WHERE DesignationCode='RESIDENTDR'),   'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-08-01', 'Full-Time', 'Resident Doctor, Cardiology rotation.'),
('EMP010', 'Meena',       'Joshi',      'Meena Joshi',            'meena.joshi@medcareindia.com',         '9810001010', (SELECT Id FROM Designation WHERE DesignationCode='SRNURSE'),      'mr', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-03-10', 'Full-Time', 'Senior Staff Nurse, ICU specialist.'),
('EMP011', 'Deepak',      'Singh',      'Deepak Singh',           'deepak.singh@medcareindia.com',        '9810001011', (SELECT Id FROM Designation WHERE DesignationCode='STAFFNURSE'),   'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-06-15', 'Full-Time', 'Staff Nurse, General Ward.'),
('EMP012', 'Lalitha',     'Krishnan',   'Lalitha Krishnan',       'lalitha.krishnan@medcareindia.com',    '9810001012', (SELECT Id FROM Designation WHERE DesignationCode='CHIEFPHARM'),   'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-11-20', 'Full-Time', 'Chief Pharmacist managing central pharmacy operations.'),
('EMP013', 'Manoj',       'Verma',      'Manoj Verma',            'manoj.verma@medcareindia.com',         '9810001013', (SELECT Id FROM Designation WHERE DesignationCode='PHARMACIST'),   'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-01-10', 'Full-Time', 'Pharmacist, Outpatient Pharmacy.'),
('EMP014', 'Radha',       'Patel',      'Radha Patel',            'radha.patel@medcareindia.com',         '9810001014', (SELECT Id FROM Designation WHERE DesignationCode='ADMEXEC'),      'gu', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-09-01', 'Full-Time', 'Administrative Executive, patient records.'),
('EMP015', 'Suresh',      'Naidu',      'Suresh Naidu',           'suresh.naidu@medcareindia.com',        '9810001015', (SELECT Id FROM Designation WHERE DesignationCode='FRONTDESK'),    'te', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-02-01', 'Full-Time', 'Front Desk Executive, patient registration.'),
-- Delhi
('EMP016', 'Harpreet',    'Kaur',       'Dr. Harpreet Kaur',      'harpreet.kaur@medcareindia.com',       '9810002001', (SELECT Id FROM Designation WHERE DesignationCode='MEDDIRECTOR'),  'pa', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-05-15', 'Full-Time', 'Medical Director, Delhi Super Specialty Hospital.'),
('EMP017', 'Nitin',       'Agarwal',    'Dr. Nitin Agarwal',      'nitin.agarwal@medcareindia.com',       '9810002002', (SELECT Id FROM Designation WHERE DesignationCode='SRSURGEON'),    'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-09-01', 'Full-Time', 'Senior Orthopedic Surgeon.'),
('EMP018', 'Pooja',       'Bhatt',      'Pooja Bhatt',            'pooja.bhatt@medcareindia.com',         '9810002003', (SELECT Id FROM Designation WHERE DesignationCode='SRNURSE'),      'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-03-20', 'Full-Time', 'Senior Staff Nurse, Delhi.'),
('EMP019', 'Kuldeep',     'Malhotra',   'Kuldeep Malhotra',       'kuldeep.malhotra@medcareindia.com',    '9810002004', (SELECT Id FROM Designation WHERE DesignationCode='HRBP'),         'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-07-01', 'Full-Time', 'HR Business Partner, North India.'),
('EMP020', 'Anita',       'Saxena',     'Dr. Anita Saxena',       'anita.saxena@medcareindia.com',        '9810002005', (SELECT Id FROM Designation WHERE DesignationCode='EMERPHYSICIAN'),'hi', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-11-01', 'Full-Time', 'Emergency Medicine Physician, MBBS, MD Emergency.'),
-- Bengaluru
('EMP021', 'Subramaniam', 'Rajan',      'Dr. Subramaniam Rajan',  'subramaniam.rajan@medcareindia.com',   '9810003001', (SELECT Id FROM Designation WHERE DesignationCode='MEDDIRECTOR'),  'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-01-10', 'Full-Time', 'Medical Director, Bengaluru Hospital.'),
('EMP022', 'Divya',       'Menon',      'Dr. Divya Menon',        'divya.menon@medcareindia.com',         '9810003002', (SELECT Id FROM Designation WHERE DesignationCode='CONSULTANT'),   'ml', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-04-15', 'Full-Time', 'Consultant Neurologist.'),
('EMP023', 'Karthik',     'Sundaram',   'Karthik Sundaram',       'karthik.sundaram@medcareindia.com',    '9810003003', (SELECT Id FROM Designation WHERE DesignationCode='RADIOLOGIST'),  'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-06-01', 'Full-Time', 'Radiologist, CT & MRI specialist.'),
('EMP024', 'Ananya',      'Bose',       'Ananya Bose',            'ananya.bose@medcareindia.com',         '9810003004', (SELECT Id FROM Designation WHERE DesignationCode='LABTECH'),      'bn', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-05-01', 'Full-Time', 'Laboratory Technician, Microbiology.'),
('EMP025', 'Prasad',      'Kulkarni',   'Prasad Kulkarni',        'prasad.kulkarni@medcareindia.com',     '9810003005', (SELECT Id FROM Designation WHERE DesignationCode='SYSADMIN'),     'mr', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-10-01', 'Full-Time', 'Systems Administrator, EHR and network.'),
-- Chennai
('EMP026', 'Lakshmi',     'Venkatesh',  'Dr. Lakshmi Venkatesh',  'lakshmi.venkatesh@medcareindia.com',   '9810004001', (SELECT Id FROM Designation WHERE DesignationCode='MEDDIRECTOR'),  'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2011-08-01', 'Full-Time', 'Medical Director, Chennai Hospital, Oncology specialist.'),
('EMP027', 'Balachandran','Kumar',      'Dr. Balachandran Kumar', 'balachandran.kumar@medcareindia.com',  '9810004002', (SELECT Id FROM Designation WHERE DesignationCode='CONSULTANT'),   'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-02-01', 'Full-Time', 'Consultant Oncologist, MBBS, MD, DM Oncology.'),
('EMP028', 'Revathi',     'Suresh',     'Revathi Suresh',         'revathi.suresh@medcareindia.com',      '9810004003', (SELECT Id FROM Designation WHERE DesignationCode='STAFFNURSE'),   'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-01-10', 'Full-Time', 'Staff Nurse, Oncology ward.'),
('EMP029', 'Murali',      'Dharan',     'Murali Dharan',          'murali.dharan@medcareindia.com',       '9810004004', (SELECT Id FROM Designation WHERE DesignationCode='SRPHARM'),      'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-11-01', 'Full-Time', 'Senior Pharmacist, Oncology drug management.'),
('EMP030', 'Sangeetha',   'Arumugam',   'Sangeetha Arumugam',     'sangeetha.arumugam@medcareindia.com',  '9810004005', (SELECT Id FROM Designation WHERE DesignationCode='HREXEC'),       'ta', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-03-01', 'Full-Time', 'HR Executive, Chennai HR operations.'),
-- Hyderabad
('EMP031', 'Venkat',      'Reddy',      'Dr. Venkat Reddy',       'venkat.reddy@medcareindia.com',        '9810005001', (SELECT Id FROM Designation WHERE DesignationCode='MEDDIRECTOR'),  'te', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2013-12-01', 'Full-Time', 'Medical Director, Hyderabad Hospital.'),
('EMP032', 'Bhavana',     'Rao',        'Dr. Bhavana Rao',        'bhavana.rao@medcareindia.com',         '9810005002', (SELECT Id FROM Designation WHERE DesignationCode='CONSULTANT'),   'te', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2017-09-01', 'Full-Time', 'Consultant Pediatrician.'),
('EMP033', 'Ravi',        'Chandra',    'Ravi Chandra',           'ravi.chandra@medcareindia.com',        '9810005003', (SELECT Id FROM Designation WHERE DesignationCode='RADTECH'),      'te', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-06-01', 'Full-Time', 'Radiology Technician, X-Ray and Ultrasound.'),
('EMP034', 'Padma',       'Devi',       'Padma Devi',             'padma.devi@medcareindia.com',          '9810005004', (SELECT Id FROM Designation WHERE DesignationCode='JRNURSE'),      'te', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-01-15', 'Full-Time', 'Junior Staff Nurse, General Ward.'),
('EMP035', 'Sunil',       'Babu',       'Sunil Babu',             'sunil.babu@medcareindia.com',          '9810005005', (SELECT Id FROM Designation WHERE DesignationCode='ACCOUNTANT'),   'te', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-08-01', 'Full-Time', 'Accountant, hospital billing and insurance claims.'),
-- Kolkata
('EMP036', 'Debashish',   'Ghosh',      'Dr. Debashish Ghosh',    'debashish.ghosh@medcareindia.com',     '9810006001', (SELECT Id FROM Designation WHERE DesignationCode='MEDDIRECTOR'),  'bn', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2014-07-01', 'Full-Time', 'Medical Director, Kolkata Hospital.'),
('EMP037', 'Ankita',      'Chatterjee', 'Dr. Ankita Chatterjee',  'ankita.chatterjee@medcareindia.com',   '9810006002', (SELECT Id FROM Designation WHERE DesignationCode='PATHOLOGIST'),  'bn', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2018-10-01', 'Full-Time', 'Pathologist, MBBS, MD Pathology.'),
('EMP038', 'Soumya',      'Das',        'Soumya Das',             'soumya.das@medcareindia.com',          '9810006003', (SELECT Id FROM Designation WHERE DesignationCode='STAFFNURSE'),   'bn', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2021-04-01', 'Full-Time', 'Staff Nurse, Pathology support.'),
('EMP039', 'Tapas',       'Banerjee',   'Tapas Banerjee',         'tapas.banerjee@medcareindia.com',      '9810006004', (SELECT Id FROM Designation WHERE DesignationCode='OPSMGR'),       'bn', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2016-05-01', 'Full-Time', 'Operations Manager, Kolkata Hospital.'),
('EMP040', 'Rupa',        'Mondal',     'Rupa Mondal',            'rupa.mondal@medcareindia.com',         '9810006005', (SELECT Id FROM Designation WHERE DesignationCode='PARAMEDICOFF'), 'bn', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-09-01', 'Full-Time', 'Paramedic Officer, Emergency response.'),
-- Pune
('EMP041', 'Shyam',       'Kulkarni',   'Dr. Shyam Kulkarni',     'shyam.kulkarni@medcareindia.com',      '9810007001', (SELECT Id FROM Designation WHERE DesignationCode='HOPADMIN'),     'mr', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2015-11-01', 'Full-Time', 'Hospital Administrator, Pune.'),
('EMP042', 'Namrata',     'Deshpande',  'Dr. Namrata Deshpande',  'namrata.deshpande@medcareindia.com',   '9810007002', (SELECT Id FROM Designation WHERE DesignationCode='CONSULTANT'),   'mr', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2019-02-01', 'Full-Time', 'Consultant Cardiologist.'),
('EMP043', 'Rohit',       'Patil',      'Rohit Patil',            'rohit.patil@medcareindia.com',         '9810007003', (SELECT Id FROM Designation WHERE DesignationCode='JRRESIDENT'),   'mr', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2023-08-01', 'Full-Time', 'Junior Resident, rotating departments.'),
('EMP044', 'Ashwini',     'More',       'Ashwini More',           'ashwini.more@medcareindia.com',        '9810007004', (SELECT Id FROM Designation WHERE DesignationCode='STAFFNURSE'),   'mr', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2020-12-01', 'Full-Time', 'Staff Nurse, Cardiology Ward.'),
('EMP045', 'Ganesh',      'Shinde',     'Ganesh Shinde',          'ganesh.shinde@medcareindia.com',       '9810007005', (SELECT Id FROM Designation WHERE DesignationCode='WARDBOY'),      'mr', (SELECT Id FROM TimeZoneMaster WHERE TimeZoneCode='IST'), '2022-06-01', 'Full-Time', 'Ward Boy, Cardiology and General wards.');


PRINT 'Inserting EmployeeLegalEntity...';
-- Mumbai/Pune → MEDCARE-IN
INSERT INTO EmployeeLegalEntity (EmployeeId, LegalEntityId, IsPrimary, StartDate) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2012-01-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2014-03-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-06-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2013-08-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2016-02-14'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2017-04-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2018-07-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2021-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2019-03-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-06-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2014-11-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2021-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2022-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2015-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2019-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2023-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2020-12-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-IN'), 1, '2022-06-01'),
-- Delhi/Kolkata → MEDCARE-NORTH
((SELECT Id FROM Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2013-05-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2016-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2018-03-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2019-07-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2017-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2014-07-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2018-10-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2021-04-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2016-05-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-NORTH'), 1, '2022-09-01'),
-- Bengaluru/Chennai/Hyderabad → MEDCARE-SOUTH
((SELECT Id FROM Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2014-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2019-04-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2017-06-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2021-05-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2020-10-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2011-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2018-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2022-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2019-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2023-03-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2013-12-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2017-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2021-06-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2023-01-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM LegalEntity WHERE EntityCode='MEDCARE-SOUTH'), 1, '2020-08-01');


PRINT 'Inserting EmployeeDepartment...';
INSERT INTO EmployeeDepartment (EmployeeId, DepartmentId, IsPrimaryDepartment, AllocationPercentage, StartDate) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2012-01-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-03-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2015-06-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2013-08-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM Department WHERE DepartmentCode='HR'),          1, 100.00, '2016-02-14'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM Department WHERE DepartmentCode='FINANCE'),     1, 100.00, '2015-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM Department WHERE DepartmentCode='IT'),          1, 100.00, '2017-04-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2018-07-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2021-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM Department WHERE DepartmentCode='ICU'),         1, 100.00, '2019-03-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2020-06-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2014-11-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2021-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2020-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2022-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2013-05-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM Department WHERE DepartmentCode='ORTHOPEDICS'), 1, 100.00, '2016-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2018-03-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM Department WHERE DepartmentCode='HR'),          1, 100.00, '2019-07-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM Department WHERE DepartmentCode='EMERGENCY'),   1, 100.00, '2017-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM Department WHERE DepartmentCode='NEUROLOGY'),   1, 100.00, '2019-04-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM Department WHERE DepartmentCode='RADIOLOGY'),   1, 100.00, '2017-06-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM Department WHERE DepartmentCode='PATHOLOGY'),   1, 100.00, '2021-05-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM Department WHERE DepartmentCode='IT'),          1, 100.00, '2020-10-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM Department WHERE DepartmentCode='ONCOLOGY'),    1, 100.00, '2011-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM Department WHERE DepartmentCode='ONCOLOGY'),    1, 100.00, '2018-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2022-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM Department WHERE DepartmentCode='PHARMACY'),    1, 100.00, '2019-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM Department WHERE DepartmentCode='HR'),          1, 100.00, '2023-03-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2013-12-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM Department WHERE DepartmentCode='PEDIATRICS'),  1, 100.00, '2017-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM Department WHERE DepartmentCode='RADIOLOGY'),   1, 100.00, '2021-06-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2023-01-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM Department WHERE DepartmentCode='FINANCE'),     1, 100.00, '2020-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2014-07-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM Department WHERE DepartmentCode='PATHOLOGY'),   1, 100.00, '2018-10-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2021-04-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM Department WHERE DepartmentCode='OPERATIONS'),  1, 100.00, '2016-05-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM Department WHERE DepartmentCode='EMERGENCY'),   1, 100.00, '2022-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM Department WHERE DepartmentCode='ADMIN'),       1, 100.00, '2015-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM Department WHERE DepartmentCode='CARDIOLOGY'),  1, 100.00, '2019-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, 100.00, '2023-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),     1, 100.00, '2020-12-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM Department WHERE DepartmentCode='OPERATIONS'),  1, 100.00, '2022-06-01');


PRINT 'Inserting EmployeeLocation...';
INSERT INTO EmployeeLocation (EmployeeId, LocationId, IsPrimaryLocation, StartDate) VALUES
-- Mumbai (EMP001-015)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2012-01-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2014-03-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2015-06-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2013-08-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2016-02-14'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2015-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2017-04-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2018-07-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2021-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2019-03-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2020-06-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2014-11-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2021-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2020-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), 1, '2022-02-01'),
-- Delhi (EMP016-020)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2013-05-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2016-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2018-03-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2019-07-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'), 1, '2017-11-01'),
-- Bengaluru (EMP021-025)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2014-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2019-04-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2017-06-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2021-05-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01'), 1, '2020-10-01'),
-- Chennai (EMP026-030)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2011-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2018-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2022-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2019-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-CHN-01'), 1, '2023-03-01'),
-- Hyderabad (EMP031-035)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2013-12-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2017-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2021-06-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2023-01-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01'), 1, '2020-08-01'),
-- Kolkata (EMP036-040)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2014-07-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2018-10-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2021-04-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2016-05-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-KOL-01'), 1, '2022-09-01'),
-- Pune (EMP041-045)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2015-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2019-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2023-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2020-12-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01'), 1, '2022-06-01');


PRINT 'Inserting EmployeeRelationship...';
INSERT INTO EmployeeRelationship (ParentEmployeeId, ChildEmployeeId, RelationshipTypeId, DepartmentId, IsPrimaryRelationship, EffectiveFrom) VALUES
-- CMO → Medical Directors (nationwide)
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'), 1, '2014-03-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'), 1, '2013-05-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'), 1, '2014-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'), 1, '2011-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'), 1, '2013-12-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'), 1, '2014-07-01'),
-- Mumbai Medical Director → Consultants/Residents
((SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CARDIOLOGY'),  1, '2015-06-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    1, '2018-07-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='CARDIOLOGY'),  1, '2021-08-01'),
-- CNO → Senior Nurses
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='ICU'),         1, '2019-03-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),     1, '2020-06-15'),
-- Chief Pharmacist → Pharmacists
((SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='PHARMACY'),    1, '2021-01-10'),
-- HR Manager → HR team
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='HR'),          1, '2019-07-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM RelationshipType WHERE RelationshipName='Direct Manager'), (SELECT Id FROM Department WHERE DepartmentCode='HR'),          1, '2023-03-01');


PRINT 'Inserting EmployeeContact...';
INSERT INTO EmployeeContact (EmployeeId, ContactType, ContactValue, IsPrimary) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), 'WorkPhone',    '+91-22-40001001', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), 'PersonalEmail','rajesh.sharma.personal@gmail.com', 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), 'WorkPhone',    '+91-22-40001002', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), 'WorkPhone',    '+91-22-40001004', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'WorkPhone',    '+91-22-40001005', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 'Slack',        '@vikram.gupta',    0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), 'WorkPhone',    '+91-22-40001007', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), 'Slack',        '@ramesh.iyer.it',  0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP016'), 'WorkPhone',    '+91-11-40002001', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP021'), 'WorkPhone',    '+91-80-40003001', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP026'), 'WorkPhone',    '+91-44-40004001', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP031'), 'WorkPhone',    '+91-40-40005001', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP036'), 'WorkPhone',    '+91-33-40006001', 1);


-- =============================================================================================================
-- MODULE 3: TEAM & SKILL
-- =============================================================================================================

PRINT 'Inserting Skill...';
INSERT INTO Skill (SkillName, SkillCategory, Description) VALUES
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


PRINT 'Inserting Team...';
INSERT INTO Team (TeamCode, TeamName, TeamType, Description) VALUES
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
INSERT INTO EmployeeTeam (EmployeeId, TeamId, RoleInTeam, AllocationPercentage, StartDate) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM Team WHERE TeamCode='TEAM-CARDIAC'),    'Lead Surgeon',         100.00, '2015-06-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM Team WHERE TeamCode='TEAM-CARDIAC'),    'Resident',             100.00, '2021-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM Team WHERE TeamCode='TEAM-CARDIAC'),    'ICU Nurse',            100.00, '2019-03-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM Team WHERE TeamCode='TEAM-CARDIAC'),    'Consultant',           100.00, '2019-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM Team WHERE TeamCode='TEAM-EMERGENCY'),  'Lead Physician',       100.00, '2017-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM Team WHERE TeamCode='TEAM-EMERGENCY'),  'Paramedic',            100.00, '2022-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Medical Director',      50.00, '2011-08-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Consultant Oncologist',100.00, '2018-02-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Nurse',                100.00, '2022-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM Team WHERE TeamCode='TEAM-ONCOLOGY'),   'Pharmacist',           100.00, '2019-11-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM Team WHERE TeamCode='TEAM-NEURO'),      'Lead Neurologist',     100.00, '2019-04-15'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM Team WHERE TeamCode='TEAM-PEDS'),       'Lead Pediatrician',    100.00, '2017-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM Team WHERE TeamCode='TEAM-RADPATH'),    'Radiologist',          100.00, '2017-06-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM Team WHERE TeamCode='TEAM-RADPATH'),    'Radiology Tech',       100.00, '2021-06-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM Team WHERE TeamCode='TEAM-RADPATH'),    'Pathologist',          100.00, '2018-10-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM Team WHERE TeamCode='TEAM-RADPATH'),    'Lab Technician',       100.00, '2021-05-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM Team WHERE TeamCode='TEAM-PHARMCNTRL'), 'Chief Pharmacist',     100.00, '2014-11-20'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM Team WHERE TeamCode='TEAM-PHARMCNTRL'), 'Pharmacist',           100.00, '2021-01-10'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM Team WHERE TeamCode='TEAM-ITOPS'),      'IT Manager',           100.00, '2017-04-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM Team WHERE TeamCode='TEAM-ITOPS'),      'Sysadmin',             100.00, '2020-10-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM Team WHERE TeamCode='TEAM-HROPS'),      'HR Manager',           100.00, '2016-02-14'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM Team WHERE TeamCode='TEAM-HROPS'),      'HRBP',                 100.00, '2019-07-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM Team WHERE TeamCode='TEAM-HROPS'),      'HR Executive',         100.00, '2023-03-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM Team WHERE TeamCode='TEAM-FINOPS'),     'Finance Manager',      100.00, '2015-09-01'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM Team WHERE TeamCode='TEAM-FINOPS'),     'Accountant',           100.00, '2020-08-01');


PRINT 'Inserting EmployeeSkill...';
INSERT INTO EmployeeSkill (EmployeeId, SkillId, SkillLevel, YearsOfExperience, IsPrimarySkill) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM Skill WHERE SkillName='Cardiac Surgery'),              'Expert',       15.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM Skill WHERE SkillName='BLS / ACLS Certification'),     'Expert',       15.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM Skill WHERE SkillName='Internal Medicine'),            'Expert',       10.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM Skill WHERE SkillName='Infection Control'),            'Advanced',      8.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM Skill WHERE SkillName='Cardiac Surgery'),              'Intermediate',  3.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM Skill WHERE SkillName='Patient Assessment'),           'Advanced',      3.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM Skill WHERE SkillName='ICU / Critical Care'),          'Expert',       10.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM Skill WHERE SkillName='Ventilator Management'),        'Expert',        9.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM Skill WHERE SkillName='BLS / ACLS Certification'),    'Expert',       10.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM Skill WHERE SkillName='Patient Assessment'),           'Advanced',      5.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM Skill WHERE SkillName='Wound Care'),                   'Advanced',      5.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM Skill WHERE SkillName='IV Therapy'),                   'Advanced',      5.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM Skill WHERE SkillName='Drug Dispensing'),              'Expert',       14.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM Skill WHERE SkillName='Drug Dispensing'),              'Intermediate',  4.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM Skill WHERE SkillName='Orthopedic Surgery'),           'Expert',       12.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM Skill WHERE SkillName='BLS / ACLS Certification'),    'Advanced',     12.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM Skill WHERE SkillName='Emergency Medicine'),           'Expert',       11.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM Skill WHERE SkillName='BLS / ACLS Certification'),    'Expert',       11.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM Skill WHERE SkillName='Neurology'),                    'Expert',       10.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM Skill WHERE SkillName='MRI Operation'),                'Expert',       10.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM Skill WHERE SkillName='CT Scan Operation'),            'Expert',       10.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM Skill WHERE SkillName='Microbiology Testing'),         'Intermediate',  4.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM Skill WHERE SkillName='EHR / EMR Systems'),            'Advanced',      6.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM Skill WHERE SkillName='Hospital Network Administration'),'Advanced',    6.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM Skill WHERE SkillName='Oncology Treatment'),           'Expert',        9.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM Skill WHERE SkillName='Chemotherapy Drug Handling'),   'Advanced',      8.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM Skill WHERE SkillName='X-Ray Imaging'),                'Advanced',      5.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM Skill WHERE SkillName='Histopathology'),               'Expert',        9.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM Skill WHERE SkillName='Hematology'),                   'Expert',        9.00, 0),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM Skill WHERE SkillName='Cardiac Surgery'),              'Advanced',      8.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM Skill WHERE SkillName='EHR / EMR Systems'),            'Expert',       10.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM Skill WHERE SkillName='Medical Billing & Coding'),     'Expert',       12.00, 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM Skill WHERE SkillName='Medical Billing & Coding'),     'Advanced',      6.00, 1);


-- =============================================================================================================
-- MODULE 5: WORK WEEK POLICY
-- =============================================================================================================

PRINT 'Inserting WorkWeekPolicy...';
INSERT INTO WorkWeekPolicy (PolicyCode, PolicyName, Description, IsDefault) VALUES
('WWP-ADMIN-INDIA',     'Standard 5-Day Work Week (Mon-Fri)', 'Administrative staff: Monday to Friday, 9AM-6PM', 1),
('WWP-CLINICAL-6DAY',   'Clinical 6-Day Work Week (Mon-Sat)', 'Clinical staff: 6 days rotating schedule', 0),
('WWP-NURSING-SHIFT',   'Nursing Rotating Shift Policy',       'Nursing staff: rotating 8-hour shifts 7 days', 0),
('WWP-EMERGENCY-7DAY',  'Emergency 7-Day Policy',             'Emergency dept: 7 days, 3-shift rotation', 0);

-- Mon-Fri Admin (480 min = 8h, with 1h break means 9AM-6PM)
PRINT 'Inserting WorkWeekPolicyDay - Admin Mon-Fri...';
INSERT INTO WorkWeekPolicyDay (WorkWeekPolicyId, DayOfWeek, IsWorkingDay, StandardWorkingMinutes, IsHalfDay) VALUES
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 0, 0, NULL,  0), -- Sunday off
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 1, 1, 480,   0), -- Monday
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 2, 1, 480,   0), -- Tuesday
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 3, 1, 480,   0), -- Wednesday
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 4, 1, 480,   0), -- Thursday
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 5, 1, 480,   0), -- Friday
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'), 6, 0, NULL,  0); -- Saturday off

-- Mon-Sat Clinical 6-day
INSERT INTO WorkWeekPolicyDay (WorkWeekPolicyId, DayOfWeek, IsWorkingDay, StandardWorkingMinutes, IsHalfDay) VALUES
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 0, 0, NULL, 0), -- Sunday off
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 1, 1, 480,  0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 2, 1, 480,  0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 3, 1, 480,  0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 4, 1, 480,  0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 5, 1, 480,  0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'), 6, 1, 240,  1); -- Saturday half-day

-- Nursing 7-day (8h shifts, roster-driven off)
INSERT INTO WorkWeekPolicyDay (WorkWeekPolicyId, DayOfWeek, IsWorkingDay, StandardWorkingMinutes, IsHalfDay) VALUES
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 0, 1, 480, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 1, 1, 480, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 2, 1, 480, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 3, 1, 480, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 4, 1, 480, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 5, 1, 480, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'), 6, 1, 480, 0);

-- Emergency 7-day
INSERT INTO WorkWeekPolicyDay (WorkWeekPolicyId, DayOfWeek, IsWorkingDay, StandardWorkingMinutes, IsHalfDay) VALUES
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 0, 1, 720, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 1, 1, 720, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 2, 1, 720, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 3, 1, 720, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 4, 1, 720, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 5, 1, 720, 0),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'), 6, 1, 720, 0);


PRINT 'Inserting WorkWeekPolicyAssignment...';
-- Global default: Admin policy
INSERT INTO WorkWeekPolicyAssignment (WorkWeekPolicyId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder) VALUES
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-ADMIN-INDIA'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='GLOBAL'), 1, '2012-01-01', 1);

-- Clinical departments → 6-day
INSERT INTO WorkWeekPolicyAssignment (WorkWeekPolicyId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder) VALUES
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'), '2012-01-01', 2),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='CARDIOLOGY'), '2012-01-01', 2),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-CLINICAL-6DAY'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='ONCOLOGY'), '2012-01-01', 2);

-- Nursing → Shift policy
INSERT INTO WorkWeekPolicyAssignment (WorkWeekPolicyId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder) VALUES
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'), '2012-01-01', 3),
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-NURSING-SHIFT'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='ICU'), '2012-01-01', 3);

-- Emergency → 7-day
INSERT INTO WorkWeekPolicyAssignment (WorkWeekPolicyId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder) VALUES
((SELECT Id FROM WorkWeekPolicy WHERE PolicyCode='WWP-EMERGENCY-7DAY'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='EMERGENCY'), '2012-01-01', 4);


-- =============================================================================================================
-- MODULE 6: SHIFT MANAGEMENT
-- =============================================================================================================

PRINT 'Inserting Shift...';
INSERT INTO Shift (ShiftCode, ShiftName, StartTime, EndTime, BreakDurationMinutes, GraceInMinutes, GraceOutMinutes, MinimumWorkingMinutes, MaximumWorkingMinutes, IsNightShift, CrossesMidnight, IsFlexible, AllowOvertime) VALUES
-- General / Admin shift — IST 9:00-18:00 (standard Indian office hours)
('SHF-GEN',     'General Shift (9AM-6PM)',          '09:00', '18:00', 60, 15, 15, 420, 540, 0, 0, 0, 1),
-- Clinical morning shift — 7:00-15:00
('SHF-MORN',    'Morning Shift (7AM-3PM)',           '07:00', '15:00', 30, 10, 10, 450, 480, 0, 0, 0, 1),
-- Clinical afternoon/evening shift — 14:00-22:00
('SHF-AFT',     'Afternoon Shift (2PM-10PM)',        '14:00', '22:00', 30, 10, 10, 450, 480, 0, 0, 0, 1),
-- Night shift — 22:00-06:00 (crosses midnight)
('SHF-NIGHT',   'Night Shift (10PM-6AM)',            '22:00', '06:00', 30, 10, 10, 450, 480, 1, 1, 0, 1),
-- Emergency 12-hour Day — 08:00-20:00
('SHF-EMER-D',  'Emergency Day Shift (8AM-8PM)',     '08:00', '20:00', 60, 10, 10, 660, 720, 0, 0, 0, 1),
-- Emergency 12-hour Night — 20:00-08:00
('SHF-EMER-N',  'Emergency Night Shift (8PM-8AM)',   '20:00', '08:00', 60, 10, 10, 660, 720, 1, 1, 0, 1),
-- OPD Shift — 10:00-17:00 (Outpatient Departments)
('SHF-OPD',     'OPD Shift (10AM-5PM)',              '10:00', '17:00', 30, 15, 15, 360, 420, 0, 0, 0, 0),
-- Flexible IT/Admin — 10:00-19:00
('SHF-FLEX',    'Flexible Shift (10AM-7PM)',         '10:00', '19:00', 60, 30, 30, 420, 540, 0, 0, 1, 1);


PRINT 'Inserting ShiftSwapStatus...';
INSERT INTO ShiftSwapStatus (StatusCode, StatusName) VALUES
('PENDING',     'Pending Approval'),
('APPROVED',    'Approved'),
('REJECTED',    'Rejected'),
('CANCELLED',   'Cancelled by Requester'),
('WITHDRAWN',   'Withdrawn by Target');


PRINT 'Inserting ShiftAssignment...';
-- Global default: General shift (admin/support/finance)
INSERT INTO ShiftAssignment (ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
((SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='GLOBAL'), 1, '2012-01-01', 1, 1);

-- HR, Finance, Admin, IT → General / Flexible
INSERT INTO ShiftAssignment (ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
((SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='HR'),          '2012-01-01', 2, 1),
((SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='FINANCE'),     '2012-01-01', 2, 1),
((SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='ADMIN'),       '2012-01-01', 2, 1),
((SELECT Id FROM Shift WHERE ShiftCode='SHF-FLEX'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='IT'),          '2012-01-01', 2, 1);

-- Clinical/OPD → Morning shift as primary
INSERT INTO ShiftAssignment (ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
((SELECT Id FROM Shift WHERE ShiftCode='SHF-MORN'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='CLINICAL'),    '2012-01-01', 3, 1),
((SELECT Id FROM Shift WHERE ShiftCode='SHF-OPD'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='CARDIOLOGY'),  '2012-01-01', 3, 1),
((SELECT Id FROM Shift WHERE ShiftCode='SHF-OPD'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='ONCOLOGY'),    '2012-01-01', 3, 1),
((SELECT Id FROM Shift WHERE ShiftCode='SHF-OPD'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='NEUROLOGY'),   '2012-01-01', 3, 1),
((SELECT Id FROM Shift WHERE ShiftCode='SHF-OPD'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='PEDIATRICS'),  '2012-01-01', 3, 1);

-- Emergency → 12-hour day primary
INSERT INTO ShiftAssignment (ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
((SELECT Id FROM Shift WHERE ShiftCode='SHF-EMER-D'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='EMERGENCY'),   '2012-01-01', 4, 1);

-- Pharmacy → Morning shift
INSERT INTO ShiftAssignment (ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
((SELECT Id FROM Shift WHERE ShiftCode='SHF-MORN'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='PHARMACY'),    '2012-01-01', 3, 1);

-- Individual overrides: Resident EMP009 works morning
INSERT INTO ShiftAssignment (ShiftId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, IsPrimaryShift) VALUES
((SELECT Id FROM Shift WHERE ShiftCode='SHF-MORN'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='EMPLOYEE'), (SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), '2021-08-01', 5, 1);


-- =============================================================================================================
-- MODULE 7: ROTATION SHIFT
-- =============================================================================================================

PRINT 'Inserting RotationShift...';
INSERT INTO RotationShift (RotationCode, RotationName, CycleLengthDays) VALUES
('ROT-NURSING-3SHIFT',  'Nursing 3-Shift Rotation (21 days)',   21),
('ROT-EMER-12HR',       'Emergency 12-Hour 2-Shift Rotation',   6);


PRINT 'Inserting RotationShiftDetail...';
-- Nursing: 7 days Morning → 7 days Afternoon → 7 days Night
INSERT INTO RotationShiftDetail (RotationShiftId, SequenceNo, ShiftId, DurationDays, IsOffDay) VALUES
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-NURSING-3SHIFT'), 1, (SELECT Id FROM Shift WHERE ShiftCode='SHF-MORN'),  7, 0),
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-NURSING-3SHIFT'), 2, (SELECT Id FROM Shift WHERE ShiftCode='SHF-AFT'),   7, 0),
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-NURSING-3SHIFT'), 3, (SELECT Id FROM Shift WHERE ShiftCode='SHF-NIGHT'), 7, 0);

-- Emergency: 2 days Day → 1 off → 2 days Night → 1 off
INSERT INTO RotationShiftDetail (RotationShiftId, SequenceNo, ShiftId, DurationDays, IsOffDay) VALUES
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-EMER-12HR'), 1, (SELECT Id FROM Shift WHERE ShiftCode='SHF-EMER-D'), 2, 0),
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-EMER-12HR'), 2, NULL,                                                 1, 1),
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-EMER-12HR'), 3, (SELECT Id FROM Shift WHERE ShiftCode='SHF-EMER-N'), 2, 0),
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-EMER-12HR'), 4, NULL,                                                 1, 1);


PRINT 'Inserting RotationShiftAssignment...';
-- Nursing dept → 3-shift rotation
INSERT INTO RotationShiftAssignment (RotationShiftId, ScopeTypeId, ScopeReferenceId, RotationStartDate, EffectiveFrom) VALUES
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-NURSING-3SHIFT'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='NURSING'),   '2024-01-01', '2024-01-01'),
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-NURSING-3SHIFT'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='ICU'),       '2024-01-01', '2024-01-01');

-- Emergency dept → 12-hr rotation
INSERT INTO RotationShiftAssignment (RotationShiftId, ScopeTypeId, ScopeReferenceId, RotationStartDate, EffectiveFrom) VALUES
((SELECT Id FROM RotationShift WHERE RotationCode='ROT-EMER-12HR'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='DEPARTMENT'), (SELECT Id FROM Department WHERE DepartmentCode='EMERGENCY'), '2024-01-01', '2024-01-01');


-- =============================================================================================================
-- MODULE 8: EMPLOYEE ROSTER (Sample - April 2025)
-- =============================================================================================================

PRINT 'Inserting EmployeeShiftRoster (sample for 2025-04-01 to 2025-04-03)...';
INSERT INTO EmployeeShiftRoster (EmployeeId, RosterDate, ShiftId, IsOffDay, IsHoliday, PlannedStartTime, PlannedEndTime) VALUES
-- EMP001 CMO - General shift
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), '2025-04-01', (SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-01 09:00:00', '2025-04-01 18:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), '2025-04-02', (SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-02 09:00:00', '2025-04-02 18:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), '2025-04-03', (SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-03 09:00:00', '2025-04-03 18:00:00'),
-- EMP010 ICU Senior Nurse - Morning shift
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), '2025-04-01', (SELECT Id FROM Shift WHERE ShiftCode='SHF-MORN'), 0, 0, '2025-04-01 07:00:00', '2025-04-01 15:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), '2025-04-02', (SELECT Id FROM Shift WHERE ShiftCode='SHF-AFT'),  0, 0, '2025-04-02 14:00:00', '2025-04-02 22:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), '2025-04-03', (SELECT Id FROM Shift WHERE ShiftCode='SHF-NIGHT'),0, 0, '2025-04-03 22:00:00', '2025-04-04 06:00:00'),
-- EMP020 Emergency Physician - 12-hr Day
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), '2025-04-01', (SELECT Id FROM Shift WHERE ShiftCode='SHF-EMER-D'),0, 0,'2025-04-01 08:00:00', '2025-04-01 20:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), '2025-04-02', NULL,                                                1, 0, NULL, NULL), -- Off day
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), '2025-04-03', (SELECT Id FROM Shift WHERE ShiftCode='SHF-EMER-N'),0, 0,'2025-04-03 20:00:00', '2025-04-04 08:00:00'),
-- EMP005 HR Manager - General shift
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2025-04-01', (SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-01 09:00:00', '2025-04-01 18:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2025-04-02', (SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-02 09:00:00', '2025-04-02 18:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2025-04-03', (SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),  0, 0, '2025-04-03 09:00:00', '2025-04-03 18:00:00');


-- =============================================================================================================
-- MODULE 9: HOLIDAY MANAGEMENT
-- =============================================================================================================

PRINT 'Inserting HolidayCalendar...';
INSERT INTO HolidayCalendar (CalendarCode, CalendarName, Description, IsDefault) VALUES
('HC-INDIA-NATIONAL',   'India National Holidays',          'Public holidays applicable across India',           1),
('HC-MH-STATE',         'Maharashtra State Holidays',       'State-specific holidays for Maharashtra',           0),
('HC-DL-STATE',         'Delhi State Holidays',             'State-specific holidays for Delhi',                 0),
('HC-KA-STATE',         'Karnataka State Holidays',         'State-specific holidays for Karnataka',             0),
('HC-TN-STATE',         'Tamil Nadu State Holidays',        'State-specific holidays for Tamil Nadu',            0),
('HC-TS-STATE',         'Telangana State Holidays',         'State-specific holidays for Telangana',             0),
('HC-WB-STATE',         'West Bengal State Holidays',       'State-specific holidays for West Bengal',           0),
('HC-OPTIONAL',         'Optional / Restricted Holidays',   'Employees may choose from optional holiday list',   0);


PRINT 'Inserting HolidayType...';
INSERT INTO HolidayType (HolidayTypeCode, HolidayTypeName, IsOptional) VALUES
('NATIONAL',    'National Holiday',         0),
('STATE',       'State Public Holiday',     0),
('RELIGIOUS',   'Religious Festival',       0),
('OPTIONAL',    'Optional / Restricted',    1);


PRINT 'Inserting Holiday (2025)...';
-- National Holidays
INSERT INTO Holiday (HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring, ApplicableYear) VALUES
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-REPDAY',   'Republic Day',                     '2025-01-26', 0, 1, NULL),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-HOLI',     'Holi',                             '2025-03-14', 0, 1, NULL),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-UGADI',    'Ugadi / Gudi Padwa',               '2025-03-30', 0, 0, 2025),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-GOODFRI',  'Good Friday',                      '2025-04-18', 0, 0, 2025),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-AMBEDKAR', 'Dr. B.R. Ambedkar Jayanti',        '2025-04-14', 0, 1, NULL),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-LABDAY',   'Labour Day / May Day',             '2025-05-01', 0, 1, NULL),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-EID',      'Eid-ul-Fitr',                      '2025-03-31', 0, 0, 2025),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-INDEPDAY', 'Independence Day',                 '2025-08-15', 0, 1, NULL),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-JANMASHTAMI','Janmashtami',                   '2025-08-16', 0, 0, 2025),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='NATIONAL'), 'HOL-GANDHIJAY','Gandhi Jayanti',                   '2025-10-02', 0, 1, NULL),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-DUSSEHRA', 'Dussehra / Navratri',              '2025-10-02', 0, 0, 2025),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-DIWALI',   'Diwali (Lakshmi Puja)',            '2025-10-20', 0, 0, 2025),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-DIWALINEXT','Diwali Holiday',                  '2025-10-21', 0, 0, 2025),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='RELIGIOUS'),'HOL-CHRISTMAS', 'Christmas Day',                   '2025-12-25', 0, 1, NULL);

-- Maharashtra-specific
INSERT INTO Holiday (HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring) VALUES
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-MH-STATE'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-MH-DAY',    'Maharashtra Day',          '2025-05-01', 0, 1),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-MH-STATE'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-CHHATH',    'Chhath Puja',              '2025-10-28', 0, 0);

-- Karnataka-specific
INSERT INTO Holiday (HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring) VALUES
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-KA-STATE'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-KA-RAJ',    'Karnataka Rajyotsava',     '2025-11-01', 0, 1);

-- Tamil Nadu-specific
INSERT INTO Holiday (HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring) VALUES
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-TN-STATE'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-PONGAL',    'Pongal',                   '2025-01-14', 0, 1),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-TN-STATE'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-PONGAL2',   'Thiruvalluvar Day',        '2025-01-15', 0, 1);

-- West Bengal-specific
INSERT INTO Holiday (HolidayCalendarId, HolidayTypeId, HolidayCode, HolidayName, HolidayDate, IsHalfDay, IsRecurring) VALUES
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-WB-STATE'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-DURGA',     'Durga Puja (Maha Ashtami)','2025-10-01', 0, 0),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-WB-STATE'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-DURGA2',    'Durga Puja (Navami)',      '2025-10-02', 0, 0),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-WB-STATE'), (SELECT Id FROM HolidayType WHERE HolidayTypeCode='STATE'), 'HOL-DURGA3',    'Durga Puja (Dashami)',     '2025-10-03', 0, 0);


PRINT 'Inserting HolidayCalendarAssignment...';
-- National calendar → All offices globally
INSERT INTO HolidayCalendarAssignment (HolidayCalendarId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, MergeStrategy, IsPrimary) VALUES
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-INDIA-NATIONAL'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='COUNTRY'), (SELECT Id FROM Country WHERE CountryCode='IN'), '2012-01-01', 1, 'MERGE', 1);

-- State calendars → specific offices
INSERT INTO HolidayCalendarAssignment (HolidayCalendarId, ScopeTypeId, ScopeReferenceId, EffectiveFrom, PriorityOrder, MergeStrategy, IsPrimary) VALUES
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-MH-STATE'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '2012-01-01', 2, 'MERGE', 0),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-MH-STATE'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01'), '2012-01-01', 2, 'MERGE', 0),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-DL-STATE'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'), '2012-01-01', 2, 'MERGE', 0),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-KA-STATE'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01'), '2012-01-01', 2, 'MERGE', 0),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-TN-STATE'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-CHN-01'), '2012-01-01', 2, 'MERGE', 0),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-TS-STATE'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01'), '2012-01-01', 2, 'MERGE', 0),
((SELECT Id FROM HolidayCalendar WHERE CalendarCode='HC-WB-STATE'),
 (SELECT Id FROM ScopeType WHERE ScopeCode='OFFICE'), (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-KOL-01'), '2012-01-01', 2, 'MERGE', 0);


-- =============================================================================================================
-- MODULE 10: ATTENDANCE MANAGEMENT
-- =============================================================================================================

PRINT 'Inserting AttendanceStatus...';
INSERT INTO AttendanceStatus (StatusCode, StatusName, IsPresent, IsAbsent, IsPaid, CountsAsWorkingDay, DisplayOrder, IsSystemStatus) VALUES
('PRESENT',     'Present',                      1, 0, 1, 1, 1, 1),
('ABSENT',      'Absent',                       0, 1, 0, 0, 2, 1),
('ON_LEAVE',    'On Approved Leave',            0, 0, 1, 0, 3, 1),
('WFH',         'Work From Home',               1, 0, 1, 1, 4, 1),
('HALF_DAY',    'Half Day Present',             1, 0, 1, 1, 5, 1),
('LATE',        'Late Arrival',                 1, 0, 1, 1, 6, 1),
('HOLIDAY',     'Public Holiday',               0, 0, 1, 0, 7, 1),
('WEEKEND',     'Weekend / Off Day',            0, 0, 0, 0, 8, 1),
('ON_DUTY',     'On Official Duty',             1, 0, 1, 1, 9, 1),
('COMP_OFF',    'Compensatory Off',             0, 0, 1, 0, 10, 1),
('REGULARIZED', 'Attendance Regularized',       1, 0, 1, 1, 11, 1);


PRINT 'Inserting AttendanceLog (sample biometric punches)...';
INSERT INTO AttendanceLog (EmployeeId, PunchTime, PunchType, DeviceId, Location, IsProcessed) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), '2025-04-01 08:52:00', 'IN',  'BIO-MUM-01', 'Mumbai HQ - Main Gate',    1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), '2025-04-01 18:07:00', 'OUT', 'BIO-MUM-01', 'Mumbai HQ - Main Gate',    1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2025-04-01 09:11:00', 'IN',  'BIO-MUM-01', 'Mumbai HQ - Main Gate',    1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2025-04-01 18:03:00', 'OUT', 'BIO-MUM-01', 'Mumbai HQ - Main Gate',    1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), '2025-04-01 06:55:00', 'IN',  'BIO-MUM-02', 'Mumbai HQ - Ward Entrance', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), '2025-04-01 15:05:00', 'OUT', 'BIO-MUM-02', 'Mumbai HQ - Ward Entrance', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), '2025-04-01 07:52:00', 'IN',  'BIO-DEL-01', 'Delhi - Emergency Entrance', 1),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), '2025-04-01 20:10:00', 'OUT', 'BIO-DEL-01', 'Delhi - Emergency Entrance', 1);


PRINT 'Inserting AttendanceRecord (processed attendance)...';
INSERT INTO AttendanceRecord (EmployeeId, AttendanceDate, ShiftId, AttendanceStatusId, CheckInTime, CheckOutTime, LateByMinutes, EarlyExitMinutes, WorkedMinutes, OvertimeMinutes, IsManualEntry) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), '2025-04-01',
 (SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM AttendanceStatus WHERE StatusCode='PRESENT'),
 '2025-04-01 08:52:00', '2025-04-01 18:07:00', 0, 0, 495, 7, 0),

((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), '2025-04-01',
 (SELECT Id FROM Shift WHERE ShiftCode='SHF-GEN'),
 (SELECT Id FROM AttendanceStatus WHERE StatusCode='LATE'),
 '2025-04-01 09:11:00', '2025-04-01 18:03:00', 11, 0, 472, 0, 0),

((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), '2025-04-01',
 (SELECT Id FROM Shift WHERE ShiftCode='SHF-MORN'),
 (SELECT Id FROM AttendanceStatus WHERE StatusCode='PRESENT'),
 '2025-04-01 06:55:00', '2025-04-01 15:05:00', 0, 0, 490, 10, 0),

((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), '2025-04-01',
 (SELECT Id FROM Shift WHERE ShiftCode='SHF-EMER-D'),
 (SELECT Id FROM AttendanceStatus WHERE StatusCode='PRESENT'),
 '2025-04-01 07:52:00', '2025-04-01 20:10:00', 0, 0, 730, 10, 0);


PRINT 'Inserting AttendanceRegularizationStatus...';
INSERT INTO AttendanceRegularizationStatus (StatusCode, StatusName) VALUES
('PENDING',     'Pending'),
('APPROVED',    'Approved'),
('REJECTED',    'Rejected'),
('CANCELLED',   'Cancelled');


-- =============================================================================================================
-- MODULE 11: LEAVE MANAGEMENT
-- =============================================================================================================

PRINT 'Inserting LeaveType...';
INSERT INTO LeaveType (LeaveCode, LeaveName, IsPaid, MaxDaysPerYear, AllowCarryForward, RequiresApproval, AllowHalfDay) VALUES
('CL',      'Casual Leave',                         1, 12.00, 0, 1, 1),
('SL',      'Sick Leave',                           1, 12.00, 0, 1, 1),
('EL',      'Earned Leave / Privilege Leave',       1, 18.00, 1, 1, 1),
('ML',      'Maternity Leave',                      1, 182.00,0, 1, 0),
('PL',      'Paternity Leave',                      1, 15.00, 0, 1, 0),
('OL',      'Optional / Restricted Holiday Leave',  0, 2.00,  0, 1, 1),
('LWP',     'Leave Without Pay',                    0, NULL,  0, 1, 0),
('COMPOFF', 'Compensatory Off Leave',               1, NULL,  0, 1, 1),
('BL',      'Bereavement Leave',                    1, 5.00,  0, 1, 0),
('STUDYLEAVE','Study / Exam Leave',                 1, 5.00,  0, 1, 0);


PRINT 'Inserting LeaveStatus...';
INSERT INTO LeaveStatus (StatusCode, StatusName) VALUES
('PENDING',     'Pending Approval'),
('APPROVED',    'Approved'),
('REJECTED',    'Rejected'),
('CANCELLED',   'Cancelled'),
('REVOKED',     'Revoked by Manager'),
('WITHDRAWN',   'Withdrawn by Employee');


PRINT 'Inserting LeaveRequest (samples)...';
INSERT INTO LeaveRequest (EmployeeId, LeaveTypeId, LeaveStatusId, FromDate, ToDate, TotalDays, IsHalfDay, Reason, ApprovedBy, ApprovedAt, AppliedAt) VALUES
-- EMP009 Resident took sick leave
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'),
 (SELECT Id FROM LeaveType WHERE LeaveCode='SL'),
 (SELECT Id FROM LeaveStatus WHERE StatusCode='APPROVED'),
 '2025-03-10', '2025-03-12', 3.00, 0, 'Viral fever', (SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), '2025-03-09 20:00:00', '2025-03-09 18:00:00'),
-- EMP011 Staff Nurse casual leave
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'),
 (SELECT Id FROM LeaveType WHERE LeaveCode='CL'),
 (SELECT Id FROM LeaveStatus WHERE StatusCode='APPROVED'),
 '2025-04-14', '2025-04-14', 1.00, 0, 'Personal work', (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), '2025-04-11 10:00:00', '2025-04-10 14:00:00'),
-- EMP028 Nurse - Maternity leave
((SELECT Id FROM Employee WHERE EmployeeCode='EMP028'),
 (SELECT Id FROM LeaveType WHERE LeaveCode='ML'),
 (SELECT Id FROM LeaveStatus WHERE StatusCode='APPROVED'),
 '2025-05-01', '2025-10-30', 183.00, 0, 'Maternity leave', (SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), '2025-04-20 11:00:00', '2025-04-15 09:00:00'),
-- EMP013 Pharmacist - Earned leave
((SELECT Id FROM Employee WHERE EmployeeCode='EMP013'),
 (SELECT Id FROM LeaveType WHERE LeaveCode='EL'),
 (SELECT Id FROM LeaveStatus WHERE StatusCode='PENDING'),
 '2025-05-20', '2025-05-24', 5.00, 0, 'Family vacation', NULL, NULL, '2025-05-08 10:00:00');


PRINT 'Inserting LeaveBalance (2025)...';
INSERT INTO LeaveBalance (EmployeeId, LeaveTypeId, BalanceYear, OpeningBalance, Allocated, Availed, Encashed, CarryForward, LastUpdatedAt) VALUES
-- EMP001 CMO
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM LeaveType WHERE LeaveCode='EL'),  2025, 5.00, 18.00, 0.00,  0.00, 5.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
-- EMP009 Resident
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM LeaveType WHERE LeaveCode='EL'),  2025, 0.00, 18.00, 0.00,  0.00, 0.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 3.00,  0.00, 0.00, GETUTCDATE()),
-- EMP010 Senior ICU Nurse
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM LeaveType WHERE LeaveCode='EL'),  2025, 3.00, 18.00, 0.00,  0.00, 3.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
-- EMP011 Staff Nurse
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM LeaveType WHERE LeaveCode='EL'),  2025, 0.00, 18.00, 0.00,  0.00, 0.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 1.00,  0.00, 0.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
-- EMP005 HR Manager
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM LeaveType WHERE LeaveCode='EL'),  2025, 7.00, 18.00, 0.00,  0.00, 7.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM LeaveType WHERE LeaveCode='CL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE()),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM LeaveType WHERE LeaveCode='SL'),  2025, 0.00, 12.00, 0.00,  0.00, 0.00, GETUTCDATE());


-- =============================================================================================================
-- MODULE 12: COMP-OFF
-- =============================================================================================================

PRINT 'Inserting CompOffType...';
INSERT INTO CompOffType (CompOffTypeCode, CompOffTypeName, ExpiryDays) VALUES
('CO-WEEKENDDUTY',  'Weekend Duty Comp-Off',            90),
('CO-HOLIDAYDUTY',  'Holiday Duty Comp-Off',            90),
('CO-OVERTIME',     'Overtime Comp-Off',                60),
('CO-EMERGENCYDUTY','Emergency Call Duty Comp-Off',     45);


PRINT 'Inserting CompOffBalance (samples)...';
INSERT INTO CompOffBalance (EmployeeId, CompOffTypeId, EarnedDate, ExpiryDate, TotalDays, AvailedDays, AttendanceRecordId) VALUES
-- EMP010 ICU Nurse worked weekend
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'),
 (SELECT Id FROM CompOffType WHERE CompOffTypeCode='CO-WEEKENDDUTY'),
 '2025-03-29', '2025-06-27', 1.00, 0.00,
 (SELECT Id FROM AttendanceRecord WHERE EmployeeId=(SELECT Id FROM Employee WHERE EmployeeCode='EMP010') AND AttendanceDate='2025-04-01')),
-- EMP020 Emergency Physician - Holiday duty
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'),
 (SELECT Id FROM CompOffType WHERE CompOffTypeCode='CO-HOLIDAYDUTY'),
 '2025-01-26', '2025-04-26', 1.00, 0.00, NULL);



-- =============================================================================================================
-- MODULE 14: BIOMETRIC & GEO-FENCE
-- =============================================================================================================

PRINT 'Inserting BiometricDevice...';
INSERT INTO BiometricDevice (DeviceCode, DeviceName, SerialNumber, OfficeId, IpAddress) VALUES
('BIO-MUM-01', 'Suprema BioStation A2 - Mumbai Main Gate',      'SN-BIO-MUM-001', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.101'),
('BIO-MUM-02', 'Suprema BioStation A2 - Mumbai Ward Block',     'SN-BIO-MUM-002', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.102'),
('BIO-MUM-03', 'ZKTeco F22 - Mumbai Emergency Entry',           'SN-BIO-MUM-003', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.103'),
('BIO-PUN-01', 'Suprema BioStation - Pune Main Entrance',       'SN-BIO-PUN-001', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01'), '10.20.1.101'),
('BIO-DEL-01', 'ZKTeco K40 - Delhi Main Gate',                  'SN-BIO-DEL-001', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'), '10.30.1.101'),
('BIO-DEL-02', 'ZKTeco K40 - Delhi Emergency Wing',             'SN-BIO-DEL-002', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01'), '10.30.1.102'),
('BIO-BLR-01', 'Realand A-F191 - Bengaluru Main Gate',          'SN-BIO-BLR-001', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01'), '10.40.1.101'),
('BIO-CHN-01', 'eSSL eTime Track - Chennai Main Entrance',      'SN-BIO-CHN-001', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-CHN-01'), '10.50.1.101'),
('BIO-HYD-01', 'Suprema CoreStation - Hyderabad Main Gate',     'SN-BIO-HYD-001', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01'), '10.60.1.101'),
('BIO-KOL-01', 'ZKTeco F22 - Kolkata Main Entrance',            'SN-BIO-KOL-001', (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-KOL-01'), '10.70.1.101');


PRINT 'Inserting BiometricEmployeeMapping...';
INSERT INTO BiometricEmployeeMapping (EmployeeId, BiometricDeviceId, DeviceEmployeeCode) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-001'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-002'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-003'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-004'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-005'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-006'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-007'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-008'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-009'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-010'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-011'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-012'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-02'), 'DEV-013'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-014'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-MUM-01'), 'DEV-015'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-016'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-017'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-018'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-DEL-01'), 'DEV-019'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-DEL-02'), 'DEV-020'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-021'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-022'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-023'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-024'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-BLR-01'), 'DEV-025'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-026'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-027'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-028'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-029'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-CHN-01'), 'DEV-030'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-031'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-032'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-033'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-034'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-HYD-01'), 'DEV-035'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-036'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-037'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-038'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-039'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-KOL-01'), 'DEV-040'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-041'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-042'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-043'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-044'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM BiometricDevice WHERE DeviceCode='BIO-PUN-01'), 'DEV-045');


PRINT 'Inserting GeoFence...';
INSERT INTO GeoFence (GeoFenceCode, GeoFenceName, Latitude, Longitude, RadiusMeters, OfficeId) VALUES
('GEO-MUM-HQ',  'Mumbai HQ Geo-Fence',          19.06596000, 72.86847000, 150.00, (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-MUM-HQ')),
('GEO-PUN-01',  'Pune Hospital Geo-Fence',       18.53141000, 73.89364000, 150.00, (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-PUN-01')),
('GEO-DEL-01',  'Delhi Hospital Geo-Fence',      28.62701000, 77.21860000, 200.00, (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-DEL-01')),
('GEO-BLR-01',  'Bengaluru Hospital Geo-Fence',  12.97160000, 77.59460000, 150.00, (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-BLR-01')),
('GEO-CHN-01',  'Chennai Hospital Geo-Fence',    13.08274000, 80.27072000, 150.00, (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-CHN-01')),
('GEO-HYD-01',  'Hyderabad Hospital Geo-Fence',  17.38500000, 78.48670000, 150.00, (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-HYD-01')),
('GEO-KOL-01',  'Kolkata Hospital Geo-Fence',    22.57260000, 88.36390000, 150.00, (SELECT Id FROM OfficeLocation WHERE LocationCode='LOC-KOL-01'));


PRINT 'Inserting MobileAttendanceLog (sample GPS punches)...';
INSERT INTO MobileAttendanceLog (EmployeeId, GeoFenceId, PunchTime, Latitude, Longitude, IsInsideGeoFence, DeviceInfo) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'),
 (SELECT Id FROM GeoFence WHERE GeoFenceCode='GEO-BLR-01'),
 '2025-04-01 09:58:00', 12.97162000, 77.59461000, 1, 'Samsung Galaxy S24 | Android 14'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP025'),
 (SELECT Id FROM GeoFence WHERE GeoFenceCode='GEO-BLR-01'),
 '2025-04-01 19:02:00', 12.97161000, 77.59460000, 1, 'Samsung Galaxy S24 | Android 14'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM GeoFence WHERE GeoFenceCode='GEO-CHN-01'),
 '2025-04-01 09:05:00', 13.08275000, 80.27074000, 1, 'iPhone 15 | iOS 17'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM GeoFence WHERE GeoFenceCode='GEO-CHN-01'),
 '2025-04-01 18:00:00', 13.08270000, 80.27072000, 1, 'iPhone 15 | iOS 17');


-- =============================================================================================================
-- VERIFICATION SUMMARY
-- =============================================================================================================
PRINT '';
PRINT '=============================================================================================================';
PRINT 'SEED DATA INSERTION COMPLETE - MedCare India Pvt. Ltd.';
PRINT '=============================================================================================================';
PRINT '';

SELECT 'Designations'       AS TableName, COUNT(*) AS RecordCount FROM Designation       UNION ALL
SELECT 'TimeZoneMaster',                  COUNT(*)               FROM TimeZoneMaster      UNION ALL
SELECT 'Country',                         COUNT(*)               FROM Country              UNION ALL
SELECT 'LegalEntity',                     COUNT(*)               FROM LegalEntity          UNION ALL
SELECT 'Region',                          COUNT(*)               FROM Region               UNION ALL
SELECT 'OfficeLocation',                  COUNT(*)               FROM OfficeLocation       UNION ALL
SELECT 'Department',                      COUNT(*)               FROM Department           UNION ALL
SELECT 'RelationshipType',                COUNT(*)               FROM RelationshipType     UNION ALL
SELECT 'DocumentType',                    COUNT(*)               FROM DocumentType         UNION ALL
SELECT 'Employee',                        COUNT(*)               FROM Employee             UNION ALL
SELECT 'EmployeeLegalEntity',             COUNT(*)               FROM EmployeeLegalEntity  UNION ALL
SELECT 'EmployeeDepartment',              COUNT(*)               FROM EmployeeDepartment   UNION ALL
SELECT 'EmployeeLocation',                COUNT(*)               FROM EmployeeLocation     UNION ALL
SELECT 'EmployeeRelationship',            COUNT(*)               FROM EmployeeRelationship UNION ALL
SELECT 'EmployeeContact',                 COUNT(*)               FROM EmployeeContact      UNION ALL
SELECT 'Skill',                           COUNT(*)               FROM Skill                UNION ALL
SELECT 'Team',                            COUNT(*)               FROM Team                 UNION ALL
SELECT 'EmployeeTeam',                    COUNT(*)               FROM EmployeeTeam         UNION ALL
SELECT 'EmployeeSkill',                   COUNT(*)               FROM EmployeeSkill        UNION ALL
SELECT 'WorkWeekPolicy',                  COUNT(*)               FROM WorkWeekPolicy       UNION ALL
SELECT 'WorkWeekPolicyDay',               COUNT(*)               FROM WorkWeekPolicyDay    UNION ALL
SELECT 'WorkWeekPolicyAssignment',        COUNT(*)               FROM WorkWeekPolicyAssignment UNION ALL
SELECT 'Shift',                           COUNT(*)               FROM Shift                UNION ALL
SELECT 'ShiftSwapStatus',                 COUNT(*)               FROM ShiftSwapStatus      UNION ALL
SELECT 'ShiftAssignment',                 COUNT(*)               FROM ShiftAssignment      UNION ALL
SELECT 'RotationShift',                   COUNT(*)               FROM RotationShift        UNION ALL
SELECT 'RotationShiftDetail',             COUNT(*)               FROM RotationShiftDetail  UNION ALL
SELECT 'RotationShiftAssignment',         COUNT(*)               FROM RotationShiftAssignment UNION ALL
SELECT 'EmployeeShiftRoster',             COUNT(*)               FROM EmployeeShiftRoster  UNION ALL
SELECT 'HolidayCalendar',                 COUNT(*)               FROM HolidayCalendar      UNION ALL
SELECT 'HolidayType',                     COUNT(*)               FROM HolidayType          UNION ALL
SELECT 'Holiday',                         COUNT(*)               FROM Holiday              UNION ALL
SELECT 'HolidayCalendarAssignment',       COUNT(*)               FROM HolidayCalendarAssignment UNION ALL
SELECT 'AttendanceStatus',                COUNT(*)               FROM AttendanceStatus     UNION ALL
SELECT 'AttendanceLog',                   COUNT(*)               FROM AttendanceLog        UNION ALL
SELECT 'AttendanceRecord',                COUNT(*)               FROM AttendanceRecord     UNION ALL
SELECT 'AttendanceRegularizationStatus',  COUNT(*)               FROM AttendanceRegularizationStatus UNION ALL
SELECT 'LeaveType',                       COUNT(*)               FROM LeaveType            UNION ALL
SELECT 'LeaveStatus',                     COUNT(*)               FROM LeaveStatus          UNION ALL
SELECT 'LeaveRequest',                    COUNT(*)               FROM LeaveRequest         UNION ALL
SELECT 'LeaveBalance',                    COUNT(*)               FROM LeaveBalance         UNION ALL
SELECT 'CompOffType',                     COUNT(*)               FROM CompOffType          UNION ALL
SELECT 'CompOffBalance',                  COUNT(*)               FROM CompOffBalance       UNION ALL
SELECT 'BiometricDevice',                 COUNT(*)               FROM BiometricDevice      UNION ALL
SELECT 'BiometricEmployeeMapping',        COUNT(*)               FROM BiometricEmployeeMapping UNION ALL
SELECT 'GeoFence',                        COUNT(*)               FROM GeoFence             UNION ALL
SELECT 'MobileAttendanceLog',             COUNT(*)               FROM MobileAttendanceLog;

COMMIT TRANSACTION;
PRINT 'Transaction committed successfully.';

-- =============================================================================================================
-- END OF SEED DATA SCRIPT
-- =============================================================================================================