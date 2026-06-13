import React, { useContext, useState, useRef, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { 
  Search, Bell, HelpCircle, User, LogOut, Settings, 
  Menu, X, ChevronDown, Plus, ShieldAlert, FileText, 
  Calendar, CreditCard, Laptop 
} from 'lucide-react';
import { AppContext } from '../context/AppContext';

export default function Header() {
  const { 
    searchQuery, setSearchQuery, 
    notifications, markNotificationsAsRead,
    theme, toggleTheme,
    sidebarOpen, setSidebarOpen,
    submitLeaveRequest, submitExpense, bookMeetingRoom, raiseITTicket
  } = useContext(AppContext);

  const navigate = useRef(useNavigate());

  // Dropdown states
  const [showNotifications, setShowNotifications] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [showQuickActions, setShowQuickActions] = useState(false);
  const [showHelp, setShowHelp] = useState(false);

  // Modal states for Quick Actions
  const [activeModal, setActiveModal] = useState(null); // 'leave', 'expense', 'room', 'ticket'

  // Form states
  const [leaveForm, setLeaveForm] = useState({ type: 'Annual', days: 1, startDate: '', endDate: '' });
  const [expenseForm, setExpenseForm] = useState({ category: 'Travel', amount: '', description: '' });
  const [roomForm, setRoomForm] = useState({ room: 'Conference Room A', date: '', startTime: '', endTime: '', purpose: '' });
  const [ticketForm, setTicketForm] = useState({ title: '', severity: 'Medium', description: '' });

  const notificationDropdownRef = useRef(null);
  const profileDropdownRef = useRef(null);
  const quickActionsDropdownRef = useRef(null);

  // Close dropdowns on outside click
  useEffect(() => {
    function handleClickOutside(event) {
      if (notificationDropdownRef.current && !notificationDropdownRef.current.contains(event.target)) {
        setShowNotifications(false);
      }
      if (profileDropdownRef.current && !profileDropdownRef.current.contains(event.target)) {
        setShowProfile(false);
      }
      if (quickActionsDropdownRef.current && !quickActionsDropdownRef.current.contains(event.target)) {
        setShowQuickActions(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const unreadCount = notifications.filter(n => !n.read).length;

  const handleNotificationClick = () => {
    setShowNotifications(!showNotifications);
    markNotificationsAsRead();
  };

  const handleQuickActionSubmit = (e, type) => {
    e.preventDefault();
    if (type === 'leave') {
      submitLeaveRequest(leaveForm);
      setLeaveForm({ type: 'Annual', days: 1, startDate: '', endDate: '' });
    } else if (type === 'expense') {
      submitExpense(expenseForm);
      setExpenseForm({ category: 'Travel', amount: '', description: '' });
    } else if (type === 'room') {
      bookMeetingRoom(roomForm);
      setRoomForm({ room: 'Conference Room A', date: '', startTime: '', endTime: '', purpose: '' });
    } else if (type === 'ticket') {
      raiseITTicket(ticketForm);
      setTicketForm({ title: '', severity: 'Medium', description: '' });
    }
    setActiveModal(null);
    setShowQuickActions(false);
  };

  return (
    <>
      <header className="header">
        <div className="header-left">
          <button 
            className="icon-btn menu-toggle" 
            style={{ display: window.innerWidth <= 1024 ? 'flex' : 'none' }}
            onClick={() => setSidebarOpen(!sidebarOpen)}
          >
            {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
          
          <Link to="/dashboard" className="logo">
            <Plus size={24} style={{ transform: 'rotate(45deg)' }} />
            <span>SdxIntranet</span>
          </Link>

          <div className="search-bar-container">
            <Search className="search-icon" size={18} />
            <input 
              type="text" 
              className="input-field" 
              placeholder="Global search (employees, tasks...)" 
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value);
                // If they are not on directory or dashboard, redirect to dashboard or tasks to see filtered search results
                if (!window.location.pathname.includes('/employees') && 
                    !window.location.pathname.includes('/tasks') &&
                    !window.location.pathname.includes('/documents') &&
                    !window.location.pathname.includes('/dashboard')) {
                  navigate.current('/dashboard');
                }
              }}
            />
          </div>
        </div>

        <div className="header-right">
          {/* Quick Actions */}
          <div className="profile-menu" ref={quickActionsDropdownRef}>
            <button className="btn btn-primary btn-mini" onClick={() => setShowQuickActions(!showQuickActions)}>
              <Plus size={16} />
              <span>Quick Action</span>
              <ChevronDown size={14} />
            </button>
            {showQuickActions && (
              <div className="dropdown-menu">
                <div className="dropdown-header">Quick Request Forms</div>
                <button className="dropdown-item" onClick={() => setActiveModal('leave')}>
                  <Calendar size={16} className="doc-icon" />
                  <span>Apply Leave</span>
                </button>
                <button className="dropdown-item" onClick={() => setActiveModal('expense')}>
                  <CreditCard size={16} className="doc-icon" />
                  <span>Submit Expense</span>
                </button>
                <button className="dropdown-item" onClick={() => setActiveModal('room')}>
                  <FileText size={16} className="doc-icon" />
                  <span>Book Meeting Room</span>
                </button>
                <button className="dropdown-item" onClick={() => setActiveModal('ticket')}>
                  <Laptop size={16} className="doc-icon" />
                  <span>Raise IT Ticket</span>
                </button>
              </div>
            )}
          </div>

          {/* Help Center */}
          <button className="icon-btn" onClick={() => setShowHelp(!showHelp)}>
            <HelpCircle size={20} />
            {showHelp && (
              <div className="dropdown-menu" style={{ width: '280px', padding: '16px' }}>
                <div style={{ fontWeight: 600, fontSize: '0.9rem', marginBottom: '8px' }}>Help Center & FAQ</div>
                <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)', lineHeight: '1.4' }}>
                  <p style={{ marginBottom: '6px' }}><strong>Global Search:</strong> Instantly filter lists in Employees, Tasks, and Documents tab.</p>
                  <p style={{ marginBottom: '6px' }}><strong>Customization:</strong> Go to settings page or dashboard gear icon to rearrange / hide dashboard sections.</p>
                  <p>For urgent IT assistance, submit a ticket via the Quick Action panel.</p>
                </div>
              </div>
            )}
          </button>

          {/* Notification Center */}
          <div className="profile-menu" ref={notificationDropdownRef}>
            <button className="icon-btn" onClick={handleNotificationClick}>
              <Bell size={20} />
              {unreadCount > 0 && <span className="badge">{unreadCount}</span>}
            </button>
            {showNotifications && (
              <div className="dropdown-menu" style={{ width: '300px' }}>
                <div className="dropdown-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span>Notifications</span>
                  {unreadCount > 0 && <span style={{ fontSize: '0.75rem', color: 'var(--primary-blue)', cursor: 'pointer' }} onClick={markNotificationsAsRead}>Mark read</span>}
                </div>
                <div style={{ maxHeight: '240px', overflowY: 'auto' }}>
                  {notifications.length === 0 ? (
                    <div style={{ padding: '16px', textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-muted)' }}>No notifications</div>
                  ) : (
                    notifications.map(n => (
                      <div 
                        key={n.id} 
                        style={{ 
                          padding: '10px 14px', 
                          borderBottom: '1px solid var(--border-color)',
                          fontSize: '0.8rem',
                          background: n.read ? 'transparent' : 'var(--primary-blue-light)',
                          color: 'var(--text-main)'
                        }}
                      >
                        <div style={{ fontWeight: n.read ? 400 : 600 }}>{n.text}</div>
                        <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: '4px' }}>{n.time}</div>
                      </div>
                    ))
                  )}
                </div>
              </div>
            )}
          </div>

          {/* Theme Toggle */}
          <button className="icon-btn" onClick={toggleTheme}>
            {theme === 'light' ? (
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
            ) : (
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
            )}
          </button>

          {/* User Profile */}
          <div className="profile-menu" ref={profileDropdownRef}>
            <button className="profile-trigger" onClick={() => setShowProfile(!showProfile)}>
              <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150" alt="Profile" />
              <div className="profile-info">
                <span className="profile-name">Sarah Connor</span>
                <span className="profile-role">Sr. Executive Admin</span>
              </div>
              <ChevronDown size={16} style={{ color: 'var(--text-muted)' }} />
            </button>
            {showProfile && (
              <div className="dropdown-menu">
                <div className="dropdown-header">Logged in as Sarah</div>
                <button className="dropdown-item" onClick={() => { navigate.current('/settings'); setShowProfile(false); }}>
                  <Settings size={16} />
                  <span>My Settings</span>
                </button>
                <div className="dropdown-divider"></div>
                <button className="dropdown-item" onClick={() => alert('Signing out (Simulated)')}>
                  <LogOut size={16} />
                  <span>Sign Out</span>
                </button>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Quick Action Forms Modals */}
      {activeModal && (
        <div className="customizer-overlay">
          <div className="customizer-modal">
            <div className="widget-header">
              <div className="widget-title">
                {activeModal === 'leave' && 'Apply for Leave'}
                {activeModal === 'expense' && 'Submit Expense Claim'}
                {activeModal === 'room' && 'Book a Meeting Room'}
                {activeModal === 'ticket' && 'Raise an IT Support Ticket'}
              </div>
              <button className="icon-btn" onClick={() => setActiveModal(null)}><X size={18} /></button>
            </div>

            {/* Leave Form */}
            {activeModal === 'leave' && (
              <form onSubmit={(e) => handleQuickActionSubmit(e, 'leave')}>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Leave Type</label>
                    <select className="input-field" value={leaveForm.type} onChange={e => setLeaveForm({...leaveForm, type: e.target.value})}>
                      <option value="Annual">Annual Leave</option>
                      <option value="Sick">Sick Leave</option>
                      <option value="Maternity/Paternity">Maternity/Paternity</option>
                      <option value="Unpaid">Unpaid Leave</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Total Days</label>
                    <input type="number" min="1" className="input-field" value={leaveForm.days} onChange={e => setLeaveForm({...leaveForm, days: parseInt(e.target.value) || 1})} />
                  </div>
                  <div className="form-group">
                    <label>Start Date</label>
                    <input type="date" required className="input-field" value={leaveForm.startDate} onChange={e => setLeaveForm({...leaveForm, startDate: e.target.value})} />
                  </div>
                  <div className="form-group">
                    <label>End Date</label>
                    <input type="date" required className="input-field" value={leaveForm.endDate} onChange={e => setLeaveForm({...leaveForm, endDate: e.target.value})} />
                  </div>
                </div>
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '20px' }}>
                  <button type="button" className="btn btn-ghost" onClick={() => setActiveModal(null)}>Cancel</button>
                  <button type="submit" className="btn btn-primary">Submit Request</button>
                </div>
              </form>
            )}

            {/* Expense Form */}
            {activeModal === 'expense' && (
              <form onSubmit={(e) => handleQuickActionSubmit(e, 'expense')}>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Category</label>
                    <select className="input-field" value={expenseForm.category} onChange={e => setExpenseForm({...expenseForm, category: e.target.value})}>
                      <option value="Travel">Travel & Lodging</option>
                      <option value="Meals">Business Meals</option>
                      <option value="Equipment">Office Equipment & IT</option>
                      <option value="Training">Training & Conferences</option>
                      <option value="Others">Others</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Amount ($)</label>
                    <input type="number" step="0.01" min="1" required className="input-field" placeholder="0.00" value={expenseForm.amount} onChange={e => setExpenseForm({...expenseForm, amount: e.target.value})} />
                  </div>
                  <div className="form-group" style={{ gridColumn: 'span 2' }}>
                    <label>Description / Justification</label>
                    <textarea required className="input-field" rows="3" placeholder="Explain the expense details..." value={expenseForm.description} onChange={e => setExpenseForm({...expenseForm, description: e.target.value})}></textarea>
                  </div>
                </div>
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '20px' }}>
                  <button type="button" className="btn btn-ghost" onClick={() => setActiveModal(null)}>Cancel</button>
                  <button type="submit" className="btn btn-primary">Submit Claim</button>
                </div>
              </form>
            )}

            {/* Room Form */}
            {activeModal === 'room' && (
              <form onSubmit={(e) => handleQuickActionSubmit(e, 'room')}>
                <div className="form-grid">
                  <div className="form-group">
                    <label>Select Room</label>
                    <select className="input-field" value={roomForm.room} onChange={e => setRoomForm({...roomForm, room: e.target.value})}>
                      <option value="Conference Room A">Conference Room A (4th Floor)</option>
                      <option value="Boardroom Omega">Boardroom Omega (5th Floor)</option>
                      <option value="Huddle Space Blue">Huddle Space Blue (2nd Floor)</option>
                      <option value="Training Center Alpha">Training Center Alpha (1st Floor)</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Date</label>
                    <input type="date" required className="input-field" value={roomForm.date} onChange={e => setRoomForm({...roomForm, date: e.target.value})} />
                  </div>
                  <div className="form-group">
                    <label>Start Time</label>
                    <input type="time" required className="input-field" value={roomForm.startTime} onChange={e => setRoomForm({...roomForm, startTime: e.target.value})} />
                  </div>
                  <div className="form-group">
                    <label>End Time</label>
                    <input type="time" required className="input-field" value={roomForm.endTime} onChange={e => setRoomForm({...roomForm, endTime: e.target.value})} />
                  </div>
                  <div className="form-group" style={{ gridColumn: 'span 2' }}>
                    <label>Meeting Purpose</label>
                    <input type="text" required className="input-field" placeholder="e.g. Core Standup" value={roomForm.purpose} onChange={e => setRoomForm({...roomForm, purpose: e.target.value})} />
                  </div>
                </div>
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '20px' }}>
                  <button type="button" className="btn btn-ghost" onClick={() => setActiveModal(null)}>Cancel</button>
                  <button type="submit" className="btn btn-primary">Book Room</button>
                </div>
              </form>
            )}

            {/* IT Ticket Form */}
            {activeModal === 'ticket' && (
              <form onSubmit={(e) => handleQuickActionSubmit(e, 'ticket')}>
                <div className="form-grid">
                  <div className="form-group" style={{ gridColumn: 'span 2' }}>
                    <label>Issue Title</label>
                    <input type="text" required className="input-field" placeholder="Brief summary of the issue" value={ticketForm.title} onChange={e => setTicketForm({...ticketForm, title: e.target.value})} />
                  </div>
                  <div className="form-group">
                    <label>Severity</label>
                    <select className="input-field" value={ticketForm.severity} onChange={e => setTicketForm({...ticketForm, severity: e.target.value})}>
                      <option value="Low">Low - General Question / Trivial</option>
                      <option value="Medium">Medium - Affects normal operations</option>
                      <option value="High">High - Blocking critical work</option>
                      <option value="Urgent">Urgent - System wide outage</option>
                    </select>
                  </div>
                  <div className="form-group" style={{ gridColumn: 'span 2' }}>
                    <label>Detailed Description</label>
                    <textarea required className="input-field" rows="4" placeholder="Provide system details, error codes or logs..." value={ticketForm.description} onChange={e => setTicketForm({...ticketForm, description: e.target.value})}></textarea>
                  </div>
                </div>
                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '20px' }}>
                  <button type="button" className="btn btn-ghost" onClick={() => setActiveModal(null)}>Cancel</button>
                  <button type="submit" className="btn btn-primary">Raise Support Ticket</button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </>
  );
}
