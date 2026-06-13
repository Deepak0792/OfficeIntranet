import React, { useState } from 'react';
import { BookOpen, Search, ChevronRight, HelpCircle, Shield, FileText, Cpu } from 'lucide-react';

export default function KnowledgeBase() {
  const [kbSearch, setKbSearch] = useState('');
  const [activeArticle, setActiveArticle] = useState(null);

  const categories = [
    { title: 'IT & Infrastructure Guides', icon: Cpu, count: 8 },
    { title: 'HR Policies & Benefits', icon: FileText, count: 12 },
    { title: 'Financial Claim Procedures', icon: HelpCircle, count: 5 },
    { title: 'Security & Compliance Regulations', icon: Shield, count: 6 },
  ];

  const articles = [
    { 
      id: 1, 
      category: 'IT & Infrastructure Guides', 
      title: 'How to setup corporate VPN tunnel', 
      content: 'To connect to the corporate VPN, download and install AnyConnect client. Launch the application, input the host gateway address "vpn.company.com", click Connect, and authenticate using your Okta Single Sign-On credentials.' 
    },
    { 
      id: 2, 
      category: 'IT & Infrastructure Guides', 
      title: 'Connecting to Wi-Fi networks in office', 
      content: 'When working inside nationwide offices, select the SSID "Corporate_Secure". Log in using your email ID prefix and Active Directory password. Unmanaged devices are restricted to the "Corporate_Guest" network.' 
    },
    { 
      id: 3, 
      category: 'HR Policies & Benefits', 
      title: 'Health & Dental insurance policies overview', 
      content: 'Corporate offers 100% premium coverage for employees and 80% coverage for dependents. Dental claims are managed by BlueCross. Policies documents can be downloaded from the Shared Documents folder.' 
    },
    { 
      id: 4, 
      category: 'HR Policies & Benefits', 
      title: 'Understanding personal leave accrual rates', 
      content: 'Full-time employees accrue Annual Leave at a rate of 1.67 days per month, yielding 20 days annually. Accrued days rollover limits are capped at 5 days into the next fiscal calendar year.' 
    },
    { 
      id: 5, 
      category: 'Financial Claim Procedures', 
      title: 'Submitting expense reimbursement claim guidelines', 
      content: 'Submit expense reports within 30 days of purchase. Receipts are mandatory for all transactions exceeding $25.00. Once submitted, allow 3-5 business days for HR review and bank disbursement.' 
    },
  ];

  // Filter articles based on user input
  const filteredArticles = articles.filter(art => 
    art.title.toLowerCase().includes(kbSearch.toLowerCase()) ||
    art.content.toLowerCase().includes(kbSearch.toLowerCase())
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '1.8rem', fontWeight: 800 }}>Knowledge Base</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.9rem' }}>Read guidelines, policies, and instructional setups across departments.</p>
        </div>

        <div className="sidebar-search" style={{ margin: 0, width: '300px' }}>
          <Search className="search-icon" size={16} />
          <input 
            type="text" 
            className="input-field" 
            placeholder="Search wiki articles..." 
            value={kbSearch}
            onChange={(e) => setKbSearch(e.target.value)}
          />
        </div>
      </div>

      {/* Categories Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '20px' }}>
        {categories.map((cat, idx) => {
          const Icon = cat.icon;
          return (
            <div key={idx} className="glass-card" style={{ display: 'flex', alignItems: 'center', gap: '14px', cursor: 'pointer' }}>
              <div style={{ color: 'var(--primary-blue)', display: 'flex', alignItems: 'center' }}>
                <Icon size={28} />
              </div>
              <div>
                <h4 style={{ fontSize: '0.85rem', fontWeight: 700 }}>{cat.title}</h4>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{cat.count} articles</p>
              </div>
            </div>
          );
        })}
      </div>

      {/* Articles List */}
      <div className="glass-card">
        <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <BookOpen size={18} className="doc-icon" />
          <span>Faq & Help Guides ({filteredArticles.length})</span>
        </h3>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {filteredArticles.length === 0 ? (
            <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '0.85rem' }}>
              No articles match your search.
            </div>
          ) : (
            filteredArticles.map(art => (
              <div 
                key={art.id} 
                className="list-item" 
                style={{ 
                  display: 'flex', 
                  flexDirection: 'column', 
                  alignItems: 'stretch',
                  padding: '14px 18px',
                  cursor: 'pointer'
                }}
                onClick={() => setActiveArticle(activeArticle === art.id ? null : art.id)}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div style={{ display: 'flex', flexDirection: 'column' }}>
                    <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--primary-blue)', textTransform: 'uppercase', marginBottom: '2px' }}>
                      {art.category}
                    </span>
                    <h4 style={{ fontSize: '0.9rem', fontWeight: 600 }}>{art.title}</h4>
                  </div>
                  <ChevronRight 
                    size={16} 
                    style={{ 
                      color: 'var(--text-muted)',
                      transform: activeArticle === art.id ? 'rotate(90deg)' : 'none',
                      transition: 'transform var(--transition-fast)'
                    }} 
                  />
                </div>

                {activeArticle === art.id && (
                  <div style={{ marginTop: '12px', borderTop: '1px solid var(--border-color)', paddingTop: '10px', fontSize: '0.85rem', lineHeight: '1.5', color: 'var(--text-main)' }}>
                    {art.content}
                  </div>
                )}
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
