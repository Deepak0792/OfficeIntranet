import React from 'react';
import { useNavigate } from 'react-router-dom';
import { CalendarDays, Clipboard, CreditCard, HelpCircle, FileDown, ShieldAlert, Video } from 'lucide-react';

export default function QuickAccess() {
  const navigate = useNavigate();

  const actions = [
    { label: 'Apply Leave', icon: CalendarDays, path: '/leave', color: 'var(--primary-blue)' },
    { label: 'Create Request', icon: Clipboard, path: '/tasks', color: 'var(--accent-purple)' },
    { label: 'Submit Expense', icon: CreditCard, path: '/approvals', color: 'var(--success)' },
    { label: 'Book Room', icon: Video, path: '/calendar', color: 'var(--warning)' },
    { label: 'Raise IT Ticket', icon: ShieldAlert, path: '/settings', color: 'var(--danger)' },
    { label: 'Download Reports', icon: FileDown, path: '/reports', color: 'var(--accent-cyan)' },
  ];

  return (
    <div className="glass-card">
      <div className="widget-header">
        <h4 className="widget-title">Quick Access Panel</h4>
      </div>

      <div className="quick-access-grid">
        {actions.map((act, idx) => {
          const Icon = act.icon;
          return (
            <button 
              key={idx} 
              className="quick-access-btn" 
              onClick={() => navigate(act.path)}
            >
              <Icon style={{ color: act.color }} />
              <span>{act.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
