import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { Clock, ArrowRight, LogIn, LogOut } from 'lucide-react';
import { AppContext } from '../../context/AppContext';
import { ResponsiveContainer, RadialBarChart, RadialBar, PolarAngleAxis } from 'recharts';

export default function AttendanceSummary() {
  const { isClockedIn, handleClockInOut, workHours, attendanceLogs } = useContext(AppContext);

  // Recharts data for radial bar
  const chartData = [
    { name: 'Attendance Rate', value: 94, fill: 'var(--primary-blue)' }
  ];

  const todayDateStr = new Date().toLocaleDateString([], { month: 'short', day: 'numeric' });

  return (
    <div className="glass-card">
      <div className="widget-header">
        <div className="widget-title">
          <Clock size={18} className="doc-icon" />
          <span>Attendance Summary</span>
        </div>
        <Link to="/attendance" className="icon-btn" style={{ fontSize: '0.8rem', gap: '4px', textDecoration: 'none', color: 'var(--primary-blue)' }}>
          <span>Logs</span>
          <ArrowRight size={14} />
        </Link>
      </div>

      <div className="attendance-summary-box">
        {/* Toggle Clock In/Out */}
        <div style={{ display: 'flex', width: '100%', alignItems: 'center', gap: '16px', justifyContent: 'space-between', padding: '6px' }}>
          <div>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Status for {todayDateStr}</div>
            <div style={{ fontSize: '1.05rem', fontWeight: 700, color: isClockedIn ? 'var(--success)' : 'var(--danger)' }}>
              {isClockedIn ? 'Active (Clocked In)' : 'Inactive (Clocked Out)'}
            </div>
            {isClockedIn && (
              <div style={{ fontSize: '1.25rem', fontWeight: 800, fontFamily: 'var(--font-display)', color: 'var(--primary-blue)', marginTop: '4px' }}>
                {workHours}
              </div>
            )}
          </div>
          <button 
            className={`btn ${isClockedIn ? 'btn-danger' : 'btn-primary'}`} 
            style={{ borderRadius: 'var(--radius-round)', padding: '10px 20px' }}
            onClick={handleClockInOut}
          >
            {isClockedIn ? (
              <>
                <LogOut size={16} />
                <span>Clock Out</span>
              </>
            ) : (
              <>
                <LogIn size={16} />
                <span>Clock In</span>
              </>
            )}
          </button>
        </div>

        {/* Radial Trend Chart */}
        <div style={{ position: 'relative', width: '120px', height: '120px', margin: '8px 0' }}>
          <ResponsiveContainer width="100%" height="100%">
            <RadialBarChart 
              cx="50%" 
              cy="50%" 
              innerRadius="75%" 
              outerRadius="100%" 
              barSize={10} 
              data={chartData} 
              startAngle={90} 
              endAngle={-270}
            >
              <PolarAngleAxis 
                type="number" 
                domain={[0, 100]} 
                angleAxisId={0} 
                tick={false} 
              />
              <RadialBar 
                minAngle={15} 
                background={{ fill: 'var(--border-color)' }} 
                clockWise 
                dataKey="value" 
                angleAxisId={0}
              />
            </RadialBarChart>
          </ResponsiveContainer>
          <div style={{
            position: 'absolute',
            top: '50%',
            left: '50%',
            transform: 'translate(-50%, -50%)',
            textAlign: 'center'
          }}>
            <div style={{ fontSize: '1.25rem', fontWeight: 800, color: 'var(--text-main)', fontFamily: 'var(--font-display)' }}>94%</div>
            <div style={{ fontSize: '0.65rem', color: 'var(--text-muted)', fontWeight: 600 }}>Attendance</div>
          </div>
        </div>

        <div className="attendance-stats-row">
          <div className="attendance-stat-col">
            <h6>20 / 22</h6>
            <p>Days Present</p>
          </div>
          <div className="attendance-stat-col">
            <h6>1</h6>
            <p>Sick Leave</p>
          </div>
          <div className="attendance-stat-col">
            <h6>8.2h</h6>
            <p>Avg / Day</p>
          </div>
        </div>
      </div>
    </div>
  );
}
