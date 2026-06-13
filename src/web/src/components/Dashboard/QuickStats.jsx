import React, { useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, Briefcase, ClipboardCheck, CheckSquare, CalendarDays, Calendar } from 'lucide-react';
import { AppContext } from '../../context/AppContext';

export default function QuickStats() {
  const { employees, tasks, approvals, events } = useContext(AppContext);
  const navigate = useNavigate();

  const totalEmployees = employees.length;
  const activeProjects = 8; // Mock project count
  const pendingApprovals = approvals.filter(a => a.status === 'pending').length;
  const openTasks = tasks.filter(t => t.status !== 'done').length;
  const leaveRequests = approvals.filter(a => a.type === 'leave' && a.status === 'pending').length;
  const upcomingMeetings = events.filter(e => e.type === 'meeting').length;

  const stats = [
    { 
      label: 'Total Employees', 
      value: totalEmployees, 
      icon: Users, 
      colorClass: 'stat-icon-blue', 
      path: '/employees' 
    },
    { 
      label: 'Active Projects', 
      value: activeProjects, 
      icon: Briefcase, 
      colorClass: 'stat-icon-purple', 
      path: '/projects' 
    },
    { 
      label: 'Pending Approvals', 
      value: pendingApprovals, 
      icon: ClipboardCheck, 
      colorClass: 'stat-icon-green', 
      path: '/approvals' 
    },
    { 
      label: 'Open Tasks', 
      value: openTasks, 
      icon: CheckSquare, 
      colorClass: 'stat-icon-amber', 
      path: '/tasks' 
    },
    { 
      label: 'Leave Requests', 
      value: leaveRequests, 
      icon: CalendarDays, 
      colorClass: 'stat-icon-cyan', 
      path: '/leave' 
    },
    { 
      label: 'Upcoming Meetings', 
      value: upcomingMeetings, 
      icon: Calendar, 
      colorClass: 'stat-icon-red', 
      path: '/calendar' 
    },
  ];

  return (
    <div className="stats-grid">
      {stats.map((stat, idx) => {
        const Icon = stat.icon;
        return (
          <div 
            key={idx} 
            className="stat-card" 
            style={{ cursor: 'pointer' }}
            onClick={() => navigate(stat.path)}
          >
            <div className={`stat-icon ${stat.colorClass}`}>
              <Icon size={22} />
            </div>
            <div className="stat-info">
              <span className="stat-value">{stat.value}</span>
              <span className="stat-label">{stat.label}</span>
            </div>
          </div>
        );
      })}
    </div>
  );
}
