import React, { useContext, useState } from 'react';
import { CheckSquare, ArrowRight, ArrowLeft, Clock, Plus, Tag, Search } from 'lucide-react';
import { AppContext } from '../context/AppContext';

export default function Tasks() {
  const { tasks, updateTaskStatus } = useContext(AppContext);
  const [taskSearch, setTaskSearch] = useState('');

  const columns = [
    { id: 'todo', title: 'To Do', color: '#64748b' },
    { id: 'in-progress', title: 'In Progress', color: 'var(--primary-blue)' },
    { id: 'review', title: 'In Review', color: 'var(--warning)' },
    { id: 'done', title: 'Completed', color: 'var(--success)' },
  ];

  // Filter tasks based on search
  const filteredTasks = tasks.filter(t => 
    t.title.toLowerCase().includes(taskSearch.toLowerCase()) ||
    t.assignee.toLowerCase().includes(taskSearch.toLowerCase())
  );

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'high': return 'priority-high';
      case 'medium': return 'priority-medium';
      case 'low': return 'priority-low';
      default: return '';
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px', height: '100%' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Task Board</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Manage and track assigned tasks in Kanban columns.</p>
        </div>
        <div className="sidebar-search" style={{ margin: 0, width: '280px' }}>
          <Search className="search-icon" size={16} />
          <input 
            type="text" 
            className="input-field" 
            placeholder="Search tasks, assignee..." 
            value={taskSearch}
            onChange={(e) => setTaskSearch(e.target.value)}
          />
        </div>
      </div>

      {/* Kanban Board Grid */}
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', 
        gap: '20px',
        alignItems: 'start',
        flex: 1
      }}>
        {columns.map(col => {
          const colTasks = filteredTasks.filter(t => t.status === col.id);
          return (
            <div key={col.id} className="glass-card" style={{ padding: '16px', minHeight: '400px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
              {/* Column Header */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderBottom: `2px solid ${col.color}`, paddingBottom: '8px' }}>
                <h3 style={{ fontSize: '1rem', fontWeight: 700 }}>{col.title}</h3>
                <span style={{ fontSize: '0.75rem', fontWeight: 700, padding: '2px 8px', borderRadius: 'var(--radius-round)', backgroundColor: 'var(--border-color)' }}>
                  {colTasks.length}
                </span>
              </div>

              {/* Column Body / Tasks list */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', flex: 1, overflowY: 'auto' }}>
                {colTasks.length === 0 ? (
                  <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.8rem', border: '1px dashed var(--border-color)', borderRadius: 'var(--radius-sm)' }}>
                    Empty Column
                  </div>
                ) : (
                  colTasks.map(task => (
                    <div 
                      key={task.id} 
                      className="glass-card" 
                      style={{ 
                        padding: '12px', 
                        backgroundColor: 'var(--bg-primary)', 
                        border: '1px solid var(--border-color)', 
                        display: 'flex', 
                        flexDirection: 'column',
                        gap: '10px'
                      }}
                    >
                      <h4 style={{ fontSize: '0.85rem', fontWeight: 600 }}>{task.title}</h4>

                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <span className={`badge-priority ${getPriorityColor(task.priority)}`}>
                          {task.priority}
                        </span>
                        <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                          Assignee: <strong>{task.assignee.split(' ')[0]}</strong>
                        </span>
                      </div>

                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.75rem', color: 'var(--text-muted)', borderTop: '1px solid var(--border-color)', paddingTop: '8px', marginTop: '4px' }}>
                        <span style={{ display: 'flex', alignItems: 'center', gap: '2px' }}>
                          <Clock size={12} />
                          {new Date(task.dueDate).toLocaleDateString([], { month: 'short', day: 'numeric' })}
                        </span>

                        {/* Status Advancement Buttons */}
                        <div style={{ display: 'flex', gap: '4px' }}>
                          {col.id !== 'todo' && (
                            <button 
                              className="icon-btn" 
                              title="Move back" 
                              onClick={() => {
                                const prevStatus = col.id === 'done' ? 'review' : col.id === 'review' ? 'in-progress' : 'todo';
                                updateTaskStatus(task.id, prevStatus);
                              }}
                              style={{ padding: '2px' }}
                            >
                              <ArrowLeft size={12} />
                            </button>
                          )}
                          {col.id !== 'done' && (
                            <button 
                              className="icon-btn" 
                              title="Move forward" 
                              onClick={() => {
                                const nextStatus = col.id === 'todo' ? 'in-progress' : col.id === 'in-progress' ? 'review' : 'done';
                                updateTaskStatus(task.id, nextStatus);
                              }}
                              style={{ padding: '2px' }}
                            >
                              <ArrowRight size={12} />
                            </button>
                          )}
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
