import React, { useContext, useState } from 'react';
import { AppContext } from '../context/AppContext';
import WelcomeSection from '../components/Dashboard/WelcomeSection';
import QuickStats from '../components/Dashboard/QuickStats';
import TasksWidget from '../components/Dashboard/TasksWidget';
import DashboardApprovals from '../components/Dashboard/DashboardApprovals';
import AnnouncementsWidget from '../components/Dashboard/AnnouncementsWidget';
import EventsWidget from '../components/Dashboard/EventsWidget';
import AttendanceSummary from '../components/Dashboard/AttendanceSummary';
import PerformanceAnalytics from '../components/Dashboard/PerformanceAnalytics';
import EmployeeDirectoryPreview from '../components/Dashboard/EmployeeDirectoryPreview';
import RecentDocuments from '../components/Dashboard/RecentDocuments';
import QuickAccess from '../components/Dashboard/QuickAccess';
import ActivityTimeline from '../components/Dashboard/ActivityTimeline';
import { Sliders, Eye, EyeOff, ChevronUp, ChevronDown, X } from 'lucide-react';
import '../styles/dashboard.css';

export default function Dashboard() {
  const { widgets, toggleWidgetVisibility, moveWidget } = useContext(AppContext);
  const [showCustomizer, setShowCustomizer] = useState(false);

  // Render widget component by id
  const renderWidget = (id) => {
    switch (id) {
      case 'tasks': return <TasksWidget />;
      case 'approvals': return <DashboardApprovals />;
      case 'announcements': return <AnnouncementsWidget />;
      case 'events': return <EventsWidget />;
      case 'attendance': return <AttendanceSummary />;
      case 'analytics': return <PerformanceAnalytics />;
      case 'directory': return <EmployeeDirectoryPreview />;
      case 'documents': return <RecentDocuments />;
      case 'quickaccess': return <QuickAccess />;
      case 'timeline': return <ActivityTimeline />;
      default: return null;
    }
  };

  // Sort widgets by order
  const sortedWidgets = [...widgets].sort((a, b) => a.order - b.order);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Dashboard Customization Options Trigger */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Corporate Intranet Hub</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Real-time activity and analytics across the organization.</p>
        </div>
        <button className="btn btn-ghost" style={{ gap: '8px' }} onClick={() => setShowCustomizer(true)}>
          <Sliders size={16} />
          <span>Customize Layout</span>
        </button>
      </div>

      {/* 1. Welcome Section (Fixed at top) */}
      {widgets.find(w => w.id === 'welcome')?.visible && <WelcomeSection />}

      {/* 2. Quick Stats Row (Fixed below welcome) */}
      {widgets.find(w => w.id === 'stats')?.visible && <QuickStats />}

      {/* 3. Customizable Widget Grid */}
      <div className="dashboard-grid">
        {sortedWidgets
          .filter(w => w.id !== 'welcome' && w.id !== 'stats') // handled above
          .filter(w => w.visible)
          .map((widget, index) => (
            <div 
              key={widget.id} 
              className={`widget-${widget.id}`}
              style={{ order: widget.order }}
            >
              {renderWidget(widget.id)}
            </div>
          ))
        }
      </div>

      {/* Customizer Overlay Modal */}
      {showCustomizer && (
        <div className="customizer-overlay">
          <div className="customizer-modal">
            <div className="widget-header">
              <div className="widget-title">
                <Sliders size={18} className="doc-icon" />
                <span>Customize Dashboard Layout</span>
              </div>
              <button className="icon-btn" onClick={() => setShowCustomizer(false)}><X size={18} /></button>
            </div>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', marginBottom: '16px' }}>
              Toggle visibility or reorder dashboard widgets using the actions below.
            </p>

            <div className="customizer-list">
              {sortedWidgets.map((widget, idx) => (
                <div key={widget.id} className="customizer-item">
                  <label>
                    <button 
                      onClick={() => toggleWidgetVisibility(widget.id)}
                      style={{ border: 'none', background: 'transparent', cursor: 'pointer', display: 'flex', color: widget.visible ? 'var(--primary-blue)' : 'var(--text-muted)' }}
                    >
                      {widget.visible ? <Eye size={18} /> : <EyeOff size={18} />}
                    </button>
                    <span style={{ textDecoration: widget.visible ? 'none' : 'line-through', opacity: widget.visible ? 1 : 0.6 }}>
                      {widget.name}
                    </span>
                  </label>

                  <div style={{ display: 'flex', gap: '4px' }}>
                    <button 
                      className="icon-btn" 
                      disabled={idx === 0}
                      onClick={() => moveWidget(idx, idx - 1)}
                      style={{ padding: '4px', opacity: idx === 0 ? 0.3 : 1 }}
                    >
                      <ChevronUp size={16} />
                    </button>
                    <button 
                      className="icon-btn" 
                      disabled={idx === widgets.length - 1}
                      onClick={() => moveWidget(idx, idx + 1)}
                      style={{ padding: '4px', opacity: idx === widgets.length - 1 ? 0.3 : 1 }}
                    >
                      <ChevronDown size={16} />
                    </button>
                  </div>
                </div>
              ))}
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: '16px' }}>
              <button className="btn btn-primary" onClick={() => setShowCustomizer(false)}>Save & Close</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
