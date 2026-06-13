import React, { useContext, useState } from 'react';
import { AppContext } from '../context/AppContext';
import { ClipboardCheck, Check, X, User, Calendar, CreditCard, FileText } from 'lucide-react';

export default function Approvals() {
  const { approvals, handleApprovalDecision } = useContext(AppContext);
  const [activeTab, setActiveTab] = useState('all');

  const pendingApprovals = approvals.filter(a => a.status === 'pending');
  const finishedApprovals = approvals.filter(a => a.status !== 'pending');

  const filteredPending = pendingApprovals.filter(a => {
    if (activeTab === 'all') return true;
    return a.type === activeTab;
  });

  const getIcon = (type) => {
    switch (type) {
      case 'leave': return <Calendar size={18} />;
      case 'expense': return <CreditCard size={18} />;
      default: return <FileText size={18} />;
    }
  };

  const getRequesterAvatar = (name) => {
    if (name.includes('Alice')) return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150';
    if (name.includes('Daniel')) return 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150';
    if (name.includes('Clara')) return 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150';
    if (name.includes('Frank')) return 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150';
    return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150';
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Approvals Center</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Review requests and claims submitted by team members.</p>
      </div>

      {/* Tabs */}
      <div className="approval-type-tabs" style={{ margin: 0 }}>
        <button className={`tab-btn ${activeTab === 'all' ? 'active' : ''}`} onClick={() => setActiveTab('all')}>All Pending ({pendingApprovals.length})</button>
        <button className={`tab-btn ${activeTab === 'leave' ? 'active' : ''}`} onClick={() => setActiveTab('leave')}>Leaves</button>
        <button className={`tab-btn ${activeTab === 'expense' ? 'active' : ''}`} onClick={() => setActiveTab('expense')}>Expenses</button>
        <button className={`tab-btn ${activeTab === 'document' ? 'active' : ''}`} onClick={() => setActiveTab('document')}>Documents</button>
        <button className={`tab-btn ${activeTab === 'purchase' ? 'active' : ''}`} onClick={() => setActiveTab('purchase')}>Purchase Orders</button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
        {/* Pending Requests Column */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ClipboardCheck size={18} className="doc-icon" />
            <span>Pending Review Queue</span>
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {filteredPending.length === 0 ? (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
                No pending requests in this category.
              </div>
            ) : (
              filteredPending.map((appr) => (
                <div 
                  key={appr.id} 
                  className="list-item" 
                  style={{ 
                    display: 'flex', 
                    flexWrap: 'wrap',
                    justifyContent: 'space-between', 
                    alignItems: 'center',
                    padding: '16px',
                    gap: '12px'
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '14px', flex: 1, minWidth: '220px' }}>
                    <img src={getRequesterAvatar(appr.requester)} alt={appr.requester} style={{ width: '40px', height: '40px', borderRadius: 'var(--radius-round)' }} />
                    <div>
                      <h4 style={{ fontSize: '0.9rem', fontWeight: 700 }}>{appr.requester}</h4>
                      <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginTop: '2px' }}>{appr.details}</p>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <span 
                      style={{ 
                        display: 'flex', 
                        alignItems: 'center', 
                        gap: '4px', 
                        fontSize: '0.75rem', 
                        fontWeight: 700, 
                        textTransform: 'uppercase',
                        padding: '3px 8px',
                        borderRadius: 'var(--radius-sm)',
                        backgroundColor: 'var(--primary-blue-light)',
                        color: 'var(--primary-blue)'
                      }}
                    >
                      {getIcon(appr.type)}
                      <span>{appr.type}</span>
                    </span>

                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button 
                        className="btn btn-primary btn-mini" 
                        style={{ backgroundColor: 'var(--success)', gap: '4px' }}
                        onClick={() => handleApprovalDecision(appr.id, 'approved')}
                      >
                        <Check size={12} />
                        <span>Approve</span>
                      </button>
                      <button 
                        className="btn btn-danger btn-mini" 
                        style={{ gap: '4px' }}
                        onClick={() => handleApprovalDecision(appr.id, 'rejected')}
                      >
                        <X size={12} />
                        <span>Reject</span>
                      </button>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Audit Log / Finished Approvals */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.1rem', marginBottom: '16px' }}>Approval Audit Logs</h3>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border-color)', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '10px' }}>Requester</th>
                  <th style={{ padding: '10px' }}>Request Details</th>
                  <th style={{ padding: '10px' }}>Decided Date</th>
                  <th style={{ padding: '10px' }}>Outcome</th>
                </tr>
              </thead>
              <tbody>
                {finishedApprovals.map((appr) => (
                  <tr key={appr.id} style={{ borderBottom: '1px solid var(--border-color)' }}>
                    <td style={{ padding: '12px 10px', fontWeight: 600 }}>{appr.requester}</td>
                    <td style={{ padding: '12px 10px' }}>{appr.details}</td>
                    <td style={{ padding: '12px 10px' }}>{appr.date}</td>
                    <td style={{ padding: '12px 10px' }}>
                      <span 
                        style={{ 
                          fontSize: '0.75rem', 
                          fontWeight: 700, 
                          padding: '2px 8px', 
                          borderRadius: 'var(--radius-sm)',
                          backgroundColor: appr.status === 'approved' ? 'var(--success-light)' : 'var(--danger-light)',
                          color: appr.status === 'approved' ? 'var(--success)' : 'var(--danger)',
                          textTransform: 'capitalize'
                        }}
                      >
                        {appr.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
