// src/components/PatientSearch.tsx
import React, { useState, useEffect, useRef } from 'react';
import type { Patient } from '../types';
import { searchPatients } from '../services/mockApi';

interface Props {
  onSelectPatient: (patient: Patient) => void;
  onOpenNewPatientModal: () => void;
}

export const PatientSearch: React.FC<Props> = ({ onSelectPatient, onOpenNewPatientModal }) => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<Patient[]>([]);
  const [loading, setLoading] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const wrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handler = setTimeout(async () => {
      if (query.trim().length >= 2) {
        setLoading(true);
        const data = await searchPatients(query);
        setResults(data);
        setLoading(false);
        setIsOpen(true);
      } else {
        setResults([]);
        setIsOpen(false);
      }
    }, 150);

    return () => clearTimeout(handler);
  }, [query]);

  // Click outside listener to dismiss dropdown
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
      <div className="search-container" ref={wrapperRef}>
        <div className="search-input-wrapper">
          <i className="fa fa-search search-icon-prefix"></i>
          <input
            type="text"
            className="patient-search-input"
            placeholder="Search by Mobile, Patient Name, or DOB (YYYY-MM-DD)..."
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onFocus={() => query.trim().length >= 2 && setIsOpen(true)}
          />
          {loading && <i className="fa fa-circle-o-notch fa-spin search-spinner"></i>}
        </div>

        {isOpen && (
          <div className="search-results-dropdown">
            {results.length > 0 ? (
              results.map((patient) => (
                <div
                  key={patient.id}
                  className="search-result-item"
                  onClick={() => {
                    onSelectPatient(patient);
                    setIsOpen(false);
                    setQuery('');
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center' }}>
                    <div className="patient-avatar-badge">
                      {patient.fullName.charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: '13.5px' }}>{patient.fullName}</div>
                      <div className="patient-meta">
                        <span><i className="fa fa-phone"></i> {patient.mobile}</span>
                        <span><i className="fa fa-calendar"></i> {patient.dob}</span>
                        <span><i className="fa fa-tint"></i> {patient.bloodGroup}</span>
                      </div>
                    </div>
                  </div>
                  <span style={{ fontSize: '11px', color: 'var(--text-light)', fontWeight: 600 }}>
                    {patient.id}
                  </span>
                </div>
              ))
            ) : (
              <div className="no-results-box">
                <p>No patient matching "{query}"</p>
                <button
                  type="button"
                  className="btn btn-primary"
                  style={{ marginTop: '8px', fontSize: '12px' }}
                  onClick={() => {
                    setIsOpen(false);
                    onOpenNewPatientModal();
                  }}
                >
                  <i className="fa fa-user-plus"></i> Register New Patient
                </button>
              </div>
            )}
          </div>
        )}
      </div>

      <button className="btn btn-primary" onClick={onOpenNewPatientModal}>
        <i className="fa fa-plus"></i> New Patient
      </button>
    </div>
  );
};