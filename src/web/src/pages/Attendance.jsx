import React, { useContext } from 'react';
import { AppContext } from '../context/AppContext';
import { Clock, CheckCircle, LogIn, LogOut, Calendar } from 'lucide-react';

export default function Attendance() {
  const { isClockedIn, handleClockInOut, workHours, attendanceLogs } = useContext(AppContext);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Attendance Tracker</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Clock in and out, track active hours, and review monthly reports.</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
        {/* Active Session & Quick Actions */}
        <div className="glass-card" style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'space-between', alignItems: 'center', gap: '20px' }}>
          <div>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: 600 }}>Active Clock In Session</span>
            <h2 style={{ fontSize: '2rem', fontWeight: 800, color: 'var(--primary-blue)', fontFamily: 'var(--font-display)', marginTop: '4px' }}>
              {isClockedIn ? workHours : '00:00:00'}
            </h2>
            <p style={{ fontSize: '0.85rem', color: isClockedIn ? 'var(--success)' : 'var(--danger)', marginTop: '2px', fontWeight: 600 }}>
              {isClockedIn ? 'You are currently clocked in.' : 'You are clocked out.'}
            </p>
          </div>

          <button 
            className={`btn ${isClockedIn ? 'btn-danger' : 'btn-primary'}`}
            style={{ padding: '14px 28px', fontSize: '1rem', borderRadius: 'var(--radius-round)', gap: '8px' }}
            onClick={handleClockInOut}
          >
            {isClockedIn ? (
              <>
                <LogOut size={20} />
                <span>Clock Out Now</span>
              </>
            ) : (
              <>
                <LogIn size={20} />
                <span>Clock In Now</span>
              </>
            )}
          </button>
        </div>

        {/* Attendance Statistics Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '20px' }}>
          <div className="glass-card" style={{ textAlign: 'center' }}>
            <h4 style={{ color: 'var(--text-muted)', fontSize: '0.85rem', marginBottom: '4px' }}>Average Work Hours</h4>
            <span style={{ fontSize: '1.6rem', fontWeight: 800, color: 'var(--primary-blue)', fontFamily: 'var(--font-display)' }}>8.2 hours</span>
          </div>
          <div className="glass-card" style={{ textAlign: 'center' }}>
            <h4 style={{ color: 'var(--text-muted)', fontSize: '0.85rem', marginBottom: '4px' }}>On-Time Arrival Rate</h4>
            <span style={{ fontSize: '1.6rem', fontWeight: 800, color: 'var(--success)', fontFamily: 'var(--font-display)' }}>96.5%</span>
          </div>
          <div className="glass-card" style={{ textAlign: 'center' }}>
            <h4 style={{ color: 'var(--text-muted)', fontSize: '0.85rem', marginBottom: '4px' }}>Leaves Taken (Month)</h4>
            <span style={{ fontSize: '1.6rem', fontWeight: 800, color: 'var(--warning)', fontFamily: 'var(--font-display)' }}>1.0 Day</span>
          </div>
        </div>

        {/* History Table */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.15rem', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
            <Calendar size={18} className="doc-icon" />
            <span>Attendance History Logs</span>
          </h3>

          <div style={{ overflowX: 'auto' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem', textAlign: 'left' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border-color)', color: 'var(--text-muted)' }}>
                  <th style={{ padding: '10px' }}>Shift Date</th>
                  <th style={{ padding: '10px' }}>Clock In Time</th>
                  <th style={{ padding: '10px' }}>Clock Out Time</th>
                  <th style={{ padding: '10px' }}>Status</th>
                </tr>
              </thead>
              <tbody>
                {attendanceLogs.map((log, idx) => (
                  <tr key={idx} style={{ borderBottom: '1px solid var(--border-color)' }}>
                    <td style={{ padding: '12px 10px', fontWeight: 600 }}>{log.date}</td>
                    <td style={{ padding: '12px 10px' }}>{log.clockIn}</td>
                    <td style={{ padding: '12px 10px' }}>{log.clockOut}</td>
                    <td style={{ padding: '12px 10px' }}>
                      <span 
                        style={{ 
                          fontSize: '0.75rem', 
                          fontWeight: 700, 
                          padding: '2px 8px', 
                          borderRadius: 'var(--radius-sm)',
                          backgroundColor: log.status === 'Present' ? 'var(--success-light)' : 'var(--warning-light)',
                          color: log.status === 'Present' ? 'var(--success)' : 'var(--warning)'
                        }}
                      >
                        {log.status}
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
