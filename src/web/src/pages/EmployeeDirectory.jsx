import React, { useContext, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { Mail, Phone, MapPin, Search } from 'lucide-react';
import { AppContext } from '../context/AppContext';

export default function EmployeeDirectory() {
  const { employees, searchQuery } = useContext(AppContext);
  const [activeDept, setActiveDept] = useState('All');
  const [localSearch, setLocalSearch] = useState('');
  const navigate = useNavigate();

  const departments = ['All', 'Engineering', 'Product', 'Design', 'Human Resources', 'Finance'];

  // Apply search query from both global search and local search input, plus department filtering
  const filteredEmployees = employees.filter(emp => {
    const matchesSearch = 
      emp.name.toLowerCase().includes(localSearch.toLowerCase()) ||
      emp.role.toLowerCase().includes(localSearch.toLowerCase()) ||
      emp.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      emp.role.toLowerCase().includes(searchQuery.toLowerCase());
      
    const matchesDept = activeDept === 'All' || emp.dept === activeDept;
    
    return matchesSearch && matchesDept;
  });

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Employee Directory</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Search and contact team members across the organization.</p>
      </div>

      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '16px', justifyContent: 'space-between', alignItems: 'center' }}>
        {/* Department tabs */}
        <div className="approval-type-tabs" style={{ margin: 0, flexWrap: 'wrap' }}>
          {departments.map(dept => (
            <button 
              key={dept} 
              className={`tab-btn ${activeDept === dept ? 'active' : ''}`}
              onClick={() => setActiveDept(dept)}
            >
              {dept}
            </button>
          ))}
        </div>

        {/* Local Search Input */}
        <div className="sidebar-search" style={{ margin: 0, width: '280px' }}>
          <Search className="search-icon" size={16} />
          <input 
            type="text" 
            className="input-field" 
            placeholder="Search name, title..." 
            value={localSearch}
            onChange={(e) => setLocalSearch(e.target.value)}
          />
        </div>
      </div>

      {/* Directory Grid */}
      {filteredEmployees.length === 0 ? (
        <div className="glass-card" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-muted)' }}>
          No team members found matching the filters.
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '20px' }}>
          {filteredEmployees.map(emp => (
            <div key={emp.id} className="glass-card" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', gap: '12px' }}>
              <img 
                src={emp.photo} 
                alt={emp.name} 
                style={{ width: '80px', height: '80px', borderRadius: 'var(--radius-round)', objectFit: 'cover', border: '3px solid var(--primary-blue-light)' }} 
              />
              <div>
                <Link to={`/employees/${emp.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                  <h3 style={{ fontSize: '1.1rem', fontWeight: 700 }}>{emp.name}</h3>
                </Link>
                <p style={{ fontSize: '0.85rem', color: 'var(--primary-blue)', fontWeight: 600, marginTop: '2px' }}>{emp.role}</p>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>{emp.dept}</p>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.8rem', color: 'var(--text-muted)' }}>
                <MapPin size={14} />
                <span>{emp.location}</span>
              </div>

              <div style={{ width: '100%', height: '1px', backgroundColor: 'var(--border-color)', margin: '4px 0' }}></div>

              <div style={{ display: 'flex', width: '100%', justifyContent: 'space-around' }}>
                <a href={`mailto:${emp.email}`} className="btn btn-secondary btn-mini" style={{ flex: 1, margin: '0 4px', gap: '6px' }}>
                  <Mail size={12} />
                  <span>Email</span>
                </a>
                <a href={`tel:${emp.phone}`} className="btn btn-ghost btn-mini" style={{ flex: 1, margin: '0 4px', gap: '6px' }}>
                  <Phone size={12} />
                  <span>Call</span>
                </a>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
