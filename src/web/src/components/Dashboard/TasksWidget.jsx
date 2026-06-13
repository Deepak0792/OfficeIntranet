import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { CheckSquare, ArrowRight, Clock } from 'lucide-react';
import { AppContext } from '../../context/AppContext';

export default function TasksWidget() {
  const { tasks, updateTaskStatus, searchQuery } = useContext(AppContext);

  // Filter tasks to show open ones (todo or in-progress or review), and apply search filter
  const activeTasks = tasks
    .filter(t => t.status !== 'done')
    .filter(t => t.title.toLowerCase().includes(searchQuery.toLowerCase()))
    .slice(0, 4); // Limit to top 4 in dashboard preview

  return (
    <div className="glass-card">
      <div className="widget-header">
        <div className="widget-title">
          <CheckSquare size={18} className="doc-icon" />
          <span>My Tasks</span>
        </div>
        <Link to="/tasks" className="icon-btn" style={{ fontSize: '0.8rem', gap: '4px', textDecoration: 'none', color: 'var(--primary-blue)' }}>
          <span>View All</span>
          <ArrowRight size={14} />
        </Link>
      </div>

      <div className="item-list">
        {activeTasks.length === 0 ? (
          <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
            No pending tasks found
          </div>
        ) : (
          activeTasks.map(task => (
            <div key={task.id} className="list-item">
              <div style={{ display: 'flex', gap: '12px', alignItems: 'flex-start', flex: 1 }}>
                <input 
                  type="checkbox" 
                  style={{ marginTop: '4px', cursor: 'pointer', width: '16px', height: '16px' }}
                  checked={task.status === 'done'}
                  onChange={() => updateTaskStatus(task.id, 'done')}
                />
                <div className="task-item-main">
                  <span style={{ fontSize: '0.85rem', fontWeight: 600 }}>{task.title}</span>
                  <div className="task-meta">
                    <span className={`badge-priority priority-${task.priority}`}>{task.priority}</span>
                    <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <Clock size={12} />
                      Due {new Date(task.dueDate).toLocaleDateString([], { month: 'short', day: 'numeric' })}
                    </span>
                  </div>
                </div>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '4px' }}>
                <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--text-muted)' }}>{task.progress}%</span>
                <div className="progress-bar-container">
                  <div className="progress-bar-fill" style={{ width: `${task.progress}%` }}></div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
