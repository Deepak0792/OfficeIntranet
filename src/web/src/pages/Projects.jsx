import React from 'react';
import { Link } from 'react-router-dom';
import { Briefcase, Calendar, Users, ArrowRight } from 'lucide-react';

export default function Projects() {
  const projectsList = [
    { id: 'proj-1', name: 'Vapor Web UI', client: 'Internal Product', progress: 85, status: 'In Progress', dueDate: '2026-08-30', teamSize: 8, lead: 'Alice Smith' },
    { id: 'proj-2', name: 'SdxCore Gateway Integration', client: 'Core Platforms', progress: 45, status: 'In Progress', dueDate: '2026-10-15', teamSize: 5, lead: 'Alice Smith' },
    { id: 'proj-3', name: 'Kubernetes Cluster Migrations', client: 'Infrastructure', progress: 100, status: 'Completed', dueDate: '2026-06-10', teamSize: 3, lead: 'Daniel Craig' },
    { id: 'proj-4', name: 'User Onboarding Flows v2', client: 'Growth Marketing', progress: 20, status: 'In Progress', dueDate: '2026-11-01', teamSize: 4, lead: 'Bob Johnson' },
    { id: 'proj-5', name: 'Brand Guide Updates', client: 'PR & Communications', progress: 95, status: 'In Review', dueDate: '2026-06-18', teamSize: 2, lead: 'Clara Oswald' },
    { id: 'proj-6', name: 'Annual IT Security Hardening', client: 'SecOps', progress: 10, status: 'Initiation', dueDate: '2027-01-30', teamSize: 6, lead: 'Daniel Craig' },
  ];

  const getStatusColor = (status) => {
    switch (status) {
      case 'Completed': return { bg: 'var(--success-light)', text: 'var(--success)' };
      case 'In Review': return { bg: 'var(--warning-light)', text: 'var(--warning)' };
      case 'In Progress': return { bg: 'var(--primary-blue-light)', text: 'var(--primary-blue)' };
      default: return { bg: 'var(--border-color)', text: 'var(--text-muted)' };
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Projects Portfolio</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Track development timelines, completion states, and project leads.</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '20px' }}>
        {projectsList.map(proj => {
          const colors = getStatusColor(proj.status);
          return (
            <div key={proj.id} className="glass-card" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between', gap: '16px' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                  <h3 style={{ fontSize: '1.15rem', fontWeight: 700 }}>{proj.name}</h3>
                  <span style={{ fontSize: '0.7rem', fontWeight: 700, padding: '2px 8px', borderRadius: 'var(--radius-sm)', backgroundColor: colors.bg, color: colors.text }}>
                    {proj.status}
                  </span>
                </div>
                <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Client: {proj.client}</p>
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.8rem', fontWeight: 600, marginBottom: '6px' }}>
                  <span>Completion</span>
                  <span>{proj.progress}%</span>
                </div>
                <div className="progress-bar-container" style={{ width: '100%', height: '8px' }}>
                  <div className="progress-bar-fill" style={{ width: `${proj.progress}%` }}></div>
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.8rem', color: 'var(--text-muted)', borderTop: '1px solid var(--border-color)', paddingTop: '12px' }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Calendar size={14} />
                  Due {new Date(proj.dueDate).toLocaleDateString([], { month: 'short', day: 'numeric', year: 'numeric' })}
                </span>
                <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                  <Users size={14} />
                  {proj.teamSize} members
                </span>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <div style={{ fontSize: '0.8rem' }}>Lead: <strong>{proj.lead}</strong></div>
                <Link to={`/projects/${proj.id}`} className="btn btn-secondary btn-mini" style={{ width: '100%', gap: '6px' }}>
                  <span>Project Workspace</span>
                  <ArrowRight size={12} />
                </Link>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
