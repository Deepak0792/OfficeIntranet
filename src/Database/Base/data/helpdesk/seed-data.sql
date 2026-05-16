-- HELPDESK SCHEMA - Seed Data
-- Organization: MedCare India Pvt. Ltd.
-- Dependencies: shared.StatusLookup, employee.Employee, time.OfficeLocation, time.Department
-- Run Order   : After shared, time, employee schemas are seeded.

-- MODULE 1 : MASTER TABLES

-- -------------------------------------------------------------------------------------------------------------
-- 1.1  Ticket Categories  (two-level hierarchy)
-- -------------------------------------------------------------------------------------------------------------
PRINT 'Inserting TicketCategory...';

INSERT INTO helpdesk.TicketCategory (CategoryCode, CategoryName, Description) VALUES
('HARDWARE',        'Hardware',              'All physical device issues'),
('SOFTWARE',        'Software',              'Application and OS issues'),
('NETWORK',         'Network',               'LAN, Wi-Fi, VPN connectivity'),
('ACCESS',          'Access & Permissions',  'User access, AD, role-based permissions'),
('SECURITY',        'Security',              'Virus, phishing, data-breach incidents'),
('EMAIL',           'Email',                 'Email configuration, delivery, spam'),
('EHR_EMR',         'EHR / EMR System',      'Electronic Health Record system issues'),
('BIOMEDICAL',      'Biomedical Equipment',  'Medical device IT interface issues'),
('GENERAL',         'General IT Support',    'Miscellaneous IT requests');

-- Sub-categories (ParentCategoryId resolved by code)
INSERT INTO helpdesk.TicketCategory (CategoryCode, CategoryName, ParentCategoryId, Description) VALUES
('HW_LAPTOP',       'Laptop Issue',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='HARDWARE'),
    'Laptop not booting, display, keyboard issues'),
('HW_DESKTOP',      'Desktop / Workstation',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='HARDWARE'),
    'Desktop or tower unit issues'),
('HW_PRINTER',      'Printer / Scanner',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='HARDWARE'),
    'Printing, scanning, paper-jam issues'),
('HW_PERIPHERAL',   'Peripheral Devices',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='HARDWARE'),
    'Mouse, keyboard, headset, webcam'),
('SW_OS',           'Operating System',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='SOFTWARE'),
    'Windows / Linux OS issues'),
('SW_OFFICE',       'MS Office / Productivity',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='SOFTWARE'),
    'Word, Excel, Teams, Outlook issues'),
('SW_ANTIVIRUS',    'Antivirus / EDR',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='SOFTWARE'),
    'Antivirus alerts, quarantine, updates'),
('SW_ERP',          'ERP / HRIS System',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='SOFTWARE'),
    'Payroll, HR, attendance system issues'),
('NET_WIFI',        'Wi-Fi Connectivity',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='NETWORK'),
    'Wireless network not connecting'),
('NET_LAN',         'LAN / Ethernet',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='NETWORK'),
    'Wired network and switch issues'),
('NET_VPN',         'VPN Access',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='NETWORK'),
    'Remote access VPN setup and drops'),
('ACC_AD',          'Active Directory / SSO',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='ACCESS'),
    'Password reset, account lockout'),
('ACC_APP',         'Application Access',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='ACCESS'),
    'Access to specific applications'),
('EHR_LOGIN',       'EHR Login / Access',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='EHR_EMR'),
    'EHR login failure, role mapping'),
('EHR_PERF',        'EHR Performance',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='EHR_EMR'),
    'EHR slowness, timeouts, data sync'),
('BIO_INTERFACE',   'Biomedical Integration',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='BIOMEDICAL'),
    'HL7 / DICOM interface alerts'),
('SEC_PHISH',       'Phishing / Suspicious Email',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='SECURITY'),
    'Report suspicious emails'),
('SEC_MALWARE',     'Malware / Ransomware',
    (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='SECURITY'),
    'Malware detection and containment');


-- -------------------------------------------------------------------------------------------------------------
-- 1.2  Support Groups  (linked to time.Department)
-- -------------------------------------------------------------------------------------------------------------
PRINT 'Inserting SupportGroup...';

INSERT INTO helpdesk.SupportGroup (SupportGroupCode, SupportGroupName, DepartmentId, Description) VALUES
('DESKTOP_SUPPORT',  'Desktop Support',
    (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),
    'End-user hardware and OS support'),
('APP_SUPPORT',      'Application Support',
    (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),
    'ERP, EHR, productivity software support'),
('INFRA_OPS',        'IT Infrastructure & Ops',
    (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),
    'Network, server, VPN and data-centre'),
('SEC_OPS',          'Security Operations',
    (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),
    'Cyber-security incidents and compliance'),
('BIOMEDICAL_IT',    'Biomedical IT',
    (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),
    'Medical device IT interfaces and DICOM'),
('EHR_SUPPORT',      'EHR / EMR Support',
    (SELECT Id FROM time.Department WHERE DepartmentCode='IT'),
    'Electronic Health Record system support');


-- -------------------------------------------------------------------------------------------------------------
-- 1.3  Asset Categories  (two-level hierarchy)
-- -------------------------------------------------------------------------------------------------------------
PRINT 'Inserting AssetCategory...';

INSERT INTO helpdesk.AssetCategory (CategoryCode, CategoryName, IsTrackable, IsConsumable, Description) VALUES
('COMPUTE',         'Computing Devices',     1, 0, 'Laptops, desktops, servers'),
('NETWORK_HW',      'Network Hardware',      1, 0, 'Switches, routers, access points'),
('PERIPHERAL',      'Peripheral Devices',    1, 0, 'Monitors, printers, scanners'),
('MOBILE',          'Mobile Devices',        1, 0, 'Smartphones and tablets'),
('BIOMEDICAL_DEV',  'Biomedical Devices',    1, 0, 'Medical equipment with IT interface'),
('CONSUMABLE',      'Consumable Supplies',   0, 1, 'Ink cartridges, cables, batteries'),
('SERVER_HW',       'Server Hardware',       1, 0, 'Physical and rack servers'),
('SECURITY_HW',     'Security Hardware',     1, 0, 'CCTV, access-control, biometrics');

-- Sub-categories
INSERT INTO helpdesk.AssetCategory (CategoryCode, CategoryName, ParentCategoryId, IsTrackable, IsConsumable, Description) VALUES
('LAPTOP',          'Laptop',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='COMPUTE'), 1, 0, 'Portable laptops'),
('DESKTOP',         'Desktop / Workstation',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='COMPUTE'), 1, 0, 'Tower or all-in-one desktops'),
('THIN_CLIENT',     'Thin Client',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='COMPUTE'), 1, 0, 'Virtual desktop thin clients'),
('SWITCH',          'Network Switch',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='NETWORK_HW'), 1, 0, 'Managed and unmanaged switches'),
('ROUTER',          'Router / Firewall',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='NETWORK_HW'), 1, 0, 'Edge routers and UTM firewalls'),
('ACCESS_POINT',    'Wireless Access Point',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='NETWORK_HW'), 1, 0, 'Wi-Fi access points'),
('MONITOR',         'Monitor / Display',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='PERIPHERAL'), 1, 0, 'LCD / LED monitors'),
('PRINTER',         'Printer / Scanner',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='PERIPHERAL'), 1, 0, 'Laser and inkjet printers'),
('PHONE_MOBILE',    'Smartphone',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='MOBILE'), 1, 0, 'Android / iOS phones'),
('TABLET',          'Tablet',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='MOBILE'), 1, 0, 'iPad and Android tablets'),
('RACK_SERVER',     'Rack Server',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='SERVER_HW'), 1, 0, 'Dell/HP rack-mount servers'),
('NAS',             'NAS Storage',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='SERVER_HW'), 1, 0, 'Network-attached storage'),
('BIOMETRIC_DEV',   'Biometric Device',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='SECURITY_HW'), 1, 0, 'Fingerprint and face attendance devices');


-- -------------------------------------------------------------------------------------------------------------
-- 1.4  Vendors
-- -------------------------------------------------------------------------------------------------------------
PRINT 'Inserting Vendor...';

INSERT INTO helpdesk.Vendor
    (VendorCode, VendorName, ContactPerson, Email, MobileNumber, WebsiteUrl, Address)
VALUES
('VND-DELL',    'Dell Technologies India',       'Rohit Kapoor',     'rohit.kapoor@dell.com',          '9900110001', 'https://www.dell.com/en-in',        'Prestige Techpark, Marathahalli, Bengaluru 560037'),
('VND-HP',      'HP India Pvt. Ltd.',            'Sunita Menon',     'sunita.menon@hp.com',            '9900110002', 'https://www.hp.com/in-en',          'DLF IT Park, Sector 74A, Gurugram 122001'),
('VND-CISCO',   'Cisco Systems India',           'Arvind Nair',      'arvind.nair@cisco.com',          '9900110003', 'https://www.cisco.com/c/en_in',     'RMZ Infinity, Bengaluru 560016'),
('VND-LENOVO',  'Lenovo India Pvt. Ltd.',        'Priti Sharma',     'priti.sharma@lenovo.com',        '9900110004', 'https://www.lenovo.com/in/en',      'World Trade Center, Bengaluru 560001'),
('VND-MS',      'Microsoft India Pvt. Ltd.',     'Sanjay Bose',      'sanjay.bose@microsoft.com',      '9900110005', 'https://www.microsoft.com/en-in',   'Embassy Golf Links, Bengaluru 560071'),
('VND-ADOBE',   'Adobe Systems India',           'Kavita Reddy',     'kavita.reddy@adobe.com',         '9900110006', 'https://www.adobe.com/in',          'Divyasree Technopolis, Hyderabad 500081'),
('VND-ZOHO',    'Zoho Corporation Pvt. Ltd.',    'Balaji Sundaram',  'balaji.sundaram@zoho.com',       '9900110007', 'https://www.zoho.com',              'Estancia IT Park, Chennai 600044'),
('VND-AMC',     'TechCare AMC Services',         'Rajesh Patil',     'rajesh.patil@techcare.in',       '9900110008', NULL,                                '34 Kalina Road, Santacruz East, Mumbai 400055'),
('VND-DIAG',    'Diagno IT Solutions',           'Meena Iyer',       'meena.iyer@diagnoit.in',         '9900110009', NULL,                                '12 Hitech City Rd, Hyderabad 500081'),
('VND-BIOCON',  'Biocon Medical Systems',        'Girish Rao',       'girish.rao@bioconmed.in',        '9900110010', NULL,                                '78 Whitefield Main Rd, Bengaluru 560066');


-- MODULE 3 : SLA POLICIES
PRINT 'Inserting SlaPolicy...';

INSERT INTO helpdesk.SlaPolicy
    (PolicyCode, PolicyName, TicketPriorityCode, ResponseTimeMinutes, ResolutionTimeMinutes, EscalationTimeMinutes)
VALUES
('SLA-CRIT',   'Critical SLA',    'CRITICAL',  15,    240,    180),
('SLA-HIGH',   'High SLA',        'HIGH',      60,    480,    360),
('SLA-MED',    'Medium SLA',      'MEDIUM',    240,   1440,   1200),
('SLA-LOW',    'Low SLA',         'LOW',       480,   4320,   3600);


-- MODULE 4 : ASSETS
PRINT 'Inserting Asset...';

INSERT INTO helpdesk.Asset
    (AssetCode, AssetTag, AssetName,
     AssetCategoryId, AssetStatusCode, VendorId,
     SerialNumber, ModelNumber, Manufacturer,
     OperatingSystem, MacAddress, IpAddress, HostName,
     PurchaseDate, WarrantyExpiryDate, PurchaseCost, CurrentBookValue,
     OfficeLocationId, CurrentEmployeeId, Description)
VALUES
-- ── Mumbai HQ Laptops ────────────────────────────────────────────────────
('AST-001', 'TAG-MUM-001', 'Dell Latitude 5540',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-001', 'Latitude 5540', 'Dell',
    'Windows 11 Pro', 'A4:C3:F1:01:02:03', '10.10.1.11', 'MEDMUM-WS001',
    '2023-04-01', '2026-03-31', 82000.00, 60000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
    'IT Manager laptop'),
('AST-002', 'TAG-MUM-002', 'HP EliteBook 840 G10',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-HP'),
    'SN-HP-002', 'EliteBook 840 G10', 'HP',
    'Windows 11 Pro', 'A4:C3:F1:01:02:04', '10.10.1.12', 'MEDMUM-WS002',
    '2023-06-15', '2026-06-14', 79000.00, 55000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
    'HR Manager laptop'),
('AST-003', 'TAG-MUM-003', 'Dell Latitude 5540',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-003', 'Latitude 5540', 'Dell',
    'Windows 11 Pro', 'A4:C3:F1:01:02:05', '10.10.1.13', 'MEDMUM-WS003',
    '2023-04-01', '2026-03-31', 82000.00, 60000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'),
    'Finance Manager laptop'),
('AST-004', 'TAG-MUM-004', 'Lenovo ThinkPad X1 Carbon',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-LENOVO'),
    'SN-LEN-004', 'ThinkPad X1 Carbon Gen 11', 'Lenovo',
    'Windows 11 Pro', 'A4:C3:F1:01:02:06', '10.10.1.14', 'MEDMUM-WS004',
    '2022-11-10', '2025-11-09', 110000.00, 72000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'),
    'CMO executive laptop'),
('AST-005', 'TAG-MUM-005', 'Dell OptiPlex 7010',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='DESKTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-005', 'OptiPlex 7010', 'Dell',
    'Windows 10 Pro', 'A4:C3:F1:01:02:07', '10.10.1.15', 'MEDMUM-DT005',
    '2021-08-01', '2024-07-31', 55000.00, 22000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'),
    'Admin executive desktop'),
-- ── Delhi Laptops ─────────────────────────────────────────────────────────
('AST-006', 'TAG-DEL-001', 'HP EliteBook 840 G10',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-HP'),
    'SN-HP-006', 'EliteBook 840 G10', 'HP',
    'Windows 11 Pro', 'B5:D4:E2:02:03:01', '10.10.2.11', 'MEDDEL-WS001',
    '2023-07-01', '2026-06-30', 79000.00, 55000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'),
    'Delhi Medical Director laptop'),
('AST-007', 'TAG-DEL-002', 'Dell Latitude 5540',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-007', 'Latitude 5540', 'Dell',
    'Windows 11 Pro', 'B5:D4:E2:02:03:02', '10.10.2.12', 'MEDDEL-WS002',
    '2023-07-01', '2026-06-30', 82000.00, 60000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
    'HR BP Delhi laptop'),
-- ── Bengaluru Laptops ─────────────────────────────────────────────────────
('AST-008', 'TAG-BLR-001', 'Lenovo ThinkPad T14',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-LENOVO'),
    'SN-LEN-008', 'ThinkPad T14 Gen 4', 'Lenovo',
    'Ubuntu 22.04 LTS', 'C6:E5:F3:03:04:01', '10.10.3.11', 'MEDBLR-WS001',
    '2023-01-15', '2026-01-14', 75000.00, 55000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
    'Sysadmin Bengaluru laptop'),
('AST-009', 'TAG-BLR-002', 'HP EliteBook 840 G10',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-HP'),
    'SN-HP-009', 'EliteBook 840 G10', 'HP',
    'Windows 11 Pro', 'C6:E5:F3:03:04:02', '10.10.3.12', 'MEDBLR-WS002',
    '2023-06-01', '2026-05-31', 79000.00, 55000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'),
    'Bengaluru Medical Director laptop'),
-- ── Shared / Pool Assets ─────────────────────────────────────────────────
('AST-010', 'TAG-MUM-010', 'HP LaserJet Pro 4001dn',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='PRINTER'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-HP'),
    'SN-HP-010', 'LaserJet Pro 4001dn', 'HP',
    NULL, NULL, '10.10.1.50', 'MEDMUM-PRN01',
    '2022-05-01', '2025-04-30', 32000.00, 18000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    NULL,
    'Shared floor printer – Mumbai HQ 3rd floor'),
('AST-011', 'TAG-MUM-011', 'Cisco Catalyst 2960-X 24-port',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='SWITCH'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-CISCO'),
    'SN-CSC-011', 'WS-C2960X-24TS-L', 'Cisco',
    'IOS 15.2', 'D7:F6:A4:04:05:01', '10.10.1.1', 'MEDMUM-SW01',
    '2021-03-01', '2024-02-28', 95000.00, 40000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    NULL,
    'Core access switch Mumbai HQ'),
('AST-012', 'TAG-MUM-012', 'Cisco ISR 4321 Router',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='ROUTER'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-CISCO'),
    'SN-CSC-012', 'ISR4321/K9', 'Cisco',
    'IOS XE 16.9', 'D7:F6:A4:04:05:02', '10.10.1.254', 'MEDMUM-RTR01',
    '2021-03-01', '2024-02-28', 185000.00, 90000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    NULL,
    'WAN edge router Mumbai HQ'),
('AST-013', 'TAG-MUM-013', 'Dell PowerEdge R750',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='RACK_SERVER'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-013', 'PowerEdge R750', 'Dell',
    'VMware ESXi 8.0', 'E8:G7:B5:05:06:01', '10.10.1.100', 'MEDMUM-SRV01',
    '2022-01-15', '2025-01-14', 420000.00, 290000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    NULL,
    'Primary application server – EHR and HRIS'),
('AST-014', 'TAG-MUM-014', 'Dell PowerEdge R750',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='RACK_SERVER'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-014', 'PowerEdge R750', 'Dell',
    'VMware ESXi 8.0', 'E8:G7:B5:05:06:02', '10.10.1.101', 'MEDMUM-SRV02',
    '2022-01-15', '2025-01-14', 420000.00, 290000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    NULL,
    'Secondary / DR application server'),
('AST-015', 'TAG-MUM-015', 'Laptops – Spare Pool',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'AVAILABLE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-015', 'Latitude 3540', 'Dell',
    'Windows 11 Pro', NULL, NULL, NULL,
    '2024-02-01', '2027-01-31', 62000.00, 62000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    NULL,
    'Spare laptop – unassigned, ready for deployment'),
-- ── Under Repair / Retired ────────────────────────────────────────────────
('AST-016', 'TAG-MUM-016', 'HP EliteBook 840 G8 (Repair)',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'UNDER_REPAIR',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-HP'),
    'SN-HP-016', 'EliteBook 840 G8', 'HP',
    'Windows 10 Pro', 'F9:H8:C6:06:07:01', NULL, NULL,
    '2021-09-01', '2024-08-31', 68000.00, 22000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    NULL,
    'Screen damage – sent to HP service centre'),
('AST-017', 'TAG-MUM-017', 'Dell OptiPlex 3060 (Retired)',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='DESKTOP'),
    'RETIRED',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-017', 'OptiPlex 3060', 'Dell',
    NULL, NULL, NULL, NULL,
    '2018-06-01', '2021-05-31', 42000.00, 0.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
    NULL,
    'End-of-life – decommissioned and wiped'),
-- ── Chennai & Hyderabad ───────────────────────────────────────────────────
('AST-018', 'TAG-CHN-001', 'HP EliteBook 840 G10',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-HP'),
    'SN-HP-018', 'EliteBook 840 G10', 'HP',
    'Windows 11 Pro', '11:22:33:44:55:01', '10.10.4.11', 'MEDCHN-WS001',
    '2023-09-01', '2026-08-31', 79000.00, 60000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'),
    'Chennai Medical Director laptop'),
('AST-019', 'TAG-HYD-001', 'Lenovo ThinkPad T14',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-LENOVO'),
    'SN-LEN-019', 'ThinkPad T14 Gen 4', 'Lenovo',
    'Windows 11 Pro', '11:22:33:44:55:02', '10.10.5.11', 'MEDHYD-WS001',
    '2023-10-01', '2026-09-30', 75000.00, 60000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-HYD-01'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'),
    'Hyderabad Medical Director laptop'),
('AST-020', 'TAG-KOL-001', 'Dell Latitude 5540',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
    'SN-DELL-020', 'Latitude 5540', 'Dell',
    'Windows 11 Pro', '11:22:33:44:55:03', '10.10.6.11', 'MEDKOL-WS001',
    '2023-11-01', '2026-10-31', 82000.00, 66000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-KOL-01'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'),
    'Kolkata Medical Director laptop'),
('AST-021', 'TAG-PUN-001', 'HP EliteBook 840 G10',
    (SELECT Id FROM helpdesk.AssetCategory WHERE CategoryCode='LAPTOP'),
    'IN_USE',
    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-HP'),
    'SN-HP-021', 'EliteBook 840 G10', 'HP',
    'Windows 11 Pro', '11:22:33:44:55:04', '10.10.7.11', 'MEDPUN-WS001',
    '2023-08-01', '2026-07-31', 79000.00, 62000.00,
    (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-PUN-01'),
    (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'),
    'Pune Hospital Admin laptop');


-- -------------------------------------------------------------------------------------------------------------
-- Asset Assignments  (current active assignments for IN_USE assets)
-- -------------------------------------------------------------------------------------------------------------
PRINT 'Inserting AssetAssignment...';

INSERT INTO helpdesk.AssetAssignment
    (AssetId, EmployeeId, AssignedByEmployeeId, AssignedDate, Remarks, IsActiveAssignment)
VALUES
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-001'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-04-05', 'New hire allocation – IT Manager', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-002'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-06-20', 'Replacement for old laptop', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-003'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-04-05', 'Finance Manager allocation', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-004'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2022-11-15', 'Executive device – CMO', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-005'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP014'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2021-08-10', 'Admin desk workstation', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-006'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-07-05', 'Delhi Med Director laptop', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-007'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-07-05', 'HR BP Delhi laptop', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-008'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-01-20', 'Sysadmin – BLR', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-009'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP021'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-06-05', 'Bengaluru Med Director laptop', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-018'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP026'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-09-05', 'Chennai Med Director laptop', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-019'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP031'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-10-05', 'Hyderabad Med Director laptop', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-020'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP036'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-11-05', 'Kolkata Med Director laptop', 1),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-021'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP041'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-08-05', 'Pune Hospital Admin laptop', 1);


-- -------------------------------------------------------------------------------------------------------------
-- Asset Maintenance Records
-- -------------------------------------------------------------------------------------------------------------
PRINT 'Inserting AssetMaintenance...';

INSERT INTO helpdesk.AssetMaintenance
    (AssetId, VendorId, MaintenanceDate, MaintenanceType, CostAmount, Description, NextMaintenanceDate, CreatedByEmployeeId)
VALUES
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-011'),
 (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-CISCO'),
 '2024-01-10', 'Preventive',    4500.00,  'Annual firmware update and port health check', '2025-01-10',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007')),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-012'),
 (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-CISCO'),
 '2024-01-10', 'Preventive',    8000.00,  'IOS XE upgrade and routing table audit',       '2025-01-10',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007')),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-013'),
 (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-DELL'),
 '2024-03-15', 'Preventive',   15000.00,  'RAM seat check, cooling fan replacement, ESXi patch', '2025-03-15',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007')),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-016'),
 (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-HP'),
 '2025-03-01', 'Corrective',   12000.00,  'Screen replacement – cracked LCD panel', NULL,
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007')),
((SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-010'),
 (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-AMC'),
 '2024-06-01', 'Preventive',    1800.00,  'Annual printer head cleaning and roller replacement', '2025-06-01',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'));


-- MODULE 5 : SOFTWARE LICENSE MANAGEMENT
PRINT 'Inserting SoftwareProduct...';

INSERT INTO helpdesk.SoftwareProduct
    (SoftwareCode, SoftwareName, VersionNumber, VendorId, LicenseTypeCode, Description)
VALUES
('SW-WIN11',   'Windows 11 Pro',               '23H2',    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-MS'),    'SUBSCRIPTION', 'Microsoft Windows 11 Professional OEM/Volume'),
('SW-M365',    'Microsoft 365 Business',        'Current', (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-MS'),    'SUBSCRIPTION', 'M365 Business Standard – Teams, Office, Exchange'),
('SW-TEAMS',   'Microsoft Teams',               'Current', (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-MS'),    'SUBSCRIPTION', 'Teams standalone (bundled with M365)'),
('SW-AV',      'Microsoft Defender for Endpoint','Current',(SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-MS'),    'SUBSCRIPTION', 'EDR and antivirus for Windows endpoints'),
('SW-ADOBE',   'Adobe Acrobat Pro DC',          '2024',    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-ADOBE'), 'SUBSCRIPTION', 'PDF creation, editing and e-signatures'),
('SW-ZOHO-HR', 'Zoho People (HRIS)',            '5.0',     (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-ZOHO'),  'SUBSCRIPTION', 'HR management and payroll system'),
('SW-ZOHO-DESK','Zoho Desk',                   '5.0',     (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-ZOHO'),  'SUBSCRIPTION', 'IT helpdesk ticketing system'),
('SW-EHR',     'MedCare EHR Platform',          '4.2',     NULL,                                                          'PERPETUAL',    'In-house Electronic Health Record system'),
('SW-PACS',    'Sectra PACS',                   '24.1',    (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-BIOCON'),'PERPETUAL',    'Radiology PACS and DICOM viewer'),
('SW-VISIO',   'Microsoft Visio Plan 2',         'Current', (SELECT Id FROM helpdesk.Vendor WHERE VendorCode='VND-MS'),    'SUBSCRIPTION', 'Diagramming for IT architecture');


PRINT 'Inserting SoftwareLicense...';

INSERT INTO helpdesk.SoftwareLicense
    (SoftwareProductId, LicenseKey, LicenseCount, UsedLicenseCount,
     PurchaseDate, ExpiryDate, PurchaseCost, IsSubscription, AutoRenewalEnabled, Remarks)
VALUES
-- Windows 11 – volume OEM per device (perpetual, counted per purchase)
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-WIN11'),
 'VK7JG-NPHTM-C97JM-9MPGT-3V66T', 50, 42,
 '2022-04-01', NULL, 180000.00, 0, 0, 'Microsoft Open License Volume – 50 seats'),
-- M365 Business Standard – annual subscription
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-M365'),
 NULL, 60, 55,
 '2024-04-01', '2025-03-31', 360000.00, 1, 1, 'Annual renewal – 60 user licences'),
-- Defender for Endpoint – bundled with M365 but tracked separately
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-AV'),
 NULL, 60, 55,
 '2024-04-01', '2025-03-31', 0.00, 1, 1, 'Bundled with M365 – no additional cost'),
-- Adobe Acrobat Pro DC – 10 named licences for Finance/HR/Docs
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-ADOBE'),
 NULL, 10, 7,
 '2024-06-01', '2025-05-31', 84000.00, 1, 1, 'Named-user subscription – Finance, HR, Admin teams'),
-- Zoho People HRIS – per-employee subscription
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-ZOHO-HR'),
 NULL, 55, 45,
 '2024-01-01', '2025-12-31', 220000.00, 1, 1, 'All-India headcount licence'),
-- Zoho Desk – IT support team
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-ZOHO-DESK'),
 NULL, 15, 8,
 '2024-01-01', '2025-12-31', 72000.00, 1, 1, 'IT helpdesk agents across all sites'),
-- EHR Platform – perpetual enterprise
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-EHR'),
 'EHR-MEDCARE-ENTERPRISE-2022', 200, 170,
 '2022-06-01', NULL, 2500000.00, 0, 0, 'Enterprise perpetual – all sites'),
-- PACS – perpetual per-site (5 concurrent)
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-PACS'),
 'PACS-SECTRA-MEDCARE-001', 5, 3,
 '2023-03-01', NULL, 750000.00, 0, 0, 'Radiology PACS – Bengaluru and Chennai sites'),
-- Visio – 3 named licences for IT architecture
((SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-VISIO'),
 NULL, 3, 2,
 '2024-04-01', '2025-03-31', 28500.00, 1, 1, 'IT architecture and network diagramming');


PRINT 'Inserting SoftwareInstallation...';

INSERT INTO helpdesk.SoftwareInstallation
    (SoftwareLicenseId, AssetId, InstalledForEmployeeId, InstalledByEmployeeId, InstalledDate, Remarks)
VALUES
-- Windows on all laptops
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-WIN11')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-001'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-04-05', 'OEM pre-installed'),
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-WIN11')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-002'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-06-20', 'OEM pre-installed'),
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-WIN11')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-003'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-04-05', 'OEM pre-installed'),
-- M365 for IT Manager
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-M365')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-001'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-04-05', 'M365 Business Standard activated'),
-- M365 for HR Manager
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-M365')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-002'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2023-06-20', 'M365 Business Standard activated'),
-- Adobe Acrobat for Finance Manager
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-ADOBE')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-003'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2024-06-05', 'Adobe Acrobat Pro DC – Finance team'),
-- EHR on all clinical laptops
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-EHR')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-004'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP001'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 '2022-11-20', 'EHR client installed – CMO laptop'),
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-EHR')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-006'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP016'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 '2023-07-10', 'EHR client – Delhi Med Director'),
-- PACS on Bengaluru radiologist laptop
((SELECT TOP 1 Id FROM helpdesk.SoftwareLicense WHERE SoftwareProductId=(SELECT Id FROM helpdesk.SoftwareProduct WHERE SoftwareCode='SW-PACS')),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-008'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 '2023-01-25', 'PACS viewer installed – BLR sysadmin');


-- MODULE 2 : TICKETS
PRINT 'Inserting Ticket...';

INSERT INTO helpdesk.Ticket
    (TicketNumber, RequesterEmployeeId, RequestedForEmployeeId,
     TicketCategoryId, TicketPriorityCode, TicketStatusCode,
     SupportGroupId, AssignedToEmployeeId, AssetId, OfficeLocationId,
     Subject, Description, OpenedAt, AssignedAt, ResolvedAt, ClosedAt)
VALUES
-- TKT-001 : Critical – Server Down (Resolved)
('TKT-2025-001',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='HW_DESKTOP'),
 'CRITICAL', 'RESOLVED',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='INFRA_OPS'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-013'),
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
 'Primary EHR server (MEDMUM-SRV01) unresponsive',
 'Application server MEDMUM-SRV01 stopped responding at 02:15 IST. EHR system completely unavailable for all clinical users across Mumbai HQ. Suspect VMware host crash.',
 '2025-01-15 02:20:00', '2025-01-15 02:35:00', '2025-01-15 04:50:00', '2025-01-15 06:00:00'),

-- TKT-002 : High – EHR Login Failure (Closed)
('TKT-2025-002',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='EHR_LOGIN'),
 'HIGH', 'CLOSED',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='EHR_SUPPORT'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 NULL,
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
 'Unable to log into EHR – LDAP authentication error',
 'Getting "LDAP Authentication failed" when trying to log into EHR since 08:30. Cardiology ward cannot access patient records. Already tried password reset – same error.',
 '2025-01-20 08:45:00', '2025-01-20 09:00:00', '2025-01-20 10:15:00', '2025-01-20 11:00:00'),

-- TKT-003 : High – Laptop Screen Damaged (Under repair - status OPEN)
('TKT-2025-003',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='HW_LAPTOP'),
 'HIGH', 'IN_PROGRESS',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='DESKTOP_SUPPORT'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-016'),
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
 'Laptop screen cracked – HP EliteBook 840 G8',
 'Dropped laptop accidentally. Screen is cracked and unusable. Need replacement or loan device to continue patient consultations.',
 '2025-02-10 09:30:00', '2025-02-10 10:00:00', NULL, NULL),

-- TKT-004 : Medium – VPN drops intermittently (Resolved)
('TKT-2025-004',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='NET_VPN'),
 'MEDIUM', 'RESOLVED',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='INFRA_OPS'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 NULL,
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-DEL-01'),
 'VPN keeps disconnecting every 30–40 minutes (WFH)',
 'Working from home using Cisco AnyConnect VPN. Connection drops every 30-40 minutes, requiring manual reconnect. HRIS and email become inaccessible during drops.',
 '2025-02-14 11:00:00', '2025-02-14 12:30:00', '2025-02-15 10:00:00', NULL),

-- TKT-005 : Medium – New employee access setup (Closed)
('TKT-2025-005',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP005'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP030'),
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='ACC_APP'),
 'MEDIUM', 'CLOSED',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='APP_SUPPORT'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 NULL,
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'),
 'New joiner (EMP030 – Sangeetha Arumugam) – IT access provisioning',
 'New HR Executive joined Chennai office on 01-Mar-2023. Please set up: AD account, M365 licence, EHR read-only access, Zoho People access, and door-access badge.',
 '2023-03-01 09:00:00', '2023-03-01 09:30:00', '2023-03-01 14:00:00', '2023-03-01 16:00:00'),

-- TKT-006 : Low – Printer paper jam (Resolved)
('TKT-2025-006',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP015'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='HW_PRINTER'),
 'LOW', 'RESOLVED',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='DESKTOP_SUPPORT'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 (SELECT Id FROM helpdesk.Asset WHERE AssetCode='AST-010'),
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
 'Printer paper jam – 3rd floor HP LaserJet',
 'HP LaserJet on 3rd floor showing paper jam error. Multiple staff waiting to print patient discharge summaries.',
 '2025-03-05 14:20:00', '2025-03-05 14:35:00', '2025-03-05 15:10:00', '2025-03-05 15:30:00'),

-- TKT-007 : High – Phishing email reported (Open)
('TKT-2025-007',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='SEC_PHISH'),
 'HIGH', 'IN_PROGRESS',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='SEC_OPS'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 NULL,
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
 'Suspicious email claiming to be from NEFT payment gateway',
 'Received email from "neft-alerts@sbi-india.support" asking to verify bank credentials for payroll disbursal. Did not click any link. Forwarding to security team for investigation.',
 '2025-04-02 11:15:00', '2025-04-02 11:30:00', NULL, NULL),

-- TKT-008 : Critical – Wi-Fi down in ICU (Resolved)
('TKT-2025-008',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP010'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='NET_WIFI'),
 'CRITICAL', 'RESOLVED',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='INFRA_OPS'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 NULL,
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-MUM-HQ'),
 'Wi-Fi completely down in ICU ward – patient monitors disconnected',
 'All wireless devices in ICU disconnected from network including bedside patient monitors. Nurses cannot update vitals in EHR. Access point MEDMUM-AP-ICU not responding to ping.',
 '2025-04-10 03:05:00', '2025-04-10 03:10:00', '2025-04-10 04:30:00', '2025-04-10 05:00:00'),

-- TKT-009 : Medium – AD password reset (Closed)
('TKT-2025-009',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP028'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='ACC_AD'),
 'MEDIUM', 'CLOSED',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='APP_SUPPORT'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 NULL,
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-CHN-01'),
 'AD account locked – cannot access EHR and email',
 'Account locked after multiple wrong password attempts following keyboard layout change. Need immediate reset to access oncology patient records.',
 '2025-04-14 08:10:00', '2025-04-14 08:20:00', '2025-04-14 08:50:00', '2025-04-14 09:00:00'),

-- TKT-010 : Low – PACS viewer slow (Open / Pending)
('TKT-2025-010',
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP023'),
 NULL,
 (SELECT Id FROM helpdesk.TicketCategory WHERE CategoryCode='EHR_PERF'),
 'LOW', 'OPEN',
 (SELECT Id FROM helpdesk.SupportGroup WHERE SupportGroupCode='EHR_SUPPORT'),
 NULL,
 NULL,
 (SELECT Id FROM time.OfficeLocation WHERE LocationCode='LOC-BLR-01'),
 'PACS viewer takes 2–3 minutes to load MRI scans',
 'Sectra PACS viewer loading time has degraded noticeably over the past week. MRI series take 2-3 minutes to load versus 15-20 seconds before. Affecting radiology report turnaround.',
 '2025-05-02 10:00:00', NULL, NULL, NULL);


-- -------------------------------------------------------------------------------------------------------------
-- Ticket Comments
-- -------------------------------------------------------------------------------------------------------------
PRINT 'Inserting TicketComment...';

INSERT INTO helpdesk.TicketComment (TicketId, CommentedBy, CommentText, IsInternalComment, CreatedAt)
VALUES
-- TKT-001 comments
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-001'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'Confirmed VMware ESXi host crash on MEDMUM-SRV01. Initiating host restart procedure. EHR downtime notice sent to all clinical heads.',
 1, '2025-01-15 02:40:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-001'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'Host restarted successfully. All VMs back online. EHR accessible from 04:55 IST. RCA report to follow within 48 hours.',
 0, '2025-01-15 05:00:00'),

-- TKT-002 comments
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-002'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 'LDAP service on AD connector had stale bind. Restarted connector service. Please retry login.',
 1, '2025-01-20 09:50:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-002'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP003'),
 'Login working now. Thank you for the quick fix.',
 0, '2025-01-20 10:20:00'),

-- TKT-003 comments
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-003'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'Spare laptop AST-015 issued as loan device. Damaged unit logged as under repair and sent to HP service centre (Job No: HP-SVC-9812).',
 0, '2025-02-10 11:30:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-003'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'HP service centre estimates 7-10 working days for screen replacement. Will update requester once unit returns.',
 1, '2025-02-10 12:00:00'),

-- TKT-004 comments
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-004'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 'Root cause: ISP MTU mismatch causing TCP keepalive failures on Cisco AnyConnect. Applied MTU fix on VPN concentrator profile. Please test.',
 0, '2025-02-15 09:30:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-004'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP019'),
 'VPN stable for the past 24 hours after the fix. Issue resolved.',
 0, '2025-02-15 10:05:00'),

-- TKT-007 comments
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-007'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'Email header analysis confirms spoofed domain. Domain flagged in Microsoft 365 Defender. User EMP006 confirmed no credentials entered.',
 1, '2025-04-02 12:00:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-007'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'Phishing domain reported to Microsoft MSTIC and CERT-In. Tenant-wide block applied. Awareness note sent to all staff.',
 0, '2025-04-02 14:30:00'),

-- TKT-008 comments
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-008'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'URGENT – ICU AP down. Dispatched on-call tech. Temporary wired connections established for critical monitors.',
 0, '2025-04-10 03:15:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-008'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'AP power supply failed. Replaced with spare unit. Wi-Fi restored in ICU at 04:35 IST. All monitors reconnected and verified.',
 0, '2025-04-10 04:40:00'),

-- TKT-010 comments
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-010'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP025'),
 'Investigating PACS performance. Initial check shows high IOPS on NAS storage backing PACS archive. Will run disk health and throughput tests.',
 1, '2025-05-02 11:00:00');


-- -------------------------------------------------------------------------------------------------------------
-- Ticket Attachments
-- -------------------------------------------------------------------------------------------------------------
PRINT 'Inserting TicketAttachment...';

INSERT INTO helpdesk.TicketAttachment
    (TicketId, UploadedBy, FileName, OriginalFileName, FileExtension, MimeType, FileSizeInBytes, FileUrl, UploadedAt)
VALUES
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-001'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP007'),
 'vmware-crash-log-20250115.txt', 'vmware-crash-log-20250115.txt',
 'txt', 'text/plain', 48320,
 'https://storage.medcareindia.in/tickets/TKT-2025-001/vmware-crash-log-20250115.txt',
 '2025-01-15 06:30:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-003'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP008'),
 'laptop-screen-damage.jpg', 'damaged_screen.jpg',
 'jpg', 'image/jpeg', 1248000,
 'https://storage.medcareindia.in/tickets/TKT-2025-003/laptop-screen-damage.jpg',
 '2025-02-10 09:35:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-007'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'),
 'phishing-email-screenshot.png', 'suspicious_email.png',
 'png', 'image/png', 320000,
 'https://storage.medcareindia.in/tickets/TKT-2025-007/phishing-email-screenshot.png',
 '2025-04-02 11:20:00'),
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-007'),
 (SELECT Id FROM employee.Employee WHERE EmployeeCode='EMP006'),
 'email-headers.txt', 'email_headers_raw.txt',
 'txt', 'text/plain', 8192,
 'https://storage.medcareindia.in/tickets/TKT-2025-007/email-headers.txt',
 '2025-04-02 11:22:00');


-- MODULE 3 : SLA TRACKING (one row per ticket)
PRINT 'Inserting TicketSlaTracking...';

INSERT INTO helpdesk.TicketSlaTracking
    (TicketId, SlaPolicyId,
     ResponseDueAt, ResolutionDueAt,
     FirstResponseAt, ResolvedAt,
     IsResponseBreached, IsResolutionBreached, BreachRemarks, LastEvaluatedAt)
VALUES
-- TKT-001 CRITICAL - 15 min response, 4 hr resolution (met both)
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-001'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-CRIT'),
 '2025-01-15 02:35:00', '2025-01-15 06:20:00',
 '2025-01-15 02:40:00', '2025-01-15 04:50:00',
 0, 0, NULL, '2025-01-15 07:00:00'),

-- TKT-002 HIGH - 1 hr response, 8 hr resolution (met both)
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-002'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-HIGH'),
 '2025-01-20 09:45:00', '2025-01-20 16:45:00',
 '2025-01-20 09:50:00', '2025-01-20 10:15:00',
 0, 0, NULL, '2025-01-20 11:00:00'),

-- TKT-003 HIGH - response met, resolution pending (open)
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-003'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-HIGH'),
 '2025-02-10 11:00:00', '2025-02-10 18:00:00',
 '2025-02-10 11:30:00', NULL,
 0, 1, 'Resolution SLA breached – unit sent for external repair (HP Service)', '2025-02-20 09:00:00'),

-- TKT-004 MEDIUM - met response, met resolution
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-004'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-MED'),
 '2025-02-14 15:00:00', '2025-02-15 11:00:00',
 '2025-02-14 12:30:00', '2025-02-15 10:00:00',
 0, 0, NULL, '2025-02-15 11:00:00'),

-- TKT-005 MEDIUM - met both (new joiner same-day provisioning)
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-005'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-MED'),
 '2023-03-01 13:00:00', '2023-03-02 09:00:00',
 '2023-03-01 09:30:00', '2023-03-01 14:00:00',
 0, 0, NULL, '2023-03-01 16:00:00'),

-- TKT-006 LOW - met both (printer jam same day)
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-006'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-LOW'),
 '2025-03-05 22:20:00', '2025-03-08 14:20:00',
 '2025-03-05 14:35:00', '2025-03-05 15:10:00',
 0, 0, NULL, '2025-03-05 16:00:00'),

-- TKT-007 HIGH - response met, resolution pending
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-007'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-HIGH'),
 '2025-04-02 12:15:00', '2025-04-02 19:15:00',
 '2025-04-02 11:30:00', NULL,
 0, 1, 'Phishing investigation ongoing beyond 8-hour SLA – extended per security protocol', '2025-04-03 09:00:00'),

-- TKT-008 CRITICAL - both met (response breached by 5 min due to critical nature)
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-008'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-CRIT'),
 '2025-04-10 03:20:00', '2025-04-10 07:05:00',
 '2025-04-10 03:15:00', '2025-04-10 04:30:00',
 0, 0, NULL, '2025-04-10 05:00:00'),

-- TKT-009 MEDIUM - both met
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-009'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-MED'),
 '2025-04-14 12:10:00', '2025-04-15 08:10:00',
 '2025-04-14 08:20:00', '2025-04-14 08:50:00',
 0, 0, NULL, '2025-04-14 09:00:00'),

-- TKT-010 LOW - unassigned, response not yet given
((SELECT Id FROM helpdesk.Ticket WHERE TicketNumber='TKT-2025-010'),
 (SELECT Id FROM helpdesk.SlaPolicy WHERE PolicyCode='SLA-LOW'),
 '2025-05-02 18:00:00', '2025-05-05 10:00:00',
 NULL, NULL,
 0, 0, NULL, '2025-05-02 10:00:00');

GO
PRINT 'Helpdesk recruitment seed data inserted successfully.';
GO