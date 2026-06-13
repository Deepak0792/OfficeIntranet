import React, { useContext, useState } from 'react';
import { Link } from 'react-router-dom';
import { ClipboardCheck, ArrowRight, Check, X } from 'lucide-react';
import { AppContext } from '../../context/AppContext';

export default function DashboardApprovals() {
  const { approvals, handleApprovalDecision } = useContext(AppContext);
  const [activeTab, setActiveTab] = useState('all');

  const pendingApprovals = approvals.filter(a => a.status === 'pending');
  const filteredApprovals = pendingApprovals.filter(a => {
    if (activeTab === 'all') return true;
    return a.type === activeTab;
  });

  const getRequesterAvatar = (name) => {
    if (name.includes('Alice')) return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150';
    if (name.includes('Daniel')) return 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150';
    if (name.includes('Clara')) return 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150';
    if (name.includes('Frank')) return 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150';
    return 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150';
  };

  return (
    <div className="glass-card">
      <div className="widget-header">
        <div className="widget-title">
          <ClipboardCheck size={18} className="doc-icon" />
          <span>Approvals Center</span>
        </div>
        <Link to="/approvals" className="icon-btn" style={{ fontSize: '0.8rem', gap: '4px', textDecoration: 'none', color: 'var(--primary-blue)' }}>
          <span>View All</span>
          <ArrowRight size={14} />
        </Link>
      </div>

      <div className="approval-type-tabs">
        <button className={`tab-btn ${activeTab === 'all' ? 'active' : ''}`} onClick={() => setActiveTab('all')}>All</button>
        <button className={`tab-btn ${activeTab === 'leave' ? 'active' : ''}`} onClick={() => setActiveTab('leave')}>Leave</button>
        <button className={`tab-btn ${activeTab === 'expense' ? 'active' : ''}`} onClick={() => setActiveTab('expense')}>Expenses</button>
        <button className={`tab-btn ${activeTab === 'document' ? 'active' : ''}`} onClick={() => setActiveTab('document')}>Docs</button>
      </div>

      <div className="item-list">
        {filteredApprovals.length === 0 ? (
          <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
            No pending approvals found
          </div>
        ) : (
          filteredApprovals.map(appr => (
            <div key={appr.id} className="list-item approval-item">
              <div className="approval-body">
                <div className="approval-requester">
                  <img src={getRequesterAvatar(appr.requester)} alt={appr.requester} className="approval-avatar" />
                  <div className="approval-details">
                    <h5>{appr.requester}</h5>
                    <p>{appr.details}</p>
                  </div>
                </div>

                <div className="approval-actions-box">
                  <button 
                    className="btn btn-primary btn-mini" 
                    style={{ backgroundColor: 'var(--success)', borderRadius: 'var(--radius-round)', width: '28px', height: '28px', padding: 0 }}
                    onClick={() => handleApprovalDecision(appr.id, 'approved')}
                  >
                    <Check size={14} />
                  </button>
                  <button 
                    className="btn btn-danger btn-mini" 
                    style={{ borderRadius: 'var(--radius-round)', width: '28px', height: '28px', padding: 0 }}
                    onClick={() => handleApprovalDecision(appr.id, 'rejected')}
                  >
                    <X size={14} />
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
