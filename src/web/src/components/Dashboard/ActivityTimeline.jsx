import React, { useContext } from 'react';
import { Clock } from 'lucide-react';
import { AppContext } from '../../context/AppContext';

export default function ActivityTimeline() {
  const { activities } = useContext(AppContext);

  const getTimelineDotColor = (type) => {
    if (type === 'attendance') return 'timeline-dot-green';
    if (type === 'approval') return 'timeline-dot-purple';
    if (type === 'task') return 'timeline-dot-red';
    return '';
  };

  return (
    <div className="glass-card">
      <div className="widget-header">
        <h4 className="widget-title">
          <Clock size={18} className="doc-icon" />
          <span>Activity Timeline</span>
        </h4>
      </div>

      <div className="timeline-box">
        {activities.length === 0 ? (
          <div style={{ padding: '16px', textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
            No recent activities
          </div>
        ) : (
          activities.map((act) => (
            <div key={act.id} className="timeline-item">
              <div className={`timeline-dot ${getTimelineDotColor(act.type)}`}></div>
              <div className="timeline-content">
                <p style={{ fontWeight: 500, fontSize: '0.85rem' }}>{act.text}</p>
                <span className="timeline-time">{act.time}</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
