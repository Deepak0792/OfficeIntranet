import React, { useState } from 'react';
import { BarChart3, FileDown, Calendar, Filter } from 'lucide-react';
import { 
  ResponsiveContainer, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend,
  LineChart, Line, AreaChart, Area
} from 'recharts';

export default function Reports() {
  const [reportType, setReportType] = useState('performance');
  const [timeframe, setTimeframe] = useState('Weekly');

  // Performance datasets
  const deptPerformance = [
    { name: 'Engineering', efficiency: 92, target: 85 },
    { name: 'Product', efficiency: 78, target: 80 },
    { name: 'Design', efficiency: 95, target: 90 },
    { name: 'Finance', efficiency: 85, target: 80 },
    { name: 'HR', efficiency: 90, target: 85 },
  ];

  // Projects completion speed datasets
  const velocityData = [
    { week: 'Wk 1', completed: 4, active: 8 },
    { week: 'Wk 2', completed: 6, active: 7 },
    { week: 'Wk 3', completed: 5, active: 9 },
    { week: 'Wk 4', completed: 8, active: 6 },
  ];

  const handleExport = (format) => {
    alert(`Generating report...\nFormat: ${format.toUpperCase()}\nTimeframe: ${timeframe}\nCategory: ${reportType}\n\nDownload will start automatically!`);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Analytical Reports</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Examine department productivity, logs efficiency, and export documents.</p>
        </div>

        <div style={{ display: 'flex', gap: '8px' }}>
          <button className="btn btn-secondary" style={{ gap: '6px' }} onClick={() => handleExport('pdf')}>
            <FileDown size={16} />
            <span>PDF Export</span>
          </button>
          <button className="btn btn-ghost" style={{ gap: '6px' }} onClick={() => handleExport('csv')}>
            <FileDown size={16} />
            <span>CSV Export</span>
          </button>
        </div>
      </div>

      {/* Filter Options Bar */}
      <div className="glass-card" style={{ display: 'flex', flexWrap: 'wrap', gap: '16px', alignItems: 'center', padding: '14px 20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.85rem', fontWeight: 600 }}>
          <Filter size={16} style={{ color: 'var(--primary-blue)' }} />
          <span>Filters</span>
        </div>

        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '12px', flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Report:</span>
            <select className="input-field" style={{ padding: '6px 12px', width: '150px' }} value={reportType} onChange={e => setReportType(e.target.value)}>
              <option value="performance">Dept Efficiency</option>
              <option value="velocity">Sprint Velocity</option>
            </select>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Timeframe:</span>
            <select className="input-field" style={{ padding: '6px 12px', width: '130px' }} value={timeframe} onChange={e => setTimeframe(e.target.value)}>
              <option value="Weekly">Weekly View</option>
              <option value="Monthly">Monthly View</option>
              <option value="Quarterly">Quarterly View</option>
            </select>
          </div>
        </div>
      </div>

      {/* Main Charts card */}
      <div className="glass-card" style={{ minHeight: '350px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h3 style={{ fontSize: '1.1rem', fontWeight: 700 }}>
            {reportType === 'performance' ? 'Department Efficiency Trends (%)' : 'Sprint Task Velocity (Tasks)'}
          </h3>
          <span style={{ fontSize: '0.75rem', fontWeight: 600, padding: '4px 10px', borderRadius: 'var(--radius-sm)', backgroundColor: 'var(--primary-blue-light)', color: 'var(--primary-blue)' }}>
            Showing {timeframe} metrics
          </span>
        </div>

        <div style={{ flex: 1, minHeight: '300px' }}>
          {reportType === 'performance' ? (
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={deptPerformance} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
                <XAxis dataKey="name" stroke="var(--text-muted)" fontSize={11} />
                <YAxis stroke="var(--text-muted)" fontSize={11} domain={[0, 100]} />
                <Tooltip 
                  contentStyle={{ 
                    background: 'var(--bg-card)', 
                    border: '1px solid var(--border-color)', 
                    borderRadius: 'var(--radius-sm)',
                    backdropFilter: 'var(--glass-blur)'
                  }} 
                />
                <Legend iconType="circle" />
                <Bar dataKey="efficiency" name="Efficiency Score" fill="var(--primary-blue)" radius={[4, 4, 0, 0]} />
                <Bar dataKey="target" name="Corporate Target" fill="var(--accent-purple)" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={velocityData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="colorCompleted" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="var(--success)" stopOpacity={0.4}/>
                    <stop offset="95%" stopColor="var(--success)" stopOpacity={0.0}/>
                  </linearGradient>
                  <linearGradient id="colorActive" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="var(--primary-blue)" stopOpacity={0.4}/>
                    <stop offset="95%" stopColor="var(--primary-blue)" stopOpacity={0.0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
                <XAxis dataKey="week" stroke="var(--text-muted)" fontSize={11} />
                <YAxis stroke="var(--text-muted)" fontSize={11} />
                <Tooltip 
                  contentStyle={{ 
                    background: 'var(--bg-card)', 
                    border: '1px solid var(--border-color)', 
                    borderRadius: 'var(--radius-sm)',
                    backdropFilter: 'var(--glass-blur)'
                  }} 
                />
                <Legend iconType="square" />
                <Area type="monotone" dataKey="completed" name="Completed Sprint Items" stroke="var(--success)" strokeWidth={2} fillOpacity={1} fill="url(#colorCompleted)" />
                <Area type="monotone" dataKey="active" name="Active Backlog Items" stroke="var(--primary-blue)" strokeWidth={2} fillOpacity={1} fill="url(#colorActive)" />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>
    </div>
  );
}
