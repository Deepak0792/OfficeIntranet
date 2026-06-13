import React, { useContext, useState } from 'react';
import { Link } from 'react-router-dom';
import { Users, ArrowRight, Search, Mail, Phone } from 'lucide-react';
import { AppContext } from '../../context/AppContext';

export default function EmployeeDirectoryPreview() {
  const { employees } = useContext(AppContext);
  const [localSearch, setLocalSearch] = useState('');

  // Filter based on search input
  const filteredEmployees = employees
    .filter(emp => emp.name.toLowerCase().includes(localSearch.toLowerCase()) || 
                   emp.dept.toLowerCase().includes(localSearch.toLowerCase()))
    .slice(0, 4); // Limit to 4 cards

  return (
    <div className="glass-card">
      <div className="widget-header">
        <div className="widget-title">
          <Users size={18} className="doc-icon" />
          <span>Employee Directory</span>
        </div>
        <Link to="/employees" className="icon-btn" style={{ fontSize: '0.8rem', gap: '4px', textDecoration: 'none', color: 'var(--primary-blue)' }}>
          <span>Directory</span>
          <ArrowRight size={14} />
        </Link>
      </div>

      <div className="sidebar-search" style={{ marginBottom: '12px' }}>
        <Search className="search-icon" size={16} />
        <input 
          type="text" 
          className="input-field" 
          placeholder="Quick search coworker..." 
          value={localSearch}
          onChange={(e) => setLocalSearch(e.target.value)}
        />
      </div>

      <div className="directory-preview-grid">
        {filteredEmployees.length === 0 ? (
          <div style={{ gridColumn: 'span 2', padding: '16px', textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
            No coworkers found
          </div>
        ) : (
          filteredEmployees.map(emp => (
            <div key={emp.id} className="directory-mini-card">
              <img src={emp.photo} alt={emp.name} className="directory-mini-avatar" />
              <div className="directory-mini-info" style={{ flex: 1, overflow: 'hidden' }}>
                <Link to={`/employees/${emp.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                  <h5 style={{ textOverflow: 'ellipsis', whiteSpace: 'nowrap', overflow: 'hidden' }}>{emp.name}</h5>
                </Link>
                <p style={{ textOverflow: 'ellipsis', whiteSpace: 'nowrap', overflow: 'hidden' }}>{emp.role}</p>
                <div style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
                  <a href={`mailto:${emp.email}`} className="icon-btn" style={{ padding: '2px', borderRadius: 'var(--radius-sm)' }} title={emp.email}>
                    <Mail size={12} />
                  </a>
                  <a href={`tel:${emp.phone}`} className="icon-btn" style={{ padding: '2px', borderRadius: 'var(--radius-sm)' }} title={emp.phone}>
                    <Phone size={12} />
                  </a>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
