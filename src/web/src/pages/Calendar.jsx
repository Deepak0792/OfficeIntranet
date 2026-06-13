import React, { useContext, useState } from 'react';
import { AppContext } from '../context/AppContext';
import { Calendar as CalendarIcon, Clock, MapPin, Plus } from 'lucide-react';

export default function CalendarPage() {
  const { events } = useContext(AppContext);
  const [selectedDay, setSelectedDay] = useState(15); // Default to June 15 for demo

  const daysInMonth = Array.from({ length: 30 }, (_, i) => i + 1);
  const weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  // Offset so June 1 starts on a Monday
  const gridOffset = Array.from({ length: 1 }, () => null);

  const getEventsForDay = (day) => {
    // Dates are formatted as '2026-06-XX'
    const dayStr = String(day).padStart(2, '0');
    return events.filter(e => e.date === `2026-06-${dayStr}`);
  };

  const getDayEvents = getEventsForDay(selectedDay);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Corporate Calendar</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Plan timelines, book virtual meeting rooms, and look up company holidays.</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
        {/* Calendar Grid card */}
        <div className="glass-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
            <h3 style={{ fontSize: '1.2rem', fontWeight: 700 }}>June 2026</h3>
            <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>Eastern Time (ET)</span>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '10px', textAlign: 'center' }}>
            {/* Weekday Labels */}
            {weekDays.map(d => (
              <div key={d} style={{ fontSize: '0.8rem', fontWeight: 700, color: 'var(--text-muted)', paddingBottom: '6px' }}>{d}</div>
            ))}

            {/* Empty slots for offset */}
            {gridOffset.map((_, idx) => (
              <div key={`offset-${idx}`}></div>
            ))}

            {/* Monthly days */}
            {daysInMonth.map(day => {
              const dayEvents = getEventsForDay(day);
              const isSelected = selectedDay === day;
              const hasEvents = dayEvents.length > 0;
              const hasHoliday = dayEvents.some(e => e.type === 'holiday');

              return (
                <button
                  key={day}
                  onClick={() => setSelectedDay(day)}
                  style={{
                    border: 'none',
                    borderRadius: 'var(--radius-sm)',
                    background: isSelected ? 'var(--primary-blue)' : 'var(--bg-primary)',
                    color: isSelected ? 'var(--text-white)' : 'var(--text-main)',
                    height: '56px',
                    display: 'flex',
                    flexDirection: 'column',
                    justifyContent: 'space-between',
                    alignItems: 'center',
                    padding: '6px',
                    cursor: 'pointer',
                    position: 'relative',
                    transition: 'all var(--transition-fast)'
                  }}
                >
                  <span style={{ fontSize: '0.85rem', fontWeight: 700 }}>{day}</span>
                  {hasEvents && (
                    <div style={{ display: 'flex', gap: '2px', justifyContent: 'center', width: '100%' }}>
                      <div style={{ 
                        width: '6px', 
                        height: '6px', 
                        borderRadius: 'var(--radius-round)', 
                        backgroundColor: hasHoliday ? 'var(--danger)' : isSelected ? 'white' : 'var(--primary-blue)' 
                      }}></div>
                    </div>
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* Selected Day Agenda */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <CalendarIcon size={18} className="doc-icon" />
            <span>Agenda for June {selectedDay}, 2026</span>
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {getDayEvents.length === 0 ? (
              <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
                No meetings or events scheduled for this date.
              </div>
            ) : (
              getDayEvents.map((evt) => (
                <div key={evt.id} className="list-item" style={{ display: 'flex', flexDirection: 'column', alignItems: 'stretch', gap: '10px', padding: '14px 18px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <h4 style={{ fontSize: '0.95rem', fontWeight: 700 }}>{evt.title}</h4>
                    <span 
                      style={{ 
                        fontSize: '0.7rem', 
                        fontWeight: 700, 
                        padding: '2px 8px', 
                        borderRadius: 'var(--radius-sm)',
                        backgroundColor: evt.type === 'holiday' ? 'var(--danger-light)' : evt.type === 'training' ? 'var(--warning-light)' : 'var(--primary-blue-light)',
                        color: evt.type === 'holiday' ? 'var(--danger)' : evt.type === 'training' ? 'var(--warning)' : 'var(--primary-blue)',
                        textTransform: 'uppercase'
                      }}
                    >
                      {evt.type}
                    </span>
                  </div>

                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: '16px', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                    <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <Clock size={12} />
                      {evt.time}
                    </span>
                    <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <MapPin size={12} />
                      {evt.location}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
