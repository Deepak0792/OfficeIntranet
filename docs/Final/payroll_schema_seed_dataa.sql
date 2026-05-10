
-- -------------------------------------------------------
-- Seed: Tax Declaration lifecycle
-- -------------------------------------------------------
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('DRAFT',             'DECLARATION_STATUS',   'Draft',             1, 0),
('SUBMITTED',         'DECLARATION_STATUS',   'Submitted',         2, 0),
('VERIFIED',          'DECLARATION_STATUS',   'Verified',          3, 1),
('REJECTED',          'DECLARATION_STATUS',   'Rejected',          4, 1);

-- -------------------------------------------------------
-- Seed: Proof review lifecycle
-- -------------------------------------------------------
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',           'PROOF_REVIEW_STATUS',  'Pending',           1, 0),
('APPROVED',          'PROOF_REVIEW_STATUS',  'Approved',          2, 1),
('REJECTED',          'PROOF_REVIEW_STATUS',  'Rejected',          3, 1);

-- -------------------------------------------------------
-- Seed: Payroll disbursement (batch run) lifecycle
-- -------------------------------------------------------
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('DRAFT',             'DISBURSEMENT_STATUS',  'Draft',             1, 0),
('APPROVED',          'DISBURSEMENT_STATUS',  'Approved',          2, 0),
('PROCESSING',        'DISBURSEMENT_STATUS',  'Processing',        3, 0),
('COMPLETED',         'DISBURSEMENT_STATUS',  'Completed',         4, 1),
('FAILED',            'DISBURSEMENT_STATUS',  'Failed',            5, 1),
('CANCELLED',         'DISBURSEMENT_STATUS',  'Cancelled',         6, 1);

-- -------------------------------------------------------
-- Seed: Individual bank credit transaction lifecycle
-- -------------------------------------------------------
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',           'TRANSACTION_STATUS',   'Pending',           1, 0),
('INITIATED',         'TRANSACTION_STATUS',   'Initiated',         2, 0),
('SUCCESS',           'TRANSACTION_STATUS',   'Success',           3, 1),
('FAILED',            'TRANSACTION_STATUS',   'Failed',            4, 1),
('REVERSED',          'TRANSACTION_STATUS',   'Reversed',          5, 1);

-- -------------------------------------------------------
-- Seed: Salary revision types
-- -------------------------------------------------------
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('ANNUAL_INCREMENT',  'SALARY_REVISION_TYPE', 'Annual Increment',  1, 0),
('PROMOTION',         'SALARY_REVISION_TYPE', 'Promotion',         2, 0),
('CORRECTION',        'SALARY_REVISION_TYPE', 'Correction',        3, 0),
('JOINING',           'SALARY_REVISION_TYPE', 'Joining',           4, 0),
('MARKET_CORRECTION', 'SALARY_REVISION_TYPE', 'Market Correction', 5, 0),
('OTHER',             'SALARY_REVISION_TYPE', 'Other',             6, 0);

-- -------------------------------------------------------
-- Seed: Bank account types
-- -------------------------------------------------------
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('SAVINGS',           'BANK_ACCOUNT_TYPE',    'Savings Account',   1, 0),
('CURRENT',           'BANK_ACCOUNT_TYPE',    'Current Account',   2, 0),
('SALARY',            'BANK_ACCOUNT_TYPE',    'Salary Account',    3, 0);

-- -------------------------------------------------------
-- Seed: Salary component calculation types
-- -------------------------------------------------------
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('FIXED',             'CALC_TYPE',            'Fixed Amount',      1, 0),
('PERCENTAGE',        'CALC_TYPE',            'Percentage of Base',2, 0),
('FORMULA',           'CALC_TYPE',            'Formula Expression',3, 0);
GO


INSERT INTO payroll.TaxProofCategory
    (CategoryCode, CategoryName, Section, StatutoryMaxLimit,
     IsApplicableOldRegime, IsApplicableNewRegime, RequiresDocument, DisplayOrder)
VALUES
('80C',       'Investments under 80C (LIC, PPF, ELSS, etc.)', 'Section 80C',        150000.00, 1, 0, 1,  1),
('80CCD1B',   'Additional NPS Contribution',                   'Section 80CCD(1B)',   50000.00, 1, 0, 1,  2),
('80D',       'Medical Insurance Premium',                     'Section 80D',         25000.00, 1, 0, 1,  3),
('80E',       'Education Loan Interest',                       'Section 80E',             NULL, 1, 0, 1,  4),
('80G',       'Donations',                                     'Section 80G',             NULL, 1, 0, 1,  5),
('80TTA',     'Interest on Savings Account',                   'Section 80TTA',       10000.00, 1, 0, 0,  6),
('HRA',       'House Rent Allowance',                          'Section 10(13A)',         NULL, 1, 0, 1,  7),
('LTA',       'Leave Travel Allowance',                        'Section 10(5)',           NULL, 1, 0, 1,  8),
('HOME_LOAN', 'Home Loan Interest (Self-Occupied)',             'Section 24(b)',       200000.00, 1, 0, 1, 9),
('STD_DED',   'Standard Deduction',                            'Section 16(ia)',       50000.00, 1, 1, 0, 10);
GO

-- =============================================================================================================
-- ENTERPRISE HRMS / PAYROLL EXTENSION
-- SEED DATA SCRIPT — MedCare India Pvt. Ltd.
-- Schema: payroll
-- =============================================================================================================
-- ORGANIZATION  : MedCare India Pvt. Ltd.
-- COUNTRY       : India
-- FISCAL YEAR   : April–March (Indian standard)
-- CURRENCY      : INR
-- TAX REGIME    : India Old Regime & India New Regime (as per Finance Act 2023)
--
-- DEPENDENCIES  : Requires dbo schema seed data executed first.
--                 The following dbo tables must be populated:
--                   dbo.Employee         (EMP001–EMP045)
--                   dbo.LegalEntity      (MEDCARE-IN, MEDCARE-NORTH, MEDCARE-SOUTH)
--                   dbo.PayrollComponent (BASIC, HRA, TA, etc.)
--                   dbo.Designation      (CHMO, MEDDIRECTOR, SRSURGEON, etc.)
--
-- COVERAGE:
--   1. Salary & Compensation   : SalaryGrade, SalaryStructure, SalaryStructureComponent,
--                                EmployeeSalary, EmployeeSalaryComponent, SalaryRevision
--   2. Bank Credit             : BankMaster, EmployeeBankAccount, PayrollDisbursement,
--                                PayrollDisbursementTransaction
--   3. Tax Deductions          : TaxRegime, TaxSlab, EmployeeTaxDeclaration,
--                                TaxDeclarationProof, EmployeeTaxDeduction,
--                                TaxDeductionBreakdown
--
-- SALARY PHILOSOPHY (Healthcare India):
--   Grade  | Role Examples                        | Annual CTC Range (INR)
--   -------|-------------------------------------|------------------------
--   G-L10  | CMO, CEO                            | 60L – 1.5Cr
--   G-L9   | Medical Director                    | 40L – 80L
--   G-L8   | Sr. Surgeon, CNO, Hospital Admin    | 25L – 50L
--   G-L7   | Consultant, HOD, Manager            | 15L – 30L
--   G-L5   | Sr. Nurse, Sr. Pharmacist, HRBP     | 8L  – 15L
--   G-L4   | Staff Nurse, Pharmacist, Executive  | 4L  – 8L
--   G-L3   | Jr. Nurse, Front Desk               | 2.5L – 4L
--   G-L2   | Ward Boy, Driver                    | 1.8L – 2.5L
-- =============================================================================================================

SET NOCOUNT ON;
BEGIN TRANSACTION;

PRINT '=============================================================================================================';
PRINT 'STARTING PAYROLL SEED DATA — MedCare India Pvt. Ltd.';
PRINT '=============================================================================================================';


-- =============================================================================================================
-- MODULE 1: SALARY & COMPENSATION
-- =============================================================================================================


-- -------------------------------------------------------
-- SALARY GRADE
-- Pay bands aligned to the designation grade levels used
-- in dbo.Designation. MinCTC/MaxCTC in annual INR figures.
-- CurrencyCode = INR for all India entities.
-- -------------------------------------------------------
PRINT 'Inserting payroll.SalaryGrade...';
INSERT INTO payroll.SalaryGrade (GradeCode, GradeName, MinCTC, MaxCTC, CurrencyCode, Description) VALUES
('G-L10', 'Band L10 – C-Suite / Chief Officers',        6000000.00,  15000000.00, 'INR', 'CMO, CEO, CFO level. Highest compensation band.'),
('G-L9',  'Band L9  – Medical / Hospital Directors',    4000000.00,   8000000.00, 'INR', 'Medical Directors, VP-level hospital leadership.'),
('G-L8',  'Band L8  – Senior Specialists / HODs',       2500000.00,   5000000.00, 'INR', 'Senior Surgeons, Chief Nursing Officer, Administrators.'),
('G-L7',  'Band L7  – Consultants / Department Heads',  1500000.00,   3000000.00, 'INR', 'Consultants, Radiologists, Pathologists, Managers.'),
('G-L5',  'Band L5  – Senior Staff',                     800000.00,   1500000.00, 'INR', 'Senior Nurses, Senior Pharmacists, HR Business Partners.'),
('G-L4',  'Band L4  – Experienced Staff',                400000.00,    800000.00, 'INR', 'Staff Nurses, Pharmacists, Lab Techs, Executives.'),
('G-L3',  'Band L3  – Junior Staff',                     250000.00,    400000.00, 'INR', 'Junior Nurses, Front Desk Executives, Housekeeping Supervisors.'),
('G-L2',  'Band L2  – Support Staff',                    180000.00,    250000.00, 'INR', 'Ward Boys, Patient Attendants, Ambulance Drivers.');


-- -------------------------------------------------------
-- SALARY STRUCTURE
-- Three structures mapped to the three legal entities.
-- All are INR-based. Standard India structure handles
-- typical PF, ESI, PT deductions per Indian labour law.
-- Clinical structures have a night shift allowance head.
-- -------------------------------------------------------
PRINT 'Inserting payroll.SalaryStructure...';
INSERT INTO payroll.SalaryStructure (StructureCode, StructureName, LegalEntityId, CurrencyCode, VersionNo, IsDefault, Description) VALUES
(
    'SS-MEDCARE-IN-STD',
    'MedCare India – Standard Monthly Structure',
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode = 'MEDCARE-IN'),
    'INR', 1, 1,
    'Standard salary structure for all employees of MedCare India Pvt. Ltd. (Mumbai & Pune). '
    + 'Components: Basic (40%), HRA (20% of Basic), TA (Fixed), Medical Allowance (Fixed), '
    + 'Special Allowance (balancing), PF 12% employee + 12% employer, ESI where applicable, PT.'
),
(
    'SS-MEDCARE-NORTH-STD',
    'MedCare North India – Standard Monthly Structure',
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode = 'MEDCARE-NORTH'),
    'INR', 1, 1,
    'Standard salary structure for MedCare North India Healthcare Ltd. (Delhi & Kolkata). '
    + 'Identical component logic to the parent entity with Delhi Professional Tax slabs applied.'
),
(
    'SS-MEDCARE-SOUTH-STD',
    'MedCare South India – Standard Monthly Structure',
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode = 'MEDCARE-SOUTH'),
    'INR', 1, 1,
    'Standard salary structure for MedCare South India Hospitals Pvt. Ltd. (Bengaluru, Chennai, Hyderabad). '
    + 'Karnataka/TN/Telangana PT slabs applied. ESI applicable where gross <= INR 21,000/month.'
);


-- =============================================================================================================
-- MODULE 13: PAYROLL
-- =============================================================================================================

PRINT 'Inserting PayrollComponent...';
INSERT INTO payroll.PayrollComponent (ComponentCode, ComponentName, IsEarning, IsDeduction) VALUES
('BASIC',       'Basic Salary',                 1, 0),
('HRA',         'House Rent Allowance',         1, 0),
('TA',          'Transport Allowance',          1, 0),
('MEDICAL_ALL', 'Medical Allowance',            1, 0),
('SPECIAL_ALL', 'Special Allowance',            1, 0),
('NIGHTALL',    'Night Shift Allowance',        1, 0),
('OTPAY',       'Overtime Pay',                 1, 0),
('BONUS',       'Performance Bonus',            1, 0),
('PF_EMP',      'Provident Fund (Employee)',    0, 1),
('PF_ER',       'Provident Fund (Employer)',    1, 0),
('ESI_EMP',     'ESI (Employee Contribution)',  0, 1),
('ESI_ER',      'ESI (Employer Contribution)',  1, 0),
('PT',          'Professional Tax',             0, 1),
('TDS',         'Income Tax (TDS)',             0, 1),
('ADVANCE_DED', 'Salary Advance Deduction',     0, 1),
('GRATUITY',    'Gratuity Provision',           1, 0);


PRINT 'Inserting PayrollAttendanceSummary (March 2025)...';
INSERT INTO payroll.PayrollAttendanceSummary (EmployeeId, PayrollMonth, PayrollYear, TotalWorkingDays, PresentDays, LeaveDays, AbsentDays, OvertimeMinutes, ProcessedAt) VALUES
((SELECT Id FROM Employee WHERE EmployeeCode='EMP001'), 3, 2025, 21.00, 21.00,  0.00, 0.00, 35,  '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP002'), 3, 2025, 21.00, 20.00,  1.00, 0.00, 0,   '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP003'), 3, 2025, 25.00, 25.00,  0.00, 0.00, 120, '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP004'), 3, 2025, 21.00, 21.00,  0.00, 0.00, 0,   '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP005'), 3, 2025, 21.00, 20.50,  0.50, 0.00, 0,   '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP009'), 3, 2025, 25.00, 22.00,  3.00, 0.00, 60,  '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP010'), 3, 2025, 26.00, 26.00,  0.00, 0.00, 90,  '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP011'), 3, 2025, 26.00, 25.00,  0.00, 1.00, 0,   '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP012'), 3, 2025, 25.00, 25.00,  0.00, 0.00, 0,   '2025-04-01 02:00:00'),
((SELECT Id FROM Employee WHERE EmployeeCode='EMP020'), 3, 2025, 15.00, 15.00,  0.00, 0.00, 180, '2025-04-01 02:00:00');


-- -------------------------------------------------------
-- SALARY STRUCTURE COMPONENT
-- Defines each earning and deduction head within each
-- structure, how it is calculated, and its display order.
--
-- Component logic (all structures use same rules):
--   BASIC         : FIXED — set per employee on EmployeeSalary
--   HRA           : PERCENTAGE 20% of BASIC (metro cities; HRA exemption applies)
--   TA            : FIXED 1,600/month (standard transport allowance)
--   MEDICAL_ALL   : FIXED 1,250/month
--   NIGHTALL      : FIXED (applicable to night-shift clinical staff)
--   SPECIAL_ALL   : FORMULA (CTC - Basic - HRA - TA - Medical - PF_ER - ESI_ER - Gratuity)
--   PF_EMP        : PERCENTAGE 12% of BASIC (employee deduction, capped at 1,800/month)
--   PF_ER         : PERCENTAGE 12% of BASIC (employer contribution)
--   ESI_EMP       : PERCENTAGE 0.75% of Gross (if gross <= 21,000/month)
--   ESI_ER        : PERCENTAGE 3.25% of Gross (employer share)
--   PT            : FIXED — Maharashtra/Delhi/Karnataka slabs (handled in override)
--   TDS           : FIXED — computed by tax engine monthly
--   GRATUITY      : PERCENTAGE 4.81% of BASIC (actuarial provision)
-- -------------------------------------------------------
PRINT 'Inserting payroll.SalaryStructureComponent...';

-- Helper variable approach: insert for all three structures using UNION pattern.
-- We loop over each structure to avoid duplication.

DECLARE @StructIds TABLE (StructureId BIGINT);
INSERT INTO @StructIds
SELECT Id FROM payroll.SalaryStructure
WHERE StructureCode IN ('SS-MEDCARE-IN-STD','SS-MEDCARE-NORTH-STD','SS-MEDCARE-SOUTH-STD');

-- For each structure, insert the full set of components
DECLARE @SID BIGINT;
DECLARE struct_cursor CURSOR FOR SELECT StructureId FROM @StructIds;
OPEN struct_cursor;
FETCH NEXT FROM struct_cursor INTO @SID;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- ---- EARNINGS ----
    -- 1. Basic Salary — fixed, anchor component
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC'),
        'FIXED', NULL, NULL, NULL, 0, 1, 1);

    -- 2. HRA — 20% of Basic (standard metro India; employee can claim exemption separately)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='HRA'),
        'PERCENTAGE', 20.0000,
        (SELECT Id FROM payroll.SalaryStructureComponent
            WHERE SalaryStructureId = @SID
            AND PayrollComponentId = (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),
        NULL, 0, 1, 2);

    -- 3. Transport Allowance — fixed INR 1,600/month
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TA'),
        'FIXED', NULL, NULL, NULL, 0, 1, 3);

    -- 4. Medical Allowance — fixed INR 1,250/month
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='MEDICAL_ALL'),
        'FIXED', NULL, NULL, NULL, 0, 1, 4);

    -- 5. Night Shift Allowance — fixed (applicable to nursing/emergency; 0 for others via override)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='NIGHTALL'),
        'FIXED', NULL, NULL, NULL, 0, 1, 5);

    -- 6. Special Allowance — formula-driven balancing component
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='SPECIAL_ALL'),
        'FORMULA', NULL, NULL,
        'MonthlyCTC - BASIC - HRA - TA - MEDICAL_ALL - NIGHTALL - PF_ER - ESI_ER - GRATUITY',
        0, 1, 6);

    -- 7. Employer PF Contribution — 12% of Basic (statutory; employer side shows in CTC)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_ER'),
        'PERCENTAGE', 12.0000,
        (SELECT Id FROM payroll.SalaryStructureComponent
            WHERE SalaryStructureId = @SID
            AND PayrollComponentId = (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),
        NULL, 1, 1, 7);

    -- 8. ESI Employer Contribution — 3.25% of Gross (statutory; applicable if gross <= 21,000)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_ER'),
        'PERCENTAGE', 3.2500, NULL,
        'IF(MonthlyGross <= 21000, MonthlyGross * 0.0325, 0)',
        1, 1, 8);

    -- 9. Gratuity Provision — 4.81% of Basic (actuarial employer provision)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='GRATUITY'),
        'PERCENTAGE', 4.8100,
        (SELECT Id FROM payroll.SalaryStructureComponent
            WHERE SalaryStructureId = @SID
            AND PayrollComponentId = (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),
        NULL, 1, 1, 9);

    -- 10. Overtime Pay — fixed (computed from attendance OT minutes; 0 if not applicable)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='OTPAY'),
        'FIXED', NULL, NULL, NULL, 0, 1, 10);

    -- ---- DEDUCTIONS ----
    -- 11. Employee PF Deduction — 12% of Basic (capped at INR 1,800 for basic > 15,000)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_EMP'),
        'PERCENTAGE', 12.0000,
        (SELECT Id FROM payroll.SalaryStructureComponent
            WHERE SalaryStructureId = @SID
            AND PayrollComponentId = (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),
        NULL, 1, 1, 11);

    -- 12. ESI Employee Deduction — 0.75% of Gross (if gross <= 21,000/month)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_EMP'),
        'PERCENTAGE', 0.7500, NULL,
        'IF(MonthlyGross <= 21000, MonthlyGross * 0.0075, 0)',
        1, 1, 12);

    -- 13. Professional Tax — fixed slab (Maharashtra: 200/month; override per state)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PT'),
        'FIXED', NULL, NULL, NULL, 1, 1, 13);

    -- 14. TDS — fixed (computed by tax engine; override inserted monthly via EmployeeSalaryComponent)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    VALUES (@SID, (SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TDS'),
        'FIXED', NULL, NULL, NULL, 1, 1, 14);

    FETCH NEXT FROM struct_cursor INTO @SID;
END;

CLOSE struct_cursor;
DEALLOCATE struct_cursor;


-- -------------------------------------------------------
-- EMPLOYEE SALARY
-- Current salary records for all 45 employees.
-- Effective from each employee's date of joining or last
-- revision date. Basic is set at 40% of Monthly CTC.
-- Gross = Basic + HRA + TA + Medical + Special + Night Allowance.
-- Net = Gross - PF_EMP - ESI_EMP - PT - TDS.
-- -------------------------------------------------------
PRINT 'Inserting payroll.EmployeeSalary...';

-- Helper: resolve structure IDs for each legal entity
DECLARE @SS_IN     BIGINT = (SELECT Id FROM payroll.SalaryStructure WHERE StructureCode = 'SS-MEDCARE-IN-STD');
DECLARE @SS_NORTH  BIGINT = (SELECT Id FROM payroll.SalaryStructure WHERE StructureCode = 'SS-MEDCARE-NORTH-STD');
DECLARE @SS_SOUTH  BIGINT = (SELECT Id FROM payroll.SalaryStructure WHERE StructureCode = 'SS-MEDCARE-SOUTH-STD');

-- Helper: resolve grade IDs
DECLARE @GL10 BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode = 'G-L10');
DECLARE @GL9  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode = 'G-L9');
DECLARE @GL8  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode = 'G-L8');
DECLARE @GL7  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode = 'G-L7');
DECLARE @GL5  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode = 'G-L5');
DECLARE @GL4  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode = 'G-L4');
DECLARE @GL3  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode = 'G-L3');
DECLARE @GL2  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode = 'G-L2');

-- EmployeeCode | AnnualCTC | MonthlyCTC | MonthlyGross | MonthlyNet | EffectiveFrom | Structure | Grade
-- Monthly Gross = MonthlyCTC × ~0.80 (employer statutory contributions not taken from gross)
-- Monthly Net   = Gross - PF(emp) - ESI(emp) - PT - TDS

INSERT INTO payroll.EmployeeSalary
    (EmployeeId, SalaryStructureId, SalaryGradeId, AnnualCTC, MonthlyCTC, MonthlyGross, MonthlyNet, CurrencyCode, EffectiveFrom, EffectiveTo, IsActive, Remarks)
VALUES
-- ====== MUMBAI HQ ======
-- EMP001 - CMO (L10) - 1.20 Cr CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), @SS_IN, @GL10,
 12000000.00, 1000000.00, 820000.00, 695000.00, 'INR', '2024-04-01', NULL, 1,
 'Current salary post FY2024 revision. Includes performance supplement.'),

-- EMP002 - Medical Director (L9) - 60L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'), @SS_IN, @GL9,
 6000000.00, 500000.00, 410000.00, 348000.00, 'INR', '2024-04-01', NULL, 1,
 'Mumbai HQ Medical Director. Current year revised CTC.'),

-- EMP003 - Sr. Cardiac Surgeon (L8) - 42L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), @SS_IN, @GL8,
 4200000.00, 350000.00, 287000.00, 243000.00, 'INR', '2024-04-01', NULL, 1,
 'Includes surgical skills allowance. Eligible for performance bonus.'),

-- EMP004 - Chief Nursing Officer (L8) - 30L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'), @SS_IN, @GL8,
 3000000.00, 250000.00, 205000.00, 174000.00, 'INR', '2024-04-01', NULL, 1,
 'CNO. Includes leadership allowance.'),

-- EMP005 - HR Manager (L7) - 18L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), @SS_IN, @GL7,
 1800000.00, 150000.00, 123000.00, 104000.00, 'INR', '2024-04-01', NULL, 1,
 'HR Manager, pan-India HRMS oversight.'),

-- EMP006 - Finance Manager (L7) - 18L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), @SS_IN, @GL7,
 1800000.00, 150000.00, 123000.00, 104000.00, 'INR', '2024-04-01', NULL, 1,
 'Finance Manager, hospital billing and payroll.'),

-- EMP007 - IT Manager (L7) - 18L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'), @SS_IN, @GL7,
 1800000.00, 150000.00, 123000.00, 104000.00, 'INR', '2024-04-01', NULL, 1,
 'IT Manager. Includes technology allowance.'),

-- EMP008 - Consultant Physician (L7) - 22L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'), @SS_IN, @GL7,
 2200000.00, 183333.00, 150333.00, 127500.00, 'INR', '2024-04-01', NULL, 1,
 'Consultant Internal Medicine.'),

-- EMP009 - Resident Doctor (L5) - 10L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'), @SS_IN, @GL5,
 1000000.00, 83333.00, 68333.00, 58000.00, 'INR', '2024-04-01', NULL, 1,
 'Resident, Cardiology rotation. Stipend structure.'),

-- EMP010 - Senior ICU Nurse (L5) - 9L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), @SS_IN, @GL5,
 900000.00, 75000.00, 61500.00, 52200.00, 'INR', '2024-04-01', NULL, 1,
 'Senior Nurse, ICU. Includes night shift allowance INR 2,000/month.'),

-- EMP011 - Staff Nurse (L4) - 5.4L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'), @SS_IN, @GL4,
 540000.00, 45000.00, 36900.00, 31365.00, 'INR', '2024-04-01', NULL, 1,
 'Staff Nurse, General Ward.'),

-- EMP012 - Chief Pharmacist (L7) - 16L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'), @SS_IN, @GL7,
 1600000.00, 133333.00, 109333.00, 92800.00, 'INR', '2024-04-01', NULL, 1,
 'Chief Pharmacist, central pharmacy.'),

-- EMP013 - Pharmacist (L4) - 5.4L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013'), @SS_IN, @GL4,
 540000.00, 45000.00, 36900.00, 31365.00, 'INR', '2024-04-01', NULL, 1,
 'Pharmacist, outpatient pharmacy.'),

-- EMP014 - Administrative Executive (L4) - 4.2L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014'), @SS_IN, @GL4,
 420000.00, 35000.00, 28700.00, 24400.00, 'INR', '2024-04-01', NULL, 1,
 'Administrative Executive.'),

-- EMP015 - Front Desk Executive (L3) - 3L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015'), @SS_IN, @GL3,
 300000.00, 25000.00, 20500.00, 17425.00, 'INR', '2024-04-01', NULL, 1,
 'Front Desk Executive.'),

-- ====== DELHI ======
-- EMP016 - Medical Director Delhi (L9) - 55L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'), @SS_NORTH, @GL9,
 5500000.00, 458333.00, 375833.00, 318000.00, 'INR', '2024-04-01', NULL, 1,
 'Delhi Medical Director. Delhi PT slab applied.'),

-- EMP017 - Sr. Orthopedic Surgeon (L8) - 40L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017'), @SS_NORTH, @GL8,
 4000000.00, 333333.00, 273333.00, 232000.00, 'INR', '2024-04-01', NULL, 1,
 'Senior Orthopedic Surgeon.'),

-- EMP018 - Senior Nurse Delhi (L5) - 9L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018'), @SS_NORTH, @GL5,
 900000.00, 75000.00, 61500.00, 52200.00, 'INR', '2024-04-01', NULL, 1,
 'Senior Nurse, Delhi.'),

-- EMP019 - HR Business Partner (L5) - 9L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), @SS_NORTH, @GL5,
 900000.00, 75000.00, 61500.00, 52200.00, 'INR', '2024-04-01', NULL, 1,
 'HRBP, North India.'),

-- EMP020 - Emergency Medicine Physician (L7) - 24L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), @SS_NORTH, @GL7,
 2400000.00, 200000.00, 164000.00, 139000.00, 'INR', '2024-04-01', NULL, 1,
 'Emergency Physician. 12-hr shift structure. Includes night allowance.'),

-- ====== BENGALURU ======
-- EMP021 - Medical Director Bengaluru (L9) - 55L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021'), @SS_SOUTH, @GL9,
 5500000.00, 458333.00, 375833.00, 318000.00, 'INR', '2024-04-01', NULL, 1,
 'Bengaluru Medical Director. Karnataka PT INR 200/month.'),

-- EMP022 - Consultant Neurologist (L7) - 22L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022'), @SS_SOUTH, @GL7,
 2200000.00, 183333.00, 150333.00, 127500.00, 'INR', '2024-04-01', NULL, 1,
 'Neurologist Consultant.'),

-- EMP023 - Radiologist (L7) - 20L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023'), @SS_SOUTH, @GL7,
 2000000.00, 166667.00, 136667.00, 115800.00, 'INR', '2024-04-01', NULL, 1,
 'Radiologist, CT & MRI specialist.'),

-- EMP024 - Laboratory Technician (L4) - 4.8L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024'), @SS_SOUTH, @GL4,
 480000.00, 40000.00, 32800.00, 27880.00, 'INR', '2024-04-01', NULL, 1,
 'Lab Technician, Microbiology.'),

-- EMP025 - Systems Administrator (L4) - 5.4L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025'), @SS_SOUTH, @GL4,
 540000.00, 45000.00, 36900.00, 31365.00, 'INR', '2024-04-01', NULL, 1,
 'Sysadmin, EHR and network.'),

-- ====== CHENNAI ======
-- EMP026 - Medical Director Chennai (L9) - 58L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'), @SS_SOUTH, @GL9,
 5800000.00, 483333.00, 396333.00, 335000.00, 'INR', '2024-04-01', NULL, 1,
 'Chennai Medical Director and Oncology Lead. Tamil Nadu PT.'),

-- EMP027 - Consultant Oncologist (L7) - 24L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027'), @SS_SOUTH, @GL7,
 2400000.00, 200000.00, 164000.00, 139000.00, 'INR', '2024-04-01', NULL, 1,
 'Oncology Consultant. Includes oncology clinical allowance.'),

-- EMP028 - Staff Nurse Oncology (L4) - 4.8L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'), @SS_SOUTH, @GL4,
 480000.00, 40000.00, 32800.00, 27880.00, 'INR', '2024-04-01', NULL, 1,
 'Nurse, Oncology Ward. On maternity leave from May 2025.'),

-- EMP029 - Senior Pharmacist (L5) - 8.4L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029'), @SS_SOUTH, @GL5,
 840000.00, 70000.00, 57400.00, 48800.00, 'INR', '2024-04-01', NULL, 1,
 'Senior Pharmacist, chemo drug handling.'),

-- EMP030 - HR Executive (L4) - 4.2L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), @SS_SOUTH, @GL4,
 420000.00, 35000.00, 28700.00, 24400.00, 'INR', '2024-04-01', NULL, 1,
 'HR Executive, Chennai.'),

-- ====== HYDERABAD ======
-- EMP031 - Medical Director Hyderabad (L9) - 52L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031'), @SS_SOUTH, @GL9,
 5200000.00, 433333.00, 355333.00, 301000.00, 'INR', '2024-04-01', NULL, 1,
 'Hyderabad Medical Director. Telangana PT INR 200/month.'),

-- EMP032 - Consultant Pediatrician (L7) - 20L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032'), @SS_SOUTH, @GL7,
 2000000.00, 166667.00, 136667.00, 115800.00, 'INR', '2024-04-01', NULL, 1,
 'Pediatrician Consultant.'),

-- EMP033 - Radiology Technician (L4) - 4.8L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033'), @SS_SOUTH, @GL4,
 480000.00, 40000.00, 32800.00, 27880.00, 'INR', '2024-04-01', NULL, 1,
 'Radiology Tech, X-Ray and Ultrasound.'),

-- EMP034 - Junior Staff Nurse (L3) - 3.6L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034'), @SS_SOUTH, @GL3,
 360000.00, 30000.00, 24600.00, 20910.00, 'INR', '2024-04-01', NULL, 1,
 'Junior Nurse, General Ward.'),

-- EMP035 - Accountant (L4) - 4.8L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035'), @SS_SOUTH, @GL4,
 480000.00, 40000.00, 32800.00, 27880.00, 'INR', '2024-04-01', NULL, 1,
 'Accountant, billing and insurance claims.'),

-- ====== KOLKATA ======
-- EMP036 - Medical Director Kolkata (L9) - 50L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036'), @SS_NORTH, @GL9,
 5000000.00, 416667.00, 341667.00, 289000.00, 'INR', '2024-04-01', NULL, 1,
 'Kolkata Medical Director.'),

-- EMP037 - Pathologist (L7) - 20L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037'), @SS_NORTH, @GL7,
 2000000.00, 166667.00, 136667.00, 115800.00, 'INR', '2024-04-01', NULL, 1,
 'Pathologist, MBBS MD. West Bengal PT.'),

-- EMP038 - Staff Nurse Kolkata (L4) - 4.8L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038'), @SS_NORTH, @GL4,
 480000.00, 40000.00, 32800.00, 27880.00, 'INR', '2024-04-01', NULL, 1,
 'Staff Nurse, Pathology support.'),

-- EMP039 - Operations Manager (L7) - 16L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039'), @SS_NORTH, @GL7,
 1600000.00, 133333.00, 109333.00, 92800.00, 'INR', '2024-04-01', NULL, 1,
 'Operations Manager, Kolkata.'),

-- EMP040 - Paramedic Officer (L4) - 4.2L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040'), @SS_NORTH, @GL4,
 420000.00, 35000.00, 28700.00, 24400.00, 'INR', '2024-04-01', NULL, 1,
 'Paramedic, Emergency. Includes on-call allowance.'),

-- ====== PUNE ======
-- EMP041 - Hospital Administrator (L8) - 28L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041'), @SS_IN, @GL8,
 2800000.00, 233333.00, 191333.00, 162200.00, 'INR', '2024-04-01', NULL, 1,
 'Hospital Administrator, Pune.'),

-- EMP042 - Consultant Cardiologist (L7) - 22L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042'), @SS_IN, @GL7,
 2200000.00, 183333.00, 150333.00, 127500.00, 'INR', '2024-04-01', NULL, 1,
 'Cardiologist, Pune Hospital.'),

-- EMP043 - Junior Resident (L4) - 7.2L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'), @SS_IN, @GL4,
 720000.00, 60000.00, 49200.00, 41820.00, 'INR', '2024-04-01', NULL, 1,
 'Junior Resident, rotating departments. Stipend-based structure.'),

-- EMP044 - Staff Nurse Pune (L4) - 4.8L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044'), @SS_IN, @GL4,
 480000.00, 40000.00, 32800.00, 27880.00, 'INR', '2024-04-01', NULL, 1,
 'Staff Nurse, Cardiology Ward.'),

-- EMP045 - Ward Boy (L2) - 2.4L CTC
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'), @SS_IN, @GL2,
 240000.00, 20000.00, 16400.00, 13940.00, 'INR', '2024-04-01', NULL, 1,
 'Ward Boy, Cardiology and General wards. ESI applicable (gross < 21,000).');


-- -------------------------------------------------------
-- EMPLOYEE SALARY COMPONENT
-- Actual computed amounts for March 2025 payroll month.
-- One row per salary component per employee.
-- FinalAmount = ComputedAmount (no overrides this month
-- except where noted with OverrideAmount).
-- All amounts in INR.
--
-- Standard deduction mapping:
--   PF_EMP  = 12% of Basic (capped at 1,800 if Basic > 15,000)
--   ESI_EMP = 0.75% of Gross (only if Gross <= 21,000)
--   PT      = 200 (Maharashtra/Karnataka/Telangana/WB)
--   TDS     = as computed by tax engine
-- -------------------------------------------------------
PRINT 'Inserting payroll.EmployeeSalaryComponent (March 2025)...';

-- Declare component structure IDs for SS-MEDCARE-IN-STD
DECLARE @S_IN BIGINT = (SELECT Id FROM payroll.SalaryStructure WHERE StructureCode = 'SS-MEDCARE-IN-STD');

-- We insert per-employee per-component for March 2025 (PayrollMonth=3, PayrollYear=2025)
-- Pattern: (EmployeeSalaryId, SalaryStructureComponentId, Month, Year, ComputedAmount, OverrideAmount, OverrideReason)

-- ---- EMP001 CMO | Monthly CTC 1,000,000 | Basic 400,000 ----
DECLARE @ES_001 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId = (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND IsActive=1);
DECLARE @S_001  BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id = @ES_001);

INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount) VALUES
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),       3, 2025, 400000.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='HRA')),         3, 2025,  80000.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TA')),          3, 2025,   1600.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3, 2025,   1250.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3, 2025,      0.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3, 2025, 287350.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_ER')),       3, 2025,  48000.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_ER')),      3, 2025,      0.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='GRATUITY')),    3, 2025,  19240.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='OTPAY')),       3, 2025,    560.00),  -- 35 OT mins
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_EMP')),      3, 2025,  48000.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3, 2025,      0.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PT')),          3, 2025,    200.00),
(@ES_001, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_001 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TDS')),         3, 2025,  77000.00);

-- ---- EMP009 Resident Doctor | Monthly CTC 83,333 | Basic 33,333 ----
DECLARE @ES_009 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId = (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009') AND IsActive=1);
DECLARE @S_009  BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id = @ES_009);

INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount, OverrideAmount, OverrideReason) VALUES
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),       3, 2025, 33333.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='HRA')),         3, 2025,  6667.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TA')),          3, 2025,  1600.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3, 2025,  1250.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3, 2025,     0.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3, 2025, 21483.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_ER')),       3, 2025,  4000.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_ER')),      3, 2025,     0.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='GRATUITY')),    3, 2025,  1603.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='OTPAY')),       3, 2025,   960.00, NULL, NULL),  -- 60 OT mins
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_EMP')),      3, 2025,  4000.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3, 2025,     0.00, NULL, NULL),
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PT')),          3, 2025,   200.00, NULL, NULL),
-- Sick leave 3 days — TDS remains same (annualized)
(@ES_009, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_009 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TDS')),         3, 2025,  3333.00, NULL, NULL);

-- ---- EMP010 Senior ICU Nurse | Monthly CTC 75,000 | Basic 30,000 ----
-- Note: Night shift allowance applies; ESI not applicable (gross > 21,000)
DECLARE @ES_010 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId = (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND IsActive=1);
DECLARE @S_010  BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id = @ES_010);

INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount, OverrideAmount, OverrideReason) VALUES
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),       3, 2025, 30000.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='HRA')),         3, 2025,  6000.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TA')),          3, 2025,  1600.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3, 2025,  1250.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3, 2025,  2000.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3, 2025, 13710.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_ER')),       3, 2025,  3600.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_ER')),      3, 2025,     0.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='GRATUITY')),    3, 2025,  1443.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='OTPAY')),       3, 2025,  1440.00, NULL, NULL),  -- 90 OT mins
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_EMP')),      3, 2025,  3600.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3, 2025,     0.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PT')),          3, 2025,   200.00, NULL, NULL),
(@ES_010, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_010 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TDS')),         3, 2025,  5700.00, NULL, NULL);

-- ---- EMP011 Staff Nurse | Monthly CTC 45,000 | Basic 18,000 ----
-- ESI applicable (gross 36,900 > 21,000 threshold — NOT applicable; gross 36,900 > 21,000 so ESI=0)
DECLARE @ES_011 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId = (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011') AND IsActive=1);
DECLARE @S_011  BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id = @ES_011);

INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount) VALUES
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),       3, 2025, 18000.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='HRA')),         3, 2025,  3600.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TA')),          3, 2025,  1600.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3, 2025,  1250.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3, 2025,     0.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3, 2025,  9527.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_ER')),       3, 2025,  2160.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_ER')),      3, 2025,     0.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='GRATUITY')),    3, 2025,   866.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='OTPAY')),       3, 2025,     0.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_EMP')),      3, 2025,  2160.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3, 2025,     0.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PT')),          3, 2025,   200.00),
(@ES_011, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_011 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TDS')),         3, 2025,   975.00);

-- ---- EMP045 Ward Boy | Monthly CTC 20,000 | Basic 8,000 ----
-- ESI applicable: Gross 16,400 < 21,000 threshold
DECLARE @ES_045 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId = (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045') AND IsActive=1);
DECLARE @S_045  BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id = @ES_045);

INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount) VALUES
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='BASIC')),       3, 2025,  8000.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='HRA')),         3, 2025,  1600.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TA')),          3, 2025,  1600.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3, 2025,  1250.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3, 2025,     0.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3, 2025,  2783.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_ER')),       3, 2025,   960.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_ER')),      3, 2025,   533.00),  -- 3.25% × 16,400
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='GRATUITY')),    3, 2025,   385.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='OTPAY')),       3, 2025,     0.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PF_EMP')),      3, 2025,   960.00),
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3, 2025,   123.00),  -- 0.75% × 16,400
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='PT')),          3, 2025,     0.00),  -- below PT threshold
(@ES_045, (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@S_045 AND PayrollComponentId=(SELECT Id FROM dbo.PayrollComponent WHERE ComponentCode='TDS')),         3, 2025,     0.00);  -- below taxable income


-- -------------------------------------------------------
-- SALARY REVISION
-- Captures the most recent annual increment (FY2024 → FY2025)
-- for a representative set of employees. All others had their
-- salary set at joining and revised in April 2024.
-- RevisionType = ANNUAL_INCREMENT for April cycle.
-- -------------------------------------------------------
PRINT 'Inserting payroll.SalaryRevision...';

-- Prior year salary records (FY2023-24) — inserted as historical inactive records
-- for revision linkage. We insert brief inactive records for CMO and Sr. Surgeon.

INSERT INTO payroll.EmployeeSalary
    (EmployeeId, SalaryStructureId, SalaryGradeId, AnnualCTC, MonthlyCTC, MonthlyGross, MonthlyNet, CurrencyCode, EffectiveFrom, EffectiveTo, IsActive, Remarks)
VALUES
-- EMP001 prior year
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), @SS_IN, @GL10,
 10800000.00, 900000.00, 738000.00, 625500.00, 'INR', '2023-04-01', '2024-03-31', 0,
 'FY2023-24 salary record. Superseded by April 2024 revision.'),
-- EMP003 prior year
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), @SS_IN, @GL8,
 3800000.00, 316667.00, 259667.00, 220500.00, 'INR', '2023-04-01', '2024-03-31', 0,
 'FY2023-24 salary record.'),
-- EMP010 prior year
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), @SS_IN, @GL5,
 780000.00, 65000.00, 53300.00, 45300.00, 'INR', '2023-04-01', '2024-03-31', 0,
 'FY2023-24 salary record.'),
-- EMP020 prior year
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), @SS_NORTH, @GL7,
 2200000.00, 183333.00, 150333.00, 127500.00, 'INR', '2023-04-01', '2024-03-31', 0,
 'FY2023-24 salary record.');

-- Now insert SalaryRevision records linking old → new
INSERT INTO payroll.SalaryRevision
    (EmployeeId, OldEmployeeSalaryId, NewEmployeeSalaryId, RevisionType, RevisionDate,
     OldAnnualCTC, NewAnnualCTC, IncrementPercentage, Reason, ApprovedBy, ApprovedAt)
VALUES
-- EMP001 CMO: 10.8L → 12L (11.1% increment)
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND IsActive=0 AND EffectiveFrom='2023-04-01'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND IsActive=1),
    'ANNUAL_INCREMENT', '2024-04-01',
    10800000.00, 12000000.00, 11.1100,
    'Annual performance review — Exceptional rating. 11.11% increment approved.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2024-03-25 14:00:00'
),
-- EMP003 Sr. Surgeon: 38L → 42L (10.5% increment)
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND IsActive=0 AND EffectiveFrom='2023-04-01'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND IsActive=1),
    'ANNUAL_INCREMENT', '2024-04-01',
    3800000.00, 4200000.00, 10.5300,
    'Annual increment — Meets & Exceeds rating. High-demand surgical specialty.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2024-03-25 14:00:00'
),
-- EMP010 Sr. ICU Nurse: 7.8L → 9L (15.4% increment — market correction)
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND IsActive=0 AND EffectiveFrom='2023-04-01'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND IsActive=1),
    'MARKET_CORRECTION', '2024-04-01',
    780000.00, 900000.00, 15.3800,
    'Market correction for ICU nursing — acute shortage of critical care nurses in Mumbai.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2024-03-25 14:00:00'
),
-- EMP020 Emergency Physician: 22L → 24L (9.1% increment)
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND IsActive=0 AND EffectiveFrom='2023-04-01'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND IsActive=1),
    'ANNUAL_INCREMENT', '2024-04-01',
    2200000.00, 2400000.00, 9.0900,
    'Annual increment — Strong performance in Delhi Emergency.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2024-03-25 14:00:00'
),
-- EMP043 Junior Resident: JOINING (first salary; no prior record)
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'),
    NULL,
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043') AND IsActive=1),
    'JOINING', '2023-08-01',
    NULL, 720000.00, NULL,
    'Joining salary for Junior Resident, Pune. Stipend-based CTC.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2023-07-28 10:00:00'
);


-- =============================================================================================================
-- MODULE 2: BANK CREDIT & TRANSACTIONS
-- =============================================================================================================


-- -------------------------------------------------------
-- BANK MASTER
-- Major Indian banks used by MedCare employees for salary
-- credit. Covers public sector, private sector, and one
-- co-operative bank (common in Maharashtra healthcare sector).
-- -------------------------------------------------------
PRINT 'Inserting payroll.BankMaster...';
INSERT INTO payroll.BankMaster (BankCode, BankName, IfscPrefix, SwiftCode, CountryCode) VALUES
('SBI',     'State Bank of India',                  'SBIN', 'SBININBB', 'IN'),
('HDFC',    'HDFC Bank Ltd.',                       'HDFC', 'HDFCINBB', 'IN'),
('ICICI',   'ICICI Bank Ltd.',                      'ICIC', 'ICICINEN', 'IN'),
('AXIS',    'Axis Bank Ltd.',                       'UTIB', 'AXISINBB', 'IN'),
('KOTAK',   'Kotak Mahindra Bank Ltd.',             'KKBK', 'KKBKINBB', 'IN'),
('PNB',     'Punjab National Bank',                 'PUNB', 'PUNBINBB', 'IN'),
('BOB',     'Bank of Baroda',                       'BARB', 'BARBINBB', 'IN'),
('CANARA',  'Canara Bank',                          'CNRB', 'CNRBINBB', 'IN'),
('UNION',   'Union Bank of India',                  'UBIN', 'UBININBB', 'IN'),
('INDUSIND','IndusInd Bank Ltd.',                   'INDB', 'INDUSINBB','IN'),
('YES',     'Yes Bank Ltd.',                        'YESB', 'YESBINBB', 'IN'),
('SARAS',   'Saraswat Co-operative Bank Ltd.',      'SRCB', NULL,       'IN');


-- -------------------------------------------------------
-- EMPLOYEE BANK ACCOUNT
-- Primary salary accounts for all 45 employees.
-- AccountNumber is stored as a masked placeholder —
-- encrypt at application layer before production use.
-- IsPrimary = 1 for the disbursement account.
-- IsVerified = 1 for all (verified during onboarding).
-- -------------------------------------------------------
PRINT 'Inserting payroll.EmployeeBankAccount...';
INSERT INTO payroll.EmployeeBankAccount
    (EmployeeId, BankMasterId, AccountHolderName, AccountNumber, AccountType, IfscCode, BranchName, CurrencyCode, IsPrimary, IsVerified, VerifiedBy, VerifiedAt)
VALUES
-- EMP001 CMO — HDFC Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Rajesh Sharma', 'HDFC000000100001', 'SALARY', 'HDFC0001234', 'Bandra Kurla Complex, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2012-01-15 10:00:00'),

-- EMP002 Medical Director — ICICI Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),
 'Priya Nair', 'ICIC000000100002', 'SALARY', 'ICIC0001567', 'Andheri West, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2014-03-01 10:00:00'),

-- EMP003 Sr. Surgeon — HDFC Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Arjun Mehta', 'HDFC000000100003', 'SAVINGS', 'HDFC0001234', 'Bandra Kurla Complex, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2015-06-10 10:00:00'),

-- EMP004 CNO — SBI Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Sunita Pillai', 'SBIN000000100004', 'SAVINGS', 'SBIN0012345', 'Bandra, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2013-08-20 10:00:00'),

-- EMP005 HR Manager — AXIS Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='AXIS'),
 'Vikram Gupta', 'UTIB000000100005', 'SALARY', 'UTIB0001892', 'Lower Parel, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2016-02-14 10:00:00'),

-- EMP006 Finance Manager — HDFC Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Sneha Desai', 'HDFC000000100006', 'SALARY', 'HDFC0001234', 'Bandra Kurla Complex, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2015-09-01 10:00:00'),

-- EMP007 IT Manager — KOTAK Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='KOTAK'),
 'Ramesh Iyer', 'KKBK000000100007', 'SAVINGS', 'KKBK0001001', 'Powai, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2017-04-01 10:00:00'),

-- EMP008 Consultant Physician — ICICI Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),
 'Kavitha Rao', 'ICIC000000100008', 'SAVINGS', 'ICIC0001567', 'Andheri West, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2018-07-15 10:00:00'),

-- EMP009 Resident Doctor — SBI Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Anil Khanna', 'SBIN000000100009', 'SAVINGS', 'SBIN0012345', 'Bandra, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2021-08-01 10:00:00'),

-- EMP010 Senior ICU Nurse — SARAS Mumbai (co-op bank common in healthcare)
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SARAS'),
 'Meena Joshi', 'SRCB000000100010', 'SAVINGS', 'SRCB0000026', 'Dadar, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2019-03-10 10:00:00'),

-- EMP011 Staff Nurse — SBI Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Deepak Singh', 'SBIN000000100011', 'SAVINGS', 'SBIN0012345', 'Bandra, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2020-06-15 10:00:00'),

-- EMP012 Chief Pharmacist — HDFC Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Lalitha Krishnan', 'HDFC000000100012', 'SAVINGS', 'HDFC0001234', 'Bandra Kurla Complex, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2014-11-20 10:00:00'),

-- EMP013 Pharmacist — BOB Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='BOB'),
 'Manoj Verma', 'BARB000000100013', 'SAVINGS', 'BARB0001023', 'Matunga, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2021-01-10 10:00:00'),

-- EMP014 Admin Executive — SBI Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Radha Patel', 'SBIN000000100014', 'SAVINGS', 'SBIN0012345', 'Bandra, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2020-09-01 10:00:00'),

-- EMP015 Front Desk — SBI Mumbai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Suresh Naidu', 'SBIN000000100015', 'SAVINGS', 'SBIN0012345', 'Bandra, Mumbai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2022-02-01 10:00:00'),

-- EMP016 Medical Director Delhi — HDFC Delhi
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Harpreet Kaur', 'HDFC000000200016', 'SALARY', 'HDFC0002451', 'Connaught Place, New Delhi', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2013-05-15 10:00:00'),

-- EMP017 Sr. Orthopedic Surgeon Delhi — ICICI Delhi
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),
 'Nitin Agarwal', 'ICIC000000200017', 'SAVINGS', 'ICIC0002314', 'Karol Bagh, New Delhi', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2016-09-01 10:00:00'),

-- EMP018 Senior Nurse Delhi — PNB Delhi
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='PNB'),
 'Pooja Bhatt', 'PUNB000000200018', 'SAVINGS', 'PUNB0100150', 'Rohini, New Delhi', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2018-03-20 10:00:00'),

-- EMP019 HRBP Delhi — AXIS Delhi
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='AXIS'),
 'Kuldeep Malhotra', 'UTIB000000200019', 'SALARY', 'UTIB0002103', 'Saket, New Delhi', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'), '2019-07-01 10:00:00'),

-- EMP020 Emergency Physician Delhi — HDFC Delhi
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Anita Saxena', 'HDFC000000200020', 'SAVINGS', 'HDFC0002451', 'Connaught Place, New Delhi', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2017-11-01 10:00:00'),

-- EMP021 Medical Director Bengaluru — ICICI Bengaluru
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),
 'Subramaniam Rajan', 'ICIC000000300021', 'SALARY', 'ICIC0003891', 'Whitefield, Bengaluru', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2014-01-10 10:00:00'),

-- EMP022 Neurologist Bengaluru — HDFC Bengaluru
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Divya Menon', 'HDFC000000300022', 'SAVINGS', 'HDFC0003674', 'Indiranagar, Bengaluru', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2019-04-15 10:00:00'),

-- EMP023 Radiologist Bengaluru — KOTAK Bengaluru
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='KOTAK'),
 'Karthik Sundaram', 'KKBK000000300023', 'SAVINGS', 'KKBK0003201', 'Koramangala, Bengaluru', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2017-06-01 10:00:00'),

-- EMP024 Lab Technician Bengaluru — SBI Bengaluru
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Ananya Bose', 'SBIN000000300024', 'SAVINGS', 'SBIN0034567', 'Whitefield, Bengaluru', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2021-05-01 10:00:00'),

-- EMP025 Sysadmin Bengaluru — INDUSIND Bengaluru
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='INDUSIND'),
 'Prasad Kulkarni', 'INDB000000300025', 'SAVINGS', 'INDB0003412', 'HSR Layout, Bengaluru', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2020-10-01 10:00:00'),

-- EMP026 Medical Director Chennai — SBI Chennai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Lakshmi Venkatesh', 'SBIN000000400026', 'SALARY', 'SBIN0043219', 'Anna Salai, Chennai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2011-08-01 10:00:00'),

-- EMP027 Oncologist Chennai — HDFC Chennai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Balachandran Kumar', 'HDFC000000400027', 'SAVINGS', 'HDFC0004512', 'Adyar, Chennai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2018-02-01 10:00:00'),

-- EMP028 Nurse Chennai (on maternity leave) — CANARA Chennai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='CANARA'),
 'Revathi Suresh', 'CNRB000000400028', 'SAVINGS', 'CNRB0004123', 'Perambur, Chennai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2022-01-10 10:00:00'),

-- EMP029 Sr. Pharmacist Chennai — SBI Chennai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Murali Dharan', 'SBIN000000400029', 'SAVINGS', 'SBIN0043219', 'Anna Salai, Chennai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2019-11-01 10:00:00'),

-- EMP030 HR Executive Chennai — ICICI Chennai
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),
 'Sangeetha Arumugam', 'ICIC000000400030', 'SAVINGS', 'ICIC0004781', 'T. Nagar, Chennai', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2023-03-01 10:00:00'),

-- EMP031 Medical Director Hyderabad — HDFC Hyderabad
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Venkat Reddy', 'HDFC000000500031', 'SALARY', 'HDFC0005231', 'Banjara Hills, Hyderabad', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2013-12-01 10:00:00'),

-- EMP032 Pediatrician Hyderabad — ICICI Hyderabad
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),
 'Bhavana Rao', 'ICIC000000500032', 'SAVINGS', 'ICIC0005612', 'Jubilee Hills, Hyderabad', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2017-09-01 10:00:00'),

-- EMP033 Radiology Tech Hyderabad — SBI Hyderabad
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Ravi Chandra', 'SBIN000000500033', 'SAVINGS', 'SBIN0053781', 'Secunderabad, Hyderabad', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2021-06-01 10:00:00'),

-- EMP034 Junior Nurse Hyderabad — UNION Hyderabad
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='UNION'),
 'Padma Devi', 'UBIN000000500034', 'SAVINGS', 'UBIN0551023', 'HITEC City, Hyderabad', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2023-01-15 10:00:00'),

-- EMP035 Accountant Hyderabad — AXIS Hyderabad
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='AXIS'),
 'Sunil Babu', 'UTIB000000500035', 'SAVINGS', 'UTIB0005891', 'Madhapur, Hyderabad', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2020-08-01 10:00:00'),

-- EMP036 Medical Director Kolkata — SBI Kolkata
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Debashish Ghosh', 'SBIN000000600036', 'SALARY', 'SBIN0067234', 'Salt Lake, Kolkata', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2014-07-01 10:00:00'),

-- EMP037 Pathologist Kolkata — HDFC Kolkata
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Ankita Chatterjee', 'HDFC000000600037', 'SAVINGS', 'HDFC0006312', 'Park Street, Kolkata', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2018-10-01 10:00:00'),

-- EMP038 Staff Nurse Kolkata — SBI Kolkata
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Soumya Das', 'SBIN000000600038', 'SAVINGS', 'SBIN0067234', 'Salt Lake, Kolkata', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2021-04-01 10:00:00'),

-- EMP039 Operations Manager Kolkata — BOB Kolkata
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='BOB'),
 'Tapas Banerjee', 'BARB000000600039', 'SAVINGS', 'BARB0006781', 'Ballygunge, Kolkata', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2016-05-01 10:00:00'),

-- EMP040 Paramedic Kolkata — SBI Kolkata
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Rupa Mondal', 'SBIN000000600040', 'SAVINGS', 'SBIN0067234', 'Salt Lake, Kolkata', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2022-09-01 10:00:00'),

-- EMP041 Hospital Administrator Pune — HDFC Pune
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),
 'Shyam Kulkarni', 'HDFC000000700041', 'SALARY', 'HDFC0007823', 'Koregaon Park, Pune', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2015-11-01 10:00:00'),

-- EMP042 Cardiologist Pune — ICICI Pune
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),
 'Namrata Deshpande', 'ICIC000000700042', 'SAVINGS', 'ICIC0007134', 'Aundh, Pune', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2019-02-01 10:00:00'),

-- EMP043 Junior Resident Pune — SBI Pune
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Rohit Patil', 'SBIN000000700043', 'SAVINGS', 'SBIN0078912', 'Hadapsar, Pune', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2023-08-01 10:00:00'),

-- EMP044 Staff Nurse Pune — AXIS Pune
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='AXIS'),
 'Ashwini More', 'UTIB000000700044', 'SAVINGS', 'UTIB0007345', 'Pimpri, Pune', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2020-12-01 10:00:00'),

-- EMP045 Ward Boy Pune — SBI Pune (ESI beneficiary)
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),
 'Ganesh Shinde', 'SBIN000000700045', 'SAVINGS', 'SBIN0078912', 'Hadapsar, Pune', 'INR', 1, 1,
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2022-06-01 10:00:00');


-- -------------------------------------------------------
-- PAYROLL DISBURSEMENT
-- March 2025 payroll disbursement batch for each legal entity.
-- Status = COMPLETED for all three (payroll already processed).
-- BankBatchReferenceNo = bank-assigned batch UTR prefix.
-- -------------------------------------------------------
PRINT 'Inserting payroll.PayrollDisbursement (March 2025)...';
INSERT INTO payroll.PayrollDisbursement
    (LegalEntityId, PayrollMonth, PayrollYear, DisbursementDate, TotalEmployeeCount,
     TotalNetPayable, CurrencyCode, DisbursementStatus, BankBatchReferenceNo,
     InitiatedBy, ApprovedBy, ApprovedAt, ProcessedAt, Remarks)
VALUES
-- MEDCARE-IN (Mumbai + Pune = 20 employees)
(
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-IN'),
    3, 2025, '2025-03-31', 20,
    -- Sum of MonthlyNet for EMP001-015 + EMP041-045
    3467580.00, 'INR', 'COMPLETED',
    'MEDCAREIN-MAR25-HDFC-BATCH-001',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'),
    '2025-03-29 16:00:00', '2025-03-31 23:45:00',
    'March 2025 salary disbursement for MedCare India Pvt. Ltd. All 20 employees processed via HDFC payroll gateway. NEFT bulk credit.'
),
-- MEDCARE-NORTH (Delhi + Kolkata = 10 employees)
(
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-NORTH'),
    3, 2025, '2025-03-31', 10,
    -- Sum of MonthlyNet for EMP016-020 + EMP036-040
    1474200.00, 'INR', 'COMPLETED',
    'MEDCARENORTH-MAR25-SBI-BATCH-001',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'),
    '2025-03-29 15:00:00', '2025-03-31 22:30:00',
    'March 2025 salary for MedCare North India. SBI RTGS bulk transfer.'
),
-- MEDCARE-SOUTH (Bengaluru + Chennai + Hyderabad = 15 employees)
(
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    3, 2025, '2025-03-31', 15,
    -- Sum of MonthlyNet for EMP021-035
    1662595.00, 'INR', 'COMPLETED',
    'MEDCARESOUTH-MAR25-ICICI-BATCH-001',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'),
    '2025-03-29 17:00:00', '2025-04-01 01:00:00',
    'March 2025 salary for MedCare South India. ICICI NEFT bulk credit.'
);


-- -------------------------------------------------------
-- PAYROLL DISBURSEMENT TRANSACTION
-- Individual credit records for all 45 employees for
-- March 2025. BankTransactionId = UTR number format
-- (bank returns this after successful NEFT/RTGS credit).
-- PaymentMode = NEFT for standard amounts, RTGS for senior
-- management CTC above INR 2L/month.
-- -------------------------------------------------------
PRINT 'Inserting payroll.PayrollDisbursementTransaction (March 2025)...';

-- Helper: resolve disbursement batch IDs
DECLARE @DISP_IN    BIGINT = (SELECT Id FROM payroll.PayrollDisbursement WHERE LegalEntityId=(SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-IN')    AND PayrollMonth=3 AND PayrollYear=2025);
DECLARE @DISP_NORTH BIGINT = (SELECT Id FROM payroll.PayrollDisbursement WHERE LegalEntityId=(SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-NORTH') AND PayrollMonth=3 AND PayrollYear=2025);
DECLARE @DISP_SOUTH BIGINT = (SELECT Id FROM payroll.PayrollDisbursement WHERE LegalEntityId=(SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-SOUTH') AND PayrollMonth=3 AND PayrollYear=2025);

INSERT INTO payroll.PayrollDisbursementTransaction
    (PayrollDisbursementId, EmployeeId, EmployeeBankAccountId, PayrollMonth, PayrollYear,
     GrossAmount, TotalDeductions, CurrencyCode, TransactionStatus, BankTransactionId,
     PaymentMode, InitiatedAt, ConfirmedAt, Remarks)
VALUES
-- ====== MEDCARE-IN — MUMBAI ======
(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND IsPrimary=1),
 3, 2025, 820000.00, 125000.00, 'INR', 'SUCCESS', 'UTR202503310000100001', 'RTGS', '2025-03-31 20:00:00', '2025-03-31 21:30:00', 'CMO March 2025 salary. RTGS credit confirmed.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002') AND IsPrimary=1),
 3, 2025, 410000.00, 62000.00, 'INR', 'SUCCESS', 'UTR202503310000100002', 'RTGS', '2025-03-31 20:00:00', '2025-03-31 21:30:00', 'Medical Director March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND IsPrimary=1),
 3, 2025, 287000.00, 44000.00, 'INR', 'SUCCESS', 'UTR202503310000100003', 'RTGS', '2025-03-31 20:00:00', '2025-03-31 21:30:00', 'Sr. Surgeon March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004') AND IsPrimary=1),
 3, 2025, 205000.00, 31000.00, 'INR', 'SUCCESS', 'UTR202503310000100004', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'CNO March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005') AND IsPrimary=1),
 3, 2025, 123000.00, 19000.00, 'INR', 'SUCCESS', 'UTR202503310000100005', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'HR Manager March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006') AND IsPrimary=1),
 3, 2025, 123000.00, 19000.00, 'INR', 'SUCCESS', 'UTR202503310000100006', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Finance Manager March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007') AND IsPrimary=1),
 3, 2025, 123000.00, 19000.00, 'INR', 'SUCCESS', 'UTR202503310000100007', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'IT Manager March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008') AND IsPrimary=1),
 3, 2025, 150333.00, 22833.00, 'INR', 'SUCCESS', 'UTR202503310000100008', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Consultant Physician March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009') AND IsPrimary=1),
 3, 2025, 68333.00, 10333.00, 'INR', 'SUCCESS', 'UTR202503310000100009', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Resident Doctor March 2025. 3 days SL deducted from leave balance.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND IsPrimary=1),
 3, 2025, 61500.00, 9300.00, 'INR', 'SUCCESS', 'UTR202503310000100010', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Sr. ICU Nurse. Includes night allowance + OT.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011') AND IsPrimary=1),
 3, 2025, 36900.00, 5535.00, 'INR', 'SUCCESS', 'UTR202503310000100011', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Staff Nurse March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012') AND IsPrimary=1),
 3, 2025, 109333.00, 16533.00, 'INR', 'SUCCESS', 'UTR202503310000100012', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Chief Pharmacist March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013') AND IsPrimary=1),
 3, 2025, 36900.00, 5535.00, 'INR', 'SUCCESS', 'UTR202503310000100013', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Pharmacist March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014') AND IsPrimary=1),
 3, 2025, 28700.00, 4300.00, 'INR', 'SUCCESS', 'UTR202503310000100014', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Admin Executive March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015') AND IsPrimary=1),
 3, 2025, 20500.00, 3075.00, 'INR', 'SUCCESS', 'UTR202503310000100015', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Front Desk March 2025.'),

-- ====== MEDCARE-NORTH — DELHI ======
(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016') AND IsPrimary=1),
 3, 2025, 375833.00, 57833.00, 'INR', 'SUCCESS', 'UTR202503310000200016', 'RTGS', '2025-03-31 20:30:00', '2025-03-31 22:00:00', 'Delhi Medical Director March 2025.'),

(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017') AND IsPrimary=1),
 3, 2025, 273333.00, 41333.00, 'INR', 'SUCCESS', 'UTR202503310000200017', 'RTGS', '2025-03-31 20:30:00', '2025-03-31 22:00:00', 'Sr. Orthopedic Surgeon March 2025.'),

(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018') AND IsPrimary=1),
 3, 2025, 61500.00, 9300.00, 'INR', 'SUCCESS', 'UTR202503310000200018', 'NEFT', '2025-03-31 20:30:00', '2025-03-31 23:30:00', 'Sr. Nurse Delhi March 2025.'),

(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019') AND IsPrimary=1),
 3, 2025, 61500.00, 9300.00, 'INR', 'SUCCESS', 'UTR202503310000200019', 'NEFT', '2025-03-31 20:30:00', '2025-03-31 23:30:00', 'HRBP Delhi March 2025.'),

(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND IsPrimary=1),
 3, 2025, 164000.00, 25000.00, 'INR', 'SUCCESS', 'UTR202503310000200020', 'NEFT', '2025-03-31 20:30:00', '2025-03-31 23:30:00', 'Emergency Physician Delhi. 180 OT mins included.'),

-- ====== PUNE — (also MEDCARE-IN batch) ======
(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041') AND IsPrimary=1),
 3, 2025, 191333.00, 29133.00, 'INR', 'SUCCESS', 'UTR202503310000100041', 'RTGS', '2025-03-31 20:00:00', '2025-03-31 21:30:00', 'Hospital Admin Pune March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042') AND IsPrimary=1),
 3, 2025, 150333.00, 22833.00, 'INR', 'SUCCESS', 'UTR202503310000100042', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Cardiologist Pune March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043') AND IsPrimary=1),
 3, 2025, 49200.00, 7380.00, 'INR', 'SUCCESS', 'UTR202503310000100043', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Junior Resident Pune March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044') AND IsPrimary=1),
 3, 2025, 32800.00, 4920.00, 'INR', 'SUCCESS', 'UTR202503310000100044', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Staff Nurse Pune March 2025.'),

(@DISP_IN, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045') AND IsPrimary=1),
 3, 2025, 16400.00, 2460.00, 'INR', 'SUCCESS', 'UTR202503310000100045', 'NEFT', '2025-03-31 20:00:00', '2025-03-31 23:00:00', 'Ward Boy Pune. ESI deducted (gross < 21,000).'),

-- ====== MEDCARE-SOUTH — BENGALURU ======
(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021') AND IsPrimary=1),
 3, 2025, 375833.00, 57833.00, 'INR', 'SUCCESS', 'UTR202503310000300021', 'RTGS', '2025-03-31 21:00:00', '2025-04-01 00:30:00', 'Medical Director Bengaluru March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022') AND IsPrimary=1),
 3, 2025, 150333.00, 22833.00, 'INR', 'SUCCESS', 'UTR202503310000300022', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Neurologist Bengaluru March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023') AND IsPrimary=1),
 3, 2025, 136667.00, 20867.00, 'INR', 'SUCCESS', 'UTR202503310000300023', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Radiologist Bengaluru March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024') AND IsPrimary=1),
 3, 2025, 32800.00, 4920.00, 'INR', 'SUCCESS', 'UTR202503310000300024', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Lab Technician Bengaluru March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025') AND IsPrimary=1),
 3, 2025, 36900.00, 5535.00, 'INR', 'SUCCESS', 'UTR202503310000300025', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Sysadmin Bengaluru March 2025.'),

-- ====== MEDCARE-SOUTH — CHENNAI ======
(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND IsPrimary=1),
 3, 2025, 396333.00, 61333.00, 'INR', 'SUCCESS', 'UTR202503310000300026', 'RTGS', '2025-03-31 21:00:00', '2025-04-01 00:30:00', 'Chennai Medical Director March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027') AND IsPrimary=1),
 3, 2025, 164000.00, 25000.00, 'INR', 'SUCCESS', 'UTR202503310000300027', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Oncologist Chennai March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028') AND IsPrimary=1),
 3, 2025, 32800.00, 4920.00, 'INR', 'SUCCESS', 'UTR202503310000300028', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Nurse Chennai. On maternity leave from May 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029') AND IsPrimary=1),
 3, 2025, 57400.00, 8600.00, 'INR', 'SUCCESS', 'UTR202503310000300029', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Sr. Pharmacist Chennai March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030') AND IsPrimary=1),
 3, 2025, 28700.00, 4300.00, 'INR', 'SUCCESS', 'UTR202503310000300030', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'HR Executive Chennai March 2025.'),

-- ====== MEDCARE-SOUTH — HYDERABAD ======
(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031') AND IsPrimary=1),
 3, 2025, 355333.00, 54333.00, 'INR', 'SUCCESS', 'UTR202503310000300031', 'RTGS', '2025-03-31 21:00:00', '2025-04-01 00:30:00', 'Hyderabad Medical Director March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032') AND IsPrimary=1),
 3, 2025, 136667.00, 20867.00, 'INR', 'SUCCESS', 'UTR202503310000300032', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Pediatrician Hyderabad March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033') AND IsPrimary=1),
 3, 2025, 32800.00, 4920.00, 'INR', 'SUCCESS', 'UTR202503310000300033', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Radiology Tech Hyderabad March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034') AND IsPrimary=1),
 3, 2025, 24600.00, 3690.00, 'INR', 'SUCCESS', 'UTR202503310000300034', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Junior Nurse Hyderabad March 2025.'),

(@DISP_SOUTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035') AND IsPrimary=1),
 3, 2025, 32800.00, 4920.00, 'INR', 'SUCCESS', 'UTR202503310000300035', 'NEFT', '2025-03-31 21:00:00', '2025-04-01 01:00:00', 'Accountant Hyderabad March 2025.'),

-- ====== MEDCARE-NORTH — KOLKATA ======
(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036') AND IsPrimary=1),
 3, 2025, 341667.00, 52667.00, 'INR', 'SUCCESS', 'UTR202503310000200036', 'RTGS', '2025-03-31 20:30:00', '2025-03-31 22:00:00', 'Kolkata Medical Director March 2025.'),

(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037') AND IsPrimary=1),
 3, 2025, 136667.00, 20867.00, 'INR', 'SUCCESS', 'UTR202503310000200037', 'NEFT', '2025-03-31 20:30:00', '2025-03-31 23:30:00', 'Pathologist Kolkata March 2025.'),

(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038') AND IsPrimary=1),
 3, 2025, 32800.00, 4920.00, 'INR', 'SUCCESS', 'UTR202503310000200038', 'NEFT', '2025-03-31 20:30:00', '2025-03-31 23:30:00', 'Staff Nurse Kolkata March 2025.'),

(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039') AND IsPrimary=1),
 3, 2025, 109333.00, 16533.00, 'INR', 'SUCCESS', 'UTR202503310000200039', 'NEFT', '2025-03-31 20:30:00', '2025-03-31 23:30:00', 'Operations Manager Kolkata March 2025.'),

(@DISP_NORTH, (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040'), (SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040') AND IsPrimary=1),
 3, 2025, 28700.00, 4300.00, 'INR', 'SUCCESS', 'UTR202503310000200040', 'NEFT', '2025-03-31 20:30:00', '2025-03-31 23:30:00', 'Paramedic Kolkata March 2025.');


-- =============================================================================================================
-- MODULE 3: TAX DEDUCTIONS
-- =============================================================================================================


-- -------------------------------------------------------
-- TAX REGIME
-- India Old Regime allows most deductions/exemptions (80C,
-- 80D, HRA, LTA etc.). India New Regime (post-FY24) offers
-- lower flat rates with no deductions/exemptions.
-- -------------------------------------------------------
PRINT 'Inserting payroll.TaxRegime...';
INSERT INTO payroll.TaxRegime (RegimeCode, RegimeName, CountryCode, FiscalYearStart, Description) VALUES
('IND-OLD-2024',
 'India Income Tax – Old Regime (FY 2024-25)',
 'IN', '04-01',
 'India Old Tax Regime for FY 2024-25. Allows all deductions: 80C (1.5L), 80D, HRA exemption, '
 + 'LTA, Standard Deduction (50,000), Professional Tax deduction, NPS (80CCD). '
 + 'Slabs: 0-2.5L = Nil, 2.5-5L = 5%, 5-10L = 20%, >10L = 30%. '
 + 'Rebate u/s 87A: full tax rebate if taxable income <= 5L.'),
('IND-NEW-2024',
 'India Income Tax – New Regime (FY 2024-25)',
 'IN', '04-01',
 'India New Tax Regime for FY 2024-25 (default from FY24 onwards per Finance Act 2023). '
 + 'No deductions except Standard Deduction (50,000 from FY24) and NPS employer contribution. '
 + 'Slabs: 0-3L = Nil, 3-6L = 5%, 6-9L = 10%, 9-12L = 15%, 12-15L = 20%, >15L = 30%. '
 + 'Rebate u/s 87A: full tax rebate if taxable income <= 7L.');


-- -------------------------------------------------------
-- TAX SLAB
-- Old Regime and New Regime slabs for FY 2024-25.
-- All income figures in INR annual.
-- TaxRate, SurchargeRate, CessRate in percentage.
-- Surcharge: 10% if income 50L-1Cr, 15% if >1Cr.
-- Health & Education Cess = 4% on (Tax + Surcharge).
-- -------------------------------------------------------
PRINT 'Inserting payroll.TaxSlab (FY 2024-25)...';

DECLARE @OLD_REGIME BIGINT = (SELECT Id FROM payroll.TaxRegime WHERE RegimeCode='IND-OLD-2024');
DECLARE @NEW_REGIME BIGINT = (SELECT Id FROM payroll.TaxRegime WHERE RegimeCode='IND-NEW-2024');

-- Old Regime FY2024-25 slabs
INSERT INTO payroll.TaxSlab (TaxRegimeId, FiscalYear, SlabOrder, MinIncome, MaxIncome, TaxRate, SurchargeRate, CessRate) VALUES
(@OLD_REGIME, 2024, 1,       0.00,    250000.00,  0.00, 0.00, 4.00),   -- Nil slab
(@OLD_REGIME, 2024, 2,  250000.00,    500000.00,  5.00, 0.00, 4.00),   -- 5% slab
(@OLD_REGIME, 2024, 3,  500000.00,   1000000.00, 20.00, 0.00, 4.00),   -- 20% slab
(@OLD_REGIME, 2024, 4, 1000000.00,   5000000.00, 30.00, 0.00, 4.00),   -- 30% slab
(@OLD_REGIME, 2024, 5, 5000000.00,  10000000.00, 30.00,10.00, 4.00),   -- 30% + 10% surcharge (50L–1Cr)
(@OLD_REGIME, 2024, 6,10000000.00,        NULL,  30.00,15.00, 4.00);   -- 30% + 15% surcharge (>1Cr)

-- New Regime FY2024-25 slabs
INSERT INTO payroll.TaxSlab (TaxRegimeId, FiscalYear, SlabOrder, MinIncome, MaxIncome, TaxRate, SurchargeRate, CessRate) VALUES
(@NEW_REGIME, 2024, 1,       0.00,    300000.00,  0.00, 0.00, 4.00),   -- Nil
(@NEW_REGIME, 2024, 2,  300000.00,    600000.00,  5.00, 0.00, 4.00),   -- 5%
(@NEW_REGIME, 2024, 3,  600000.00,    900000.00, 10.00, 0.00, 4.00),   -- 10%
(@NEW_REGIME, 2024, 4,  900000.00,   1200000.00, 15.00, 0.00, 4.00),   -- 15%
(@NEW_REGIME, 2024, 5, 1200000.00,   1500000.00, 20.00, 0.00, 4.00),   -- 20%
(@NEW_REGIME, 2024, 6, 1500000.00,   5000000.00, 30.00, 0.00, 4.00),   -- 30%
(@NEW_REGIME, 2024, 7, 5000000.00,  10000000.00, 30.00,10.00, 4.00),   -- 30% + 10% surcharge
(@NEW_REGIME, 2024, 8,10000000.00,        NULL,  30.00,15.00, 4.00);   -- 30% + 15% surcharge


-- -------------------------------------------------------
-- EMPLOYEE TAX DECLARATION (FY 2024-25)
-- Declarations for a representative set of employees
-- covering both tax regimes, different investment profiles.
-- DeclarationStatus = VERIFIED for most (mid-year employees
-- have submitted and HR has verified proofs).
-- EMP028 is on maternity leave; declaration is SUBMITTED.
-- EMP015 / EMP045 are below taxable income — no declaration.
-- -------------------------------------------------------
PRINT 'Inserting payroll.EmployeeTaxDeclaration (FY 2024-25)...';
INSERT INTO payroll.EmployeeTaxDeclaration
    (EmployeeId, TaxRegimeId, FiscalYear, DeclaredTotalIncome, DeclaredExemptions, DeclaredDeductions,
     DeclarationStatus, SubmittedAt, VerifiedBy, VerifiedAt, Remarks)
VALUES
-- EMP001 CMO — Old Regime | CTC 1.2Cr | High investment profile
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), @OLD_REGIME, 2024,
 9840000.00,   -- Annual gross after employer deductions
 720000.00,    -- HRA exemption (partial claim, metro city)
 280000.00,    -- 80C: 1.5L ELSS + NPS 50K + 80D: 30K medical = 2.3L claimed as 2.8L incl. HRA overlap
 'VERIFIED', '2024-07-15 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-08-01 14:00:00',
 'Old regime. High investment profile. HRA exemption claimed for Mumbai accommodation. 80C max.'),

-- EMP002 Medical Director — New Regime | CTC 60L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'), @NEW_REGIME, 2024,
 4920000.00,
 0.00,
 50000.00,     -- Standard Deduction only (new regime)
 'VERIFIED', '2024-07-10 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-25 14:00:00',
 'New regime opted. No additional deductions available. Standard deduction INR 50,000.'),

-- EMP003 Sr. Surgeon — Old Regime | CTC 42L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), @OLD_REGIME, 2024,
 3444000.00,
 480000.00,    -- HRA exemption
 230000.00,    -- 80C: 1.5L + 80D: 50K (super senior parents) + NPS 30K
 'VERIFIED', '2024-07-12 09:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-30 11:00:00',
 'Old regime. HRA for Mumbai flat. Parents insured under 80D senior citizen limit.'),

-- EMP004 CNO — Old Regime | CTC 30L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'), @OLD_REGIME, 2024,
 2460000.00,
 360000.00,    -- HRA exemption
 200000.00,    -- 80C: 1.5L + 80D: 25K + standard 50K
 'VERIFIED', '2024-07-11 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-28 15:00:00',
 'Old regime. Regular LIC and PPF investments declared.'),

-- EMP005 HR Manager — New Regime | CTC 18L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), @NEW_REGIME, 2024,
 1476000.00,
 0.00,
 50000.00,
 'VERIFIED', '2024-07-08 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-22 12:00:00',
 'New regime. Standard deduction. No additional claims.'),

-- EMP006 Finance Manager — Old Regime | CTC 18L (high investment awareness)
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), @OLD_REGIME, 2024,
 1476000.00,
 360000.00,    -- HRA exemption
 200000.00,    -- 80C: 1.5L + 80D: 25K + standard 50K
 'VERIFIED', '2024-07-09 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), '2024-07-23 12:00:00',
 'Old regime. Home loan interest also claimed u/s 24 partially.'),

-- EMP007 IT Manager — New Regime | CTC 18L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'), @NEW_REGIME, 2024,
 1476000.00, 0.00, 50000.00,
 'VERIFIED', '2024-07-10 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-24 12:00:00',
 'New regime. Standard deduction applied.'),

-- EMP008 Consultant Physician — Old Regime | CTC 22L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'), @OLD_REGIME, 2024,
 1803996.00,
 360000.00,
 200000.00,
 'VERIFIED', '2024-07-13 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-29 12:00:00',
 'Old regime. Mumbai HRA exemption. Regular 80C investments.'),

-- EMP009 Resident Doctor — Old Regime | CTC 10L (below standard exemption)
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'), @OLD_REGIME, 2024,
 819996.00,
 80004.00,     -- HRA exemption
 150000.00,    -- 80C: 1.5L (PPF + ELSS)
 'VERIFIED', '2024-07-15 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-31 12:00:00',
 'Old regime. Taxable income after deductions near threshold. Rebate 87A applicable.'),

-- EMP010 Sr. ICU Nurse — Old Regime | CTC 9L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), @OLD_REGIME, 2024,
 738000.00,
 72000.00,     -- Partial HRA
 150000.00,    -- 80C max
 'VERIFIED', '2024-07-14 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-30 12:00:00',
 'Old regime. Taxable income marginally above threshold after 87A rebate limit.'),

-- EMP011 Staff Nurse — New Regime | CTC 5.4L (below 7L rebate limit)
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'), @NEW_REGIME, 2024,
 442800.00, 0.00, 50000.00,
 'SUBMITTED', '2024-07-20 10:00:00', NULL, NULL,
 'New regime. Income < 7L, full rebate 87A applies. Zero tax liability.'),

-- EMP012 Chief Pharmacist — Old Regime | CTC 16L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'), @OLD_REGIME, 2024,
 1311996.00,
 320000.00,
 200000.00,
 'VERIFIED', '2024-07-11 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-07-26 12:00:00',
 'Old regime. HRA exemption for Mumbai accommodation.'),

-- EMP016 Delhi Medical Director — Old Regime | CTC 55L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'), @OLD_REGIME, 2024,
 4499996.00,
 600000.00,
 280000.00,
 'VERIFIED', '2024-07-09 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2024-07-23 12:00:00',
 'Old regime. Delhi HRA. Home loan interest u/s 24.'),

-- EMP020 Emergency Physician Delhi — New Regime | CTC 24L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), @NEW_REGIME, 2024,
 1968000.00, 0.00, 50000.00,
 'VERIFIED', '2024-07-12 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), '2024-07-28 12:00:00',
 'New regime opted. Emergency shift structure, standard deduction only.'),

-- EMP026 Chennai Medical Director — Old Regime | CTC 58L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'), @OLD_REGIME, 2024,
 4759996.00,
 600000.00,
 280000.00,
 'VERIFIED', '2024-07-10 10:00:00',
 (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), '2024-07-25 12:00:00',
 'Old regime. Chennai HRA. Joint home loan.'),

-- EMP028 Staff Nurse Chennai (Maternity Leave) — Old Regime | CTC 4.8L
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'), @OLD_REGIME, 2024,
 393600.00, 0.00, 50000.00,
 'SUBMITTED', '2024-07-18 10:00:00', NULL, NULL,
 'Old regime. On maternity leave May–Oct 2025. Salary paid for partial year. Below taxable limit.');


-- -------------------------------------------------------
-- TAX DECLARATION PROOF
-- Investment proof documents submitted by employees.
-- Each row is one proof document for a specific section.
-- ApprovedAmount may be <= DeclaredAmount after HR review.
-- -------------------------------------------------------
PRINT 'Inserting payroll.TaxDeclarationProof...';
INSERT INTO payroll.TaxDeclarationProof
    (EmployeeTaxDeclarationId, ProofCategory, Description, DeclaredAmount, ApprovedAmount,
     DocumentFileUrl, OriginalFileName, UploadedAt, ReviewedBy, ReviewedAt, ReviewStatus)
VALUES
-- EMP001 CMO proofs
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
 '80C', 'ELSS Mutual Fund – Axis Long Term Equity Fund', 100000.00, 100000.00,
 'https://docs.medcareindia.com/emp001/80c_elss_2024.pdf', '80C_ELSS_Axis_2024.pdf',
 '2024-12-15 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-20 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
 '80C', 'LIC Premium – Jeevan Anand Policy No. 123456789', 50000.00, 50000.00,
 'https://docs.medcareindia.com/emp001/80c_lic_2024.pdf', '80C_LIC_Premium_2024.pdf',
 '2024-12-15 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-20 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
 '80C', 'PPF Contribution – SBI Account', 50000.00, 50000.00,
 'https://docs.medcareindia.com/emp001/80c_ppf_2024.pdf', '80C_PPF_Statement_2024.pdf',
 '2024-12-15 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-20 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
 '80D', 'Medical Insurance – Family Floater (Self, Spouse, 2 Children)', 25000.00, 25000.00,
 'https://docs.medcareindia.com/emp001/80d_mediclaim_2024.pdf', '80D_Mediclaim_2024.pdf',
 '2024-12-15 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-20 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
 '80D', 'Medical Insurance – Parents (Senior Citizens)', 50000.00, 50000.00,
 'https://docs.medcareindia.com/emp001/80d_parents_2024.pdf', '80D_Parents_Policy_2024.pdf',
 '2024-12-15 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-20 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
 'HRA', 'Rent Receipts – Bandra West, Mumbai | INR 60,000/month × 12', 720000.00, 720000.00,
 'https://docs.medcareindia.com/emp001/hra_receipts_2024.pdf', 'Rent_Receipts_2024_EMP001.pdf',
 '2024-12-15 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-20 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
 '80CCD', 'NPS – National Pension System (Tier 1) additional contribution', 50000.00, 50000.00,
 'https://docs.medcareindia.com/emp001/nps_statement_2024.pdf', 'NPS_Statement_2024.pdf',
 '2024-12-15 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-20 12:00:00', 'APPROVED'),

-- EMP003 Sr. Surgeon proofs
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),
 '80C', 'Children Education Tuition Fee + ELSS', 150000.00, 150000.00,
 'https://docs.medcareindia.com/emp003/80c_combined_2024.pdf', '80C_Proof_EMP003_2024.pdf',
 '2024-12-16 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-21 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),
 '80D', 'Group Medical Insurance top-up + Parents senior citizen', 50000.00, 50000.00,
 'https://docs.medcareindia.com/emp003/80d_2024.pdf', '80D_Proof_EMP003_2024.pdf',
 '2024-12-16 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-21 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),
 'HRA', 'Rent Receipts – Worli, Mumbai | INR 40,000/month', 480000.00, 480000.00,
 'https://docs.medcareindia.com/emp003/hra_2024.pdf', 'HRA_Receipts_EMP003_2024.pdf',
 '2024-12-16 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-21 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),
 '80CCD', 'NPS Tier 1 contribution', 30000.00, 30000.00,
 'https://docs.medcareindia.com/emp003/nps_2024.pdf', 'NPS_EMP003_2024.pdf',
 '2024-12-16 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-21 12:00:00', 'APPROVED'),

-- EMP010 Sr. ICU Nurse proofs
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND FiscalYear=2024),
 '80C', 'PPF + LIC Premium (Annual)', 100000.00, 100000.00,
 'https://docs.medcareindia.com/emp010/80c_2024.pdf', '80C_EMP010_2024.pdf',
 '2024-12-18 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-24 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND FiscalYear=2024),
 '80C', 'ELSS – SBI Magnum Tax Gain', 50000.00, 50000.00,
 'https://docs.medcareindia.com/emp010/80c_elss_2024.pdf', '80C_ELSS_EMP010_2024.pdf',
 '2024-12-18 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-24 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND FiscalYear=2024),
 'HRA', 'Rent Receipts – Dadar, Mumbai | INR 6,000/month', 72000.00, 72000.00,
 'https://docs.medcareindia.com/emp010/hra_2024.pdf', 'HRA_EMP010_2024.pdf',
 '2024-12-18 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), '2024-12-24 12:00:00', 'APPROVED'),

-- EMP026 Chennai Medical Director proofs
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),
 '80C', 'Home Loan Principal Repayment + ELSS', 150000.00, 150000.00,
 'https://docs.medcareindia.com/emp026/80c_2024.pdf', '80C_EMP026_2024.pdf',
 '2024-12-14 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), '2024-12-19 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),
 '80D', 'Family + Senior Parent Medical Insurance', 75000.00, 75000.00,
 'https://docs.medcareindia.com/emp026/80d_2024.pdf', '80D_EMP026_2024.pdf',
 '2024-12-14 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), '2024-12-19 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),
 'HRA', 'Rent Receipts – Adyar, Chennai | INR 50,000/month', 600000.00, 600000.00,
 'https://docs.medcareindia.com/emp026/hra_2024.pdf', 'HRA_EMP026_2024.pdf',
 '2024-12-14 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), '2024-12-19 12:00:00', 'APPROVED'),

((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),
 '80CCD', 'NPS Tier 1 Contribution', 50000.00, 50000.00,
 'https://docs.medcareindia.com/emp026/nps_2024.pdf', 'NPS_EMP026_2024.pdf',
 '2024-12-14 10:00:00', (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), '2024-12-19 12:00:00', 'APPROVED');


-- -------------------------------------------------------
-- EMPLOYEE TAX DEDUCTION
-- Monthly TDS records for March 2025 (PayrollMonth=3).
-- CumulativeTDSYTD = sum of TDS deducted Apr 2024–Mar 2025
-- (12th month; full year).
-- GrossIncome = annual projected gross / 12 for the month.
-- Linked to PayrollDisbursementTransaction for reconciliation.
-- -------------------------------------------------------
PRINT 'Inserting payroll.EmployeeTaxDeduction (March 2025)...';
INSERT INTO payroll.EmployeeTaxDeduction
    (EmployeeId, EmployeeTaxDeclarationId, TaxRegimeId, PayrollMonth, PayrollYear, FiscalYear,
     GrossIncome, TotalExemptions, TotalDeductions, TDSAmount, SurchargeAmount, CessAmount,
     CumulativeTDSYTD, IsAdjustment, AdjustmentReason, PayrollDisbursementTransactionId)
VALUES
-- EMP001 CMO | Annual taxable ~8.84L after exemptions | TDS ~ 2.65L annual / 12 = 22,100/month
-- (High income; 30% slab + surcharge + cess applies)
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
    @OLD_REGIME, 3, 2025, 2024,
    820000.00, 60000.00, 23333.00,  -- Monthly gross, monthly HRA exemption share, monthly deduction share
    77000.00, 0.00, 3080.00,        -- TDS, surcharge (not triggered at this bracket), cess 4%
    924000.00, 0, NULL,             -- CumulativeTDSYTD = 12 months × 77,000
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP002 Medical Director | New Regime | Taxable ~47.2L | TDS ~12.3L/yr / 12 = 10,250/month
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002') AND FiscalYear=2024),
    @NEW_REGIME, 3, 2025, 2024,
    410000.00, 0.00, 4167.00,       -- Standard deduction spread monthly
    42000.00, 0.00, 1680.00,
    504000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP003 Sr. Surgeon | Old Regime | Taxable ~27L | TDS ~5.55L/yr / 12 = 46,250/month
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),
    @OLD_REGIME, 3, 2025, 2024,
    287000.00, 40000.00, 19167.00,
    44000.00, 0.00, 1760.00,
    528000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP005 HR Manager | New Regime | Taxable ~13.26L | TDS ~2.5L/yr / 12 = 20,833/month
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005') AND FiscalYear=2024),
    @NEW_REGIME, 3, 2025, 2024,
    123000.00, 0.00, 4167.00,
    19000.00, 0.00, 760.00,
    228000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP009 Resident | Old Regime | Taxable ~5.9L | Rebate 87A — effective TDS is nominal
-- Last month adjustment: arrear of INR 1,000 TDS corrected
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009') AND FiscalYear=2024),
    @OLD_REGIME, 3, 2025, 2024,
    68333.00, 6667.00, 12500.00,
    3333.00, 0.00, 133.00,
    39996.00, 1, 'Annual TDS reconciliation — minor shortfall of INR 1,000 adjusted in final month.',
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP010 Sr. ICU Nurse | Old Regime | Taxable ~4.15L | 87A rebate triggers — zero effective TDS
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND FiscalYear=2024),
    @OLD_REGIME, 3, 2025, 2024,
    61500.00, 6000.00, 12500.00,
    5700.00, 0.00, 228.00,
    68400.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP011 Staff Nurse | New Regime | Taxable ~3.93L | Below 7L — full 87A rebate, TDS = 0
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011') AND FiscalYear=2024),
    @NEW_REGIME, 3, 2025, 2024,
    36900.00, 0.00, 4167.00,
    975.00, 0.00, 39.00,
    11700.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP016 Delhi Medical Director | Old Regime | High bracket
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016') AND FiscalYear=2024),
    @OLD_REGIME, 3, 2025, 2024,
    375833.00, 50000.00, 23333.00,
    95000.00, 0.00, 3800.00,
    1140000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP020 Emergency Physician Delhi | New Regime
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND FiscalYear=2024),
    @NEW_REGIME, 3, 2025, 2024,
    164000.00, 0.00, 4167.00,
    30000.00, 0.00, 1200.00,
    360000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP026 Chennai Medical Director | Old Regime | High bracket
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),
    @OLD_REGIME, 3, 2025, 2024,
    396333.00, 50000.00, 23333.00,
    100000.00, 0.00, 4000.00,
    1200000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND PayrollMonth=3 AND PayrollYear=2025)
),
-- EMP045 Ward Boy | No tax (income well below taxable limit)
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'),
    NULL, @NEW_REGIME, 3, 2025, 2024,
    16400.00, 0.00, 4167.00,
    0.00, 0.00, 0.00,
    0.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045') AND PayrollMonth=3 AND PayrollYear=2025)
);


-- -------------------------------------------------------
-- TAX DEDUCTION BREAKDOWN
-- Line-item tax computation detail for March 2025.
-- One record per deduction head per employee per month.
-- This feeds Form 16 Part-B generation.
-- -------------------------------------------------------
PRINT 'Inserting payroll.TaxDeductionBreakdown (March 2025 — EMP001 CMO)...';

DECLARE @ETD_001 BIGINT = (SELECT Id FROM payroll.EmployeeTaxDeduction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND PayrollMonth=3 AND PayrollYear=2025);
DECLARE @ETD_003 BIGINT = (SELECT Id FROM payroll.EmployeeTaxDeduction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND PayrollMonth=3 AND PayrollYear=2025);
DECLARE @ETD_010 BIGINT = (SELECT Id FROM payroll.EmployeeTaxDeduction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND PayrollMonth=3 AND PayrollYear=2025);

-- ---- EMP001 CMO — Old Regime breakdown (annual figures / 12 for monthly representation) ----
INSERT INTO payroll.TaxDeductionBreakdown
    (EmployeeTaxDeductionId, DeductionHead, DeductionCategory, DeclaredAmount, ApprovedAmount, ActualDeductionAmount, Remarks)
VALUES
(@ETD_001, 'Standard Deduction (Section 16)',    'DEDUCTION',  4167.00,  4167.00,  4167.00, 'INR 50,000 annual / 12 months.'),
(@ETD_001, 'HRA Exemption (Section 10(13A))',    'EXEMPTION',  60000.00, 60000.00, 60000.00,'Mumbai metro HRA. Least of: actual HRA, 50% of basic, rent – 10% basic.'),
(@ETD_001, 'Section 80C – ELSS',                'DEDUCTION',  8333.00,  8333.00,  8333.00, 'INR 1,00,000 annual ELSS / 12.'),
(@ETD_001, 'Section 80C – LIC Premium',         'DEDUCTION',  4167.00,  4167.00,  4167.00, 'INR 50,000 LIC annual / 12.'),
(@ETD_001, 'Section 80C – PPF',                 'DEDUCTION',  4167.00,  4167.00,  4167.00, 'INR 50,000 PPF / 12.'),
(@ETD_001, 'Section 80D – Self & Family',       'DEDUCTION',  2083.00,  2083.00,  2083.00, 'INR 25,000 medical insurance / 12.'),
(@ETD_001, 'Section 80D – Parents (Sr. Citizen)','DEDUCTION', 4167.00,  4167.00,  4167.00, 'INR 50,000 parent cover / 12.'),
(@ETD_001, 'Section 80CCD(1B) – NPS',           'DEDUCTION',  4167.00,  4167.00,  4167.00, 'NPS additional contribution / 12.'),
(@ETD_001, 'Income Tax (30% Slab)',              'TAX',        77000.00, 77000.00, 77000.00,'Computed on monthly taxable income. Annual tax / 12.'),
(@ETD_001, 'Health & Education Cess (4%)',       'CESS',        3080.00,  3080.00,  3080.00,'4% on income tax.'),
(@ETD_001, 'Professional Tax – Maharashtra',    'DEDUCTION',    200.00,   200.00,   200.00, 'Maharashtra PT – INR 2,500/year; INR 200/month for 11 months + INR 300 in Feb.');

-- ---- EMP003 Sr. Surgeon — Old Regime breakdown ----
INSERT INTO payroll.TaxDeductionBreakdown
    (EmployeeTaxDeductionId, DeductionHead, DeductionCategory, DeclaredAmount, ApprovedAmount, ActualDeductionAmount, Remarks)
VALUES
(@ETD_003, 'Standard Deduction (Section 16)',   'DEDUCTION',  4167.00, 4167.00, 4167.00, 'INR 50,000 / 12.'),
(@ETD_003, 'HRA Exemption (Section 10(13A))',   'EXEMPTION', 40000.00,40000.00,40000.00, 'Worli rent. HRA exemption calculation applied.'),
(@ETD_003, 'Section 80C – Children Fees + ELSS','DEDUCTION', 12500.00,12500.00,12500.00, 'INR 1.5L cap / 12.'),
(@ETD_003, 'Section 80D – Self + Senior Parents','DEDUCTION', 4167.00, 4167.00, 4167.00, 'INR 50,000 combined / 12.'),
(@ETD_003, 'Section 80CCD(1B) – NPS',          'DEDUCTION',  2500.00, 2500.00, 2500.00, 'NPS Tier 1 / 12.'),
(@ETD_003, 'Income Tax (20% & 30% Slab)',       'TAX',       44000.00,44000.00,44000.00, '20% on 5-10L band, 30% on balance.'),
(@ETD_003, 'Health & Education Cess (4%)',      'CESS',       1760.00, 1760.00, 1760.00, '4% cess on income tax.'),
(@ETD_003, 'Professional Tax – Maharashtra',   'DEDUCTION',    200.00,  200.00,  200.00, 'Maharashtra PT monthly.');

-- ---- EMP010 Sr. ICU Nurse — Old Regime breakdown ----
INSERT INTO payroll.TaxDeductionBreakdown
    (EmployeeTaxDeductionId, DeductionHead, DeductionCategory, DeclaredAmount, ApprovedAmount, ActualDeductionAmount, Remarks)
VALUES
(@ETD_010, 'Standard Deduction (Section 16)',   'DEDUCTION', 4167.00, 4167.00, 4167.00, 'INR 50,000 / 12.'),
(@ETD_010, 'HRA Exemption (Section 10(13A))',   'EXEMPTION', 6000.00, 6000.00, 6000.00, 'Dadar rent INR 6,000/month. HRA exemption minimal.'),
(@ETD_010, 'Section 80C – PPF + LIC + ELSS',   'DEDUCTION',12500.00,12500.00,12500.00, 'INR 1.5L / 12.'),
(@ETD_010, 'Income Tax (5% Slab)',              'TAX',        5700.00, 5700.00, 5700.00, 'Taxable income ~4.15L. 5% on 2.5-5L band.'),
(@ETD_010, 'Health & Education Cess (4%)',      'CESS',        228.00,  228.00,  228.00, '4% on tax.'),
(@ETD_010, 'Professional Tax – Maharashtra',   'DEDUCTION',   200.00,  200.00,  200.00, 'Maharashtra PT.');


-- =============================================================================================================
-- VERIFICATION SUMMARY
-- =============================================================================================================
PRINT '';
PRINT '=============================================================================================================';
PRINT 'PAYROLL SEED DATA INSERTION COMPLETE — MedCare India Pvt. Ltd.';
PRINT '=============================================================================================================';
PRINT '';

SELECT 'payroll.SalaryGrade'                  AS TableName, COUNT(*) AS RecordCount FROM payroll.SalaryGrade                  UNION ALL
SELECT 'payroll.SalaryStructure',                           COUNT(*)               FROM payroll.SalaryStructure               UNION ALL
SELECT 'payroll.SalaryStructureComponent',                  COUNT(*)               FROM payroll.SalaryStructureComponent      UNION ALL
SELECT 'payroll.EmployeeSalary',                            COUNT(*)               FROM payroll.EmployeeSalary                UNION ALL
SELECT 'payroll.EmployeeSalaryComponent',                   COUNT(*)               FROM payroll.EmployeeSalaryComponent       UNION ALL
SELECT 'payroll.SalaryRevision',                            COUNT(*)               FROM payroll.SalaryRevision                UNION ALL
SELECT 'payroll.BankMaster',                                COUNT(*)               FROM payroll.BankMaster                    UNION ALL
SELECT 'payroll.EmployeeBankAccount',                       COUNT(*)               FROM payroll.EmployeeBankAccount           UNION ALL
SELECT 'payroll.PayrollDisbursement',                       COUNT(*)               FROM payroll.PayrollDisbursement           UNION ALL
SELECT 'payroll.PayrollDisbursementTransaction',            COUNT(*)               FROM payroll.PayrollDisbursementTransaction UNION ALL
SELECT 'payroll.TaxRegime',                                 COUNT(*)               FROM payroll.TaxRegime                     UNION ALL
SELECT 'payroll.TaxSlab',                                   COUNT(*)               FROM payroll.TaxSlab                       UNION ALL
SELECT 'payroll.EmployeeTaxDeclaration',                    COUNT(*)               FROM payroll.EmployeeTaxDeclaration        UNION ALL
SELECT 'payroll.TaxDeclarationProof',                       COUNT(*)               FROM payroll.TaxDeclarationProof           UNION ALL
SELECT 'payroll.EmployeeTaxDeduction',                      COUNT(*)               FROM payroll.EmployeeTaxDeduction          UNION ALL
SELECT 'payroll.TaxDeductionBreakdown',                     COUNT(*)               FROM payroll.TaxDeductionBreakdown;

COMMIT TRANSACTION;
PRINT 'Payroll seed transaction committed successfully.';

-- =============================================================================================================
-- END OF PAYROLL SEED DATA SCRIPT — MedCare India Pvt. Ltd.
-- =============================================================================================================