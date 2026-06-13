import React, { useContext } from 'react';
import { Link } from 'react-router-dom';
import { FolderOpen, ArrowRight, FileText, Download, FileSpreadsheet } from 'lucide-react';
import { AppContext } from '../../context/AppContext';

export default function RecentDocuments() {
  const { documents, searchQuery } = useContext(AppContext);

  // Filter documents by global search query
  const filteredDocs = documents
    .filter(doc => doc.name.toLowerCase().includes(searchQuery.toLowerCase()))
    .slice(0, 4); // Limit to top 4

  const getDocIcon = (type) => {
    if (type === 'excel') return <FileSpreadsheet className="doc-icon" size={16} style={{ color: '#10b981' }} />;
    return <FileText className="doc-icon" size={16} style={{ color: '#0062ff' }} />;
  };

  return (
    <div className="glass-card">
      <div className="widget-header">
        <div className="widget-title">
          <FolderOpen size={18} className="doc-icon" />
          <span>Recent Documents</span>
        </div>
        <Link to="/documents" className="icon-btn" style={{ fontSize: '0.8rem', gap: '4px', textDecoration: 'none', color: 'var(--primary-blue)' }}>
          <span>Files</span>
          <ArrowRight size={14} />
        </Link>
      </div>

      <div className="item-list">
        {filteredDocs.length === 0 ? (
          <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
            No matching documents found
          </div>
        ) : (
          filteredDocs.map(doc => (
            <div key={doc.id} className="list-item document-item">
              <div className="document-meta-info">
                {getDocIcon(doc.type)}
                <div className="document-details">
                  <h5 style={{ fontSize: '0.85rem', fontWeight: 600 }}>{doc.name}</h5>
                  <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                    {doc.size} • Version {doc.version} • {doc.modified}
                  </p>
                </div>
              </div>

              <button 
                className="icon-btn" 
                title="Download file" 
                onClick={() => alert(`Downloading ${doc.name} (Simulated)`)}
                style={{ padding: '6px' }}
              >
                <Download size={14} />
              </button>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
