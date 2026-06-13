import React, { useContext } from 'react';
import { Outlet } from 'react-router-dom';
import Header from './Header';
import Sidebar from './Sidebar';
import { AppContext } from '../context/AppContext';

export default function Layout() {
  const { sidebarOpen, setSidebarOpen } = useContext(AppContext);

  return (
    <div className="app-container">
      <Header />
      <Sidebar />
      
      {/* Mobile drawer backdrop overlay */}
      {sidebarOpen && (
        <div 
          className="sidebar-overlay" 
          style={{
            position: 'fixed',
            top: '70px',
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(0, 0, 0, 0.35)',
            backdropFilter: 'blur(3px)',
            zIndex: 85,
            transition: 'opacity 0.25s ease'
          }}
          onClick={() => setSidebarOpen(false)}
        />
      )}

      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
}
