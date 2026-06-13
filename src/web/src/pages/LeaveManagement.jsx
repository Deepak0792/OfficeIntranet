import React, { useContext, useState } from 'react';
import { AppContext } from '../context/AppContext';
import { Calendar, AlertCircle, CheckCircle } from 'lucide-react';

export default function LeaveManagement() {
  const { approvals, submitLeaveRequest } = useContext(AppContext);

  // Form states
  const [formData, setFormData] = useState({ type: 'Annual', days: 1, startDate: '', endDate: '', reason: '' });
  const [success, setSuccess] = useState(false);

  const balances = [
    { type: 'Annual Leave', remaining: 18, total: 25, color: 'var(--primary-blue)' },
    { type: 'Sick Leave', remaining: 4, total: 10, color: 'var(--success)' },
    { type: 'Personal Leave', remaining: 3, total: 5, color: 'var(--warning)' },
  ];

  const handleSubmit = (e) => {
    e.preventDefault();
    submitLeaveRequest(formData);
    setSuccess(true);
    setFormData({ type: 'Annual', days: 1, startDate: '', endDate: '', reason: '' });
    setTimeout(() => setSuccess(false), 4000);
  };

  const userLeaveRequests = approvals.filter(a => a.type === 'leave');

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Leave Management</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Check your remaining leaves and submit requests for approval.</p>
      </div>

      {/* Leave Balances Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '20px' }}>
        {balances.map((bal, idx) => {
          const pct = (bal.remaining / bal.total) * 100;
          return (
            <div key={idx} className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '0.9rem', fontWeight: 700 }}>{bal.type}</span>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{bal.remaining} / {bal.total} days</span>
              </div>
              <div className="progress-bar-container" style={{ width: '100%', height: '8px' }}>
                <div className="progress-bar-fill" style={{ width: `${pct}%`, backgroundColor: bal.color }}></div>
              </div>
              <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', alignSelf: 'flex-end' }}>{pct.toFixed(0)}% available</span>
            </div>
          );
        })}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
        {/* Request Form */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.15rem', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
            <Calendar size={18} className="doc-icon" />
            <span>Request Leave Form</span>
          </h3>

          {success && (
            <div style={{ 
              display: 'flex', 
              alignItems: 'center', 
              gap: '8px', 
              padding: '12px', 
              borderRadius: 'var(--radius-sm)', 
              backgroundColor: 'var(--success-light)', 
              color: 'var(--success)',
              fontSize: '0.85rem',
              fontWeight: 500,
              marginBottom: '16px'
            }}>
              <CheckCircle size={16} />
              <span>Leave request submitted successfully and is pending approval!</span>
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="form-grid">
              <div className="form-group">
                <label>Leave Type</label>
                <select 
                  className="input-field" 
                  value={formData.type} 
                  onChange={e => setFormData({ ...formData, type: e.target.value })}
                >
                  <option value="Annual">Annual Leave</option>
                  <option value="Sick">Sick Leave</option>
                  <option value="Personal">Personal Leave</option>
                  <option value="Maternity/Paternity">Maternity/Paternity</option>
                </select>
              </div>
              <div className="form-group">
                <label>Total Days</label>
                <input 
                  type="number" 
                  min="1" 
                  className="input-field" 
                  value={formData.days} 
                  onChange={e => setFormData({ ...formData, days: parseInt(e.target.value) || 1 })}
                />
              </div>
              <div className="form-group">
                <label>Start Date</label>
                <input 
                  type="date" 
                  required 
                  className="input-field" 
                  value={formData.startDate} 
                  onChange={e => setFormData({ ...formData, startDate: e.target.value })}
                />
              </div>
              <div className="form-group">
                <label>End Date</label>
                <input 
                  type="date" 
                  required 
                  className="input-field" 
                  value={formData.endDate} 
                  onChange={e => setFormData({ ...formData, endDate: e.target.value })}
                />
              </div>
              <div className="form-group" style={{ gridColumn: 'span 2' }}>
                <label>Reason / Comments</label>
                <textarea 
                  className="input-field" 
                  rows="3" 
                  placeholder="Provide supporting comments (optional)..." 
                  value={formData.reason} 
                  onChange={e => setFormData({ ...formData, reason: e.target.value })}
                ></textarea>
              </div>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '20px' }}>
              <button type="submit" className="btn btn-primary">Submit Leave Request</button>
            </div>
          </form>
        </div>

        {/* Requests History Log */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.15rem', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
            <AlertCircle size={18} className="doc-icon" />
            <span>Leave Requests History Log</span>
          </h3>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border-color)', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '10px' }}>Requester</th>
                  <th style={{ padding: '10px' }}>Details</th>
                  <th style={{ padding: '10px' }}>Submit Date</th>
                  <th style={{ padding: '10px' }}>Status</th>
                </tr>
              </thead>
              <tbody>
                {userLeaveRequests.length === 0 ? (
                  <tr>
                    <td colSpan="4" style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)' }}>
                      No leave history recorded.
                    </td>
                  </tr>
                ) : (
                  userLeaveRequests.map((req) => (
                    <tr key={req.id} style={{ borderBottom: '1px solid var(--border-color)' }}>
                      <td style={{ padding: '12px 10px', fontWeight: 600 }}>{req.requester}</td>
                      <td style={{ padding: '12px 10px' }}>{req.details}</td>
                      <td style={{ padding: '12px 10px' }}>{req.date}</td>
                      <td style={{ padding: '12px 10px' }}>
                        <span 
                          style={{ 
                            fontSize: '0.75rem', 
                            fontWeight: 700, 
                            padding: '2px 8px', 
                            borderRadius: 'var(--radius-sm)',
                            backgroundColor: req.status === 'approved' ? 'var(--success-light)' : req.status === 'rejected' ? 'var(--danger-light)' : 'var(--warning-light)',
                            color: req.status === 'approved' ? 'var(--success)' : req.status === 'rejected' ? 'var(--danger)' : 'var(--warning)',
                            textTransform: 'capitalize'
                          }}
                        >
                          {req.status}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
