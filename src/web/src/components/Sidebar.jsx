import React, { useContext, useState } from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, Users, Layers, Briefcase, CheckSquare, 
  CalendarDays, Clock, FolderOpen, ClipboardCheck, Megaphone, 
  BookOpen, Calendar, BarChart3, Settings, Search, X
} from 'lucide-react';
import { AppContext } from '../context/AppContext';

export default function Sidebar() {
  const { sidebarOpen, setSidebarOpen } = useContext(AppContext);
  const [localQuery, setLocalQuery] = useState('');

  // Sidebar navigation items
  const menuItems = [
    { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboard },
    { name: 'Employee Directory', path: '/employees', icon: Users },
    { name: 'Departments', path: '/departments', icon: Layers },
    { name: 'Projects', path: '/projects', icon: Briefcase },
    { name: 'Tasks', path: '/tasks', icon: CheckSquare },
    { name: 'Leave Management', path: '/leave', icon: CalendarDays },
    { name: 'Attendance', path: '/attendance', icon: Clock },
    { name: 'Documents', path: '/documents', icon: FolderOpen },
    { name: 'Approvals', path: '/approvals', icon: ClipboardCheck },
    { name: 'Announcements', path: '/announcements', icon: Megaphone },
    { name: 'Knowledge Base', path: '/knowledge-base', icon: BookOpen },
    { name: 'Calendar', path: '/calendar', icon: Calendar },
    { name: 'Reports', path: '/reports', icon: BarChart3 },
    { name: 'Settings', path: '/settings', icon: Settings },
  ];

  // Filter menu items based on user input
  const filteredMenuItems = menuItems.filter(item => 
    item.name.toLowerCase().includes(localQuery.toLowerCase())
  );

  return (
    <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
      {/* Sidebar Navigation Search */}
      <div className="sidebar-search">
        <Search className="search-icon" size={16} />
        <input 
          type="text" 
          className="input-field" 
          placeholder="Filter navigation..." 
          value={localQuery}
          onChange={(e) => setLocalQuery(e.target.value)}
        />
        {localQuery && (
          <button 
            onClick={() => setLocalQuery('')} 
            style={{ 
              position: 'absolute', 
              right: '8px', 
              top: '50%', 
              transform: 'translateY(-50%)',
              border: 'none',
              background: 'transparent',
              color: 'var(--text-muted)',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center'
            }}
          >
            <X size={14} />
          </button>
        )}
      </div>

      <nav className="sidebar-nav">
        {filteredMenuItems.length === 0 ? (
          <div style={{ padding: '12px', textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
            No links found
          </div>
        ) : (
          filteredMenuItems.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.path}
                to={item.path}
                className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
                onClick={() => setSidebarOpen(false)} // Close sidebar drawer on click (mobile view)
              >
                <Icon />
                <span>{item.name}</span>
              </NavLink>
            );
          })
        )}
      </nav>
    </aside>
  );
}
