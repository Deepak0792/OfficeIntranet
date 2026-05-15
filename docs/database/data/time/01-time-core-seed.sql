-- =============================================================================================================
-- TIME SCHEMA - Seed Data
-- Organization: MedCare India Pvt. Ltd. (India)
-- Dependencies: shared.StatusLookup
-- =============================================================================================================

SET NOCOUNT ON;
BEGIN TRANSACTION;

-- =============================================================================================================
-- MASTER DATA - Time zones, countries, regions, office locations, legal entities, 
--             - departments, scope tyepe, geo fence, biometric device
-- =============================================================================================================

-- =============================================================================================================
-- SEED DATA - TimeZoneMaster
-- =============================================================================================================

PRINT 'Inserting TimeZoneMaster...';
INSERT INTO time.TimeZoneMaster (TimeZoneCode, TimeZoneName, UtcOffset, OffsetMinutes, SupportsDaylightSaving, WindowsTimeZoneId, IanaTimeZoneId, CountryCode) VALUES
('IST', 'India Standard Time', '+05:30', 330, 0, 'India Standard Time', 'Asia/Kolkata', 'IN');


-- =============================================================================================================
-- SEED DATA - Country
-- =============================================================================================================

PRINT 'Inserting Country...';
INSERT INTO time.Country (CountryCode, CountryName, CurrencyCode, TimeZoneId) VALUES
('IN', 'India', 'INR', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'));

-- =============================================================================================================
-- SEED DATA - Region
-- =============================================================================================================

PRINT 'Inserting Region...';
-- States
INSERT INTO time.Region (CountryId, RegionName, RegionType, ParentRegionId) VALUES
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Maharashtra',      'State', NULL),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Delhi',            'State', NULL),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Karnataka',        'State', NULL),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Tamil Nadu',       'State', NULL),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Telangana',        'State', NULL),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'West Bengal',      'State', NULL);

-- Cities
INSERT INTO time.Region (CountryId, RegionName, RegionType, ParentRegionId) VALUES
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Mumbai',       'City', (SELECT Id FROM time.Region WHERE RegionName='Maharashtra')),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Pune',         'City', (SELECT Id FROM time.Region WHERE RegionName='Maharashtra')),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'New Delhi',    'City', (SELECT Id FROM time.Region WHERE RegionName='Delhi')),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Bengaluru',    'City', (SELECT Id FROM time.Region WHERE RegionName='Karnataka')),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Chennai',      'City', (SELECT Id FROM time.Region WHERE RegionName='Tamil Nadu')),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Hyderabad',    'City', (SELECT Id FROM time.Region WHERE RegionName='Telangana')),
((SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Kolkata',      'City', (SELECT Id FROM time.Region WHERE RegionName='West Bengal'));

-- =============================================================================================================
-- SEED DATA - LegalEntity
-- =============================================================================================================

PRINT 'Inserting LegalEntity...';
INSERT INTO time.LegalEntity (EntityCode, EntityName, CountryId, TaxIdentificationNumber, RegistrationNumber, CurrencyCode) VALUES
('MEDCARE-IN',      'MedCare India Pvt. Ltd.',              (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'AABCM1234A',    'U85110MH2005PTC154321', 'INR'),
('MEDCARE-NORTH',   'MedCare North India Healthcare Ltd.',  (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'AABCM5678B',    'U85110DL2010PTC199876', 'INR'),
('MEDCARE-SOUTH',   'MedCare South India Hospitals Pvt. Ltd.', (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'AABCM9012C', 'U85110KA2012PTC234567', 'INR');


-- =============================================================================================================
-- SEED DATA - OfficeLocation
-- =============================================================================================================

PRINT 'Inserting OfficeLocation...';
INSERT INTO time.OfficeLocation (LegalEntityId, CountryId, RegionId, LocationCode, LocationName, BuildingName, AddressLine1, City, StateProvince, PostalCode, Latitude, Longitude, TimeZoneId, IsHeadOffice) VALUES
(
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'),
    (SELECT Id FROM time.Country WHERE CountryCode='IN'),
    (SELECT Id FROM time.Region WHERE RegionName='Mumbai'),
    'LOC-MUM-HQ', 'MedCare Mumbai HQ & Hospital', 'MedCare Tower',
    'Plot 14, Bandra Kurla Complex', 'Mumbai', 'Maharashtra', '400051',
    19.0659600, 72.8684700,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), 1
),
(
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-IN'),
    (SELECT Id FROM time.Country WHERE CountryCode='IN'),
    (SELECT Id FROM time.Region WHERE RegionName='Pune'),
    'LOC-PUN-01', 'MedCare Pune Hospital', 'Koregaon Medical Complex',
    'Survey No. 55, Koregaon Park', 'Pune', 'Maharashtra', '411001',
    18.5314100, 73.8936400,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'),
    (SELECT Id FROM time.Country WHERE CountryCode='IN'),
    (SELECT Id FROM time.Region WHERE RegionName='New Delhi'),
    'LOC-DEL-01', 'MedCare Delhi Super Specialty Hospital', 'MedCare Delhi Block',
    'A-12, Sector 62, Noida Adjacent', 'New Delhi', 'Delhi', '110001',
    28.6270100, 77.2186000,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    (SELECT Id FROM time.Country WHERE CountryCode='IN'),
    (SELECT Id FROM time.Region WHERE RegionName='Bengaluru'),
    'LOC-BLR-01', 'MedCare Bengaluru Hospital', 'Whitefield Medical Hub',
    '48, EPIP Zone, Whitefield', 'Bengaluru', 'Karnataka', '560066',
    12.9716000, 77.5946000,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    (SELECT Id FROM time.Country WHERE CountryCode='IN'),
    (SELECT Id FROM time.Region WHERE RegionName='Chennai'),
    'LOC-CHN-01', 'MedCare Chennai Multi-Specialty Hospital', 'Perambur Health City',
    '22, Anna Salai, Perambur', 'Chennai', 'Tamil Nadu', '600011',
    13.0827400, 80.2707200,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    (SELECT Id FROM time.Country WHERE CountryCode='IN'),
    (SELECT Id FROM time.Region WHERE RegionName='Hyderabad'),
    'LOC-HYD-01', 'MedCare Hyderabad Hospital', 'HITEC Health Park',
    '8-2-268/A, Road No. 3, Banjara Hills', 'Hyderabad', 'Telangana', '500034',
    17.3850000, 78.4867000,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), 0
),
(
    (SELECT Id FROM time.LegalEntity WHERE EntityCode='MEDCARE-NORTH'),
    (SELECT Id FROM time.Country WHERE CountryCode='IN'),
    (SELECT Id FROM time.Region WHERE RegionName='Kolkata'),
    'LOC-KOL-01', 'MedCare Kolkata Diagnostic & Hospital', 'Salt Lake Medical Tower',
    'Block CD-52, Sector 1, Salt Lake City', 'Kolkata', 'West Bengal', '700064',
    22.5726000, 88.3639000,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode='IST'), 0
);

-- =============================================================================================================
-- SEED DATA - Department
-- =============================================================================================================

PRINT 'Inserting Department...';
INSERT INTO time.Department (DepartmentCode, DepartmentName, ParentDepartmentId, Description) VALUES
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
INSERT INTO time.Department (DepartmentCode, DepartmentName, ParentDepartmentId, Description) VALUES
('CARDIOLOGY',  'Cardiology',       (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),   'Heart and cardiovascular services'),
('ORTHOPEDICS', 'Orthopedics',      (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),   'Bone, joint and musculoskeletal care'),
('PEDIATRICS',  'Pediatrics',       (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),   'Child and neonatal care'),
('ONCOLOGY',    'Oncology',         (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),   'Cancer diagnosis and treatment'),
('NEUROLOGY',   'Neurology',        (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),   'Brain and nervous system care'),
('RADIOLOGY',   'Radiology',        (SELECT Id FROM time.Department WHERE DepartmentCode='DIAGNOSTICS'),'X-Ray, MRI, CT Scan services'),
('PATHOLOGY',   'Pathology & Lab',  (SELECT Id FROM time.Department WHERE DepartmentCode='DIAGNOSTICS'),'Blood tests, biopsies, cultures'),
('ICU',         'Intensive Care Unit', (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'), 'Critical care nursing');

-- =============================================================================================================
-- SEED DATA - Scope Types
-- =============================================================================================================

PRINT 'Inserting Scope Types...';
INSERT INTO time.ScopeType (ScopeCode, ScopeName, HierarchyLevel)
VALUES
('GLOBAL', 'Global', 1),
('COUNTRY', 'Country', 2),
('LEGAL_ENTITY', 'Legal Entity', 3),
('OFFICE', 'Office', 4),
('DEPARTMENT', 'Department', 5),
('TEAM', 'Team', 6),
('EMPLOYEE', 'Employee', 7);

-- =============================================================================================================
-- SEED DATA - Designation
-- =============================================================================================================

PRINT 'Inserting Designation...';
INSERT INTO time.Designation (DesignationCode, DesignationName, Grade) VALUES
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


-- =============================================================================================================
-- SEED DATA - DocumentType
-- =============================================================================================================

PRINT 'Inserting DocumentType...';
INSERT INTO time.DocumentType (DocumentTypeCode, DocumentTypeName, Description, IsMandatory) VALUES
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
-- SEED DATA - GeoFence
-- =============================================================================================================

PRINT 'Inserting GeoFence...';
INSERT INTO time.GeoFence (GeoFenceCode, GeoFenceName, Latitude, Longitude, RadiusMeters, OfficeId) VALUES
('GEO-MUM-HQ',  'Mumbai HQ Geo-Fence',          19.06596000, 72.86847000, 150.00, (SELECT Id FROM  time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ')),
('GEO-PUN-01',  'Pune Hospital Geo-Fence',       18.53141000, 73.89364000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01')),
('GEO-DEL-01',  'Delhi Hospital Geo-Fence',      28.62701000, 77.21860000, 200.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01')),
('GEO-BLR-01',  'Bengaluru Hospital Geo-Fence',  12.97160000, 77.59460000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01')),
('GEO-CHN-01',  'Chennai Hospital Geo-Fence',    13.08274000, 80.27072000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01')),
('GEO-HYD-01',  'Hyderabad Hospital Geo-Fence',  17.38500000, 78.48670000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01')),
('GEO-KOL-01',  'Kolkata Hospital Geo-Fence',    22.57260000, 88.36390000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'));

-- =============================================================================================================
-- SEED DATA - BiometricDevice
-- =============================================================================================================

PRINT 'Inserting BiometricDevice...';
INSERT INTO time.BiometricDevice (DeviceCode, DeviceName, SerialNumber, OfficeId, IpAddress) VALUES
('BIO-MUM-01', 'Suprema BioStation A2 - Mumbai Main Gate',      'SN-BIO-MUM-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.101'),
('BIO-MUM-02', 'Suprema BioStation A2 - Mumbai Ward Block',     'SN-BIO-MUM-002', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.102'),
('BIO-MUM-03', 'ZKTeco F22 - Mumbai Emergency Entry',           'SN-BIO-MUM-003', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.103'),
('BIO-PUN-01', 'Suprema BioStation - Pune Main Entrance',       'SN-BIO-PUN-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), '10.20.1.101'),
('BIO-DEL-01', 'ZKTeco K40 - Delhi Main Gate',                  'SN-BIO-DEL-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), '10.30.1.101'),
('BIO-DEL-02', 'ZKTeco K40 - Delhi Emergency Wing',             'SN-BIO-DEL-002', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), '10.30.1.102'),
('BIO-BLR-01', 'Realand A-F191 - Bengaluru Main Gate',          'SN-BIO-BLR-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), '10.40.1.101'),
('BIO-CHN-01', 'eSSL eTime Track - Chennai Main Entrance',      'SN-BIO-CHN-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), '10.50.1.101'),
('BIO-HYD-01', 'Suprema CoreStation - Hyderabad Main Gate',     'SN-BIO-HYD-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), '10.60.1.101'),
('BIO-KOL-01', 'ZKTeco F22 - Kolkata Main Entrance',            'SN-BIO-KOL-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), '10.70.1.101');


COMMIT TRANSACTION;
PRINT 'Time schema seed data inserted successfully.';
GO