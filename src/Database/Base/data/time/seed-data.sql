-- TIME SCHEMA - Seed Data
-- Organization: MedCare India Pvt. Ltd. (India)
-- Dependencies: shared.StatusLookup
-- All PKs are UNIQUEIDENTIFIER with no DEFAULT — NEWID() supplied on every INSERT.
-- time.Country.CreatedBy / LastUpdatedBy are INT (not yet migrated) — omitted.

-- ============================================================
-- SEED DATA - TimeZoneMaster
-- ============================================================

PRINT 'Inserting TimeZoneMaster...';
INSERT INTO time.TimeZoneMaster (Id, TimeZoneCode, TimeZoneName, UtcOffset, OffsetMinutes, SupportsDaylightSaving, WindowsTimeZoneId, IanaTimeZoneId, CountryCode) VALUES
(NEWID(), 'IST', 'India Standard Time', '+05:30', 330, 0, 'India Standard Time', 'Asia/Kolkata', 'IN');


-- ============================================================
-- SEED DATA - Country
-- ============================================================
-- Note: CreatedBy / LastUpdatedBy are INT in this table — omitted (default NULL).

PRINT 'Inserting Country...';
INSERT INTO time.Country (Id, CountryCode, CountryName, CurrencyCode, TimeZoneId) VALUES
(NEWID(), 'IN', 'India', 'INR', (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'));


-- ============================================================
-- SEED DATA - Region (States)
-- ============================================================

PRINT 'Inserting Region (States)...';
INSERT INTO time.Region (Id, CountryId, RegionName, RegionType, ParentRegionId) VALUES
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Maharashtra',  'State', NULL),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Delhi',        'State', NULL),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Karnataka',    'State', NULL),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Tamil Nadu',   'State', NULL),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Telangana',    'State', NULL),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'West Bengal',  'State', NULL);

-- Cities (inserted after states so ParentRegionId subqueries resolve correctly)
PRINT 'Inserting Region (Cities)...';
INSERT INTO time.Region (Id, CountryId, RegionName, RegionType, ParentRegionId) VALUES
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Mumbai',    'City', (SELECT Id FROM time.Region WHERE RegionName='Maharashtra' AND RegionType='State')),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Pune',      'City', (SELECT Id FROM time.Region WHERE RegionName='Maharashtra' AND RegionType='State')),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'New Delhi', 'City', (SELECT Id FROM time.Region WHERE RegionName='Delhi'       AND RegionType='State')),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Bengaluru', 'City', (SELECT Id FROM time.Region WHERE RegionName='Karnataka'   AND RegionType='State')),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Chennai',   'City', (SELECT Id FROM time.Region WHERE RegionName='Tamil Nadu'  AND RegionType='State')),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Hyderabad', 'City', (SELECT Id FROM time.Region WHERE RegionName='Telangana'   AND RegionType='State')),
(NEWID(), (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'Kolkata',   'City', (SELECT Id FROM time.Region WHERE RegionName='West Bengal' AND RegionType='State'));


-- ============================================================
-- SEED DATA - LegalEntity
-- ============================================================

PRINT 'Inserting LegalEntity...';
INSERT INTO time.LegalEntity (Id, EntityCode, EntityName, CountryId, TaxIdentificationNumber, RegistrationNumber, CurrencyCode) VALUES
(NEWID(), 'MEDCARE-IN',    'MedCare India Pvt. Ltd.',                 (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'AABCM1234A', 'U85110MH2005PTC154321', 'INR'),
(NEWID(), 'MEDCARE-NORTH', 'MedCare North India Healthcare Ltd.',     (SELECT Id FROM time.Country WHERE CountryCode='IN'), 'AABCM5678B', 'U85110DL2010PTC199876', 'INR'),
(NEWID(), 'MEDCARE-SOUTH', 'MedCare South India Hospitals Pvt. Ltd.',(SELECT Id FROM time.Country WHERE CountryCode='IN'), 'AABCM9012C', 'U85110KA2012PTC234567', 'INR');


-- ============================================================
-- SEED DATA - OfficeLocation
-- ============================================================

PRINT 'Inserting OfficeLocation...';
INSERT INTO time.OfficeLocation (Id, LegalEntityId, CountryId, RegionId, LocationCode, LocationName, BuildingName, AddressLine1, City, StateProvince, PostalCode, Latitude, Longitude, TimeZoneId, IsHeadOffice) VALUES
(
    NEWID(),
    (SELECT Id FROM time.LegalEntity    WHERE EntityCode   = 'MEDCARE-IN'),
    (SELECT Id FROM time.Country        WHERE CountryCode  = 'IN'),
    (SELECT Id FROM time.Region         WHERE RegionName   = 'Mumbai'    AND RegionType = 'City'),
    'LOC-MUM-HQ', 'MedCare Mumbai HQ & Hospital', 'MedCare Tower',
    'Plot 14, Bandra Kurla Complex', 'Mumbai', 'Maharashtra', '400051',
    19.0659600, 72.8684700,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'), 1
),
(
    NEWID(),
    (SELECT Id FROM time.LegalEntity    WHERE EntityCode   = 'MEDCARE-IN'),
    (SELECT Id FROM time.Country        WHERE CountryCode  = 'IN'),
    (SELECT Id FROM time.Region         WHERE RegionName   = 'Pune'      AND RegionType = 'City'),
    'LOC-PUN-01', 'MedCare Pune Hospital', 'Koregaon Medical Complex',
    'Survey No. 55, Koregaon Park', 'Pune', 'Maharashtra', '411001',
    18.5314100, 73.8936400,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'), 0
),
(
    NEWID(),
    (SELECT Id FROM time.LegalEntity    WHERE EntityCode   = 'MEDCARE-NORTH'),
    (SELECT Id FROM time.Country        WHERE CountryCode  = 'IN'),
    (SELECT Id FROM time.Region         WHERE RegionName   = 'New Delhi'  AND RegionType = 'City'),
    'LOC-DEL-01', 'MedCare Delhi Super Specialty Hospital', 'MedCare Delhi Block',
    'A-12, Sector 62, Noida Adjacent', 'New Delhi', 'Delhi', '110001',
    28.6270100, 77.2186000,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'), 0
),
(
    NEWID(),
    (SELECT Id FROM time.LegalEntity    WHERE EntityCode   = 'MEDCARE-SOUTH'),
    (SELECT Id FROM time.Country        WHERE CountryCode  = 'IN'),
    (SELECT Id FROM time.Region         WHERE RegionName   = 'Bengaluru'  AND RegionType = 'City'),
    'LOC-BLR-01', 'MedCare Bengaluru Hospital', 'Whitefield Medical Hub',
    '48, EPIP Zone, Whitefield', 'Bengaluru', 'Karnataka', '560066',
    12.9716000, 77.5946000,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'), 0
),
(
    NEWID(),
    (SELECT Id FROM time.LegalEntity    WHERE EntityCode   = 'MEDCARE-SOUTH'),
    (SELECT Id FROM time.Country        WHERE CountryCode  = 'IN'),
    (SELECT Id FROM time.Region         WHERE RegionName   = 'Chennai'    AND RegionType = 'City'),
    'LOC-CHN-01', 'MedCare Chennai Multi-Specialty Hospital', 'Perambur Health City',
    '22, Anna Salai, Perambur', 'Chennai', 'Tamil Nadu', '600011',
    13.0827400, 80.2707200,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'), 0
),
(
    NEWID(),
    (SELECT Id FROM time.LegalEntity    WHERE EntityCode   = 'MEDCARE-SOUTH'),
    (SELECT Id FROM time.Country        WHERE CountryCode  = 'IN'),
    (SELECT Id FROM time.Region         WHERE RegionName   = 'Hyderabad'  AND RegionType = 'City'),
    'LOC-HYD-01', 'MedCare Hyderabad Hospital', 'HITEC Health Park',
    '8-2-268/A, Road No. 3, Banjara Hills', 'Hyderabad', 'Telangana', '500034',
    17.3850000, 78.4867000,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'), 0
),
(
    NEWID(),
    (SELECT Id FROM time.LegalEntity    WHERE EntityCode   = 'MEDCARE-NORTH'),
    (SELECT Id FROM time.Country        WHERE CountryCode  = 'IN'),
    (SELECT Id FROM time.Region         WHERE RegionName   = 'Kolkata'    AND RegionType = 'City'),
    'LOC-KOL-01', 'MedCare Kolkata Diagnostic & Hospital', 'Salt Lake Medical Tower',
    'Block CD-52, Sector 1, Salt Lake City', 'Kolkata', 'West Bengal', '700064',
    22.5726000, 88.3639000,
    (SELECT Id FROM time.TimeZoneMaster WHERE TimeZoneCode = 'IST'), 0
);


-- ============================================================
-- SEED DATA - Department
-- ============================================================

PRINT 'Inserting Department (top-level)...';
INSERT INTO time.Department (Id, DepartmentCode, DepartmentName, ParentDepartmentId, Description) VALUES
(NEWID(), 'CLINICAL',    'Clinical Services',        NULL, 'All clinical and patient-care departments'),
(NEWID(), 'NURSING',     'Nursing Services',         NULL, 'Nursing operations and ward management'),
(NEWID(), 'PHARMACY',    'Pharmacy',                 NULL, 'Drug dispensing and management'),
(NEWID(), 'DIAGNOSTICS', 'Diagnostics',              NULL, 'Radiology, Pathology and Lab Services'),
(NEWID(), 'EMERGENCY',   'Emergency & Trauma',       NULL, 'Emergency medicine and trauma care'),
(NEWID(), 'ADMIN',       'Administration',           NULL, 'Hospital administration and front desk'),
(NEWID(), 'HR',          'Human Resources',          NULL, 'HR operations, recruitment and compliance'),
(NEWID(), 'IT',          'Information Technology',   NULL, 'Hospital IT systems, EHR, network'),
(NEWID(), 'FINANCE',     'Finance & Accounts',       NULL, 'Billing, payroll, financial control'),
(NEWID(), 'OPERATIONS',  'Operations',               NULL, 'Housekeeping, facilities, transport'),
(NEWID(), 'SURGERY',     'Surgery',                  NULL, 'General and specialized surgical services');

-- Sub-departments (inserted after top-level so ParentDepartmentId subqueries resolve)
PRINT 'Inserting Department (sub-departments)...';
INSERT INTO time.Department (Id, DepartmentCode, DepartmentName, ParentDepartmentId, Description) VALUES
(NEWID(), 'CARDIOLOGY',  'Cardiology',            (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    'Heart and cardiovascular services'),
(NEWID(), 'ORTHOPEDICS', 'Orthopedics',           (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    'Bone, joint and musculoskeletal care'),
(NEWID(), 'PEDIATRICS',  'Pediatrics',            (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    'Child and neonatal care'),
(NEWID(), 'ONCOLOGY',    'Oncology',              (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    'Cancer diagnosis and treatment'),
(NEWID(), 'NEUROLOGY',   'Neurology',             (SELECT Id FROM time.Department WHERE DepartmentCode='CLINICAL'),    'Brain and nervous system care'),
(NEWID(), 'RADIOLOGY',   'Radiology',             (SELECT Id FROM time.Department WHERE DepartmentCode='DIAGNOSTICS'), 'X-Ray, MRI, CT Scan services'),
(NEWID(), 'PATHOLOGY',   'Pathology & Lab',       (SELECT Id FROM time.Department WHERE DepartmentCode='DIAGNOSTICS'), 'Blood tests, biopsies, cultures'),
(NEWID(), 'ICU',         'Intensive Care Unit',   (SELECT Id FROM time.Department WHERE DepartmentCode='NURSING'),     'Critical care nursing');


-- ============================================================
-- SEED DATA - ScopeType
-- ============================================================

PRINT 'Inserting ScopeType...';
INSERT INTO time.ScopeType (Id, ScopeCode, ScopeName, HierarchyLevel) VALUES
(NEWID(), 'GLOBAL',       'Global',       1),
(NEWID(), 'COUNTRY',      'Country',      2),
(NEWID(), 'LEGAL_ENTITY', 'Legal Entity', 3),
(NEWID(), 'OFFICE',       'Office',       4),
(NEWID(), 'DEPARTMENT',   'Department',   5),
(NEWID(), 'TEAM',         'Team',         6),
(NEWID(), 'EMPLOYEE',     'Employee',     7);


-- ============================================================
-- SEED DATA - Designation
-- ============================================================

PRINT 'Inserting Designation...';
INSERT INTO time.Designation (Id, DesignationCode, DesignationName, Grade) VALUES
(NEWID(), 'CHMO',         'Chief Medical Officer',            'L10'),
(NEWID(), 'MEDDIRECTOR',  'Medical Director',                 'L9'),
(NEWID(), 'SRSURGEON',    'Senior Consultant Surgeon',        'L8'),
(NEWID(), 'CONSULTANT',   'Consultant Physician',             'L7'),
(NEWID(), 'RESIDENTDR',   'Resident Doctor',                  'L5'),
(NEWID(), 'JRRESIDENT',   'Junior Resident',                  'L4'),
(NEWID(), 'CHFNURSE',     'Chief Nursing Officer',            'L8'),
(NEWID(), 'SRNURSE',      'Senior Staff Nurse',               'L5'),
(NEWID(), 'STAFFNURSE',   'Staff Nurse',                      'L4'),
(NEWID(), 'JRNURSE',      'Junior Staff Nurse',               'L3'),
(NEWID(), 'CHIEFPHARM',   'Chief Pharmacist',                 'L7'),
(NEWID(), 'SRPHARM',      'Senior Pharmacist',                'L5'),
(NEWID(), 'PHARMACIST',   'Pharmacist',                       'L4'),
(NEWID(), 'RADIOLOGIST',  'Radiologist',                      'L7'),
(NEWID(), 'RADTECH',      'Radiology Technician',             'L4'),
(NEWID(), 'PATHOLOGIST',  'Pathologist',                      'L7'),
(NEWID(), 'LABTECH',      'Laboratory Technician',            'L4'),
(NEWID(), 'HOPADMIN',     'Hospital Administrator',           'L8'),
(NEWID(), 'ADMEXEC',      'Administrative Executive',         'L4'),
(NEWID(), 'FRONTDESK',    'Front Desk Executive',             'L3'),
(NEWID(), 'HRMANAGER',    'HR Manager',                       'L7'),
(NEWID(), 'HRBP',         'HR Business Partner',              'L5'),
(NEWID(), 'HREXEC',       'HR Executive',                     'L4'),
(NEWID(), 'ITMANAGER',    'IT Manager',                       'L7'),
(NEWID(), 'SRSYSADMIN',   'Senior Systems Administrator',     'L5'),
(NEWID(), 'SYSADMIN',     'Systems Administrator',            'L4'),
(NEWID(), 'FINMANAGER',   'Finance Manager',                  'L7'),
(NEWID(), 'ACCOUNTANT',   'Accountant',                       'L4'),
(NEWID(), 'OPSMGR',       'Operations Manager',               'L7'),
(NEWID(), 'OPSEXEC',      'Operations Executive',             'L4'),
(NEWID(), 'EMERPHYSICIAN','Emergency Medicine Physician',     'L7'),
(NEWID(), 'PARAMEDICOFF', 'Paramedic Officer',                'L4'),
(NEWID(), 'WARDBOY',      'Ward Boy / Patient Attendant',     'L2'),
(NEWID(), 'HOUSEKEEPING', 'Housekeeping Supervisor',          'L3'),
(NEWID(), 'AMBULANCEDRV', 'Ambulance Driver',                 'L2');


-- ============================================================
-- SEED DATA - DocumentType
-- ============================================================

PRINT 'Inserting DocumentType...';
INSERT INTO time.DocumentType (Id, DocumentTypeCode, DocumentTypeName, Description, IsMandatory) VALUES
(NEWID(), 'AADHAAR',      'Aadhaar Card',                     'Government-issued biometric identity card',              1),
(NEWID(), 'PAN',          'PAN Card',                         'Permanent Account Number for taxation',                  1),
(NEWID(), 'PASSPORT',     'Passport',                         'International travel document',                          0),
(NEWID(), 'MEDLICENSE',   'Medical License / MCI Reg.',       'Medical Council of India registration',                  1),
(NEWID(), 'NURSINGREG',   'Nursing Council Registration',     'State/National Nursing Council certificate',             1),
(NEWID(), 'PHARMLICENSE', 'Pharmacy License',                 'State Pharmacy Council registration',                    1),
(NEWID(), 'OFFLETTER',    'Offer Letter',                     'Signed employment offer letter',                         1),
(NEWID(), 'JOININGFORM',  'Joining Form',                     'Employee joining and declaration form',                  1),
(NEWID(), 'EDUCATIONCERT','Educational Certificates',         'Degree/diploma certificates',                            1),
(NEWID(), 'PREVEXPLETT',  'Previous Experience Letter',       'Relieving/experience letter from prior employer',        0),
(NEWID(), 'BANKDETAILS',  'Bank Account Details',             'Cancelled cheque or bank passbook',                      1),
(NEWID(), 'COVIDVACC',    'COVID-19 Vaccination Certificate', 'Full vaccination proof',                                 1);


-- ============================================================
-- SEED DATA - GeoFence
-- ============================================================

PRINT 'Inserting GeoFence...';
INSERT INTO time.GeoFence (Id, GeoFenceCode, GeoFenceName, Latitude, Longitude, RadiusMeters, OfficeId) VALUES
(NEWID(), 'GEO-MUM-HQ', 'Mumbai HQ Geo-Fence',         19.06596000, 72.86847000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ')),
(NEWID(), 'GEO-PUN-01', 'Pune Hospital Geo-Fence',      18.53141000, 73.89364000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01')),
(NEWID(), 'GEO-DEL-01', 'Delhi Hospital Geo-Fence',     28.62701000, 77.21860000, 200.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01')),
(NEWID(), 'GEO-BLR-01', 'Bengaluru Hospital Geo-Fence', 12.97160000, 77.59460000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01')),
(NEWID(), 'GEO-CHN-01', 'Chennai Hospital Geo-Fence',   13.08274000, 80.27072000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01')),
(NEWID(), 'GEO-HYD-01', 'Hyderabad Hospital Geo-Fence', 17.38500000, 78.48670000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01')),
(NEWID(), 'GEO-KOL-01', 'Kolkata Hospital Geo-Fence',   22.57260000, 88.36390000, 150.00, (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'));


-- ============================================================
-- SEED DATA - BiometricDevice
-- ============================================================

PRINT 'Inserting BiometricDevice...';
INSERT INTO time.BiometricDevice (Id, DeviceCode, DeviceName, SerialNumber, OfficeId, IpAddress) VALUES
(NEWID(), 'BIO-MUM-01', 'Suprema BioStation A2 - Mumbai Main Gate',    'SN-BIO-MUM-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.101'),
(NEWID(), 'BIO-MUM-02', 'Suprema BioStation A2 - Mumbai Ward Block',   'SN-BIO-MUM-002', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.102'),
(NEWID(), 'BIO-MUM-03', 'ZKTeco F22 - Mumbai Emergency Entry',         'SN-BIO-MUM-003', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'), '10.10.1.103'),
(NEWID(), 'BIO-PUN-01', 'Suprema BioStation - Pune Main Entrance',     'SN-BIO-PUN-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'), '10.20.1.101'),
(NEWID(), 'BIO-DEL-01', 'ZKTeco K40 - Delhi Main Gate',                'SN-BIO-DEL-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), '10.30.1.101'),
(NEWID(), 'BIO-DEL-02', 'ZKTeco K40 - Delhi Emergency Wing',           'SN-BIO-DEL-002', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'), '10.30.1.102'),
(NEWID(), 'BIO-BLR-01', 'Realand A-F191 - Bengaluru Main Gate',        'SN-BIO-BLR-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'), '10.40.1.101'),
(NEWID(), 'BIO-CHN-01', 'eSSL eTime Track - Chennai Main Entrance',    'SN-BIO-CHN-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'), '10.50.1.101'),
(NEWID(), 'BIO-HYD-01', 'Suprema CoreStation - Hyderabad Main Gate',   'SN-BIO-HYD-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'), '10.60.1.101'),
(NEWID(), 'BIO-KOL-01', 'ZKTeco F22 - Kolkata Main Entrance',          'SN-BIO-KOL-001', (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'), '10.70.1.101');


PRINT 'Time schema seed data inserted successfully.';
GO
