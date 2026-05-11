-- =============================================================================================================
-- PART B — SEED DATA
-- Organization: MedCare India Pvt. Ltd.
-- Fiscal Year  : April–March (Indian standard)
-- Currency     : INR
-- =============================================================================================================

BEGIN TRANSACTION;
PRINT 'Starting payroll seed data — MedCare India Pvt. Ltd.';


-- =============================================================================================================
--     PART B — SEED DATA:
--     S0.  dbo.StatusLookup seed
--     S1.  payroll.TaxProofCategory seed
--     S2.  payroll.SalaryGrade seed
--     S3.  payroll.SalaryStructure seed
--     S4.  payroll.PayrollComponent seed
--     S5.  payroll.SalaryStructureComponent seed
--     S6.  payroll.TaxRegime seed
--     S7.  payroll.TaxSlab seed
--     S8.  payroll.EmployeeSalary seed
--     S9.  payroll.EmployeeSalaryComponent seed (March 2025)
--     S10. payroll.SalaryRevision seed
--     S11. payroll.BankMaster seed
--     S12. payroll.EmployeeBankAccount seed
--     S13. payroll.PayrollDisbursement seed (March 2025)
--     S14. payroll.PayrollDisbursementTransaction seed (March 2025)
--     S15. payroll.PayrollAttendanceSummary seed (March 2025)
--     S16. payroll.EmployeeTaxDeclaration seed (FY 2024-25)
--     S17. payroll.TaxDeclarationItem seed
--     S18. payroll.TaxDeclarationProof seed
--     S19. payroll.EmployeeTaxDeduction seed (March 2025)
--     S20. payroll.TaxDeductionBreakdown seed
-- =============================================================================================================

PRINT 'S0. Seeding dbo.StatusLookup...';

-- Declaration lifecycle
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('DRAFT',             'DECLARATION_STATUS',   'Draft',             1, 0),
('SUBMITTED',         'DECLARATION_STATUS',   'Submitted',         2, 0),
('VERIFIED',          'DECLARATION_STATUS',   'Verified',          3, 1),
('REJECTED',          'DECLARATION_STATUS',   'Rejected',          4, 1);

-- Proof review lifecycle
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',           'PROOF_REVIEW_STATUS',  'Pending',           1, 0),
('APPROVED',          'PROOF_REVIEW_STATUS',  'Approved',          2, 1),
('REJECTED',          'PROOF_REVIEW_STATUS',  'Rejected',          3, 1);

-- Payroll disbursement batch lifecycle
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('DRAFT',             'DISBURSEMENT_STATUS',  'Draft',             1, 0),
('APPROVED',          'DISBURSEMENT_STATUS',  'Approved',          2, 0),
('PROCESSING',        'DISBURSEMENT_STATUS',  'Processing',        3, 0),
('COMPLETED',         'DISBURSEMENT_STATUS',  'Completed',         4, 1),
('FAILED',            'DISBURSEMENT_STATUS',  'Failed',            5, 1),
('CANCELLED',         'DISBURSEMENT_STATUS',  'Cancelled',         6, 1);

-- Individual bank credit transaction lifecycle
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('PENDING',           'TRANSACTION_STATUS',   'Pending',           1, 0),
('INITIATED',         'TRANSACTION_STATUS',   'Initiated',         2, 0),
('SUCCESS',           'TRANSACTION_STATUS',   'Success',           3, 1),
('FAILED',            'TRANSACTION_STATUS',   'Failed',            4, 1),
('REVERSED',          'TRANSACTION_STATUS',   'Reversed',          5, 1);

-- Payment Mode
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('NEFT',           'PAYMENT_MODE_TYPE',   'neft',           1, 0),
('RTGS',           'PAYMENT_MODE_TYPE',   'rtgs',           2, 0),
('IMPS',           'PAYMENT_MODE_TYPE',   'imps',           3, 0),
('SWIFT',          'PAYMENT_MODE_TYPE',   'swift',          4, 0);

-- Salary revision types
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('ANNUAL_INCREMENT',  'SALARY_REVISION_TYPE', 'Annual Increment',  1, 0),
('PROMOTION',         'SALARY_REVISION_TYPE', 'Promotion',         2, 0),
('CORRECTION',        'SALARY_REVISION_TYPE', 'Correction',        3, 0),
('JOINING',           'SALARY_REVISION_TYPE', 'Joining',           4, 0),
('MARKET_CORRECTION', 'SALARY_REVISION_TYPE', 'Market Correction', 5, 0),
('OTHER',             'SALARY_REVISION_TYPE', 'Other',             6, 0);

-- Bank account types
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('SAVINGS',           'BANK_ACCOUNT_TYPE',    'Savings Account',   1, 0),
('CURRENT',           'BANK_ACCOUNT_TYPE',    'Current Account',   2, 0),
('SALARY',            'BANK_ACCOUNT_TYPE',    'Salary Account',    3, 0);

-- Salary component calculation types
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('FIXED',             'CALC_TYPE',            'Fixed Amount',      1, 0),
('PERCENTAGE',        'CALC_TYPE',            'Percentage of Base',2, 0),
('FORMULA',           'CALC_TYPE',            'Formula Expression',3, 0);

-- Tax deduction categories
INSERT INTO dbo.StatusLookup (StatusCode, StatusGroup, Label, DisplayOrder, IsTerminal) VALUES
('EXEMPTION',         'DEDUCTION_CATEGORY',   'Exemption',         1, 0),
('DEDUCTION',         'DEDUCTION_CATEGORY',   'Deduction',         2, 0),
('TAX',               'DEDUCTION_CATEGORY',   'Tax',               3, 0),
('CESS',              'DEDUCTION_CATEGORY',   'Cess',              4, 0),
('REBATE',            'DEDUCTION_CATEGORY',   'Rebate',            5, 0);
GO


-- =============================================================================================================
-- S1. payroll.TaxProofCategory seed
-- =============================================================================================================

PRINT 'S1. Seeding payroll.TaxProofCategory...';

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
-- S2. payroll.SalaryGrade seed
-- =============================================================================================================

PRINT 'S2. Seeding payroll.SalaryGrade...';

INSERT INTO payroll.SalaryGrade (GradeCode, GradeName, MinCTC, MaxCTC, CurrencyCode, Description) VALUES
('G-L10', 'Band L10 – C-Suite / Chief Officers',        6000000.00,  15000000.00, 'INR', 'CMO, CEO, CFO level. Highest compensation band.'),
('G-L9',  'Band L9  – Medical / Hospital Directors',    4000000.00,   8000000.00, 'INR', 'Medical Directors, VP-level hospital leadership.'),
('G-L8',  'Band L8  – Senior Specialists / HODs',       2500000.00,   5000000.00, 'INR', 'Senior Surgeons, Chief Nursing Officer, Administrators.'),
('G-L7',  'Band L7  – Consultants / Department Heads',  1500000.00,   3000000.00, 'INR', 'Consultants, Radiologists, Pathologists, Managers.'),
('G-L5',  'Band L5  – Senior Staff',                     800000.00,   1500000.00, 'INR', 'Senior Nurses, Senior Pharmacists, HR Business Partners.'),
('G-L4',  'Band L4  – Experienced Staff',                400000.00,    800000.00, 'INR', 'Staff Nurses, Pharmacists, Lab Techs, Executives.'),
('G-L3',  'Band L3  – Junior Staff',                     250000.00,    400000.00, 'INR', 'Junior Nurses, Front Desk Executives, Housekeeping Supervisors.'),
('G-L2',  'Band L2  – Support Staff',                    180000.00,    250000.00, 'INR', 'Ward Boys, Patient Attendants, Ambulance Drivers.');


-- =============================================================================================================
-- S3. payroll.SalaryStructure seed
-- =============================================================================================================

PRINT 'S3. Seeding payroll.SalaryStructure...';

INSERT INTO payroll.SalaryStructure (StructureCode, StructureName, LegalEntityId, CurrencyCode, VersionNo, IsDefault, Description) VALUES
(
    'SS-MEDCARE-IN-STD',
    'MedCare India – Standard Monthly Structure',
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode = 'MEDCARE-IN'),
    'INR', 1, 1,
    'Standard structure for Mumbai & Pune. Basic 40%, HRA 20% of Basic, TA Fixed, Medical Allowance Fixed, Special Allowance (balancing), PF 12% emp+er, ESI where applicable, PT.'
),
(
    'SS-MEDCARE-NORTH-STD',
    'MedCare North India – Standard Monthly Structure',
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode = 'MEDCARE-NORTH'),
    'INR', 1, 1,
    'Standard structure for Delhi & Kolkata. Same component logic as parent entity; Delhi/WB PT slabs applied.'
),
(
    'SS-MEDCARE-SOUTH-STD',
    'MedCare South India – Standard Monthly Structure',
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode = 'MEDCARE-SOUTH'),
    'INR', 1, 1,
    'Standard structure for Bengaluru, Chennai, Hyderabad. Karnataka/TN/Telangana PT slabs. ESI applicable where gross <= INR 21,000/month.'
);


-- =============================================================================================================
-- S4. payroll.PayrollComponent seed
-- =============================================================================================================

PRINT 'S4. Seeding payroll.PayrollComponent...';

INSERT INTO payroll.PayrollComponent (ComponentCode, ComponentName, IsEarning, IsDeduction) VALUES
('BASIC',       'Basic Salary',                 1, 0),
('HRA',         'House Rent Allowance',         1, 0),
('TA',          'Transport Allowance',          1, 0),
('MEDICAL_ALL', 'Medical Allowance',            1, 0),
('SPECIAL_ALL', 'Special Allowance',            1, 0),
('NIGHTALL',    'Night Shift Allowance',        1, 0),
('OTPAY',       'Overtime Pay',                 1, 0),
('BONUS',       'Performance Bonus',            1, 0),
('PF_ER',       'Provident Fund (Employer)',    1, 0),
('ESI_ER',      'ESI (Employer Contribution)',  1, 0),
('GRATUITY',    'Gratuity Provision',           1, 0),
('PF_EMP',      'Provident Fund (Employee)',    0, 1),
('ESI_EMP',     'ESI (Employee Contribution)',  0, 1),
('PT',          'Professional Tax',             0, 1),
('TDS',         'Income Tax (TDS)',             0, 1),
('ADVANCE_DED', 'Salary Advance Deduction',     0, 1);


-- =============================================================================================================
-- S5. payroll.SalaryStructureComponent seed
-- =============================================================================================================
-- Components are identical across all three structures.
-- CURSOR inserts the full set for each structure.
--
-- Component logic:
--   BASIC       : FIXED — set per employee
--   HRA         : PERCENTAGE 20% of BASIC
--   TA          : FIXED 1,600/month
--   MEDICAL_ALL : FIXED 1,250/month
--   NIGHTALL    : FIXED (zero for non-shift; override for clinical night staff)
--   SPECIAL_ALL : FORMULA (MonthlyCTC - BASIC - HRA - TA - MEDICAL_ALL - NIGHTALL - PF_ER - ESI_ER - GRATUITY)
--   PF_ER       : PERCENTAGE 12% of BASIC (employer contribution, CTC component)
--   ESI_ER      : FORMULA 3.25% of Gross if Gross <= 21,000
--   GRATUITY    : PERCENTAGE 4.81% of BASIC (actuarial provision)
--   OTPAY       : FIXED (computed from attendance OT minutes)
--   PF_EMP      : PERCENTAGE 12% of BASIC (employee deduction, capped at 1,800)
--   ESI_EMP     : FORMULA 0.75% of Gross if Gross <= 21,000
--   PT          : FIXED (state slab; Maharashtra 200/month; override per state)
--   TDS         : FIXED (monthly from tax engine)
-- =============================================================================================================

PRINT 'S5. Seeding payroll.SalaryStructureComponent...';

DECLARE @StructIds TABLE (StructureId BIGINT);
INSERT INTO @StructIds
SELECT Id FROM payroll.SalaryStructure
WHERE StructureCode IN ('SS-MEDCARE-IN-STD','SS-MEDCARE-NORTH-STD','SS-MEDCARE-SOUTH-STD');

DECLARE @SID BIGINT;
DECLARE struct_cursor CURSOR FOR SELECT StructureId FROM @StructIds;
OPEN struct_cursor;
FETCH NEXT FROM struct_cursor INTO @SID;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- 1. BASIC — FIXED anchor
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FIXED', NULL, NULL, NULL, 0, 1, 1
    FROM payroll.PayrollComponent WHERE ComponentCode = 'BASIC';

    -- 2. HRA — 20% of BASIC
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'PERCENTAGE', 20.0000,
        (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@SID
            AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),
        NULL, 0, 1, 2
    FROM payroll.PayrollComponent WHERE ComponentCode = 'HRA';

    -- 3. TA — FIXED 1,600
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FIXED', NULL, NULL, NULL, 0, 1, 3
    FROM payroll.PayrollComponent WHERE ComponentCode = 'TA';

    -- 4. MEDICAL_ALL — FIXED 1,250
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FIXED', NULL, NULL, NULL, 0, 1, 4
    FROM payroll.PayrollComponent WHERE ComponentCode = 'MEDICAL_ALL';

    -- 5. NIGHTALL — FIXED (override per employee)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FIXED', NULL, NULL, NULL, 0, 1, 5
    FROM payroll.PayrollComponent WHERE ComponentCode = 'NIGHTALL';

    -- 6. SPECIAL_ALL — FORMULA balancing
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FORMULA', NULL, NULL,
        'MonthlyCTC - BASIC - HRA - TA - MEDICAL_ALL - NIGHTALL - PF_ER - ESI_ER - GRATUITY',
        0, 1, 6
    FROM payroll.PayrollComponent WHERE ComponentCode = 'SPECIAL_ALL';

    -- 7. PF_ER — 12% of BASIC (employer)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'PERCENTAGE', 12.0000,
        (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@SID
            AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),
        NULL, 1, 1, 7
    FROM payroll.PayrollComponent WHERE ComponentCode = 'PF_ER';

    -- 8. ESI_ER — 3.25% of Gross if applicable
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FORMULA', 3.2500, NULL,
        'IF(MonthlyGross <= 21000, MonthlyGross * 0.0325, 0)',
        1, 1, 8
    FROM payroll.PayrollComponent WHERE ComponentCode = 'ESI_ER';

    -- 9. GRATUITY — 4.81% of BASIC
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'PERCENTAGE', 4.8100,
        (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@SID
            AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),
        NULL, 1, 1, 9
    FROM payroll.PayrollComponent WHERE ComponentCode = 'GRATUITY';

    -- 10. OTPAY — FIXED (from attendance OT minutes)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FIXED', NULL, NULL, NULL, 0, 1, 10
    FROM payroll.PayrollComponent WHERE ComponentCode = 'OTPAY';

    -- 11. PF_EMP — 12% of BASIC (employee deduction)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'PERCENTAGE', 12.0000,
        (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@SID
            AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),
        NULL, 1, 1, 11
    FROM payroll.PayrollComponent WHERE ComponentCode = 'PF_EMP';

    -- 12. ESI_EMP — 0.75% of Gross if applicable
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FORMULA', 0.7500, NULL,
        'IF(MonthlyGross <= 21000, MonthlyGross * 0.0075, 0)',
        1, 1, 12
    FROM payroll.PayrollComponent WHERE ComponentCode = 'ESI_EMP';

    -- 13. PT — FIXED (state slab; Maharashtra 200/month)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FIXED', NULL, NULL, NULL, 1, 1, 13
    FROM payroll.PayrollComponent WHERE ComponentCode = 'PT';

    -- 14. TDS — FIXED (monthly from tax engine; override inserted per month)
    INSERT INTO payroll.SalaryStructureComponent
        (SalaryStructureId, PayrollComponentId, CalculationType, PercentageValue, BaseComponentId, FormulaExpression, IsStatutory, IsActive, SortOrder)
    SELECT @SID, Id, 'FIXED', NULL, NULL, NULL, 1, 1, 14
    FROM payroll.PayrollComponent WHERE ComponentCode = 'TDS';

    FETCH NEXT FROM struct_cursor INTO @SID;
END;

CLOSE struct_cursor;
DEALLOCATE struct_cursor;


-- =============================================================================================================
-- S6. payroll.TaxRegime seed
-- =============================================================================================================

PRINT 'S6. Seeding payroll.TaxRegime...';

INSERT INTO payroll.TaxRegime (RegimeCode, RegimeName, CountryCode, FiscalYearStart, Description) VALUES
('IND-OLD-2024',
 'India Income Tax – Old Regime (FY 2024-25)', 'IN', '04-01',
 'Old Tax Regime FY2024-25. Allows all deductions: 80C (1.5L), 80D, HRA, LTA, Std Deduction (50K), PT, NPS. '
 + 'Slabs: 0-2.5L=Nil, 2.5-5L=5%, 5-10L=20%, >10L=30%. Rebate u/s 87A if taxable income <= 5L.'),
('IND-NEW-2024',
 'India Income Tax – New Regime (FY 2024-25)', 'IN', '04-01',
 'New Tax Regime FY2024-25 (default from FY24 per Finance Act 2023). No deductions except Std Deduction (50K). '
 + 'Slabs: 0-3L=Nil, 3-6L=5%, 6-9L=10%, 9-12L=15%, 12-15L=20%, >15L=30%. Rebate u/s 87A if taxable income <= 7L.');


-- =============================================================================================================
-- S7. payroll.TaxSlab seed — FY 2024-25
-- =============================================================================================================

PRINT 'S7. Seeding payroll.TaxSlab (FY 2024-25)...';

DECLARE @OLD_REGIME BIGINT = (SELECT Id FROM payroll.TaxRegime WHERE RegimeCode='IND-OLD-2024');
DECLARE @NEW_REGIME BIGINT = (SELECT Id FROM payroll.TaxRegime WHERE RegimeCode='IND-NEW-2024');

-- Old Regime slabs
INSERT INTO payroll.TaxSlab (TaxRegimeId, FiscalYear, SlabOrder, MinIncome, MaxIncome, TaxRate, SurchargeRate, CessRate) VALUES
(@OLD_REGIME, 2024, 1,        0.00,    250000.00,  0.00,  0.00, 4.00),
(@OLD_REGIME, 2024, 2,   250000.00,    500000.00,  5.00,  0.00, 4.00),
(@OLD_REGIME, 2024, 3,   500000.00,   1000000.00, 20.00,  0.00, 4.00),
(@OLD_REGIME, 2024, 4,  1000000.00,   5000000.00, 30.00,  0.00, 4.00),
(@OLD_REGIME, 2024, 5,  5000000.00,  10000000.00, 30.00, 10.00, 4.00),
(@OLD_REGIME, 2024, 6, 10000000.00,         NULL, 30.00, 15.00, 4.00);

-- New Regime slabs
INSERT INTO payroll.TaxSlab (TaxRegimeId, FiscalYear, SlabOrder, MinIncome, MaxIncome, TaxRate, SurchargeRate, CessRate) VALUES
(@NEW_REGIME, 2024, 1,        0.00,    300000.00,  0.00,  0.00, 4.00),
(@NEW_REGIME, 2024, 2,   300000.00,    600000.00,  5.00,  0.00, 4.00),
(@NEW_REGIME, 2024, 3,   600000.00,    900000.00, 10.00,  0.00, 4.00),
(@NEW_REGIME, 2024, 4,   900000.00,   1200000.00, 15.00,  0.00, 4.00),
(@NEW_REGIME, 2024, 5,  1200000.00,   1500000.00, 20.00,  0.00, 4.00),
(@NEW_REGIME, 2024, 6,  1500000.00,   5000000.00, 30.00,  0.00, 4.00),
(@NEW_REGIME, 2024, 7,  5000000.00,  10000000.00, 30.00, 10.00, 4.00),
(@NEW_REGIME, 2024, 8, 10000000.00,         NULL, 30.00, 15.00, 4.00);


-- =============================================================================================================
-- S8. payroll.EmployeeSalary seed — FY 2024-25 current records + prior-year historical records
-- =============================================================================================================

PRINT 'S8. Seeding payroll.EmployeeSalary...';

DECLARE @SS_IN     BIGINT = (SELECT Id FROM payroll.SalaryStructure WHERE StructureCode='SS-MEDCARE-IN-STD');
DECLARE @SS_NORTH  BIGINT = (SELECT Id FROM payroll.SalaryStructure WHERE StructureCode='SS-MEDCARE-NORTH-STD');
DECLARE @SS_SOUTH  BIGINT = (SELECT Id FROM payroll.SalaryStructure WHERE StructureCode='SS-MEDCARE-SOUTH-STD');

DECLARE @GL10 BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode='G-L10');
DECLARE @GL9  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode='G-L9');
DECLARE @GL8  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode='G-L8');
DECLARE @GL7  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode='G-L7');
DECLARE @GL5  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode='G-L5');
DECLARE @GL4  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode='G-L4');
DECLARE @GL3  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode='G-L3');
DECLARE @GL2  BIGINT = (SELECT Id FROM payroll.SalaryGrade WHERE GradeCode='G-L2');

-- ---- Current records (FY 2024-25, IsActive=1) ----
INSERT INTO payroll.EmployeeSalary
    (EmployeeId, SalaryStructureId, SalaryGradeId, AnnualCTC, MonthlyCTC, MonthlyGross, MonthlyNet, CurrencyCode, EffectiveFrom, EffectiveTo, IsActive, Remarks)
VALUES
-- MUMBAI HQ
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), @SS_IN, @GL10, 12000000.00,1000000.00, 820000.00, 695000.00,'INR','2024-04-01',NULL,1,'Current salary post FY2024 revision. Includes performance supplement.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'), @SS_IN, @GL9,   6000000.00, 500000.00, 410000.00, 348000.00,'INR','2024-04-01',NULL,1,'Mumbai HQ Medical Director. Current year revised CTC.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), @SS_IN, @GL8,   4200000.00, 350000.00, 287000.00, 243000.00,'INR','2024-04-01',NULL,1,'Includes surgical skills allowance. Eligible for performance bonus.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'), @SS_IN, @GL8,   3000000.00, 250000.00, 205000.00, 174000.00,'INR','2024-04-01',NULL,1,'CNO. Includes leadership allowance.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), @SS_IN, @GL7,   1800000.00, 150000.00, 123000.00, 104000.00,'INR','2024-04-01',NULL,1,'HR Manager, pan-India HRMS oversight.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), @SS_IN, @GL7,   1800000.00, 150000.00, 123000.00, 104000.00,'INR','2024-04-01',NULL,1,'Finance Manager, hospital billing and payroll.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'), @SS_IN, @GL7,   1800000.00, 150000.00, 123000.00, 104000.00,'INR','2024-04-01',NULL,1,'IT Manager. Includes technology allowance.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'), @SS_IN, @GL7,   2200000.00, 183333.00, 150333.00, 127500.00,'INR','2024-04-01',NULL,1,'Consultant Internal Medicine.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'), @SS_IN, @GL5,   1000000.00,  83333.00,  68333.00,  58000.00,'INR','2024-04-01',NULL,1,'Resident, Cardiology rotation. Stipend structure.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), @SS_IN, @GL5,    900000.00,  75000.00,  61500.00,  52200.00,'INR','2024-04-01',NULL,1,'Senior Nurse, ICU. Includes night shift allowance INR 2,000/month.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'), @SS_IN, @GL4,    540000.00,  45000.00,  36900.00,  31365.00,'INR','2024-04-01',NULL,1,'Staff Nurse, General Ward.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'), @SS_IN, @GL7,   1600000.00, 133333.00, 109333.00,  92800.00,'INR','2024-04-01',NULL,1,'Chief Pharmacist, central pharmacy.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013'), @SS_IN, @GL4,    540000.00,  45000.00,  36900.00,  31365.00,'INR','2024-04-01',NULL,1,'Pharmacist, outpatient pharmacy.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014'), @SS_IN, @GL4,    420000.00,  35000.00,  28700.00,  24400.00,'INR','2024-04-01',NULL,1,'Administrative Executive.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015'), @SS_IN, @GL3,    300000.00,  25000.00,  20500.00,  17425.00,'INR','2024-04-01',NULL,1,'Front Desk Executive.'),
-- DELHI
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'), @SS_NORTH, @GL9, 5500000.00, 458333.00, 375833.00, 318000.00,'INR','2024-04-01',NULL,1,'Delhi Medical Director. Delhi PT slab applied.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017'), @SS_NORTH, @GL8, 4000000.00, 333333.00, 273333.00, 232000.00,'INR','2024-04-01',NULL,1,'Senior Orthopedic Surgeon.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018'), @SS_NORTH, @GL5,  900000.00,  75000.00,  61500.00,  52200.00,'INR','2024-04-01',NULL,1,'Senior Nurse, Delhi.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), @SS_NORTH, @GL5,  900000.00,  75000.00,  61500.00,  52200.00,'INR','2024-04-01',NULL,1,'HRBP, North India.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), @SS_NORTH, @GL7, 2400000.00, 200000.00, 164000.00, 139000.00,'INR','2024-04-01',NULL,1,'Emergency Physician. 12-hr shift. Includes night allowance.'),
-- BENGALURU
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021'), @SS_SOUTH, @GL9, 5500000.00, 458333.00, 375833.00, 318000.00,'INR','2024-04-01',NULL,1,'Bengaluru Medical Director. Karnataka PT INR 200/month.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022'), @SS_SOUTH, @GL7, 2200000.00, 183333.00, 150333.00, 127500.00,'INR','2024-04-01',NULL,1,'Neurologist Consultant.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023'), @SS_SOUTH, @GL7, 2000000.00, 166667.00, 136667.00, 115800.00,'INR','2024-04-01',NULL,1,'Radiologist, CT & MRI specialist.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024'), @SS_SOUTH, @GL4,  480000.00,  40000.00,  32800.00,  27880.00,'INR','2024-04-01',NULL,1,'Lab Technician, Microbiology.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025'), @SS_SOUTH, @GL4,  540000.00,  45000.00,  36900.00,  31365.00,'INR','2024-04-01',NULL,1,'Sysadmin, EHR and network.'),
-- CHENNAI
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'), @SS_SOUTH, @GL9, 5800000.00, 483333.00, 396333.00, 335000.00,'INR','2024-04-01',NULL,1,'Chennai Medical Director and Oncology Lead. Tamil Nadu PT.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027'), @SS_SOUTH, @GL7, 2400000.00, 200000.00, 164000.00, 139000.00,'INR','2024-04-01',NULL,1,'Oncology Consultant. Includes oncology clinical allowance.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'), @SS_SOUTH, @GL4,  480000.00,  40000.00,  32800.00,  27880.00,'INR','2024-04-01',NULL,1,'Nurse, Oncology Ward. On maternity leave from May 2025.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029'), @SS_SOUTH, @GL5,  840000.00,  70000.00,  57400.00,  48800.00,'INR','2024-04-01',NULL,1,'Senior Pharmacist, chemo drug handling.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), @SS_SOUTH, @GL4,  420000.00,  35000.00,  28700.00,  24400.00,'INR','2024-04-01',NULL,1,'HR Executive, Chennai.'),
-- HYDERABAD
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031'), @SS_SOUTH, @GL9, 5200000.00, 433333.00, 355333.00, 301000.00,'INR','2024-04-01',NULL,1,'Hyderabad Medical Director. Telangana PT INR 200/month.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032'), @SS_SOUTH, @GL7, 2000000.00, 166667.00, 136667.00, 115800.00,'INR','2024-04-01',NULL,1,'Pediatrician Consultant.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033'), @SS_SOUTH, @GL4,  480000.00,  40000.00,  32800.00,  27880.00,'INR','2024-04-01',NULL,1,'Radiology Tech, X-Ray and Ultrasound.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034'), @SS_SOUTH, @GL3,  360000.00,  30000.00,  24600.00,  20910.00,'INR','2024-04-01',NULL,1,'Junior Nurse, General Ward.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035'), @SS_SOUTH, @GL4,  480000.00,  40000.00,  32800.00,  27880.00,'INR','2024-04-01',NULL,1,'Accountant, billing and insurance claims.'),
-- KOLKATA
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036'), @SS_NORTH, @GL9, 5000000.00, 416667.00, 341667.00, 289000.00,'INR','2024-04-01',NULL,1,'Kolkata Medical Director.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037'), @SS_NORTH, @GL7, 2000000.00, 166667.00, 136667.00, 115800.00,'INR','2024-04-01',NULL,1,'Pathologist, MBBS MD. West Bengal PT.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038'), @SS_NORTH, @GL4,  480000.00,  40000.00,  32800.00,  27880.00,'INR','2024-04-01',NULL,1,'Staff Nurse, Pathology support.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039'), @SS_NORTH, @GL7, 1600000.00, 133333.00, 109333.00,  92800.00,'INR','2024-04-01',NULL,1,'Operations Manager, Kolkata.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040'), @SS_NORTH, @GL4,  420000.00,  35000.00,  28700.00,  24400.00,'INR','2024-04-01',NULL,1,'Paramedic, Emergency. Includes on-call allowance.'),
-- PUNE
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041'), @SS_IN, @GL8,   2800000.00, 233333.00, 191333.00, 162200.00,'INR','2024-04-01',NULL,1,'Hospital Administrator, Pune.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042'), @SS_IN, @GL7,   2200000.00, 183333.00, 150333.00, 127500.00,'INR','2024-04-01',NULL,1,'Cardiologist, Pune Hospital.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'), @SS_IN, @GL4,    720000.00,  60000.00,  49200.00,  41820.00,'INR','2024-04-01',NULL,1,'Junior Resident, rotating departments. Stipend-based structure.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044'), @SS_IN, @GL4,    480000.00,  40000.00,  32800.00,  27880.00,'INR','2024-04-01',NULL,1,'Staff Nurse, Cardiology Ward.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'), @SS_IN, @GL2,    240000.00,  20000.00,  16400.00,  13940.00,'INR','2024-04-01',NULL,1,'Ward Boy, Cardiology and General wards. ESI applicable (gross < 21,000).');

-- ---- Historical (FY 2023-24, IsActive=0) — for revision linkage ----
INSERT INTO payroll.EmployeeSalary
    (EmployeeId, SalaryStructureId, SalaryGradeId, AnnualCTC, MonthlyCTC, MonthlyGross, MonthlyNet, CurrencyCode, EffectiveFrom, EffectiveTo, IsActive, Remarks)
VALUES
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), @SS_IN,    @GL10, 10800000.00, 900000.00, 738000.00, 625500.00,'INR','2023-04-01','2024-03-31',0,'FY2023-24 salary. Superseded by April 2024 revision.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), @SS_IN,    @GL8,   3800000.00, 316667.00, 259667.00, 220500.00,'INR','2023-04-01','2024-03-31',0,'FY2023-24 salary.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), @SS_IN,    @GL5,    780000.00,  65000.00,  53300.00,  45300.00,'INR','2023-04-01','2024-03-31',0,'FY2023-24 salary.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), @SS_NORTH, @GL7,   2200000.00, 183333.00, 150333.00, 127500.00,'INR','2023-04-01','2024-03-31',0,'FY2023-24 salary.');


-- =============================================================================================================
-- S9. payroll.EmployeeSalaryComponent seed — March 2025
-- =============================================================================================================

PRINT 'S9. Seeding payroll.EmployeeSalaryComponent (March 2025)...';

-- Helper macro: returns SalaryStructureComponent.Id for a given salary record + component code
-- Usage: (SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@SalStruct AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='XXXX'))

-- ---- EMP001 CMO | Basic 400,000 ----
DECLARE @ES_001 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND IsActive=1);
DECLARE @ST_001 BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id=@ES_001);
INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount) VALUES
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),       3,2025,400000.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='HRA')),         3,2025, 80000.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TA')),          3,2025,  1600.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3,2025,  1250.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3,2025,     0.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3,2025,287350.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_ER')),       3,2025, 48000.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_ER')),      3,2025,     0.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='GRATUITY')),    3,2025, 19240.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='OTPAY')),       3,2025,   560.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_EMP')),      3,2025, 48000.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3,2025,     0.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PT')),          3,2025,   200.00),
(@ES_001,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_001 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TDS')),         3,2025, 77000.00);

-- ---- EMP009 Resident | Basic 33,333 | 3 days SL (leave deducted from balance, salary not impacted) ----
DECLARE @ES_009 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009') AND IsActive=1);
DECLARE @ST_009 BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id=@ES_009);
INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount) VALUES
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),       3,2025, 33333.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='HRA')),         3,2025,  6667.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TA')),          3,2025,  1600.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3,2025,  1250.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3,2025,     0.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3,2025, 21483.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_ER')),       3,2025,  4000.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_ER')),      3,2025,     0.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='GRATUITY')),    3,2025,  1603.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='OTPAY')),       3,2025,   960.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_EMP')),      3,2025,  4000.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3,2025,     0.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PT')),          3,2025,   200.00),
(@ES_009,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_009 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TDS')),         3,2025,  3333.00);

-- ---- EMP010 Sr. ICU Nurse | Basic 30,000 | Night allowance 2,000 | ESI not applicable (gross > 21,000) ----
DECLARE @ES_010 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND IsActive=1);
DECLARE @ST_010 BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id=@ES_010);
INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount, OverrideAmount, OverrideReason) VALUES
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),       3,2025, 30000.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='HRA')),         3,2025,  6000.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TA')),          3,2025,  1600.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3,2025,  1250.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3,2025,  2000.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3,2025, 13710.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_ER')),       3,2025,  3600.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_ER')),      3,2025,     0.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='GRATUITY')),    3,2025,  1443.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='OTPAY')),       3,2025,  1440.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_EMP')),      3,2025,  3600.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3,2025,     0.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PT')),          3,2025,   200.00,NULL,NULL),
(@ES_010,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_010 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TDS')),         3,2025,  5700.00,NULL,NULL);

-- ---- EMP011 Staff Nurse | Basic 18,000 | ESI not applicable (gross 36,900 > 21,000) ----
DECLARE @ES_011 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011') AND IsActive=1);
DECLARE @ST_011 BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id=@ES_011);
INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount) VALUES
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),       3,2025, 18000.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='HRA')),         3,2025,  3600.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TA')),          3,2025,  1600.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3,2025,  1250.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3,2025,     0.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3,2025,  9527.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_ER')),       3,2025,  2160.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_ER')),      3,2025,     0.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='GRATUITY')),    3,2025,   866.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='OTPAY')),       3,2025,     0.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_EMP')),      3,2025,  2160.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3,2025,     0.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PT')),          3,2025,   200.00),
(@ES_011,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_011 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TDS')),         3,2025,   975.00);

-- ---- EMP045 Ward Boy | Basic 8,000 | ESI applicable (gross 16,400 < 21,000) ----
DECLARE @ES_045 BIGINT = (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045') AND IsActive=1);
DECLARE @ST_045 BIGINT = (SELECT SalaryStructureId FROM payroll.EmployeeSalary WHERE Id=@ES_045);
INSERT INTO payroll.EmployeeSalaryComponent (EmployeeSalaryId, SalaryStructureComponentId, PayrollMonth, PayrollYear, ComputedAmount) VALUES
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='BASIC')),       3,2025,  8000.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='HRA')),         3,2025,  1600.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TA')),          3,2025,  1600.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='MEDICAL_ALL')), 3,2025,  1250.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='NIGHTALL')),    3,2025,     0.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='SPECIAL_ALL')), 3,2025,  2783.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_ER')),       3,2025,   960.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_ER')),      3,2025,   533.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='GRATUITY')),    3,2025,   385.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='OTPAY')),       3,2025,     0.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PF_EMP')),      3,2025,   960.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='ESI_EMP')),     3,2025,   123.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='PT')),          3,2025,     0.00),
(@ES_045,(SELECT Id FROM payroll.SalaryStructureComponent WHERE SalaryStructureId=@ST_045 AND PayrollComponentId=(SELECT Id FROM payroll.PayrollComponent WHERE ComponentCode='TDS')),         3,2025,     0.00);


-- =============================================================================================================
-- S10. payroll.SalaryRevision seed
-- =============================================================================================================

PRINT 'S10. Seeding payroll.SalaryRevision...';

INSERT INTO payroll.SalaryRevision
    (EmployeeId, OldEmployeeSalaryId, NewEmployeeSalaryId, RevisionType, RevisionDate,
     OldAnnualCTC, NewAnnualCTC, IncrementPercentage, Reason, ApprovedBy, ApprovedAt)
VALUES
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND IsActive=0 AND EffectiveFrom='2023-04-01'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND IsActive=1),
    'ANNUAL_INCREMENT','2024-04-01',10800000.00,12000000.00,11.1100,
    'Annual performance review — Exceptional rating. 11.11% increment approved.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2024-03-25 14:00:00'
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND IsActive=0 AND EffectiveFrom='2023-04-01'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND IsActive=1),
    'ANNUAL_INCREMENT','2024-04-01',3800000.00,4200000.00,10.5300,
    'Annual increment — Meets & Exceeds rating. High-demand surgical specialty.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2024-03-25 14:00:00'
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND IsActive=0 AND EffectiveFrom='2023-04-01'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND IsActive=1),
    'MARKET_CORRECTION','2024-04-01',780000.00,900000.00,15.3800,
    'Market correction for ICU nursing — acute shortage of critical care nurses in Mumbai.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2024-03-25 14:00:00'
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND IsActive=0 AND EffectiveFrom='2023-04-01'),
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND IsActive=1),
    'ANNUAL_INCREMENT','2024-04-01',2200000.00,2400000.00,9.0900,
    'Annual increment — Strong performance in Delhi Emergency.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2024-03-25 14:00:00'
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'),
    NULL,
    (SELECT Id FROM payroll.EmployeeSalary WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043') AND IsActive=1),
    'JOINING','2023-08-01',NULL,720000.00,NULL,
    'Joining salary for Junior Resident, Pune. Stipend-based CTC.',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2023-07-28 10:00:00'
);


-- =============================================================================================================
-- S11. payroll.BankMaster seed
-- =============================================================================================================

PRINT 'S11. Seeding payroll.BankMaster...';

INSERT INTO payroll.BankMaster (BankCode, BankName, IfscPrefix, SwiftCode, CountryCode) VALUES
('SBI',      'State Bank of India',                 'SBIN', 'SBININBB', 'IN'),
('HDFC',     'HDFC Bank Ltd.',                      'HDFC', 'HDFCINBB', 'IN'),
('ICICI',    'ICICI Bank Ltd.',                     'ICIC', 'ICICINEN', 'IN'),
('AXIS',     'Axis Bank Ltd.',                      'UTIB', 'AXISINBB', 'IN'),
('KOTAK',    'Kotak Mahindra Bank Ltd.',             'KKBK', 'KKBKINBB', 'IN'),
('PNB',      'Punjab National Bank',                'PUNB', 'PUNBINBB', 'IN'),
('BOB',      'Bank of Baroda',                      'BARB', 'BARBINBB', 'IN'),
('CANARA',   'Canara Bank',                         'CNRB', 'CNRBINBB', 'IN'),
('UNION',    'Union Bank of India',                 'UBIN', 'UBININBB', 'IN'),
('INDUSIND', 'IndusInd Bank Ltd.',                  'INDB', 'INDUSINBB','IN'),
('YES',      'Yes Bank Ltd.',                       'YESB', 'YESBINBB', 'IN'),
('SARAS',    'Saraswat Co-operative Bank Ltd.',     'SRCB', NULL,       'IN');


-- =============================================================================================================
-- S12. payroll.EmployeeBankAccount seed — all 45 employees
-- =============================================================================================================

PRINT 'S12. Seeding payroll.EmployeeBankAccount...';

INSERT INTO payroll.EmployeeBankAccount
    (EmployeeId, BankMasterId, AccountHolderName, AccountNumber, AccountType, IfscCode, BranchName, CurrencyCode, IsPrimary, IsVerified, VerifiedBy, VerifiedAt)
VALUES
-- MUMBAI
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Rajesh Sharma',        'HDFC000000100001','SALARY','HDFC0001234','Bandra Kurla Complex, Mumbai','INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2012-01-15 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),   'Priya Nair',           'ICIC000000100002','SALARY','ICIC0001567','Andheri West, Mumbai',         'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2014-03-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Arjun Mehta',          'HDFC000000100003','SAVINGS','HDFC0001234','Bandra Kurla Complex, Mumbai','INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2015-06-10 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Sunita Pillai',        'SBIN000000100004','SAVINGS','SBIN0012345','Bandra, Mumbai',               'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2013-08-20 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='AXIS'),    'Vikram Gupta',         'UTIB000000100005','SALARY','UTIB0001892','Lower Parel, Mumbai',          'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2016-02-14 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Sneha Desai',          'HDFC000000100006','SALARY','HDFC0001234','Bandra Kurla Complex, Mumbai','INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2015-09-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='KOTAK'),   'Ramesh Iyer',          'KKBK000000100007','SAVINGS','KKBK0001001','Powai, Mumbai',                'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2017-04-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),   'Kavitha Rao',          'ICIC000000100008','SAVINGS','ICIC0001567','Andheri West, Mumbai',         'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2018-07-15 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Anil Khanna',          'SBIN000000100009','SAVINGS','SBIN0012345','Bandra, Mumbai',               'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2021-08-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SARAS'),   'Meena Joshi',          'SRCB000000100010','SAVINGS','SRCB0000026','Dadar, Mumbai',                'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2019-03-10 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Deepak Singh',         'SBIN000000100011','SAVINGS','SBIN0012345','Bandra, Mumbai',               'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2020-06-15 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Lalitha Krishnan',     'HDFC000000100012','SAVINGS','HDFC0001234','Bandra Kurla Complex, Mumbai','INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2014-11-20 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='BOB'),     'Manoj Verma',          'BARB000000100013','SAVINGS','BARB0001023','Matunga, Mumbai',              'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2021-01-10 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Radha Patel',          'SBIN000000100014','SAVINGS','SBIN0012345','Bandra, Mumbai',               'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2020-09-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Suresh Naidu',         'SBIN000000100015','SAVINGS','SBIN0012345','Bandra, Mumbai',               'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2022-02-01 10:00:00'),
-- DELHI
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Harpreet Kaur',        'HDFC000000200016','SALARY','HDFC0002451','Connaught Place, New Delhi',  'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2013-05-15 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),   'Nitin Agarwal',        'ICIC000000200017','SAVINGS','ICIC0002314','Karol Bagh, New Delhi',        'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2016-09-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='PNB'),     'Pooja Bhatt',          'PUNB000000200018','SAVINGS','PUNB0100150','Rohini, New Delhi',            'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2018-03-20 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='AXIS'),    'Kuldeep Malhotra',     'UTIB000000200019','SALARY','UTIB0002103','Saket, New Delhi',             'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'),'2019-07-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Anita Saxena',         'HDFC000000200020','SAVINGS','HDFC0002451','Connaught Place, New Delhi',  'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2017-11-01 10:00:00'),
-- BENGALURU
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),   'Subramaniam Rajan',    'ICIC000000300021','SALARY','ICIC0003891','Whitefield, Bengaluru',        'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2014-01-10 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Divya Menon',          'HDFC000000300022','SAVINGS','HDFC0003674','Indiranagar, Bengaluru',       'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2019-04-15 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='KOTAK'),   'Karthik Sundaram',     'KKBK000000300023','SAVINGS','KKBK0003201','Koramangala, Bengaluru',       'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2017-06-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Ananya Bose',          'SBIN000000300024','SAVINGS','SBIN0034567','Whitefield, Bengaluru',        'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2021-05-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='INDUSIND'),'Prasad Kulkarni',      'INDB000000300025','SAVINGS','INDB0003412','HSR Layout, Bengaluru',        'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2020-10-01 10:00:00'),
-- CHENNAI
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Lakshmi Venkatesh',    'SBIN000000400026','SALARY','SBIN0043219','Anna Salai, Chennai',          'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2011-08-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Balachandran Kumar',   'HDFC000000400027','SAVINGS','HDFC0004512','Adyar, Chennai',               'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2018-02-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='CANARA'),  'Revathi Suresh',       'CNRB000000400028','SAVINGS','CNRB0004123','Perambur, Chennai',            'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2022-01-10 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Murali Dharan',        'SBIN000000400029','SAVINGS','SBIN0043219','Anna Salai, Chennai',          'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2019-11-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),   'Sangeetha Arumugam',   'ICIC000000400030','SAVINGS','ICIC0004781','T. Nagar, Chennai',            'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2023-03-01 10:00:00'),
-- HYDERABAD
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Venkat Reddy',         'HDFC000000500031','SALARY','HDFC0005231','Banjara Hills, Hyderabad',     'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2013-12-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),   'Bhavana Rao',          'ICIC000000500032','SAVINGS','ICIC0005612','Jubilee Hills, Hyderabad',     'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2017-09-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Ravi Chandra',         'SBIN000000500033','SAVINGS','SBIN0053781','Secunderabad, Hyderabad',      'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2021-06-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='UNION'),   'Padma Devi',           'UBIN000000500034','SAVINGS','UBIN0551023','HITEC City, Hyderabad',        'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2023-01-15 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='AXIS'),    'Sunil Babu',           'UTIB000000500035','SAVINGS','UTIB0005891','Madhapur, Hyderabad',          'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2020-08-01 10:00:00'),
-- KOLKATA
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Debashish Ghosh',      'SBIN000000600036','SALARY','SBIN0067234','Salt Lake, Kolkata',           'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2014-07-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Ankita Chatterjee',    'HDFC000000600037','SAVINGS','HDFC0006312','Park Street, Kolkata',         'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2018-10-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Soumya Das',           'SBIN000000600038','SAVINGS','SBIN0067234','Salt Lake, Kolkata',           'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2021-04-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='BOB'),     'Tapas Banerjee',       'BARB000000600039','SAVINGS','BARB0006781','Ballygunge, Kolkata',          'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2016-05-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Rupa Mondal',          'SBIN000000600040','SAVINGS','SBIN0067234','Salt Lake, Kolkata',           'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2022-09-01 10:00:00'),
-- PUNE
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='HDFC'),    'Shyam Kulkarni',       'HDFC000000700041','SALARY','HDFC0007823','Koregaon Park, Pune',          'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2015-11-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='ICICI'),   'Namrata Deshpande',    'ICIC000000700042','SAVINGS','ICIC0007134','Aundh, Pune',                  'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2019-02-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Rohit Patil',          'SBIN000000700043','SAVINGS','SBIN0078912','Hadapsar, Pune',               'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2023-08-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='AXIS'),    'Ashwini More',         'UTIB000000700044','SAVINGS','UTIB0007345','Pimpri, Pune',                 'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2020-12-01 10:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'),(SELECT Id FROM payroll.BankMaster WHERE BankCode='SBI'),     'Ganesh Shinde',        'SBIN000000700045','SAVINGS','SBIN0078912','Hadapsar, Pune',               'INR',1,1,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2022-06-01 10:00:00');


-- =============================================================================================================
-- S13. payroll.PayrollDisbursement seed — March 2025
-- =============================================================================================================

PRINT 'S13. Seeding payroll.PayrollDisbursement (March 2025)...';

INSERT INTO payroll.PayrollDisbursement
    (LegalEntityId, PayrollMonth, PayrollYear, DisbursementDate, TotalEmployeeCount,
     TotalNetPayable, CurrencyCode, DisbursementStatus, BankBatchReferenceNo,
     InitiatedBy, ApprovedBy, ApprovedAt, ProcessedAt, Remarks)
VALUES
(
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-IN'),
    3,2025,'2025-03-31',20,3467580.00,'INR','COMPLETED',
    'MEDCAREIN-MAR25-HDFC-BATCH-001',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'),
    '2025-03-29 16:00:00','2025-03-31 23:45:00',
    'March 2025 salary disbursement for MedCare India Pvt. Ltd. (Mumbai + Pune). 20 employees. NEFT bulk credit via HDFC gateway.'
),
(
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-NORTH'),
    3,2025,'2025-03-31',10,1474200.00,'INR','COMPLETED',
    'MEDCARENORTH-MAR25-SBI-BATCH-001',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'),
    '2025-03-29 15:00:00','2025-03-31 22:30:00',
    'March 2025 salary for MedCare North India (Delhi + Kolkata). SBI RTGS bulk transfer.'
),
(
    (SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-SOUTH'),
    3,2025,'2025-03-31',15,1662595.00,'INR','COMPLETED',
    'MEDCARESOUTH-MAR25-ICICI-BATCH-001',
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'),
    '2025-03-29 17:00:00','2025-04-01 01:00:00',
    'March 2025 salary for MedCare South India (Bengaluru + Chennai + Hyderabad). ICICI NEFT bulk credit.'
);


-- =============================================================================================================
-- S14. payroll.PayrollDisbursementTransaction seed — March 2025 — all 45 employees
-- =============================================================================================================

PRINT 'S14. Seeding payroll.PayrollDisbursementTransaction (March 2025)...';

DECLARE @DISP_IN    BIGINT = (SELECT Id FROM payroll.PayrollDisbursement WHERE LegalEntityId=(SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-IN')    AND PayrollMonth=3 AND PayrollYear=2025);
DECLARE @DISP_NORTH BIGINT = (SELECT Id FROM payroll.PayrollDisbursement WHERE LegalEntityId=(SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-NORTH') AND PayrollMonth=3 AND PayrollYear=2025);
DECLARE @DISP_SOUTH BIGINT = (SELECT Id FROM payroll.PayrollDisbursement WHERE LegalEntityId=(SELECT Id FROM dbo.LegalEntity WHERE EntityCode='MEDCARE-SOUTH') AND PayrollMonth=3 AND PayrollYear=2025);

INSERT INTO payroll.PayrollDisbursementTransaction
    (PayrollDisbursementId, EmployeeId, EmployeeBankAccountId, PayrollMonth, PayrollYear,
     GrossAmount, TotalDeductions, CurrencyCode, TransactionStatus, BankTransactionId,
     PaymentMode, InitiatedAt, ConfirmedAt, Remarks)
VALUES
-- MUMBAI (MEDCARE-IN batch)
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND IsPrimary=1),3,2025, 820000.00,125000.00,'INR','SUCCESS','UTR202503310000100001','RTGS','2025-03-31 20:00:00','2025-03-31 21:30:00','CMO March 2025. RTGS credit confirmed.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002') AND IsPrimary=1),3,2025, 410000.00, 62000.00,'INR','SUCCESS','UTR202503310000100002','RTGS','2025-03-31 20:00:00','2025-03-31 21:30:00','Medical Director March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND IsPrimary=1),3,2025, 287000.00, 44000.00,'INR','SUCCESS','UTR202503310000100003','RTGS','2025-03-31 20:00:00','2025-03-31 21:30:00','Sr. Surgeon March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004') AND IsPrimary=1),3,2025, 205000.00, 31000.00,'INR','SUCCESS','UTR202503310000100004','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','CNO March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005') AND IsPrimary=1),3,2025, 123000.00, 19000.00,'INR','SUCCESS','UTR202503310000100005','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','HR Manager March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006') AND IsPrimary=1),3,2025, 123000.00, 19000.00,'INR','SUCCESS','UTR202503310000100006','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Finance Manager March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007') AND IsPrimary=1),3,2025, 123000.00, 19000.00,'INR','SUCCESS','UTR202503310000100007','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','IT Manager March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008') AND IsPrimary=1),3,2025, 150333.00, 22833.00,'INR','SUCCESS','UTR202503310000100008','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Consultant Physician March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009') AND IsPrimary=1),3,2025,  68333.00, 10333.00,'INR','SUCCESS','UTR202503310000100009','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Resident Doctor. 3 days SL deducted from leave balance.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND IsPrimary=1),3,2025,  61500.00,  9300.00,'INR','SUCCESS','UTR202503310000100010','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Sr. ICU Nurse. Night allowance + OT included.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011') AND IsPrimary=1),3,2025,  36900.00,  5535.00,'INR','SUCCESS','UTR202503310000100011','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Staff Nurse March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012') AND IsPrimary=1),3,2025, 109333.00, 16533.00,'INR','SUCCESS','UTR202503310000100012','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Chief Pharmacist March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013') AND IsPrimary=1),3,2025,  36900.00,  5535.00,'INR','SUCCESS','UTR202503310000100013','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Pharmacist March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014') AND IsPrimary=1),3,2025,  28700.00,  4300.00,'INR','SUCCESS','UTR202503310000100014','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Admin Executive March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015') AND IsPrimary=1),3,2025,  20500.00,  3075.00,'INR','SUCCESS','UTR202503310000100015','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Front Desk March 2025.'),
-- PUNE (MEDCARE-IN batch)
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041') AND IsPrimary=1),3,2025, 191333.00, 29133.00,'INR','SUCCESS','UTR202503310000100041','RTGS','2025-03-31 20:00:00','2025-03-31 21:30:00','Hospital Admin Pune March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042') AND IsPrimary=1),3,2025, 150333.00, 22833.00,'INR','SUCCESS','UTR202503310000100042','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Cardiologist Pune March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043') AND IsPrimary=1),3,2025,  49200.00,  7380.00,'INR','SUCCESS','UTR202503310000100043','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Junior Resident Pune March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044') AND IsPrimary=1),3,2025,  32800.00,  4920.00,'INR','SUCCESS','UTR202503310000100044','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Staff Nurse Pune March 2025.'),
(@DISP_IN,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045') AND IsPrimary=1),3,2025,  16400.00,  2460.00,'INR','SUCCESS','UTR202503310000100045','NEFT','2025-03-31 20:00:00','2025-03-31 23:00:00','Ward Boy Pune. ESI deducted (gross < 21,000).'),
-- DELHI (MEDCARE-NORTH batch)
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016') AND IsPrimary=1),3,2025, 375833.00, 57833.00,'INR','SUCCESS','UTR202503310000200016','RTGS','2025-03-31 20:30:00','2025-03-31 22:00:00','Delhi Medical Director March 2025.'),
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017') AND IsPrimary=1),3,2025, 273333.00, 41333.00,'INR','SUCCESS','UTR202503310000200017','RTGS','2025-03-31 20:30:00','2025-03-31 22:00:00','Sr. Orthopedic Surgeon March 2025.'),
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018') AND IsPrimary=1),3,2025,  61500.00,  9300.00,'INR','SUCCESS','UTR202503310000200018','NEFT','2025-03-31 20:30:00','2025-03-31 23:30:00','Sr. Nurse Delhi March 2025.'),
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019') AND IsPrimary=1),3,2025,  61500.00,  9300.00,'INR','SUCCESS','UTR202503310000200019','NEFT','2025-03-31 20:30:00','2025-03-31 23:30:00','HRBP Delhi March 2025.'),
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND IsPrimary=1),3,2025, 164000.00, 25000.00,'INR','SUCCESS','UTR202503310000200020','NEFT','2025-03-31 20:30:00','2025-03-31 23:30:00','Emergency Physician Delhi. 180 OT mins included.'),
-- KOLKATA (MEDCARE-NORTH batch)
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036') AND IsPrimary=1),3,2025, 341667.00, 52667.00,'INR','SUCCESS','UTR202503310000200036','RTGS','2025-03-31 20:30:00','2025-03-31 22:00:00','Kolkata Medical Director March 2025.'),
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037') AND IsPrimary=1),3,2025, 136667.00, 20867.00,'INR','SUCCESS','UTR202503310000200037','NEFT','2025-03-31 20:30:00','2025-03-31 23:30:00','Pathologist Kolkata March 2025.'),
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038') AND IsPrimary=1),3,2025,  32800.00,  4920.00,'INR','SUCCESS','UTR202503310000200038','NEFT','2025-03-31 20:30:00','2025-03-31 23:30:00','Staff Nurse Kolkata March 2025.'),
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039') AND IsPrimary=1),3,2025, 109333.00, 16533.00,'INR','SUCCESS','UTR202503310000200039','NEFT','2025-03-31 20:30:00','2025-03-31 23:30:00','Operations Manager Kolkata March 2025.'),
(@DISP_NORTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040') AND IsPrimary=1),3,2025,  28700.00,  4300.00,'INR','SUCCESS','UTR202503310000200040','NEFT','2025-03-31 20:30:00','2025-03-31 23:30:00','Paramedic Kolkata March 2025.'),
-- BENGALURU (MEDCARE-SOUTH batch)
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021') AND IsPrimary=1),3,2025, 375833.00, 57833.00,'INR','SUCCESS','UTR202503310000300021','RTGS','2025-03-31 21:00:00','2025-04-01 00:30:00','Medical Director Bengaluru March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022') AND IsPrimary=1),3,2025, 150333.00, 22833.00,'INR','SUCCESS','UTR202503310000300022','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Neurologist Bengaluru March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023') AND IsPrimary=1),3,2025, 136667.00, 20867.00,'INR','SUCCESS','UTR202503310000300023','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Radiologist Bengaluru March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024') AND IsPrimary=1),3,2025,  32800.00,  4920.00,'INR','SUCCESS','UTR202503310000300024','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Lab Technician Bengaluru March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025') AND IsPrimary=1),3,2025,  36900.00,  5535.00,'INR','SUCCESS','UTR202503310000300025','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Sysadmin Bengaluru March 2025.'),
-- CHENNAI (MEDCARE-SOUTH batch)
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND IsPrimary=1),3,2025, 396333.00, 61333.00,'INR','SUCCESS','UTR202503310000300026','RTGS','2025-03-31 21:00:00','2025-04-01 00:30:00','Chennai Medical Director March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027') AND IsPrimary=1),3,2025, 164000.00, 25000.00,'INR','SUCCESS','UTR202503310000300027','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Oncologist Chennai March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028') AND IsPrimary=1),3,2025,  32800.00,  4920.00,'INR','SUCCESS','UTR202503310000300028','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Nurse Chennai. On maternity leave from May 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029') AND IsPrimary=1),3,2025,  57400.00,  8600.00,'INR','SUCCESS','UTR202503310000300029','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Sr. Pharmacist Chennai March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030') AND IsPrimary=1),3,2025,  28700.00,  4300.00,'INR','SUCCESS','UTR202503310000300030','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','HR Executive Chennai March 2025.'),
-- HYDERABAD (MEDCARE-SOUTH batch)
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031') AND IsPrimary=1),3,2025, 355333.00, 54333.00,'INR','SUCCESS','UTR202503310000300031','RTGS','2025-03-31 21:00:00','2025-04-01 00:30:00','Hyderabad Medical Director March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032') AND IsPrimary=1),3,2025, 136667.00, 20867.00,'INR','SUCCESS','UTR202503310000300032','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Pediatrician Hyderabad March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033') AND IsPrimary=1),3,2025,  32800.00,  4920.00,'INR','SUCCESS','UTR202503310000300033','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Radiology Tech Hyderabad March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034') AND IsPrimary=1),3,2025,  24600.00,  3690.00,'INR','SUCCESS','UTR202503310000300034','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Junior Nurse Hyderabad March 2025.'),
(@DISP_SOUTH,(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035'),(SELECT Id FROM payroll.EmployeeBankAccount WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035') AND IsPrimary=1),3,2025,  32800.00,  4920.00,'INR','SUCCESS','UTR202503310000300035','NEFT','2025-03-31 21:00:00','2025-04-01 01:00:00','Accountant Hyderabad March 2025.');


-- =============================================================================================================
-- S15. payroll.PayrollAttendanceSummary seed — March 2025
-- =============================================================================================================

PRINT 'S15. Seeding payroll.PayrollAttendanceSummary (March 2025)...';

INSERT INTO payroll.PayrollAttendanceSummary
    (EmployeeId, PayrollMonth, PayrollYear, TotalWorkingDays, PresentDays, LeaveDays, AbsentDays, OvertimeMinutes, ProcessedAt)
VALUES
-- Full month attendance representative samples; all 45 employees covered
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), 3,2025, 21.00, 21.00, 0.00, 0.00,  35, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'), 3,2025, 21.00, 20.00, 1.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), 3,2025, 25.00, 25.00, 0.00, 0.00, 120, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), 3,2025, 21.00, 20.50, 0.50, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'), 3,2025, 21.00, 18.00, 3.00, 0.00,  60, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), 3,2025, 26.00, 26.00, 0.00, 0.00,  90, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'), 3,2025, 26.00, 25.00, 1.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP013'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP014'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP015'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP017'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP018'), 3,2025, 26.00, 26.00, 0.00, 0.00,  30, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), 3,2025, 15.00, 15.00, 0.00, 0.00, 180, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP021'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP022'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP023'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP024'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP025'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP027'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'), 3,2025, 26.00, 26.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP029'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP031'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP032'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP033'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP034'), 3,2025, 26.00, 26.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP035'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP036'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP037'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP038'), 3,2025, 26.00, 25.00, 0.00, 1.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP039'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP040'), 3,2025, 15.00, 15.00, 0.00, 0.00,  45, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP041'), 3,2025, 21.00, 21.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP042'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP043'), 3,2025, 25.00, 25.00, 0.00, 0.00,   0, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP044'), 3,2025, 26.00, 26.00, 0.00, 0.00,  20, '2025-04-01 02:00:00'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'), 3,2025, 26.00, 26.00, 0.00, 0.00,   0, '2025-04-01 02:00:00');


-- =============================================================================================================
-- S16. payroll.EmployeeTaxDeclaration seed — FY 2024-25
-- =============================================================================================================

PRINT 'S16. Seeding payroll.EmployeeTaxDeclaration (FY 2024-25)...';

INSERT INTO payroll.EmployeeTaxDeclaration
    (EmployeeId, TaxRegimeId, FiscalYear, DeclaredTotalIncome, DeclaredExemptions, DeclaredDeductions,
     DeclarationStatus, SubmittedAt, VerifiedBy, VerifiedAt, Remarks)
VALUES
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'), @OLD_REGIME, 2024,  9840000.00, 720000.00, 280000.00,'VERIFIED','2024-07-15 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-08-01 14:00:00','Old regime. High investment profile. HRA Mumbai. 80C max.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'), @NEW_REGIME, 2024,  4920000.00,      0.00,  50000.00,'VERIFIED','2024-07-10 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-25 14:00:00','New regime opted. Standard deduction only.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'), @OLD_REGIME, 2024,  3444000.00, 480000.00, 230000.00,'VERIFIED','2024-07-12 09:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-30 11:00:00','Old regime. HRA Worli. Senior parent insurance under 80D.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP004'), @OLD_REGIME, 2024,  2460000.00, 360000.00, 200000.00,'VERIFIED','2024-07-11 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-28 15:00:00','Old regime. Regular LIC and PPF declared.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'), @NEW_REGIME, 2024,  1476000.00,      0.00,  50000.00,'VERIFIED','2024-07-08 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-22 12:00:00','New regime. Standard deduction only.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'), @OLD_REGIME, 2024,  1476000.00, 360000.00, 200000.00,'VERIFIED','2024-07-09 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),'2024-07-23 12:00:00','Old regime. Home loan interest u/s 24 partially claimed.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP007'), @NEW_REGIME, 2024,  1476000.00,      0.00,  50000.00,'VERIFIED','2024-07-10 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-24 12:00:00','New regime. Standard deduction.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP008'), @OLD_REGIME, 2024,  1803996.00, 360000.00, 200000.00,'VERIFIED','2024-07-13 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-29 12:00:00','Old regime. Mumbai HRA exemption.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'), @OLD_REGIME, 2024,   819996.00,  80004.00, 150000.00,'VERIFIED','2024-07-15 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-31 12:00:00','Old regime. Taxable income near threshold; 87A rebate applicable.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'), @OLD_REGIME, 2024,   738000.00,  72000.00, 150000.00,'VERIFIED','2024-07-14 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-30 12:00:00','Old regime. Dadar rent HRA minimal.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'), @NEW_REGIME, 2024,   442800.00,      0.00,  50000.00,'SUBMITTED','2024-07-20 10:00:00',NULL,NULL,'New regime. Income < 7L, full 87A rebate. Zero tax liability.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP012'), @OLD_REGIME, 2024,  1311996.00, 320000.00, 200000.00,'VERIFIED','2024-07-11 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-07-26 12:00:00','Old regime. HRA exemption Mumbai.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'), @OLD_REGIME, 2024,  4499996.00, 600000.00, 280000.00,'VERIFIED','2024-07-09 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2024-07-23 12:00:00','Old regime. Delhi HRA. Home loan interest u/s 24.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'), @NEW_REGIME, 2024,  1968000.00,      0.00,  50000.00,'VERIFIED','2024-07-12 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP019'),'2024-07-28 12:00:00','New regime. Emergency shift, standard deduction only.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'), @OLD_REGIME, 2024,  4759996.00, 600000.00, 280000.00,'VERIFIED','2024-07-10 10:00:00',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),'2024-07-25 12:00:00','Old regime. Chennai HRA. Joint home loan.'),
((SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP028'), @OLD_REGIME, 2024,   393600.00,      0.00,  50000.00,'SUBMITTED','2024-07-18 10:00:00',NULL,NULL,'Old regime. Maternity leave May-Oct 2025. Below taxable limit.');


-- =============================================================================================================
-- S17. payroll.TaxDeclarationItem seed
-- =============================================================================================================

PRINT 'S17. Seeding payroll.TaxDeclarationItem...';

-- EMP001 — Old Regime items
INSERT INTO payroll.TaxDeclarationItem (EmployeeTaxDeclarationId, TaxProofCategoryId, DeclaredAmount, ApprovedAmount) VALUES
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80C'),     200000.00, 200000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80D'),      75000.00,  75000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='HRA'),     720000.00, 720000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80CCD1B'),  50000.00,  50000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='STD_DED'),  50000.00,  50000.00);

-- EMP002 — New Regime (standard deduction only)
INSERT INTO payroll.TaxDeclarationItem (EmployeeTaxDeclarationId, TaxProofCategoryId, DeclaredAmount, ApprovedAmount) VALUES
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='STD_DED'), 50000.00, 50000.00);

-- EMP003 — Old Regime items
INSERT INTO payroll.TaxDeclarationItem (EmployeeTaxDeclarationId, TaxProofCategoryId, DeclaredAmount, ApprovedAmount) VALUES
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80C'),     150000.00, 150000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80D'),      50000.00,  50000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='HRA'),     480000.00, 480000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80CCD1B'),  30000.00,  30000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='STD_DED'),  50000.00,  50000.00);

-- EMP010 — Old Regime items
INSERT INTO payroll.TaxDeclarationItem (EmployeeTaxDeclarationId, TaxProofCategoryId, DeclaredAmount, ApprovedAmount) VALUES
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80C'),     150000.00, 150000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='HRA'),      72000.00,  72000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='STD_DED'),  50000.00,  50000.00);

-- EMP026 — Old Regime items
INSERT INTO payroll.TaxDeclarationItem (EmployeeTaxDeclarationId, TaxProofCategoryId, DeclaredAmount, ApprovedAmount) VALUES
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80C'),     150000.00, 150000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80D'),      75000.00,  75000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='HRA'),     600000.00, 600000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='80CCD1B'),  50000.00,  50000.00),
((SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),(SELECT Id FROM payroll.TaxProofCategory WHERE CategoryCode='STD_DED'),  50000.00,  50000.00);


-- =============================================================================================================
-- S18. payroll.TaxDeclarationProof seed
-- =============================================================================================================

PRINT 'S18. Seeding payroll.TaxDeclarationProof...';

-- EMP001 proofs
INSERT INTO payroll.TaxDeclarationProof
    (TaxDeclarationItemId, Description, DeclaredAmount, ApprovedAmount, DocumentFileUrl, OriginalFileName, UploadedAt, ReviewStatus, ReviewedBy, ReviewedAt)
VALUES
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80C'),
 'ELSS Mutual Fund – Axis Long Term Equity Fund',100000.00,100000.00,'https://docs.medcareindia.com/emp001/80c_elss_2024.pdf',      '80C_ELSS_Axis_2024.pdf',     '2024-12-15 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-20 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80C'),
 'LIC Premium – Jeevan Anand Policy No. 123456789',50000.00,50000.00,'https://docs.medcareindia.com/emp001/80c_lic_2024.pdf',       '80C_LIC_Premium_2024.pdf',   '2024-12-15 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-20 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80C'),
 'PPF Contribution – SBI Account',50000.00,50000.00,'https://docs.medcareindia.com/emp001/80c_ppf_2024.pdf',        '80C_PPF_Statement_2024.pdf', '2024-12-15 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-20 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80D'),
 'Medical Insurance – Family Floater (Self, Spouse, 2 Children)',25000.00,25000.00,'https://docs.medcareindia.com/emp001/80d_mediclaim_2024.pdf','80D_Mediclaim_2024.pdf','2024-12-15 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-20 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80D'),
 'Medical Insurance – Parents (Senior Citizens)',50000.00,50000.00,'https://docs.medcareindia.com/emp001/80d_parents_2024.pdf','80D_Parents_Policy_2024.pdf','2024-12-15 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-20 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND etd.FiscalYear=2024 AND tpc.CategoryCode='HRA'),
 'Rent Receipts – Bandra West, Mumbai – INR 60,000/month x 12',720000.00,720000.00,'https://docs.medcareindia.com/emp001/hra_receipts_2024.pdf','Rent_Receipts_2024_EMP001.pdf','2024-12-15 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-20 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80CCD1B'),
 'NPS – National Pension System (Tier 1) additional contribution',50000.00,50000.00,'https://docs.medcareindia.com/emp001/nps_statement_2024.pdf','NPS_Statement_2024.pdf','2024-12-15 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-20 12:00:00');

-- EMP003 proofs
INSERT INTO payroll.TaxDeclarationProof
    (TaxDeclarationItemId, Description, DeclaredAmount, ApprovedAmount, DocumentFileUrl, OriginalFileName, UploadedAt, ReviewStatus, ReviewedBy, ReviewedAt)
VALUES
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80C'),
 'Children Education Tuition Fee + ELSS',150000.00,150000.00,'https://docs.medcareindia.com/emp003/80c_combined_2024.pdf','80C_Proof_EMP003_2024.pdf','2024-12-16 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-21 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80D'),
 'Group Medical Insurance top-up + Parents senior citizen cover',50000.00,50000.00,'https://docs.medcareindia.com/emp003/80d_2024.pdf','80D_Proof_EMP003_2024.pdf','2024-12-16 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-21 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND etd.FiscalYear=2024 AND tpc.CategoryCode='HRA'),
 'Rent Receipts – Worli, Mumbai – INR 40,000/month',480000.00,480000.00,'https://docs.medcareindia.com/emp003/hra_2024.pdf','HRA_Receipts_EMP003_2024.pdf','2024-12-16 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-21 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80CCD1B'),
 'NPS Tier 1 contribution',30000.00,30000.00,'https://docs.medcareindia.com/emp003/nps_2024.pdf','NPS_EMP003_2024.pdf','2024-12-16 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-21 12:00:00');

-- EMP010 proofs
INSERT INTO payroll.TaxDeclarationProof
    (TaxDeclarationItemId, Description, DeclaredAmount, ApprovedAmount, DocumentFileUrl, OriginalFileName, UploadedAt, ReviewStatus, ReviewedBy, ReviewedAt)
VALUES
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80C'),
 'PPF + LIC Premium (Annual)',100000.00,100000.00,'https://docs.medcareindia.com/emp010/80c_2024.pdf','80C_EMP010_2024.pdf','2024-12-18 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-24 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80C'),
 'ELSS – SBI Magnum Tax Gain',50000.00,50000.00,'https://docs.medcareindia.com/emp010/80c_elss_2024.pdf','80C_ELSS_EMP010_2024.pdf','2024-12-18 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-24 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND etd.FiscalYear=2024 AND tpc.CategoryCode='HRA'),
 'Rent Receipts – Dadar, Mumbai – INR 6,000/month',72000.00,72000.00,'https://docs.medcareindia.com/emp010/hra_2024.pdf','HRA_EMP010_2024.pdf','2024-12-18 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP006'),'2024-12-24 12:00:00');

-- EMP026 proofs
INSERT INTO payroll.TaxDeclarationProof
    (TaxDeclarationItemId, Description, DeclaredAmount, ApprovedAmount, DocumentFileUrl, OriginalFileName, UploadedAt, ReviewStatus, ReviewedBy, ReviewedAt)
VALUES
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80C'),
 'Home Loan Principal Repayment + ELSS',150000.00,150000.00,'https://docs.medcareindia.com/emp026/80c_2024.pdf','80C_EMP026_2024.pdf','2024-12-14 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),'2024-12-19 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80D'),
 'Family + Senior Parent Medical Insurance',75000.00,75000.00,'https://docs.medcareindia.com/emp026/80d_2024.pdf','80D_EMP026_2024.pdf','2024-12-14 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),'2024-12-19 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND etd.FiscalYear=2024 AND tpc.CategoryCode='HRA'),
 'Rent Receipts – Adyar, Chennai – INR 50,000/month',600000.00,600000.00,'https://docs.medcareindia.com/emp026/hra_2024.pdf','HRA_EMP026_2024.pdf','2024-12-14 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),'2024-12-19 12:00:00'),
((SELECT tdi.Id FROM payroll.TaxDeclarationItem tdi INNER JOIN payroll.EmployeeTaxDeclaration etd ON etd.Id=tdi.EmployeeTaxDeclarationId INNER JOIN payroll.TaxProofCategory tpc ON tpc.Id=tdi.TaxProofCategoryId WHERE etd.EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND etd.FiscalYear=2024 AND tpc.CategoryCode='80CCD1B'),
 'NPS Tier 1 Contribution',50000.00,50000.00,'https://docs.medcareindia.com/emp026/nps_2024.pdf','NPS_EMP026_2024.pdf','2024-12-14 10:00:00','APPROVED',(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP030'),'2024-12-19 12:00:00');


-- =============================================================================================================
-- S19. payroll.EmployeeTaxDeduction seed — March 2025
-- =============================================================================================================

PRINT 'S19. Seeding payroll.EmployeeTaxDeduction (March 2025)...';

INSERT INTO payroll.EmployeeTaxDeduction
    (EmployeeId, EmployeeTaxDeclarationId, TaxRegimeId, PayrollMonth, PayrollYear, FiscalYear,
     GrossIncome, TotalExemptions, TotalDeductions, TDSAmount, SurchargeAmount, CessAmount,
     CumulativeTDSYTD, IsAdjustment, AdjustmentReason, PayrollDisbursementTransactionId)
VALUES
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND FiscalYear=2024),
    @OLD_REGIME, 3,2025,2024, 820000.00,60000.00,23333.00, 77000.00,0.00,3080.00, 924000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002') AND FiscalYear=2024),
    @NEW_REGIME, 3,2025,2024, 410000.00,0.00,4167.00, 42000.00,0.00,1680.00, 504000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP002') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND FiscalYear=2024),
    @OLD_REGIME, 3,2025,2024, 287000.00,40000.00,19167.00, 44000.00,0.00,1760.00, 528000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005') AND FiscalYear=2024),
    @NEW_REGIME, 3,2025,2024, 123000.00,0.00,4167.00, 19000.00,0.00,760.00, 228000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP005') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009') AND FiscalYear=2024),
    @OLD_REGIME, 3,2025,2024, 68333.00,6667.00,12500.00, 3333.00,0.00,133.00, 39996.00, 1,
    'Annual TDS reconciliation — minor shortfall of INR 1,000 adjusted in final month.',
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP009') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND FiscalYear=2024),
    @OLD_REGIME, 3,2025,2024, 61500.00,6000.00,12500.00, 5700.00,0.00,228.00, 68400.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011') AND FiscalYear=2024),
    @NEW_REGIME, 3,2025,2024, 36900.00,0.00,4167.00, 975.00,0.00,39.00, 11700.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP011') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016') AND FiscalYear=2024),
    @OLD_REGIME, 3,2025,2024, 375833.00,50000.00,23333.00, 95000.00,0.00,3800.00, 1140000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP016') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND FiscalYear=2024),
    @NEW_REGIME, 3,2025,2024, 164000.00,0.00,4167.00, 30000.00,0.00,1200.00, 360000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP020') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026'),
    (SELECT Id FROM payroll.EmployeeTaxDeclaration WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND FiscalYear=2024),
    @OLD_REGIME, 3,2025,2024, 396333.00,50000.00,23333.00, 100000.00,0.00,4000.00, 1200000.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP026') AND PayrollMonth=3 AND PayrollYear=2025)
),
(
    (SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045'),
    NULL, @NEW_REGIME, 3,2025,2024,
    16400.00,0.00,4167.00, 0.00,0.00,0.00, 0.00, 0, NULL,
    (SELECT Id FROM payroll.PayrollDisbursementTransaction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP045') AND PayrollMonth=3 AND PayrollYear=2025)
);


-- =============================================================================================================
-- S20. payroll.TaxDeductionBreakdown seed — March 2025
-- =============================================================================================================

PRINT 'S20. Seeding payroll.TaxDeductionBreakdown (March 2025)...';

DECLARE @ETD_001 BIGINT = (SELECT Id FROM payroll.EmployeeTaxDeduction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP001') AND PayrollMonth=3 AND PayrollYear=2025);
DECLARE @ETD_003 BIGINT = (SELECT Id FROM payroll.EmployeeTaxDeduction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP003') AND PayrollMonth=3 AND PayrollYear=2025);
DECLARE @ETD_010 BIGINT = (SELECT Id FROM payroll.EmployeeTaxDeduction WHERE EmployeeId=(SELECT Id FROM dbo.Employee WHERE EmployeeCode='EMP010') AND PayrollMonth=3 AND PayrollYear=2025);

-- EMP001 CMO breakdown
INSERT INTO payroll.TaxDeductionBreakdown
    (EmployeeTaxDeductionId, DeductionHead, DeductionCategory, DeclaredAmount, ApprovedAmount, ActualDeductionAmount, Remarks)
VALUES
(@ETD_001,'Standard Deduction (Section 16)',         'DEDUCTION',  4167.00, 4167.00, 4167.00,'INR 50,000 annual / 12.'),
(@ETD_001,'HRA Exemption (Section 10(13A))',          'EXEMPTION',60000.00,60000.00,60000.00,'Mumbai metro HRA. Least of actual HRA, 50% basic, rent-10% basic.'),
(@ETD_001,'Section 80C – ELSS',                      'DEDUCTION',  8333.00, 8333.00, 8333.00,'INR 1,00,000 ELSS annual / 12.'),
(@ETD_001,'Section 80C – LIC Premium',               'DEDUCTION',  4167.00, 4167.00, 4167.00,'INR 50,000 LIC annual / 12.'),
(@ETD_001,'Section 80C – PPF',                       'DEDUCTION',  4167.00, 4167.00, 4167.00,'INR 50,000 PPF / 12.'),
(@ETD_001,'Section 80D – Self & Family',             'DEDUCTION',  2083.00, 2083.00, 2083.00,'INR 25,000 mediclaim / 12.'),
(@ETD_001,'Section 80D – Parents (Sr. Citizen)',     'DEDUCTION',  4167.00, 4167.00, 4167.00,'INR 50,000 parent cover / 12.'),
(@ETD_001,'Section 80CCD(1B) – NPS',                 'DEDUCTION',  4167.00, 4167.00, 4167.00,'NPS additional contribution / 12.'),
(@ETD_001,'Income Tax (30% Slab)',                   'TAX',        77000.00,77000.00,77000.00,'Computed on monthly taxable income; annual tax / 12.'),
(@ETD_001,'Health & Education Cess (4%)',            'CESS',        3080.00, 3080.00, 3080.00,'4% on income tax.'),
(@ETD_001,'Professional Tax – Maharashtra',          'DEDUCTION',    200.00,  200.00,  200.00,'Maharashtra PT INR 2,500/yr; INR 200/month x 11 + INR 300 Feb.');

-- EMP003 Sr. Surgeon breakdown
INSERT INTO payroll.TaxDeductionBreakdown
    (EmployeeTaxDeductionId, DeductionHead, DeductionCategory, DeclaredAmount, ApprovedAmount, ActualDeductionAmount, Remarks)
VALUES
(@ETD_003,'Standard Deduction (Section 16)',         'DEDUCTION',  4167.00, 4167.00, 4167.00,'INR 50,000 / 12.'),
(@ETD_003,'HRA Exemption (Section 10(13A))',          'EXEMPTION',40000.00,40000.00,40000.00,'Worli rent. HRA exemption calculation applied.'),
(@ETD_003,'Section 80C – Children Fees + ELSS',      'DEDUCTION',12500.00,12500.00,12500.00,'INR 1.5L cap / 12.'),
(@ETD_003,'Section 80D – Self + Senior Parents',     'DEDUCTION',  4167.00, 4167.00, 4167.00,'INR 50,000 combined / 12.'),
(@ETD_003,'Section 80CCD(1B) – NPS',                 'DEDUCTION',  2500.00, 2500.00, 2500.00,'NPS Tier 1 / 12.'),
(@ETD_003,'Income Tax (20% & 30% Slab)',             'TAX',        44000.00,44000.00,44000.00,'20% on 5-10L band; 30% on balance.'),
(@ETD_003,'Health & Education Cess (4%)',            'CESS',        1760.00, 1760.00, 1760.00,'4% cess on income tax.'),
(@ETD_003,'Professional Tax – Maharashtra',          'DEDUCTION',    200.00,  200.00,  200.00,'Maharashtra PT monthly.');

-- EMP010 Sr. ICU Nurse breakdown
INSERT INTO payroll.TaxDeductionBreakdown
    (EmployeeTaxDeductionId, DeductionHead, DeductionCategory, DeclaredAmount, ApprovedAmount, ActualDeductionAmount, Remarks)
VALUES
(@ETD_010,'Standard Deduction (Section 16)',         'DEDUCTION',  4167.00, 4167.00, 4167.00,'INR 50,000 / 12.'),
(@ETD_010,'HRA Exemption (Section 10(13A))',          'EXEMPTION',  6000.00, 6000.00, 6000.00,'Dadar rent INR 6,000/month. HRA exemption minimal.'),
(@ETD_010,'Section 80C – PPF + LIC + ELSS',          'DEDUCTION',12500.00,12500.00,12500.00,'INR 1.5L / 12.'),
(@ETD_010,'Income Tax (5% Slab)',                    'TAX',         5700.00, 5700.00, 5700.00,'Taxable income ~4.15L. 5% on 2.5-5L band.'),
(@ETD_010,'Health & Education Cess (4%)',            'CESS',         228.00,  228.00,  228.00,'4% on tax.'),
(@ETD_010,'Professional Tax – Maharashtra',          'DEDUCTION',    200.00,  200.00,  200.00,'Maharashtra PT.');


-- =============================================================================================================
-- VERIFICATION SUMMARY
-- =============================================================================================================

PRINT '';
PRINT '=============================================================================================================';
PRINT 'PAYROLL SEED DATA INSERTION COMPLETE — MedCare India Pvt. Ltd.';
PRINT '=============================================================================================================';
PRINT '';

SELECT 'dbo.StatusLookup'                           AS TableName, COUNT(*) AS RecordCount FROM dbo.StatusLookup                           UNION ALL
SELECT 'payroll.TaxProofCategory',                               COUNT(*)               FROM payroll.TaxProofCategory                    UNION ALL
SELECT 'payroll.SalaryGrade',                                    COUNT(*)               FROM payroll.SalaryGrade                         UNION ALL
SELECT 'payroll.SalaryStructure',                                COUNT(*)               FROM payroll.SalaryStructure                     UNION ALL
SELECT 'payroll.PayrollComponent',                               COUNT(*)               FROM payroll.PayrollComponent                    UNION ALL
SELECT 'payroll.SalaryStructureComponent',                       COUNT(*)               FROM payroll.SalaryStructureComponent            UNION ALL
SELECT 'payroll.EmployeeSalary',                                 COUNT(*)               FROM payroll.EmployeeSalary                      UNION ALL
SELECT 'payroll.EmployeeSalaryComponent',                        COUNT(*)               FROM payroll.EmployeeSalaryComponent             UNION ALL
SELECT 'payroll.SalaryRevision',                                 COUNT(*)               FROM payroll.SalaryRevision                      UNION ALL
SELECT 'payroll.BankMaster',                                     COUNT(*)               FROM payroll.BankMaster                          UNION ALL
SELECT 'payroll.EmployeeBankAccount',                            COUNT(*)               FROM payroll.EmployeeBankAccount                 UNION ALL
SELECT 'payroll.PayrollDisbursement',                            COUNT(*)               FROM payroll.PayrollDisbursement                 UNION ALL
SELECT 'payroll.PayrollDisbursementTransaction',                 COUNT(*)               FROM payroll.PayrollDisbursementTransaction      UNION ALL
SELECT 'payroll.PayrollAttendanceSummary',                       COUNT(*)               FROM payroll.PayrollAttendanceSummary            UNION ALL
SELECT 'payroll.TaxRegime',                                      COUNT(*)               FROM payroll.TaxRegime                           UNION ALL
SELECT 'payroll.TaxSlab',                                        COUNT(*)               FROM payroll.TaxSlab                             UNION ALL
SELECT 'payroll.EmployeeTaxDeclaration',                         COUNT(*)               FROM payroll.EmployeeTaxDeclaration              UNION ALL
SELECT 'payroll.TaxDeclarationItem',                             COUNT(*)               FROM payroll.TaxDeclarationItem                  UNION ALL
SELECT 'payroll.TaxDeclarationProof',                            COUNT(*)               FROM payroll.TaxDeclarationProof                 UNION ALL
SELECT 'payroll.EmployeeTaxDeduction',                           COUNT(*)               FROM payroll.EmployeeTaxDeduction                UNION ALL
SELECT 'payroll.TaxDeductionBreakdown',                          COUNT(*)               FROM payroll.TaxDeductionBreakdown;

COMMIT TRANSACTION;
PRINT 'Payroll seed transaction committed successfully.';

-- =============================================================================================================
-- END OF SCRIPT — ENTERPRISE HRMS PAYROLL SCHEMA + SEED DATA
-- =============================================================================================================