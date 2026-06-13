import React, { useContext } from 'react';
import { Megaphone, User, Calendar, Tag } from 'lucide-react';
import { AppContext } from '../context/AppContext';

export default function Announcements() {
  const { announcements } = useContext(AppContext);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Company News Feed</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Read official press releases, HR announcements, and celebration reports.</p>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
        {announcements.map((ann) => (
          <div key={ann.id} className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '8px' }}>
              <h2 style={{ fontSize: '1.3rem', fontWeight: 700 }}>{ann.title}</h2>
              <span 
                style={{ 
                  fontSize: '0.75rem', 
                  fontWeight: 700, 
                  padding: '3px 10px', 
                  borderRadius: 'var(--radius-sm)',
                  backgroundColor: ann.category === 'IT Support' ? 'var(--warning-light)' : ann.category === 'Holiday' ? 'var(--danger-light)' : 'var(--primary-blue-light)',
                  color: ann.category === 'IT Support' ? 'var(--warning)' : ann.category === 'Holiday' ? 'var(--danger)' : 'var(--primary-blue)'
                }}
              >
                {ann.category}
              </span>
            </div>

            <p style={{ fontSize: '0.95rem', lineHeight: '1.6', color: 'var(--text-main)' }}>
              {ann.content}
            </p>

            <div style={{ 
              display: 'flex', 
              flexWrap: 'wrap', 
              gap: '16px', 
              fontSize: '0.8rem', 
              color: 'var(--text-muted)',
              borderTop: '1px solid var(--border-color)',
              paddingTop: '12px',
              marginTop: '4px'
            }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                <User size={14} />
                Published by: <strong>{ann.author}</strong>
              </span>
              <span>•</span>
              <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                <Calendar size={14} />
                Date: {new Date(ann.date).toLocaleDateString([], { month: 'long', day: 'numeric', year: 'numeric' })}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
