import React, { useContext } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { ArrowLeft, User, Mail, Phone } from 'lucide-react';
import { AppContext } from '../context/AppContext';

export default function DepartmentDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { employees } = useContext(AppContext);

  // Department configurations
  const deptsConfig = {
    'dept-eng': { name: 'Engineering', lead: 'Alice Smith', desc: 'Core platform development, gateway architecture, and system DevOps pipelines.' },
    'dept-prod': { name: 'Product Management', lead: 'Bob Johnson', desc: 'Roadmaps definition, user research, product strategy and requirements alignment.' },
    'dept-design': { name: 'UI/UX Design', lead: 'Clara Oswald', desc: 'Brand refreshing, interactive dashboards wireframing, design system management.' },
    'dept-hr': { name: 'Human Resources', lead: 'Eva Green', desc: 'Employee benefits management, recruitment processes, talent onboarding and policies.' },
    'dept-fin': { name: 'Finance & Accounts', lead: 'Frank Miller', desc: 'Corporate budgets coordination, expenses audit, resource forecasting and compliance.' },
  };

  const currentDept = deptsConfig[id];

  if (!currentDept) {
    return (
      <div className="glass-card" style={{ textAlign: 'center', padding: '40px' }}>
        <h2>Department Not Found</h2>
        <p style={{ color: 'var(--text-muted)', margin: '12px 0 20px' }}>The requested department does not exist.</p>
        <button className="btn btn-primary" onClick={() => navigate('/departments')}>
          <ArrowLeft size={16} />
          <span>Back to Departments</span>
        </button>
      </div>
    );
  }

  // Filter employees matching the department name
  const roster = employees.filter(emp => emp.dept === currentDept.name);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <button className="btn btn-ghost" onClick={() => navigate('/departments')} style={{ gap: '8px' }}>
          <ArrowLeft size={16} />
          <span>Back to Departments</span>
        </button>
      </div>

      <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
        <h2 style={{ fontSize: '1.6rem', fontWeight: 800 }}>{currentDept.name} Department</h2>
        <p style={{ fontSize: '0.95rem', color: 'var(--text-muted)' }}>{currentDept.desc}</p>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.9rem', marginTop: '10px', padding: '8px 12px', borderRadius: 'var(--radius-sm)', backgroundColor: 'var(--primary-blue-light)', color: 'var(--primary-blue)', alignSelf: 'flex-start' }}>
          <User size={16} />
          <span>Department Lead: <strong>{currentDept.lead}</strong></span>
        </div>
      </div>

      <div>
        <h3 style={{ fontSize: '1.25rem', marginBottom: '16px' }}>Team Roster ({roster.length})</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '20px' }}>
          {roster.map(emp => (
            <div key={emp.id} className="glass-card" style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
              <img 
                src={emp.photo} 
                alt={emp.name} 
                style={{ width: '50px', height: '50px', borderRadius: 'var(--radius-round)', objectFit: 'cover' }} 
              />
              <div style={{ flex: 1, overflow: 'hidden' }}>
                <Link to={`/employees/${emp.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                  <h4 style={{ fontSize: '0.95rem', fontWeight: 700, textOverflow: 'ellipsis', whiteSpace: 'nowrap', overflow: 'hidden' }}>{emp.name}</h4>
                </Link>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', margin: '2px 0 6px', textOverflow: 'ellipsis', whiteSpace: 'nowrap', overflow: 'hidden' }}>{emp.role}</p>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <a href={`mailto:${emp.email}`} className="icon-btn" style={{ padding: '4px', borderRadius: 'var(--radius-sm)' }}>
                    <Mail size={12} />
                  </a>
                  <a href={`tel:${emp.phone}`} className="icon-btn" style={{ padding: '4px', borderRadius: 'var(--radius-sm)' }}>
                    <Phone size={12} />
                  </a>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
