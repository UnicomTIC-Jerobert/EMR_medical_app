// src/App.tsx
import React, { useState } from 'react';
import './App.css';
import './styles/patients.css';
import './styles/consultation.css';
import './styles/inventory.css';
import type { Patient } from './types';
import { PatientSearch } from './components/PatientSearch';
import { NewPatientModal } from './components/NewPatientModal';
import { ConsultationView } from './components/ConsultationView';
import { InventoryView } from './components/InventoryView';

export const App = () => {
  const [activeTab, setActiveTab] = useState<'consultation' | 'inventory'>('consultation');
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
            onSelectPatient={(p) => {
              setActivePatient(p);
              setActiveTab('consultation'); // Switch back to consultation automatically on search
            }} 
            onOpenNewPatientModal={() => setIsModalOpen(true)}
          />
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
              <i className="fa fa-circle" style={{ color: 'var(--success)', fontSize: '10px', marginRight: '6px' }}></i>
              SQLite Engine Active
            </span>
          </div>
        </header>

        <main className="content-canvas">
          {/* TAB 1: CONSULTATION */}
          {activeTab === 'consultation' && (
            <>
              {activePatient ? (
                <>
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
                      <i className="fa fa-times"></i> Change Patient
                    </button>
                  </div>

                  <ConsultationView 
                    patient={activePatient} 
                    onVisitSaved={() => setActivePatient(null)} 
                  />
                </>
              ) : (
                <div style={{
                  padding: '40px',
                  textAlign: 'center',
                  backgroundColor: 'var(--bg-surface)',
                  border: '1px dashed var(--border-color)',
                  borderRadius: 'var(--radius-md)',
                  color: 'var(--text-muted)'
                }}>
                  <i className="fa fa-search" style={{ fontSize: '28px', marginBottom: '12px', color: 'var(--text-light)' }}></i>
                  <h3 style={{ fontSize: '15px', color: 'var(--text-main)', marginBottom: '4px' }}>No Active Patient Selected</h3>
                  <p>Search by <b>Mobile number</b>, <b>Patient Name</b>, or <b>DOB</b> above, or register a new patient.</p>
                </div>
              )}
            </>
          )}

          {/* TAB 2: INVENTORY */}
          {activeTab === 'inventory' && <InventoryView />}
        </main>
      </div>

      {/* Patient Registration Dialog */}
      <NewPatientModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onCreated={(newP) => {
          setActivePatient(newP);
          setActiveTab('consultation');
        }}
      />
    </div>
  );
};

export default App;