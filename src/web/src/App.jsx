import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import EmployeeDirectory from './pages/EmployeeDirectory';
import EmployeeDetail from './pages/EmployeeDetail';
import Departments from './pages/Departments';
import DepartmentDetail from './pages/DepartmentDetail';
import Projects from './pages/Projects';
import ProjectDetail from './pages/ProjectDetail';
import Tasks from './pages/Tasks';
import LeaveManagement from './pages/LeaveManagement';
import Attendance from './pages/Attendance';
import Documents from './pages/Documents';
import Approvals from './pages/Approvals';
import Announcements from './pages/Announcements';
import KnowledgeBase from './pages/KnowledgeBase';
import Calendar from './pages/Calendar';
import Reports from './pages/Reports';
import Settings from './pages/Settings';
import './styles/index.css';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="employees" element={<EmployeeDirectory />} />
          <Route path="employees/:id" element={<EmployeeDetail />} />
          <Route path="departments" element={<Departments />} />
          <Route path="departments/:id" element={<DepartmentDetail />} />
          <Route path="projects" element={<Projects />} />
          <Route path="projects/:id" element={<ProjectDetail />} />
          <Route path="tasks" element={<Tasks />} />
          <Route path="leave" element={<LeaveManagement />} />
          <Route path="attendance" element={<Attendance />} />
          <Route path="documents" element={<Documents />} />
          <Route path="approvals" element={<Approvals />} />
          <Route path="announcements" element={<Announcements />} />
          <Route path="knowledge-base" element={<KnowledgeBase />} />
          <Route path="calendar" element={<Calendar />} />
          <Route path="reports" element={<Reports />} />
          <Route path="settings" element={<Settings />} />
          <Route path="*" element={<Navigate to="/dashboard" replace />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
