import React, { createContext, useState, useEffect } from 'react';

export const AppContext = createContext();

export const AppProvider = ({ children }) => {
  // Theme State
  const [theme, setTheme] = useState('light');

  // Search States
  const [searchQuery, setSearchQuery] = useState('');
  const [sidebarQuery, setSidebarQuery] = useState('');

  // Sidebar Open State (for Mobile View)
  const [sidebarOpen, setSidebarOpen] = useState(false);

  // Notifications
  const [notifications, setNotifications] = useState([
    { id: 1, text: 'Sarah Connor submitted a Leave Request', time: '10 mins ago', read: false },
    { id: 2, text: 'Vapor project milestone completed', time: '1 hour ago', read: false },
    { id: 3, text: 'IT System Maintenance scheduled for Sunday', time: '4 hours ago', read: true },
    { id: 4, text: 'New HR policy document uploaded', time: '1 day ago', read: true }
  ]);

  // Dashboard Widget Configurations (Customization Options)
  const [widgets, setWidgets] = useState([
    { id: 'welcome', name: 'Welcome Banner', visible: true, order: 1 },
    { id: 'stats', name: 'Statistics Cards', visible: true, order: 2 },
    { id: 'tasks', name: 'My Tasks Widget', visible: true, order: 3 },
    { id: 'approvals', name: 'Approvals Center', visible: true, order: 4 },
    { id: 'announcements', name: 'Company Announcements', visible: true, order: 5 },
    { id: 'events', name: 'Upcoming Events', visible: true, order: 6 },
    { id: 'attendance', name: 'Attendance Summary', visible: true, order: 7 },
    { id: 'analytics', name: 'Performance Analytics', visible: true, order: 8 },
    { id: 'directory', name: 'Employee Directory Preview', visible: true, order: 9 },
    { id: 'documents', name: 'Recent Documents', visible: true, order: 10 },
    { id: 'quickaccess', name: 'Quick Access Panel', visible: true, order: 11 },
    { id: 'timeline', name: 'Activity Timeline', visible: true, order: 12 },
  ]);

  // Attendance Clock-in State
  const [isClockedIn, setIsClockedIn] = useState(false);
  const [clockInTime, setClockInTime] = useState(null);
  const [workHours, setWorkHours] = useState('00:00:00');
  const [attendanceLogs, setAttendanceLogs] = useState([
    { date: '2026-06-12', clockIn: '09:02 AM', clockOut: '06:05 PM', status: 'Present' },
    { date: '2026-06-11', clockIn: '08:58 AM', clockOut: '05:45 PM', status: 'Present' },
    { date: '2026-06-10', clockIn: '09:15 AM', clockOut: '06:00 PM', status: 'Present' },
    { date: '2026-06-09', clockIn: '—', clockOut: '—', status: 'Sick Leave' },
    { date: '2026-06-08', clockIn: '08:55 AM', clockOut: '05:30 PM', status: 'Present' },
  ]);

  // Mock Employees Database
  const [employees, setEmployees] = useState([
    { id: 'emp-101', name: 'Alice Smith', role: 'Engineering Lead', dept: 'Engineering', email: 'alice.smith@company.com', phone: '+1 (555) 019-2834', location: 'San Francisco, CA', photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', bio: 'Alice is a veteran software engineer with 8+ years of experience building scalable applications. She leads the Core Platform group.', projects: ['Vapor Web UI', 'SdxCore Core Gateway'], hireDate: '2021-04-12' },
    { id: 'emp-102', name: 'Bob Johnson', role: 'Product Manager', dept: 'Product', email: 'bob.johnson@company.com', phone: '+1 (555) 014-9988', location: 'Seattle, WA', photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', bio: 'Bob defines product roadmaps and works closely with engineering and marketing teams.', projects: ['Vapor Roadmap', 'User Onboarding v2'], hireDate: '2022-08-01' },
    { id: 'emp-103', name: 'Clara Oswald', role: 'UI/UX Designer', dept: 'Design', email: 'clara.oswald@company.com', phone: '+1 (555) 017-4567', location: 'San Francisco, CA', photo: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150', bio: 'Clara is passionate about creating clean, beautiful and user-centered design experiences.', projects: ['Brand Refresh', 'Design System System'], hireDate: '2023-11-15' },
    { id: 'emp-104', name: 'Daniel Craig', role: 'DevOps Engineer', dept: 'Engineering', email: 'daniel.craig@company.com', phone: '+1 (555) 012-7890', location: 'Austin, TX', photo: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', bio: 'Daniel manages infrastructure, pipelines, cloud hosting environments, and monitoring systems.', projects: ['Kubernetes Migration', 'Security Hardening'], hireDate: '2020-02-10' },
    { id: 'emp-105', name: 'Eva Green', role: 'HR Manager', dept: 'Human Resources', email: 'eva.green@company.com', phone: '+1 (555) 011-2233', location: 'New York, NY', photo: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', bio: 'Eva handles employee onboarding, benefits, training, policy creation, and culture.', projects: ['Summer Intern Program', 'Annual Review Flow'], hireDate: '2019-06-20' },
    { id: 'emp-106', name: 'Frank Miller', role: 'Financial Analyst', dept: 'Finance', email: 'frank.miller@company.com', phone: '+1 (555) 013-4455', location: 'Chicago, IL', photo: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150', bio: 'Frank reports on financial trends, budgets, resource planning, and compliance audits.', projects: ['Q3 Budget Planning', 'Cost Optimization Project'], hireDate: '2024-01-15' },
  ]);

  // Tasks Database
  const [tasks, setTasks] = useState([
    { id: 'task-1', title: 'Complete code review for Gateway API', assignee: 'Alice Smith', status: 'in-progress', priority: 'high', dueDate: '2026-06-15', progress: 75 },
    { id: 'task-2', title: 'Draft Product Roadmap spec for Q3', assignee: 'Bob Johnson', status: 'todo', priority: 'medium', dueDate: '2026-06-20', progress: 0 },
    { id: 'task-3', title: 'Design Glassmorphism dashboard mockup', assignee: 'Clara Oswald', status: 'review', priority: 'high', dueDate: '2026-06-14', progress: 90 },
    { id: 'task-4', title: 'Update Kubernetes cluster certificates', assignee: 'Daniel Craig', status: 'done', priority: 'high', dueDate: '2026-06-10', progress: 100 },
    { id: 'task-5', title: 'Conduct interviews for Senior React Dev', assignee: 'Eva Green', status: 'todo', priority: 'medium', dueDate: '2026-06-18', progress: 20 },
    { id: 'task-6', title: 'Finalize Q3 Budget estimates', assignee: 'Frank Miller', status: 'in-progress', priority: 'high', dueDate: '2026-06-16', progress: 40 },
    { id: 'task-7', title: 'Write documentation for deployment pipelines', assignee: 'Daniel Craig', status: 'todo', priority: 'low', dueDate: '2026-06-25', progress: 0 },
    { id: 'task-8', title: 'Verify client feedback on onboarding demo', assignee: 'Bob Johnson', status: 'done', priority: 'medium', dueDate: '2026-06-08', progress: 100 },
  ]);

  // Approvals Center
  const [approvals, setApprovals] = useState([
    { id: 'appr-1', requester: 'Alice Smith', type: 'leave', details: 'Annual Leave Request (3 days: June 18-20)', date: '2026-06-12', status: 'pending' },
    { id: 'appr-2', requester: 'Daniel Craig', type: 'expense', details: 'AWS Training Course reimbursement ($450.00)', date: '2026-06-11', status: 'pending' },
    { id: 'appr-3', requester: 'Clara Oswald', type: 'document', details: 'Creative Guidelines v2 Approval', date: '2026-06-12', status: 'pending' },
    { id: 'appr-4', requester: 'Frank Miller', type: 'purchase', details: 'Renewing Enterprise Adobe Suite ($2,400.00)', date: '2026-06-10', status: 'approved' },
    { id: 'appr-5', requester: 'Bob Johnson', type: 'expense', details: 'Client lunch expense ($85.50)', date: '2026-06-09', status: 'rejected' },
  ]);

  // Announcements
  const [announcements, setAnnouncements] = useState([
    { id: 'ann-1', title: 'Welcome New Executive Leadership', content: 'We are thrilled to welcome our new VP of Product Development. A town hall is scheduled for next Tuesday to introduce them and share our future plans.', date: '2026-06-12', author: 'HR Department', category: 'Corporate' },
    { id: 'ann-2', title: 'Upcoming Server Maintenance', content: 'Our main hosting servers will undergo scheduled updates on Sunday, June 14, from 2:00 AM to 5:00 AM EST. Expected downtime is 15 minutes.', date: '2026-06-11', author: 'IT Operations', category: 'IT Support' },
    { id: 'ann-3', title: 'Juneteenth Corporate Holiday Reminder', content: 'In observance of Juneteenth, our offices will be closed on Friday, June 19. Enjoy the extended weekend with family and friends!', date: '2026-06-10', author: 'HR Department', category: 'Holiday' },
    { id: 'ann-4', title: 'Employee Spotlight: Clara Oswald', content: 'This month, we celebrate Clara Oswald for her fantastic work in spearheading the new corporate design system guidelines.', date: '2026-06-08', author: 'HR Communications', category: 'Celebration' },
  ]);

  // Upcoming Events
  const [events, setEvents] = useState([
    { id: 'evt-1', title: 'Weekly Core Dev Standup', type: 'meeting', date: '2026-06-15', time: '10:00 AM - 10:30 AM', location: 'Meeting Room Alpha / Zoom' },
    { id: 'evt-2', title: 'Product Launch Q3 Sync', type: 'meeting', date: '2026-06-15', time: '02:00 PM - 03:00 PM', location: 'Zoom Link' },
    { id: 'evt-3', title: 'Juneteenth Holiday', type: 'holiday', date: '2026-06-19', time: 'All Day', location: 'Nationwide Offices' },
    { id: 'evt-4', title: 'React Performance Workshop', type: 'training', date: '2026-06-17', time: '01:00 PM - 03:00 PM', location: 'Training Lab C' },
    { id: 'evt-5', title: 'Clara Oswald Birthday Celebration', type: 'event', date: '2026-06-16', time: '04:00 PM - 04:30 PM', location: '4th Floor Breakroom' },
  ]);

  // Recent Documents
  const [documents, setDocuments] = useState([
    { id: 'doc-1', name: 'Employee_Handbook_2026.pdf', size: '2.4 MB', modified: '2026-06-10 11:30 AM', type: 'pdf', version: 'v1.4' },
    { id: 'doc-2', name: 'Corporate_Design_Guidelines.pdf', size: '15.8 MB', modified: '2026-06-12 04:15 PM', type: 'pdf', version: 'v2.0' },
    { id: 'doc-3', name: 'Q3_Financial_Forecast.xlsx', size: '840 KB', modified: '2026-06-11 09:45 AM', type: 'excel', version: 'v3.2' },
    { id: 'doc-4', name: 'Gateway_Architecture_Doc.docx', size: '1.2 MB', modified: '2026-06-08 02:20 PM', type: 'word', version: 'v1.1' },
    { id: 'doc-5', name: 'Summer_Internship_Plan.pdf', size: '4.1 MB', modified: '2026-06-12 10:00 AM', type: 'pdf', version: 'v1.0' },
  ]);

  // Timeline Activities
  const [activities, setActivities] = useState([
    { id: 'act-1', text: 'You clocked in today', time: '09:02 AM', type: 'attendance' },
    { id: 'act-2', text: 'Alice Smith requested 3 days of Annual Leave', time: '10:14 AM', type: 'approval' },
    { id: 'act-3', text: 'Daniel Craig completed the task "Update Kubernetes cluster certificates"', time: '11:30 AM', type: 'task' },
    { id: 'act-4', text: 'Clara Oswald updated file "Corporate_Design_Guidelines.pdf"', time: '04:15 PM', type: 'document' },
  ]);

  // Active theme application
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  // Work Hours Ticker
  useEffect(() => {
    let interval = null;
    if (isClockedIn && clockInTime) {
      interval = setInterval(() => {
        const diff = Date.now() - clockInTime;
        const totalSecs = Math.floor(diff / 1000);
        const hrs = String(Math.floor(totalSecs / 3600)).padStart(2, '0');
        const mins = String(Math.floor((totalSecs % 3600) / 60)).padStart(2, '0');
        const secs = String(totalSecs % 60).padStart(2, '0');
        setWorkHours(`${hrs}:${mins}:${secs}`);
      }, 1000);
    } else {
      setWorkHours('00:00:00');
    }
    return () => clearInterval(interval);
  }, [isClockedIn, clockInTime]);

  const toggleTheme = () => {
    setTheme(prev => (prev === 'light' ? 'dark' : 'light'));
  };

  // Clock-in / Clock-out Action
  const handleClockInOut = () => {
    if (!isClockedIn) {
      setIsClockedIn(true);
      const now = Date.now();
      setClockInTime(now);
      const timeStr = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      setActivities(prev => [
        { id: `act-${Date.now()}`, text: `You clocked in at ${timeStr}`, time: timeStr, type: 'attendance' },
        ...prev
      ]);
    } else {
      setIsClockedIn(false);
      setClockInTime(null);
      const timeStr = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      const dateStr = new Date().toISOString().split('T')[0];
      setActivities(prev => [
        { id: `act-${Date.now()}`, text: `You clocked out at ${timeStr} (Total Hours: ${workHours})`, time: timeStr, type: 'attendance' },
        ...prev
      ]);
      setAttendanceLogs(prev => [
        { date: dateStr, clockIn: '09:02 AM', clockOut: timeStr, status: 'Present' },
        ...prev.slice(1) // update today's log
      ]);
    }
  };

  // Complete/Update Task
  const updateTaskStatus = (taskId, newStatus) => {
    setTasks(prev =>
      prev.map(t => {
        if (t.id === taskId) {
          const prog = newStatus === 'done' ? 100 : newStatus === 'todo' ? 0 : t.progress;
          return { ...t, status: newStatus, progress: prog };
        }
        return t;
      })
    );
    // Add activity log
    const task = tasks.find(t => t.id === taskId);
    if (task) {
      setActivities(prev => [
        { id: `act-${Date.now()}`, text: `You updated task "${task.title}" to ${newStatus}`, time: 'Just now', type: 'task' },
        ...prev
      ]);
    }
  };

  // Approve/Reject request
  const handleApprovalDecision = (apprId, decision) => {
    setApprovals(prev =>
      prev.map(a => (a.id === apprId ? { ...a, status: decision } : a))
    );
    const item = approvals.find(a => a.id === apprId);
    if (item) {
      setNotifications(prev => [
        { id: Date.now(), text: `Approval request by ${item.requester} has been ${decision}`, time: 'Just now', read: false },
        ...prev
      ]);
      setActivities(prev => [
        { id: `act-${Date.now()}`, text: `You ${decision}ed ${item.requester}'s ${item.type} request`, time: 'Just now', type: 'approval' },
        ...prev
      ]);
    }
  };

  // Quick Action Forms Handlers
  const submitLeaveRequest = (req) => {
    const newAppr = {
      id: `appr-${Date.now()}`,
      requester: 'You (Current User)',
      type: 'leave',
      details: `${req.type} Leave Request (${req.days} days: ${req.startDate} to ${req.endDate})`,
      date: new Date().toISOString().split('T')[0],
      status: 'pending'
    };
    setApprovals(prev => [newAppr, ...prev]);
    setActivities(prev => [
      { id: `act-${Date.now()}`, text: `You submitted a leave request for ${req.days} days`, time: 'Just now', type: 'approval' },
      ...prev
    ]);
  };

  const submitExpense = (exp) => {
    const newAppr = {
      id: `appr-${Date.now()}`,
      requester: 'You (Current User)',
      type: 'expense',
      details: `${exp.category} reimbursement request ($${parseFloat(exp.amount).toFixed(2)}) - ${exp.description}`,
      date: new Date().toISOString().split('T')[0],
      status: 'pending'
    };
    setApprovals(prev => [newAppr, ...prev]);
    setActivities(prev => [
      { id: `act-${Date.now()}`, text: `You submitted a reimbursement request for $${exp.amount}`, time: 'Just now', type: 'approval' },
      ...prev
    ]);
  };

  const bookMeetingRoom = (booking) => {
    const newEvent = {
      id: `evt-${Date.now()}`,
      title: `${booking.purpose} (${booking.room})`,
      type: 'meeting',
      date: booking.date,
      time: `${booking.startTime} - ${booking.endTime}`,
      location: booking.room
    };
    setEvents(prev => [newEvent, ...prev]);
    setActivities(prev => [
      { id: `act-${Date.now()}`, text: `You booked ${booking.room} for ${booking.purpose}`, time: 'Just now', type: 'event' },
      ...prev
    ]);
  };

  const raiseITTicket = (ticket) => {
    setNotifications(prev => [
      { id: Date.now(), text: `IT Ticket #${Math.floor(Math.random() * 8000 + 1000)} created: ${ticket.title}`, time: 'Just now', read: false },
      ...prev
    ]);
    setActivities(prev => [
      { id: `act-${Date.now()}`, text: `You raised IT Ticket: "${ticket.title}"`, time: 'Just now', type: 'task' },
      ...prev
    ]);
  };

  const addDocument = (doc) => {
    const newDoc = {
      id: `doc-${Date.now()}`,
      name: doc.name,
      size: doc.size || '1.0 MB',
      modified: new Date().toLocaleString(),
      type: doc.type || 'pdf',
      version: 'v1.0'
    };
    setDocuments(prev => [newDoc, ...prev]);
    setActivities(prev => [
      { id: `act-${Date.now()}`, text: `You uploaded document "${doc.name}"`, time: 'Just now', type: 'document' },
      ...prev
    ]);
  };

  // Toggle widget visibility
  const toggleWidgetVisibility = (id) => {
    setWidgets(prev =>
      prev.map(w => (w.id === id ? { ...w, visible: !w.visible } : w))
    );
  };

  // Reorder widgets (moves widget to a different position)
  const moveWidget = (draggedIndex, targetIndex) => {
    setWidgets(prev => {
      const result = Array.from(prev);
      const [removed] = result.splice(draggedIndex, 1);
      result.splice(targetIndex, 0, removed);
      // update the order field
      return result.map((w, idx) => ({ ...w, order: idx + 1 }));
    });
  };

  const markNotificationsAsRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
  };

  return (
    <AppContext.Provider
      value={{
        theme,
        toggleTheme,
        searchQuery,
        setSearchQuery,
        sidebarQuery,
        setSidebarQuery,
        sidebarOpen,
        setSidebarOpen,
        notifications,
        markNotificationsAsRead,
        widgets,
        toggleWidgetVisibility,
        moveWidget,
        isClockedIn,
        clockInTime,
        workHours,
        attendanceLogs,
        handleClockInOut,
        employees,
        tasks,
        updateTaskStatus,
        approvals,
        handleApprovalDecision,
        announcements,
        events,
        documents,
        activities,
        submitLeaveRequest,
        submitExpense,
        bookMeetingRoom,
        raiseITTicket,
        addDocument,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};
