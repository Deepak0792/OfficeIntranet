import React, { useContext, useState } from 'react';
import { AppContext } from '../context/AppContext';
import { FolderOpen, FileText, FileSpreadsheet, Plus, Upload, Download, Search, CheckCircle } from 'lucide-react';

export default function Documents() {
  const { documents, addDocument } = useContext(AppContext);

  // States
  const [localSearch, setLocalSearch] = useState('');
  const [showUpload, setShowUpload] = useState(false);
  const [newFile, setNewFile] = useState({ name: '', size: '1.2 MB', type: 'pdf' });
  const [success, setSuccess] = useState(false);

  const folders = [
    { name: 'Policies & Handbooks', filesCount: 3 },
    { name: 'Brand & Marketing', filesCount: 5 },
    { name: 'Financial Forecasts', filesCount: 2 },
    { name: 'Engineering Specs', filesCount: 4 },
  ];

  const getDocIcon = (type) => {
    if (type === 'excel') return <FileSpreadsheet size={24} style={{ color: '#10b981' }} />;
    return <FileText size={24} style={{ color: '#0062ff' }} />;
  };

  const handleUploadSubmit = (e) => {
    e.preventDefault();
    if (!newFile.name) return;
    
    // Append extension if missing
    let filename = newFile.name;
    const ext = newFile.type === 'excel' ? '.xlsx' : newFile.type === 'word' ? '.docx' : '.pdf';
    if (!filename.toLowerCase().endsWith(ext)) {
      filename += ext;
    }

    addDocument({ name: filename, size: newFile.size, type: newFile.type });
    setSuccess(true);
    setNewFile({ name: '', size: '1.2 MB', type: 'pdf' });
    setTimeout(() => {
      setSuccess(false);
      setShowUpload(false);
    }, 2000);
  };

  const filteredDocs = documents.filter(doc => 
    doc.name.toLowerCase().includes(localSearch.toLowerCase())
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Document Library</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Browse corporate folders, shared manuals, and project assets.</p>
        </div>

        <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
          <div className="sidebar-search" style={{ margin: 0, width: '240px' }}>
            <Search className="search-icon" size={16} />
            <input 
              type="text" 
              className="input-field" 
              placeholder="Search library..." 
              value={localSearch}
              onChange={(e) => setLocalSearch(e.target.value)}
            />
          </div>

          <button className="btn btn-primary" style={{ gap: '6px' }} onClick={() => setShowUpload(true)}>
            <Plus size={16} />
            <span>Upload File</span>
          </button>
        </div>
      </div>

      {/* Folders Grid */}
      <div>
        <h3 style={{ fontSize: '1.1rem', marginBottom: '12px' }}>Folders</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: '20px' }}>
          {folders.map((fold, idx) => (
            <div key={idx} className="glass-card" style={{ display: 'flex', alignItems: 'center', gap: '14px', cursor: 'pointer' }}>
              <div style={{ color: 'var(--primary-blue)', display: 'flex', alignItems: 'center' }}>
                <FolderOpen size={32} />
              </div>
              <div>
                <h4 style={{ fontSize: '0.9rem', fontWeight: 700 }}>{fold.name}</h4>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{fold.filesCount} items</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Shared Files List */}
      <div className="glass-card">
        <h3 style={{ fontSize: '1.1rem', marginBottom: '16px' }}>Shared Files Workspace</h3>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {filteredDocs.length === 0 ? (
            <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
              No matching files found.
            </div>
          ) : (
            filteredDocs.map(doc => (
              <div 
                key={doc.id} 
                className="list-item" 
                style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  justifyContent: 'space-between',
                  padding: '12px 16px'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  {getDocIcon(doc.type)}
                  <div>
                    <h4 style={{ fontSize: '0.9rem', fontWeight: 600 }}>{doc.name}</h4>
                    <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)', marginTop: '2px' }}>
                      Size: {doc.size} • Version: {doc.version} • Modified: {doc.modified}
                    </p>
                  </div>
                </div>

                <div style={{ display: 'flex', gap: '6px' }}>
                  <button 
                    className="btn btn-secondary btn-mini" 
                    style={{ gap: '4px' }}
                    onClick={() => alert(`Downloading ${doc.name} (Simulated)`)}
                  >
                    <Download size={12} />
                    <span>Download</span>
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>

      {/* Upload File Simulation Modal */}
      {showUpload && (
        <div className="customizer-overlay">
          <div className="customizer-modal">
            <div className="widget-header">
              <div className="widget-title">
                <Upload size={18} className="doc-icon" />
                <span>Upload New File</span>
              </div>
              <button className="icon-btn" onClick={() => setShowUpload(false)}><Plus style={{ transform: 'rotate(45deg)' }} size={18} /></button>
            </div>

            {success ? (
              <div style={{ 
                display: 'flex', 
                flexDirection: 'column',
                alignItems: 'center', 
                gap: '12px', 
                padding: '30px 10px', 
                color: 'var(--success)',
                textAlign: 'center'
              }}>
                <CheckCircle size={48} />
                <h4 style={{ color: 'var(--success)' }}>Upload Complete!</h4>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>The file is now shared in the workspace database.</p>
              </div>
            ) : (
              <form onSubmit={handleUploadSubmit}>
                <div className="form-grid" style={{ gridTemplateColumns: '1fr' }}>
                  <div className="form-group">
                    <label>File Name</label>
                    <input 
                      type="text" 
                      required 
                      className="input-field" 
                      placeholder="e.g. Project_Milestones" 
                      value={newFile.name} 
                      onChange={e => setNewFile({ ...newFile, name: e.target.value })}
                    />
                  </div>
                  <div className="form-group">
                    <label>File Type</label>
                    <select 
                      className="input-field" 
                      value={newFile.type}
                      onChange={e => setNewFile({ ...newFile, type: e.target.value })}
                    >
                      <option value="pdf">Adobe PDF (.pdf)</option>
                      <option value="word">Word Document (.docx)</option>
                      <option value="excel">Excel Sheet (.xlsx)</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Simulated Size</label>
                    <input 
                      type="text" 
                      required 
                      className="input-field" 
                      value={newFile.size} 
                      onChange={e => setNewFile({ ...newFile, size: e.target.value })}
                    />
                  </div>
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px', marginTop: '20px' }}>
                  <button type="button" className="btn btn-ghost" onClick={() => setShowUpload(false)}>Cancel</button>
                  <button type="submit" className="btn btn-primary">Upload File</button>
                </div>
              </form>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
