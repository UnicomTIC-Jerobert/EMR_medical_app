// src/components/ConsultationView.tsx
import React, { useState } from 'react';
import type { Patient, PrescriptionItem, Medicine, ClinicalData } from '../types';
import { semanticSearchMedicines, saveConsultationVisit } from '../services/mockApi';

interface Props {
  patient: Patient;
  onVisitSaved: () => void;
}

export const ConsultationView: React.FC<Props> = ({ patient, onVisitSaved }) => {
  // Chief Complaints & Clinical Notes
  const [chiefComplaints, setChiefComplaints] = useState('');

  // Fixed Vitals (Relational attributes)
  const [vitals, setVitals] = useState({
    bp: '120/80',
    pulse: '72',
    temperature: '98.4',
    weight: '68',
    spo2: '99'
  });

  // Dynamic NoSQL Attributes (Saved as JSON in SQLite)
  const [customParams, setCustomParams] = useState<{ id: string; key: string; value: string }[]>([]);

  // Dynamic Prescription Rows
  const [items, setItems] = useState<PrescriptionItem[]>([
    {
      id: 'row-1',
      medicineId: 0,
      medicineName: '',
      dosage: '500mg',
      frequency: '1-0-1',
      durationDays: 5,
      instructions: 'After food'
    }
  ]);

  // Active Dropdown state for medicine search
  const [activeSearchIndex, setActiveSearchIndex] = useState<number | null>(null);
  const [searchResults, setSearchResults] = useState<Medicine[]>([]);
  const [saving, setSaving] = useState(false);

  // Handle Dynamic Rows
  const addRow = () => {
    setItems([
      ...items,
      {
        id: `row-${Date.now()}`,
        medicineId: 0,
        medicineName: '',
        dosage: '1 tab',
        frequency: '1-0-1',
        durationDays: 3,
        instructions: 'After meals'
      }
    ]);
  };

  const removeRow = (index: number) => {
    if (items.length === 1) return; // Keep at least one row
    setItems(items.filter((_, i) => i !== index));
  };

  const updateRow = <K extends keyof PrescriptionItem>(index: number, key: K, value: PrescriptionItem[K]) => {
    const updated = [...items];
    updated[index][key] = value;
    setItems(updated);
  };

  // Medicine Semantic Search Trigger
  const handleMedInput = async (index: number, text: string) => {
    updateRow(index, 'medicineName', text);
    if (text.trim().length >= 2) {
      setActiveSearchIndex(index);
      const meds = await semanticSearchMedicines(text);
      setSearchResults(meds);
    } else {
      setActiveSearchIndex(null);
      setSearchResults([]);
    }
  };

  const selectMedicine = (index: number, med: Medicine) => {
    const updated = [...items];
    updated[index].medicineId = med.id;
    updated[index].medicineName = med.brandName;
    setItems(updated);
    setActiveSearchIndex(null);
  };

  // Dynamic NoSQL Parameters
  const addCustomParam = () => {
    setCustomParams([...customParams, { id: `param-${Date.now()}`, key: '', value: '' }]);
  };

  const removeCustomParam = (id: string) => {
    setCustomParams(customParams.filter((p) => p.id !== id));
  };

  const updateCustomParam = (id: string, field: 'key' | 'value', val: string) => {
    setCustomParams(
      customParams.map((p) => (p.id === id ? { ...p, [field]: val } : p))
    );
  };

  // Final Submission
  const handleFinalizeVisit = async () => {
    if (items.some((it) => !it.medicineName)) {
      alert('Please select or specify medicine names for all rows.');
      return;
    }

    setSaving(true);
    // Build NoSQL JSON structure
    const customNotesObj: Record<string, string> = {};
    customParams.forEach((cp) => {
      if (cp.key.trim()) customNotesObj[cp.key.trim()] = cp.value.trim();
    });

    const clinicalPayload: ClinicalData = {
      bp: vitals.bp,
      pulse: vitals.pulse,
      temperature: vitals.temperature,
      weight: vitals.weight,
      spo2: vitals.spo2,
      customNotes: customNotesObj
    };

    const res = await saveConsultationVisit({
      patientId: patient.id,
      visitDate: new Date().toISOString(),
      chiefComplaints,
      clinicalData: clinicalPayload,
      prescriptions: items
    });

    setSaving(false);
    if (res.success) {
      alert(`Visit ${res.visitId} recorded successfully! Stock deducted.`);
      onVisitSaved();
    }
  };

  return (
    <div className="consultation-container">
      {/* 1. Clinical Notes & Observations (NoSQL JSON Data) */}
      <div className="clinical-card">
        <div className="clinical-card-header">
          <span className="clinical-card-title">
            <i className="fa fa-heartbeat" style={{ color: 'var(--danger)' }}></i>
            Vitals & Dynamic Clinical Observations (NoSQL)
          </span>
          <button type="button" className="btn btn-secondary" style={{ fontSize: '11.5px', padding: '4px 8px' }} onClick={addCustomParam}>
            <i className="fa fa-plus"></i> Add Custom Field
          </button>
        </div>

        <div className="clinical-card-body">
          {/* Base Vitals */}
          <div className="vitals-grid">
            <div className="vital-input-box">
              <label className="vital-label"><i className="fa fa-dashboard"></i> BP (mmHg)</label>
              <input value={vitals.bp} onChange={(e) => setVitals({ ...vitals, bp: e.target.value })} placeholder="120/80" />
            </div>
            <div className="vital-input-box">
              <label className="vital-label"><i className="fa fa-heart"></i> Pulse (bpm)</label>
              <input value={vitals.pulse} onChange={(e) => setVitals({ ...vitals, pulse: e.target.value })} placeholder="72" />
            </div>
            <div className="vital-input-box">
              <label className="vital-label"><i className="fa fa-thermometer-half"></i> Temp (°F)</label>
              <input value={vitals.temperature} onChange={(e) => setVitals({ ...vitals, temperature: e.target.value })} placeholder="98.4" />
            </div>
            <div className="vital-input-box">
              <label className="vital-label"><i className="fa fa-user"></i> Weight (kg)</label>
              <input value={vitals.weight} onChange={(e) => setVitals({ ...vitals, weight: e.target.value })} placeholder="70" />
            </div>
            <div className="vital-input-box">
              <label className="vital-label"><i className="fa fa-tint"></i> SpO2 (%)</label>
              <input value={vitals.spo2} onChange={(e) => setVitals({ ...vitals, spo2: e.target.value })} placeholder="99" />
            </div>
          </div>

          {/* Dynamic NoSQL Key-Values (e.g. Blood Sugar, Waist, Allergy notes) */}
          {customParams.length > 0 && (
            <div className="dynamic-obs-container">
              <div style={{ fontSize: '12px', fontWeight: 600, color: 'var(--text-muted)', marginBottom: '8px' }}>
                Custom Parameters (Stored in SQLite JSON column):
              </div>
              {customParams.map((cp) => (
                <div key={cp.id} className="dynamic-obs-row">
                  <input
                    placeholder="Field Name (e.g. Fasting Sugar)"
                    value={cp.key}
                    onChange={(e) => updateCustomParam(cp.id, 'key', e.target.value)}
                    style={{ width: '220px' }}
                  />
                  <input
                    placeholder="Observation Value (e.g. 110 mg/dL)"
                    value={cp.value}
                    onChange={(e) => updateCustomParam(cp.id, 'value', e.target.value)}
                    style={{ flex: 1 }}
                  />
                  <button type="button" className="btn btn-danger" style={{ padding: '6px 10px' }} onClick={() => removeCustomParam(cp.id)}>
                    <i className="fa fa-trash"></i>
                  </button>
                </div>
              ))}
            </div>
          )}

          <div style={{ marginTop: '16px' }}>
            <label className="vital-label" style={{ marginBottom: '6px' }}>
              <i className="fa fa-stethoscope"></i> Chief Complaints & Clinical Findings
            </label>
            <textarea
              rows={2}
              style={{ width: '100%', resize: 'vertical' }}
              placeholder="e.g. Patient presents with high fever, sore throat for 3 days. No cough..."
              value={chiefComplaints}
              onChange={(e) => setChiefComplaints(e.target.value)}
            />
          </div>
        </div>
      </div>

      {/* 2. Dynamic Prescriptions Table with Semantic Search */}
      <div className="clinical-card">
        <div className="clinical-card-header">
          <span className="clinical-card-title">
            <i className="fa fa-medkit" style={{ color: 'var(--primary)' }}></i>
            Prescription Items (Dynamic Table with Semantic Search)
          </span>
          <button type="button" className="btn btn-secondary" style={{ fontSize: '12px' }} onClick={addRow}>
            <i className="fa fa-plus"></i> Add Medicine Row
          </button>
        </div>

        <div className="clinical-card-body" style={{ padding: 0 }}>
          <div className="prescription-table-wrapper">
            <table className="prescription-table">
              <thead>
                <tr>
                  <th style={{ width: '35%' }}>Medicine Name (Brand / Generic / Symptoms)</th>
                  <th style={{ width: '15%' }}>Dosage</th>
                  <th style={{ width: '15%' }}>Frequency</th>
                  <th style={{ width: '10%' }}>Days</th>
                  <th style={{ width: '20%' }}>Instructions</th>
                  <th style={{ width: '5%', textAlign: 'center' }}></th>
                </tr>
              </thead>
              <tbody>
                {items.map((row, idx) => (
                  <tr key={row.id}>
                    {/* Medicine Semantic Search Dropdown */}
                    <td className="med-search-cell">
                      <input
                        type="text"
                        className="table-input"
                        placeholder="Search by symptom or name (e.g. fever, amox, acidity)..."
                        value={row.medicineName}
                        onChange={(e) => handleMedInput(idx, e.target.value)}
                      />
                      {activeSearchIndex === idx && searchResults.length > 0 && (
                        <div className="med-dropdown">
                          {searchResults.map((med) => (
                            <div
                              key={med.id}
                              className="med-dropdown-item"
                              onClick={() => selectMedicine(idx, med)}
                            >
                              <div>
                                <div style={{ fontWeight: 600, fontSize: '13px' }}>{med.brandName}</div>
                                <div className="med-generic-sub">{med.genericName} • {med.category}</div>
                                <div style={{ marginTop: '2px' }}>
                                  {med.symptoms.slice(0, 3).map((sym) => (
                                    <span key={sym} className="symptom-tag">{sym}</span>
                                  ))}
                                </div>
                              </div>
                              <span
                                className={`stock-badge ${
                                  med.stockQty > 50 ? 'stock-healthy' : med.stockQty > 15 ? 'stock-low' : 'stock-critical'
                                }`}
                              >
                                {med.stockQty} in stock
                              </span>
                            </div>
                          ))}
                        </div>
                      )}
                    </td>

                    {/* Dosage */}
                    <td>
                      <input
                        type="text"
                        className="table-input"
                        placeholder="500mg"
                        value={row.dosage}
                        onChange={(e) => updateRow(idx, 'dosage', e.target.value)}
                      />
                    </td>

                    {/* Frequency */}
                    <td>
                      <select
                        className="table-input"
                        value={row.frequency}
                        onChange={(e) => updateRow(idx, 'frequency', e.target.value)}
                      >
                        <option value="1-0-1">1-0-1 (Twice Daily)</option>
                        <option value="1-1-1">1-1-1 (Thrice Daily)</option>
                        <option value="1-0-0">1-0-0 (Morning Only)</option>
                        <option value="0-0-1">0-0-1 (Night Only)</option>
                        <option value="SOS">SOS (As Needed)</option>
                      </select>
                    </td>

                    {/* Duration in Days */}
                    <td>
                      <input
                        type="number"
                        min="1"
                        className="table-input"
                        value={row.durationDays}
                        onChange={(e) => updateRow(idx, 'durationDays', parseInt(e.target.value) || 1)}
                      />
                    </td>

                    {/* Instructions */}
                    <td>
                      <input
                        type="text"
                        className="table-input"
                        placeholder="After meals"
                        value={row.instructions}
                        onChange={(e) => updateRow(idx, 'instructions', e.target.value)}
                      />
                    </td>

                    {/* Actions */}
                    <td style={{ textAlign: 'center' }}>
                      <button
                        type="button"
                        className="btn btn-danger"
                        style={{ padding: '4px 8px', fontSize: '11px' }}
                        onClick={() => removeRow(idx)}
                        disabled={items.length === 1}
                        title="Remove Medicine"
                      >
                        <i className="fa fa-times"></i>
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* 3. Action Footer Bar */}
      <div className="action-bar">
        <button type="button" className="btn btn-secondary" onClick={addRow}>
          <i className="fa fa-plus"></i> Add Another Medicine
        </button>
        <button
          type="button"
          className="btn btn-primary"
          style={{ padding: '10px 24px', fontSize: '14px' }}
          onClick={handleFinalizeVisit}
          disabled={saving}
        >
          {saving ? (
            <>
              <i className="fa fa-spinner fa-spin"></i> Finalizing & Updating Stock...
            </>
          ) : (
            <>
              <i className="fa fa-check"></i> Finalize Consultation & Print
            </>
          )}
        </button>
      </div>
    </div>
  );
};