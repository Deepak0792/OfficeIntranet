import React, { useContext } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Mail, Phone, MapPin, Calendar, Briefcase, FileText } from 'lucide-react';
import { AppContext } from '../context/AppContext';

export default function EmployeeDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { employees } = useContext(AppContext);

  // Find the selected employee
  const employee = employees.find(emp => emp.id === id);

  if (!employee) {
    return (
      <div className="glass-card" style={{ textAlign: 'center', padding: '40px' }}>
        <h2>Employee Not Found</h2>
        <p style={{ color: 'var(--text-muted)', margin: '12px 0 20px' }}>The requested employee ID does not exist in our systems.</p>
        <button className="btn btn-primary" onClick={() => navigate('/employees')}>
          <ArrowLeft size={16} />
          <span>Back to Directory</span>
        </button>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Back button */}
      <div>
        <button className="btn btn-ghost" onClick={() => navigate('/employees')} style={{ gap: '8px' }}>
          <ArrowLeft size={16} />
          <span>Back to Directory</span>
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
        {/* Main profile header card */}
        <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: '40px', gap: '16px' }}>
          <img 
            src={employee.photo} 
            alt={employee.name} 
            style={{ width: '120px', height: '120px', borderRadius: 'var(--radius-round)', objectFit: 'cover', border: '4px solid var(--primary-blue-light)' }} 
          />
          <div>
            <h2 style={{ fontSize: '1.8rem', fontWeight: 800 }}>{employee.name}</h2>
            <p style={{ fontSize: '1.1rem', color: 'var(--primary-blue)', fontWeight: 600, marginTop: '4px' }}>{employee.role}</p>
            <p style={{ fontSize: '0.95rem', color: 'var(--text-muted)' }}>{employee.dept} Department</p>
          </div>

          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '24px', justifyContent: 'center', color: 'var(--text-muted)', fontSize: '0.9rem', marginTop: '8px' }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <MapPin size={16} />
              {employee.location}
            </span>
            <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Calendar size={16} />
              Joined {new Date(employee.hireDate).toLocaleDateString([], { month: 'long', year: 'numeric', day: 'numeric' })}
            </span>
          </div>
        </div>

        {/* Detail cards */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
          {/* Biography */}
          <div className="glass-card">
            <h3 style={{ fontSize: '1.15rem', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
              <FileText size={18} className="doc-icon" />
              <span>Biography</span>
            </h3>
            <p style={{ fontSize: '0.95rem', lineHeight: '1.6', color: 'var(--text-main)' }}>{employee.bio}</p>
          </div>

          {/* Contact Information */}
          <div className="glass-card">
            <h3 style={{ fontSize: '1.15rem', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
              <Mail size={18} className="doc-icon" />
              <span>Contact Information</span>
            </h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--border-color)', paddingBottom: '8px' }}>
                <span style={{ fontSize: '0.9rem', color: 'var(--text-muted)' }}>Email Address</span>
                <a href={`mailto:${employee.email}`} style={{ fontSize: '0.95rem', color: 'var(--primary-blue)', fontWeight: 500, textDecoration: 'none' }}>{employee.email}</a>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '4px' }}>
                <span style={{ fontSize: '0.9rem', color: 'var(--text-muted)' }}>Phone Number</span>
                <a href={`tel:${employee.phone}`} style={{ fontSize: '0.95rem', color: 'var(--primary-blue)', fontWeight: 500, textDecoration: 'none' }}>{employee.phone}</a>
              </div>
            </div>
          </div>

          {/* Active Projects */}
          <div className="glass-card">
            <h3 style={{ fontSize: '1.15rem', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
              <Briefcase size={18} className="doc-icon" />
              <span>Assigned Projects</span>
            </h3>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px' }}>
              {employee.projects.map((proj, idx) => (
                <span 
                  key={idx} 
                  style={{ 
                    padding: '6px 14px', 
                    borderRadius: 'var(--radius-round)', 
                    backgroundColor: 'var(--primary-blue-light)', 
                    color: 'var(--primary-blue)', 
                    fontWeight: 600,
                    fontSize: '0.85rem' 
                  }}
                >
                  {proj}
                </span>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
