import React from 'react';
import { Link } from 'react-router-dom';
import { Layers, Users, ShieldAlert, Cpu, Palette, BarChart, User } from 'lucide-react';

export default function Departments() {
  const departmentsList = [
    { id: 'dept-eng', name: 'Engineering', lead: 'Alice Smith', membersCount: 18, icon: Cpu, desc: 'Core platform development, gateway architecture, and system DevOps pipelines.' },
    { id: 'dept-prod', name: 'Product Management', lead: 'Bob Johnson', membersCount: 5, icon: Layers, desc: 'Roadmaps definition, user research, product strategy and requirements alignment.' },
    { id: 'dept-design', name: 'UI/UX Design', lead: 'Clara Oswald', membersCount: 4, icon: Palette, desc: 'Brand refreshing, interactive dashboards wireframing, design system management.' },
    { id: 'dept-hr', name: 'Human Resources', lead: 'Eva Green', membersCount: 3, icon: Users, desc: 'Employee benefits management, recruitment processes, talent onboarding and policies.' },
    { id: 'dept-fin', name: 'Finance & Accounts', lead: 'Frank Miller', membersCount: 3, icon: BarChart, desc: 'Corporate budgets coordination, expenses audit, resource forecasting and compliance.' },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Corporate Departments</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Overview of team divisions, heads of departments, and roles.</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '20px' }}>
        {departmentsList.map(dept => {
          const IconComponent = dept.icon;
          return (
            <div key={dept.id} className="glass-card" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between', gap: '16px' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <div style={{ 
                      display: 'flex', 
                      alignItems: 'center', 
                      justifyContent: 'center', 
                      width: '40px', 
                      height: '40px', 
                      borderRadius: 'var(--radius-sm)',
                      backgroundColor: 'var(--primary-blue-light)',
                      color: 'var(--primary-blue)'
                    }}>
                      <IconComponent size={20} />
                    </div>
                    <h3 style={{ fontSize: '1.2rem', fontWeight: 700 }}>{dept.name}</h3>
                  </div>
                  <span style={{ fontSize: '0.75rem', fontWeight: 700, padding: '4px 10px', borderRadius: 'var(--radius-round)', backgroundColor: 'var(--border-color)', color: 'var(--text-muted)' }}>
                    {dept.membersCount} Members
                  </span>
                </div>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', lineHeight: '1.5' }}>{dept.desc}</p>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.85rem' }}>
                  <User size={14} style={{ color: 'var(--text-muted)' }} />
                  <span>Lead: <strong>{dept.lead}</strong></span>
                </div>
                <Link to={`/departments/${dept.id}`} className="btn btn-secondary btn-mini" style={{ width: '100%' }}>
                  View Team Roster
                </Link>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
