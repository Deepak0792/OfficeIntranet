import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Calendar, Users, Briefcase, FileText, CheckCircle2, Circle } from 'lucide-react';

export default function ProjectDetail() {
  const { id } = useParams();
  const navigate = useNavigate();

  const projectsConfig = {
    'proj-1': { name: 'Vapor Web UI', client: 'Internal Product', progress: 85, status: 'In Progress', dueDate: '2026-08-30', team: ['Alice Smith', 'Clara Oswald', 'Bob Johnson'], desc: 'Modernize the front-end user experience of the Core Vapor control system into a high-performance web dashboard.', milestones: [
      { id: 1, name: 'Wireframing & UX designs', completed: true },
      { id: 2, name: 'Component UI library building', completed: true },
      { id: 3, name: 'API gateway integration', completed: true },
      { id: 4, name: 'Performance tuning & caching tests', completed: false },
      { id: 5, name: 'Deploy final release to QA', completed: false }
    ]},
    'proj-2': { name: 'SdxCore Gateway Integration', client: 'Core Platforms', progress: 45, status: 'In Progress', dueDate: '2026-10-15', team: ['Alice Smith', 'Daniel Craig'], desc: 'Align building blocks of gateway proxy servers to support high-throughput intranet requests routing.', milestones: [
      { id: 1, name: 'Core proxy rules definition', completed: true },
      { id: 2, name: 'Docker network testing', completed: true },
      { id: 3, name: 'Access Control Lists (ACL) configurations', completed: false },
      { id: 4, name: 'Load balancing setup', completed: false }
    ]},
    'proj-3': { name: 'Kubernetes Cluster Migrations', client: 'Infrastructure', progress: 100, status: 'Completed', dueDate: '2026-06-10', team: ['Daniel Craig', 'Alice Smith'], desc: 'Transition corporate backend systems from legacy Virtual Machines into automated Kubernetes namespaces.', milestones: [
      { id: 1, name: 'Setup cluster control plane nodes', completed: true },
      { id: 2, name: 'Helm chart configurations deployment', completed: true },
      { id: 3, name: 'Live traffic routing switches', completed: true }
    ]},
    'proj-4': { name: 'User Onboarding Flows v2', client: 'Growth Marketing', progress: 20, status: 'In Progress', dueDate: '2026-11-01', team: ['Bob Johnson', 'Clara Oswald'], desc: 'Redesign onboarding checklist and profile creation guides to accelerate team integration.', milestones: [
      { id: 1, name: 'Onboarding survey forms drafting', completed: true },
      { id: 2, name: 'Develop wizard UI panels', completed: false },
      { id: 3, name: 'User analytics telemetry hookups', completed: false }
    ]},
    'proj-5': { name: 'Brand Guide Updates', client: 'PR & Communications', progress: 95, status: 'In Review', dueDate: '2026-06-18', team: ['Clara Oswald', 'Bob Johnson'], desc: 'Compile style regulations, font systems, color guidelines, and media assets kits.', milestones: [
      { id: 1, name: 'Collect brand typography specs', completed: true },
      { id: 2, name: 'Generate design tokens assets', completed: true },
      { id: 3, name: 'Review guidelines document with PM', completed: true },
      { id: 4, name: 'Final sign-off by VP Marketing', completed: false }
    ]},
    'proj-6': { name: 'Annual IT Security Hardening', client: 'SecOps', progress: 10, status: 'Initiation', dueDate: '2027-01-30', team: ['Daniel Craig', 'Alice Smith'], desc: 'Examine corporate infrastructure to eliminate vulnerabilities, update security certificates, and run pen tests.', milestones: [
      { id: 1, name: 'Conduct code analysis scan', completed: true },
      { id: 2, name: 'Database encryption key rotations', completed: false },
      { id: 3, name: 'Run external penetration test simulations', completed: false }
    ]},
  };

  const project = projectsConfig[id];

  if (!project) {
    return (
      <div className="glass-card" style={{ textAlign: 'center', padding: '40px' }}>
        <h2>Project Workspace Not Found</h2>
        <p style={{ color: 'var(--text-muted)', margin: '12px 0 20px' }}>The requested project workspace ID does not exist.</p>
        <button className="btn btn-primary" onClick={() => navigate('/projects')}>
          <ArrowLeft size={16} />
          <span>Back to Projects</span>
        </button>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <button className="btn btn-ghost" onClick={() => navigate('/projects')} style={{ gap: '8px' }}>
          <ArrowLeft size={16} />
          <span>Back to Projects</span>
        </button>
      </div>

      <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h2 style={{ fontSize: '1.6rem', fontWeight: 800 }}>{project.name}</h2>
          <span style={{ fontSize: '0.8rem', fontWeight: 700, padding: '4px 12px', borderRadius: 'var(--radius-sm)', backgroundColor: 'var(--primary-blue-light)', color: 'var(--primary-blue)' }}>
            {project.status}
          </span>
        </div>
        <p style={{ fontSize: '0.95rem', color: 'var(--text-muted)', lineHeight: '1.5' }}>{project.desc}</p>
        
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '20px', fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '8px' }}>
          <span>Client / Division: <strong>{project.client}</strong></span>
          <span>•</span>
          <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
            <Calendar size={14} />
            Due {new Date(project.dueDate).toLocaleDateString([], { month: 'long', day: 'numeric', year: 'numeric' })}
          </span>
        </div>

        <div style={{ marginTop: '10px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', fontWeight: 600, marginBottom: '6px' }}>
            <span>Completion Rate</span>
            <span>{project.progress}%</span>
          </div>
          <div className="progress-bar-container" style={{ width: '100%', height: '10px' }}>
            <div className="progress-bar-fill" style={{ width: `${project.progress}%` }}></div>
          </div>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
        {/* Milestones / Checklist */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.15rem', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
            <FileText size={18} className="doc-icon" />
            <span>Project Milestones Checklist</span>
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {project.milestones.map(mile => (
              <div key={mile.id} style={{ display: 'flex', alignItems: 'center', gap: '10px', fontSize: '0.9rem' }}>
                {mile.completed ? (
                  <CheckCircle2 size={18} style={{ color: 'var(--success)' }} />
                ) : (
                  <Circle size={18} style={{ color: 'var(--text-muted)' }} />
                )}
                <span style={{ textDecoration: mile.completed ? 'line-through' : 'none', opacity: mile.completed ? 0.6 : 1 }}>
                  {mile.name}
                </span>
              </div>
            ))}
          </div>
        </div>

        {/* Assigned Team Members list */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.15rem', display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
            <Users size={18} className="doc-icon" />
            <span>Assigned Team Roster</span>
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {project.team.map((name, idx) => (
              <div key={idx} style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '8px', borderRadius: 'var(--radius-sm)', backgroundColor: 'var(--bg-primary)' }}>
                <div style={{ 
                  width: '32px', 
                  height: '32px', 
                  borderRadius: 'var(--radius-round)', 
                  backgroundColor: 'var(--primary-blue)', 
                  color: 'white', 
                  display: 'flex', 
                  alignItems: 'center', 
                  justifyContent: 'center',
                  fontWeight: 700,
                  fontSize: '0.8rem'
                }}>
                  {name.split(' ').map(n => n[0]).join('')}
                </div>
                <span style={{ fontSize: '0.9rem', fontWeight: 600 }}>{name}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
