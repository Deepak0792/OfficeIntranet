IF NOT EXISTS (SELECT 1 FROM expense.ExpenseCategory WHERE CategoryCode = 'TRAVEL')
BEGIN
    INSERT INTO expense.ExpenseCategory (CategoryCode, CategoryName, Description)
    VALUES
    ('TRAVEL',          'Travel',          'Business travel: flights, trains, cabs, fuel, parking.'),
    ('FOOD',            'Food',            'Client meals, business dinners, daily allowances.'),
    ('ACCOMMODATION',   'Accommodation',   'Hotel stays, lodging during business travel.'),
    ('INTERNET',        'Internet',        'WFH internet reimbursement.'),
    ('MOBILE',          'Mobile',          'Mobile phone bills, SIM card costs.'),
    ('LAPTOP',          'Laptop',          'Laptop purchases and repairs (asset reimbursement).'),
    ('OFFICE_SUPPLIES', 'Office Supplies', 'Stationery, printer supplies, misc office items.'),
    ('MEDICAL',         'Medical',         'Medical reimbursements, health checkups, insurance.'),
    ('TRAINING',        'Training',        'Courses, certifications, conference fees.'),
    ('RELOCATION',      'Relocation',      'Moving expenses, relocation allowances.');
END
GO

PRINT 'Expense core data inserted successfully.';
GO