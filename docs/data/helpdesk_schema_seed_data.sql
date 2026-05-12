-- =============================================================================================================
-- STATUS LOOKUP SEEDING
-- Centralized statuses replacing module-specific status tables
-- =============================================================================================================

PRINT 'Seeding Helpdesk StatusLookup values...';
GO

INSERT INTO dbo.StatusLookup
(
    StatusCode,
    StatusGroup,
    Label,
    Description,
    DisplayOrder,
    IsTerminal
)
VALUES

-- =====================================================================================
-- TICKET STATUS
-- =====================================================================================
('OPEN',               'HELPDESK_TICKET_STATUS',      'Open',                 'Newly created ticket',                         1, 0),
('ASSIGNED',           'HELPDESK_TICKET_STATUS',      'Assigned',             'Ticket assigned to support staff',             2, 0),
('IN_PROGRESS',        'HELPDESK_TICKET_STATUS',      'In Progress',          'Work is in progress',                          3, 0),
('ON_HOLD',            'HELPDESK_TICKET_STATUS',      'On Hold',              'Waiting for dependency or requester',          4, 0),
('RESOLVED',           'HELPDESK_TICKET_STATUS',      'Resolved',             'Issue resolved awaiting closure',              5, 0),
('CLOSED',             'HELPDESK_TICKET_STATUS',      'Closed',               'Ticket fully closed',                          6, 1),
('CANCELLED',          'HELPDESK_TICKET_STATUS',      'Cancelled',            'Ticket cancelled',                             7, 1),
('REOPENED',           'HELPDESK_TICKET_STATUS',      'Reopened',             'Previously closed ticket reopened',            8, 0),

-- =====================================================================================
-- TICKET PRIORITY
-- =====================================================================================
('LOW',                'HELPDESK_TICKET_PRIORITY',    'Low',                  'Low impact issue',                             1, 0),
('MEDIUM',             'HELPDESK_TICKET_PRIORITY',    'Medium',               'Moderate impact issue',                        2, 0),
('HIGH',               'HELPDESK_TICKET_PRIORITY',    'High',                 'High impact issue',                            3, 0),
('CRITICAL',           'HELPDESK_TICKET_PRIORITY',    'Critical',             'Business critical issue',                      4, 0),

-- =====================================================================================
-- ASSET STATUS
-- =====================================================================================
('AVAILABLE',          'HELPDESK_ASSET_STATUS',       'Available',            'Available for assignment',                     1, 0),
('ASSIGNED',           'HELPDESK_ASSET_STATUS',       'Assigned',             'Assigned to employee',                         2, 0),
('IN_REPAIR',          'HELPDESK_ASSET_STATUS',       'In Repair',            'Under maintenance or repair',                  3, 0),
('DAMAGED',            'HELPDESK_ASSET_STATUS',       'Damaged',              'Damaged asset',                                4, 0),
('LOST',               'HELPDESK_ASSET_STATUS',       'Lost',                 'Lost asset',                                   5, 1),
('DISPOSED',           'HELPDESK_ASSET_STATUS',       'Disposed',             'Disposed or retired asset',                    6, 1),

-- =====================================================================================
-- SOFTWARE LICENSE TYPE
-- =====================================================================================
('PER_USER',           'HELPDESK_LICENSE_TYPE',       'Per User',             'License allocated per user',                   1, 0),
('PER_DEVICE',         'HELPDESK_LICENSE_TYPE',       'Per Device',           'License allocated per device',                 2, 0),
('SITE_LICENSE',       'HELPDESK_LICENSE_TYPE',       'Site License',         'Organization wide license',                    3, 0),
('SUBSCRIPTION',       'HELPDESK_LICENSE_TYPE',       'Subscription',         'Recurring subscription license',               4, 0),
('TRIAL',              'HELPDESK_LICENSE_TYPE',       'Trial',                'Trial or evaluation license',                  5, 0);
GO