// src/App.tsx
import React, { useState } from 'react';
import './App.css';
import './styles/patients.css';
import type { Patient } from './types';
import { PatientSearch } from './components/PatientSearch';
import { NewPatientModal } from './components/NewPatientModal';

export const App = () => {
  const [activeTab, setActiveTab] = useState<'consultation' | 'patients' | 'inventory'>('consultation');
  const [activePatient, setActivePatient] = useState<Patient | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <div className="app-container">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="brand-section">
          <i className="fa fa-heartbeat brand-icon"></i>
          <span>OmniClinic EMR</span>
        </div>
        <ul className="nav-list">
          <li 
            className={`nav-item ${activeTab === 'consultation' ? 'active' : ''}`}
            onClick={() => setActiveTab('consultation')}
          >
            <i className="fa fa-user-md"></i>
            <span>Consultation</span>
          </li>
          <li 
            className={`nav-item ${activeTab === 'patients' ? 'active' : ''}`}
            onClick={() => setActiveTab('patients')}
          >
            <i className="fa fa-users"></i>
            <span>Patients</span>
          </li>
          <li 
            className={`nav-item ${activeTab === 'inventory' ? 'active' : ''}`}
            onClick={() => setActiveTab('inventory')}
          >
            <i className="fa fa-medkit"></i>
            <span>Inventory</span>
          </li>
        </ul>
      </aside>

      {/* Main Panel */}
      <div className="main-wrapper">
        <header className="top-bar">
          <PatientSearch 
            onSelectPatient={(p) => setActivePatient(p)} 
            onOpenNewPatientModal={() => setIsModalOpen(true)}
          />
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
              <i className="fa fa-circle" style={{ color: 'var(--success)', fontSize: '10px', marginRight: '6px' }}></i>
              SQLite WAL Active
            </span>
          </div>
        </header>

        <main className="content-canvas">
          {/* Active Patient Banner */}
          {activePatient ? (
            <div className="patient-banner">
              <div>
                <div className="patient-banner-title">
                  <i className="fa fa-user-circle" style={{ color: 'var(--primary)' }}></i>
                  {activePatient.fullName}
                  <span style={{ fontSize: '12px', fontWeight: 500, color: 'var(--text-muted)' }}>
                    ({activePatient.gender}, DOB: {activePatient.dob})
                  </span>
                  {activePatient.allergies && activePatient.allergies !== 'None' && (
                    <span className="tag-badge">
                      <i className="fa fa-warning"></i> Allergy: {activePatient.allergies}
                    </span>
                  )}
                </div>
                <div className="patient-banner-details">
                  <span><b>ID:</b> {activePatient.id}</span>
                  <span><b>Mobile:</b> {activePatient.mobile}</span>
                  <span><b>Blood Group:</b> {activePatient.bloodGroup}</span>
                  {activePatient.address && <span><b>Address:</b> {activePatient.address}</span>}
                </div>
              </div>
              <button 
                className="btn btn-secondary" 
                style={{ fontSize: '12px' }}
                onClick={() => setActivePatient(null)}
              >
                <i className="fa fa-times"></i> Clear Selection
              </button>
            </div>
          ) : (
            <div style={{
              padding: '24px',
              textAlign: 'center',
              backgroundColor: 'var(--bg-surface)',
              border: '1px dashed var(--border-color)',
              borderRadius: 'var(--radius-md)',
              marginBottom: '20px',
              color: 'var(--text-muted)'
            }}>
              <i className="fa fa-search" style={{ fontSize: '24px', marginBottom: '8px', color: 'var(--text-light)' }}></i>
              <p>Search by <b>Mobile number</b>, <b>Patient Name</b>, or <b>DOB</b> above to load a consultation file.</p>
            </div>
          )}

          {/* Placeholders for upcoming steps */}
          {activePatient && (
            <div style={{
              background: 'var(--bg-surface)',
              border: '1px solid var(--border-color)',
              borderRadius: 'var(--radius-md)',
              padding: '20px'
            }}>
              <h3 style={{ fontSize: '15px', fontWeight: 600, marginBottom: '10px' }}>
                <i className="fa fa-stethoscope" style={{ color: 'var(--primary)', marginRight: '8px' }}></i>
                Consultation Record for {activePatient.fullName}
              </h3>
              <p style={{ color: 'var(--text-muted)', fontSize: '13px' }}>
                Ready for Dynamic Clinical Records (Vitals) and the Dynamic Prescription Table (Subtask 4 & 5).
              </p>
            </div>
          )}
        </main>
      </div>

      {/* Patient Registration Dialog */}
      <NewPatientModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onCreated={(newP) => setActivePatient(newP)}
      />
    </div>
  );
};

export default App;