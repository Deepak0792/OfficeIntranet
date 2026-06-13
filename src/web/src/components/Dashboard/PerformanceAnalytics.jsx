import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { BarChart3, ArrowRight } from 'lucide-react';
import { 
  ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip,
  BarChart, Bar, CartesianGrid, Legend 
} from 'recharts';

export default function PerformanceAnalytics() {
  const [activeMetric, setActiveMetric] = useState('productivity');

  // Productivity Trend data
  const productivityData = [
    { day: 'Mon', TeamA: 82, TeamB: 78, TeamC: 85 },
    { day: 'Tue', TeamA: 88, TeamB: 82, TeamC: 89 },
    { day: 'Wed', TeamA: 95, TeamB: 89, TeamC: 92 },
    { day: 'Thu', TeamA: 90, TeamB: 85, TeamC: 88 },
    { day: 'Fri', TeamA: 94, TeamB: 91, TeamC: 95 },
  ];

  // Department Completion Rates
  const completionData = [
    { name: 'Engineering', completed: 88, ongoing: 12 },
    { name: 'Product', completed: 75, ongoing: 25 },
    { name: 'Design', completed: 92, ongoing: 8 },
    { name: 'Finance', completed: 80, ongoing: 20 },
    { name: 'HR', completed: 95, ongoing: 5 },
  ];

  return (
    <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div className="widget-header">
        <div className="widget-title">
          <BarChart3 size={18} className="doc-icon" />
          <span>Team Performance Analytics</span>
        </div>
        
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div className="approval-type-tabs" style={{ margin: 0 }}>
            <button 
              className={`tab-btn ${activeMetric === 'productivity' ? 'active' : ''}`} 
              onClick={() => setActiveMetric('productivity')}
            >
              Productivity
            </button>
            <button 
              className={`tab-btn ${activeMetric === 'completion' ? 'active' : ''}`} 
              onClick={() => setActiveMetric('completion')}
            >
              Completion
            </button>
          </div>
          <Link to="/reports" className="icon-btn" style={{ fontSize: '0.8rem', gap: '4px', textDecoration: 'none', color: 'var(--primary-blue)' }}>
            <span>Reports</span>
            <ArrowRight size={14} />
          </Link>
        </div>
      </div>

      <div style={{ flex: 1, minHeight: '260px' }}>
        {activeMetric === 'productivity' ? (
          <ResponsiveContainer width="100%" height={260}>
            <AreaChart data={productivityData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
              <defs>
                <linearGradient id="colorTeamA" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="var(--primary-blue)" stopOpacity={0.4}/>
                  <stop offset="95%" stopColor="var(--primary-blue)" stopOpacity={0.0}/>
                </linearGradient>
                <linearGradient id="colorTeamC" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="var(--accent-purple)" stopOpacity={0.4}/>
                  <stop offset="95%" stopColor="var(--accent-purple)" stopOpacity={0.0}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
              <XAxis dataKey="day" stroke="var(--text-muted)" fontSize={11} />
              <YAxis stroke="var(--text-muted)" fontSize={11} />
              <Tooltip 
                contentStyle={{ 
                  background: 'var(--bg-card)', 
                  border: '1px solid var(--border-color)', 
                  borderRadius: 'var(--radius-sm)',
                  backdropFilter: 'var(--glass-blur)'
                }} 
              />
              <Legend verticalAlign="top" height={36} iconType="circle" />
              <Area type="monotone" dataKey="TeamA" name="Platform Team" stroke="var(--primary-blue)" strokeWidth={2} fillOpacity={1} fill="url(#colorTeamA)" />
              <Area type="monotone" dataKey="TeamC" name="Gateway Team" stroke="var(--accent-purple)" strokeWidth={2} fillOpacity={1} fill="url(#colorTeamC)" />
            </AreaChart>
          </ResponsiveContainer>
        ) : (
          <ResponsiveContainer width="100%" height={260}>
            <BarChart data={completionData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
              <XAxis dataKey="name" stroke="var(--text-muted)" fontSize={10} />
              <YAxis stroke="var(--text-muted)" fontSize={11} />
              <Tooltip 
                contentStyle={{ 
                  background: 'var(--bg-card)', 
                  border: '1px solid var(--border-color)', 
                  borderRadius: 'var(--radius-sm)',
                  backdropFilter: 'var(--glass-blur)'
                }} 
              />
              <Legend verticalAlign="top" height={36} iconType="square" />
              <Bar dataKey="completed" name="Completed Tasks" fill="var(--primary-blue)" radius={[4, 4, 0, 0]} />
              <Bar dataKey="ongoing" name="Ongoing Tasks" fill="var(--warning)" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </div>
    </div>
  );
}
