import React, { useContext, useState } from 'react';
import { AppContext } from '../context/AppContext';
import { Settings as SettingsIcon, User, Sliders, Bell, CheckCircle } from 'lucide-react';

export default function Settings() {
  const { widgets, toggleWidgetVisibility, theme, toggleTheme } = useContext(AppContext);
  const [profile, setProfile] = useState({ name: 'Sarah Connor', email: 'sarah.connor@company.com', phone: '+1 (555) 012-3456', role: 'Sr. Executive Admin' });
  const [prefSaved, setPrefSaved] = useState(false);

  const handleSubmitProfile = (e) => {
    e.preventDefault();
    setPrefSaved(true);
    setTimeout(() => setPrefSaved(false), 3000);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Profile & Settings</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Configure your profile details, layout preferences, and notification channels.</p>
      </div>

      {prefSaved && (
        <div style={{ 
          display: 'flex', 
          alignItems: 'center', 
          gap: '8px', 
          padding: '12px', 
          borderRadius: 'var(--radius-sm)', 
          backgroundColor: 'var(--success-light)', 
          color: 'var(--success)',
          fontSize: '0.85rem',
          fontWeight: 500
        }}>
          <CheckCircle size={16} />
          <span>Profile configuration saved successfully!</span>
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '20px' }}>
        {/* Profile Settings form */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <User size={18} className="doc-icon" />
            <span>Personal Profile Details</span>
          </h3>

          <form onSubmit={handleSubmitProfile}>
            <div className="form-grid">
              <div className="form-group">
                <label>Full Name</label>
                <input type="text" className="input-field" value={profile.name} onChange={e => setProfile({...profile, name: e.target.value})} />
              </div>
              <div className="form-group">
                <label>Email Address</label>
                <input type="email" className="input-field" value={profile.email} onChange={e => setProfile({...profile, email: e.target.value})} />
              </div>
              <div className="form-group">
                <label>Phone Number</label>
                <input type="text" className="input-field" value={profile.phone} onChange={e => setProfile({...profile, phone: e.target.value})} />
              </div>
              <div className="form-group">
                <label>Role / Designation</label>
                <input type="text" className="input-field" disabled value={profile.role} />
              </div>
            </div>
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '20px' }}>
              <button type="submit" className="btn btn-primary">Save Profile</button>
            </div>
          </form>
        </div>

        {/* Dashboard customization controls */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Sliders size={18} className="doc-icon" />
            <span>Dashboard Layout Toggles</span>
          </h3>
          <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '16px' }}>
            Select which sections are visible on your landing dashboard view.
          </p>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px' }}>
            {widgets.map((widget) => (
              <label 
                key={widget.id} 
                style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  gap: '8px', 
                  fontSize: '0.85rem', 
                  cursor: 'pointer',
                  padding: '10px',
                  borderRadius: 'var(--radius-sm)',
                  backgroundColor: 'var(--bg-primary)',
                  border: '1px solid var(--border-color)'
                }}
              >
                <input 
                  type="checkbox" 
                  checked={widget.visible}
                  onChange={() => toggleWidgetVisibility(widget.id)}
                  style={{ width: '16px', height: '16px', cursor: 'pointer' }}
                />
                <span>{widget.name}</span>
              </label>
            ))}
          </div>
        </div>

        {/* Application configurations */}
        <div className="glass-card">
          <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <SettingsIcon size={18} className="doc-icon" />
            <span>Global Preferences</span>
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', fontSize: '0.85rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: '1px solid var(--border-color)', paddingBottom: '12px' }}>
              <div>
                <h4 style={{ fontWeight: 600 }}>Theme Control</h4>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '2px' }}>Toggle application lighting mode styles.</p>
              </div>
              <button className="btn btn-secondary btn-mini" onClick={toggleTheme}>
                Switch to {theme === 'light' ? 'Dark Mode' : 'Light Mode'}
              </button>
            </div>

            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '4px' }}>
              <div>
                <h4 style={{ fontWeight: 600 }}>Email Digests</h4>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '2px' }}>Receive weekly reports summarizing approvals and metrics.</p>
              </div>
              <input type="checkbox" defaultChecked style={{ width: '18px', height: '18px', cursor: 'pointer' }} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
