-- STATUS GROUPS SEEDED INTO shared.StatusLookup:
--   EMPLOYMENT_TYPE         - FULL_TIME | PART_TIME | CONTRACT | INTERIM | INTERN
--   CONTACT_TYPE            - WORK_PHONE | PERSONAL_EMAIL | SLACK | SKYPE | TEAMS
--   LEAVE_REQUEST_STATUS    - PENDING | APPROVED | REJECTED | CANCELLED
--   ATTENDANCE_STATUS       - PRESENT | ABSENT | ON_LEAVE | WORK_FROM_HOME | LATE
--   SHIFT_SWAP_STATUS       - PENDING | APPROVED | REJECTED | CANCELLED
--   ATTENDANCE_REGULARIZATION_STATUS - PENDING | APPROVED | REJECTED
--   HELPDESK_TICKET_STATUS  - OPEN | IN_PROGRESS | PENDING_CUSTOMER | RESOLVED | CLOSED | CANCELLED
--   HELPDESK_TICKET_PRIORITY- CRITICAL | HIGH | MEDIUM | LOW
--   HELPDESK_ASSET_STATUS   - AVAILABLE | IN_USE | UNDER_REPAIR | RETIRED | LOST
--   HELPDESK_LICENSE_TYPE   - PERPETUAL | SUBSCRIPTION | FREE | OPEN_SOURCE
--   ONBOARDING_TASK_STATUS  - PENDING | IN_PROGRESS | COMPLETED | WAIVED
--   DOC_VERIFY_STATUS       - PENDING | SUBMITTED | UNDER_REVIEW | VERIFIED | REJECTED | RESUBMITTED | EXPIRED | WAIVED
--   BGV_STATUS              - PENDING | IN_PROGRESS | COMPLETED | DISCREPANCY_FOUND | FAILED | WAIVED
--   BGV_RESULT               - CLEAR | DISCREPANCY | UNABLE_TO_VERIFY | FAILED
--   BGV_CHECK_TYPE           - CRIMINAL | EMPLOYMENT_HISTORY | EDUCATION | IDENTITY | CREDIT | REFERENCE | DRUG_TEST | ADDRESS
--   ONBOARDING_PHASE         - PRE_ONBOARDING | POST_ONBOARDING
--   EXIT_TYPE                - RESIGNATION | TERMINATION | RETIREMENT | CONTRACT_END | ABSCONDING
--   EXIT_INTERVIEW_STATUS    - PENDING | SCHEDULED | COMPLETED | SKIPPED
--   CLEARANCE_STATUS         - PENDING | IN_PROGRESS | COMPLETED
--   FINAL_SETTLEMENT_STATUS  - PENDING | PROCESSED | PAID
--   CLEARANCE_ITEM_STATUS    - PENDING | COMPLETED | WAIVED
--   POLICY_STATUS            - DRAFT | ACTIVE | ARCHIVED | SUPERSEDED
--   POLICY_ACK_STATUS        - PENDING | ACKNOWLEDGED | OVERDUE
--   SALARY_SLIP_STATUS       - DRAFT | PUBLISHED | DOWNLOADED | REVISED
--   PERF_CYCLE_TYPE          - ANNUAL | BI_ANNUAL | QUARTERLY | PROBATION
--   PERF_CYCLE_STATUS        - UPCOMING | GOAL_SETTING | IN_REVIEW | COMPLETED | ARCHIVED
--   PERF_REVIEW_STATUS       - PENDING | SELF_SUBMITTED | MANAGER_REVIEW | HRBP_REVIEW | COMPLETED | ACKNOWLEDGED
--   GOAL_STATUS              - DRAFT | SUBMITTED | APPROVED | IN_PROGRESS | COMPLETED | CANCELLED
--   GOAL_KR_STATUS           - PENDING | ON_TRACK | AT_RISK | ACHIEVED | NOT_ACHIEVED
--   TRAINING_MODE            - ONLINE | OFFLINE | HYBRID | SELF_PACED
--   TRAINING_BATCH_STATUS    - UPCOMING | ONGOING | COMPLETED | CANCELLED
--   TRAINING_RECORD_STATUS   - ENROLLED | IN_PROGRESS | COMPLETED | FAILED | DROPPED | ABSENT
--   RECOMMENDATION_STATUS    - STRONG_YES | YES | MAYBE | NO | STRONG_NO
--   INTERVIEW_STATUS         - SCHEDULED | COMPLETED | CANCELLED | RESCHEDULED | NO_SHOW
--   JOB_POSTING_STATUS       - DRAFT | OPEN | ON_HOLD | CLOSED | CANCELLED
--   APPLICATION_STATUS       - APPLIED | SCREENING | INTERVIEW | OFFER | NEGOTIATION | HIRED | REJECTED | WITHDRAWN
--   OFFER_STATUS             - ISSUED | ACCEPTED | REJECTED | EXPIRED | REVOKED
--   NEGOTIATION_STATUS       - IN_PROGRESS | ACCEPTED | REJECTED | COUNTERED | WITHDRAWN
--   DECLARATION_STATUS       - DRAFT | SUBMITTED | VERIFIED | REJECTED
--   PROOF_REVIEW_STATUS      - PENDING | APPROVED | REJECTED
--   DISBURSEMENT_STATUS      - DRAFT | APPROVED | PROCESSING | COMPLETED | FAILED | CANCELLED
--   TRANSACTION_STATUS       - PENDING | INITIATED | SUCCESS | FAILED | REVERSED
--   SALARY_REVISION_TYPE     - ANNUAL_INCREMENT | PROMOTION | CORRECTION | JOINING | MARKET_CORRECTION | OTHER
--   BANK_ACCOUNT_TYPE        - SAVINGS | CURRENT | SALARY
--   CALC_TYPE                - FIXED | PERCENTAGE | FORMULA
--   DEDUCTION_CATEGORY       - EXEMPTION | DEDUCTION | TAX | CESS | REBATE

-- JUST FOR REFERENCE

-- ============================================================
-- LOOKUP DEFINITIONS : COUNTRY / STATE / CITY
-- ============================================================

-- COUNTRY LOOKUP
IF NOT EXISTS (
    SELECT 1
    FROM shared.LookupDefinition
    WHERE LookupCode = 'COUNTRY'
)
BEGIN

    INSERT INTO shared.LookupDefinition
    (
        LookupDefinitionId,
        LookupCode,
        LookupName,
        LookupSourceType,
        SourceObjectName,
        SqlStatement,
        ValueField,
        TextField,
        SupportsParentFilter,
        IsSystem,
        IsActive
    )
    VALUES
    (
        '59B9433E-F36B-1410-8804-001812045BC4',
        'COUNTRY',
        'Country Lookup',
        'STATIC_SQL',
        'time.Country',

        '
        SELECT
            CAST(Id AS NVARCHAR(100)) AS Id,
			''uniqueidentifier'' AS IdType,
            CountryName AS Name,
            0 AS DisplayOrder
        FROM time.Country
        ORDER BY CountryName
        ',
        'Id',
        'Name',
        0,
        1,
        1
    );

END
GO


-- ============================================================
-- STATE LOOKUP
-- Parent = COUNTRY
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM shared.LookupDefinition
    WHERE LookupCode = 'STATE'
)
BEGIN

    INSERT INTO shared.LookupDefinition
    (
        LookupDefinitionId,
        LookupCode,
        LookupName,
        LookupSourceType,
        SourceObjectName,
        ParentLookupDefinitionId,
        SqlStatement,
        ValueField,
        TextField,
        ParentValueField,
        SupportsParentFilter,
        IsSystem,
        IsActive
    )
    VALUES
    (
        '59B9433E-F36B-1410-8804-001812045BC5',
        'STATE',
        'State Lookup',
        'STATIC_SQL',
        'time.Region',

        (
            SELECT LookupDefinitionId
            FROM shared.LookupDefinition
            WHERE LookupCode = 'COUNTRY'
        ),

        '
        SELECT
            CAST(r.Id AS NVARCHAR(100)) AS Id,
			''uniqueidentifier'' AS IdType,
            r.RegionName AS Name,
            0 AS DisplayOrder
        FROM time.Region r
        WHERE r.RegionType = ''State''
          AND (
                @ParentId IS NULL
                OR r.CountryId = CAST(@ParentId AS UNIQUEIDENTIFIER)
              )
        ORDER BY r.RegionName
        ',
        'Id',
        'Name',
        'ParentId',
        1,
        1,
        1
    );

END
GO


-- ============================================================
-- CITY LOOKUP
-- Parent = STATE
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM shared.LookupDefinition
    WHERE LookupCode = 'CITY'
)
BEGIN

    INSERT INTO shared.LookupDefinition
    (
        LookupDefinitionId,
        LookupCode,
        LookupName,
        LookupSourceType,
        SourceObjectName,
        ParentLookupDefinitionId,
        SqlStatement,
        ValueField,
        TextField,
        ParentValueField,
        SupportsParentFilter,
        IsSystem,
        IsActive
    )
    VALUES
    (
        '59B9433E-F36B-1410-8804-001812045BC7',
        'CITY',
        'City Lookup',
        'STATIC_SQL',
        'time.Region',

        (
            SELECT LookupDefinitionId
            FROM shared.LookupDefinition
            WHERE LookupCode = 'STATE'
        ),

        '
        SELECT
            CAST(r.Id AS NVARCHAR(100)) AS Id,
			''uniqueidentifier'' AS IdType,
            r.RegionName AS Name,
            0 AS DisplayOrder
        FROM time.Region r
        WHERE r.RegionType = ''City''
          AND (
                @ParentId IS NULL
                OR r.ParentRegionId = CAST(@ParentId AS UNIQUEIDENTIFIER)
              )
        ORDER BY r.RegionName
        ',
        'Id',
        'Name',
        'ParentId',
        1,
        1,
        1
    );
END
GO

PRINT 'Shared schema StatusLookup seed data inserted successfully.';
GO
-- ============================================================
-- SEED DATA: expense.ExpenseCategory
-- Id is UNIQUEIDENTIFIER with no DEFAULT, so NEWID() is supplied explicitly.
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM expense.ExpenseCategory WHERE CategoryCode = 'TRAVEL')
BEGIN
    INSERT INTO expense.ExpenseCategory (Id, CategoryCode, CategoryName, Description)
    VALUES
    (NEWID(), 'TRAVEL',          'Travel',          'Business travel: flights, trains, cabs, fuel, parking.'),
    (NEWID(), 'FOOD',            'Food',             'Client meals, business dinners, daily allowances.'),
    (NEWID(), 'ACCOMMODATION',   'Accommodation',    'Hotel stays, lodging during business travel.'),
    (NEWID(), 'INTERNET',        'Internet',         'WFH internet reimbursement.'),
    (NEWID(), 'MOBILE',          'Mobile',           'Mobile phone bills, SIM card costs.'),
    (NEWID(), 'LAPTOP',          'Laptop',           'Laptop purchases and repairs (asset reimbursement).'),
    (NEWID(), 'OFFICE_SUPPLIES', 'Office Supplies',  'Stationery, printer supplies, misc office items.'),
    (NEWID(), 'MEDICAL',         'Medical',          'Medical reimbursements, health checkups, insurance.'),
    (NEWID(), 'TRAINING',        'Training',         'Courses, certifications, conference fees.'),
    (NEWID(), 'RELOCATION',      'Relocation',       'Moving expenses, relocation allowances.');
END
GO

PRINT 'Expense core data inserted successfully.';
GO
