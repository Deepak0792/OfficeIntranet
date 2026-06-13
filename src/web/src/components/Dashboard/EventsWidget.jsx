import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { Calendar, ArrowRight, MapPin, Clock } from 'lucide-react';
import { AppContext } from '../../context/AppContext';

export default function EventsWidget() {
  const { events } = useContext(AppContext);

  // Sort events by date ascending
  const sortedEvents = [...events].sort((a, b) => new Date(a.date) - new Date(b.date)).slice(0, 4);

  const getEventMonthStr = (dateStr) => {
    const d = new Date(dateStr);
    return d.toLocaleDateString([], { month: 'short' });
  };

  const getEventDayStr = (dateStr) => {
    const d = new Date(dateStr);
    return d.getDate();
  };

  return (
    <div className="glass-card">
      <div className="widget-header">
        <div className="widget-title">
          <Calendar size={18} className="doc-icon" />
          <span>Upcoming Events</span>
        </div>
        <Link to="/calendar" className="icon-btn" style={{ fontSize: '0.8rem', gap: '4px', textDecoration: 'none', color: 'var(--primary-blue)' }}>
          <span>Calendar</span>
          <ArrowRight size={14} />
        </Link>
      </div>

      <div className="item-list">
        {sortedEvents.map(evt => (
          <div key={evt.id} className="list-item event-item">
            <div className="event-date-block" style={{
              backgroundColor: evt.type === 'holiday' ? 'var(--danger-light)' : evt.type === 'training' ? 'var(--warning-light)' : 'var(--primary-blue-light)',
              color: evt.type === 'holiday' ? 'var(--danger)' : evt.type === 'training' ? 'var(--warning)' : 'var(--primary-blue)'
            }}>
              <span className="event-day">{getEventDayStr(evt.date)}</span>
              <span className="event-month">{getEventMonthStr(evt.date)}</span>
            </div>

            <div className="event-info">
              <h5 style={{ fontWeight: 600 }}>{evt.title}</h5>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginTop: '2px', fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '2px' }}>
                  <Clock size={12} />
                  {evt.time}
                </span>
                <span style={{ display: 'flex', alignItems: 'center', gap: '2px' }}>
                  <MapPin size={12} />
                  {evt.location}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
