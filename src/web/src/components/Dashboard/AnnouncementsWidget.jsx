import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { Megaphone, ArrowRight, Tag } from 'lucide-react';
import { AppContext } from '../../context/AppContext';

export default function AnnouncementsWidget() {
  const { announcements } = useContext(AppContext);

  return (
    <div className="glass-card">
      <div className="widget-header">
        <div className="widget-title">
          <Megaphone size={18} className="doc-icon" />
          <span>Company Announcements</span>
        </div>
        <Link to="/announcements" className="icon-btn" style={{ fontSize: '0.8rem', gap: '4px', textDecoration: 'none', color: 'var(--primary-blue)' }}>
          <span>View All</span>
          <ArrowRight size={14} />
        </Link>
      </div>

      <div className="item-list">
        {announcements.slice(0, 3).map(ann => (
          <div key={ann.id} className="announcement-card announcement-box">
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '4px' }}>
                <span className="announcement-title">{ann.title}</span>
                <span 
                  style={{ 
                    fontSize: '0.65rem', 
                    fontWeight: 700, 
                    padding: '2px 6px', 
                    borderRadius: 'var(--radius-sm)',
                    backgroundColor: ann.category === 'IT Support' ? 'var(--warning-light)' : ann.category === 'Holiday' ? 'var(--danger-light)' : 'var(--primary-blue-light)',
                    color: ann.category === 'IT Support' ? 'var(--warning)' : ann.category === 'Holiday' ? 'var(--danger)' : 'var(--primary-blue)'
                  }}
                >
                  {ann.category}
                </span>
              </div>
              <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', lineHeight: '1.4', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                {ann.content}
              </p>
            </div>
            
            <div className="announcement-meta">
              <span>By {ann.author}</span>
              <span>•</span>
              <span>{new Date(ann.date).toLocaleDateString([], { month: 'short', day: 'numeric', year: 'numeric' })}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
