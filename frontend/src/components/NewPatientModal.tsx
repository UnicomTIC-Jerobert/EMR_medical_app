// src/components/NewPatientModal.tsx
import React, { useState } from 'react';
import type { Patient, Gender } from '../types';
import { createPatient } from '../services/mockApi';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onCreated: (patient: Patient) => void;
}

export const NewPatientModal: React.FC<Props> = ({ isOpen, onClose, onCreated }) => {
  const [formData, setFormData] = useState({
    fullName: '',
    mobile: '',
    dob: '',
    gender: 'Male' as Gender,
    bloodGroup: 'O+',
    allergies: '',
    address: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.fullName || !formData.mobile || !formData.dob) {
      alert('Please fill in required fields: Name, Mobile, and Date of Birth');
      return;
    }
    setIsSubmitting(true);
    const newP = await createPatient(formData);
    setIsSubmitting(false);
    onCreated(newP);
    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal-dialog">
        <div className="modal-header">
          <h3 style={{ fontSize: '15px', fontWeight: 600 }}>
            <i className="fa fa-user-plus" style={{ marginRight: '8px', color: 'var(--primary)' }}></i>
            Register New Patient
          </h3>
          <button 
            type="button" 
            onClick={onClose} 
            style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '16px', color: 'var(--text-muted)' }}
          >
            <i className="fa fa-times"></i>
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            <div className="form-group">
              <label>Full Name *</label>
              <input
                type="text"
                required
                placeholder="e.g. John Doe"
                value={formData.fullName}
                onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
              />
            </div>

            <div className="form-grid">
              <div className="form-group">
                <label>Mobile Number *</label>
                <input
                  type="tel"
                  required
                  placeholder="10-digit number"
                  value={formData.mobile}
                  onChange={(e) => setFormData({ ...formData, mobile: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Date of Birth *</label>
                <input
                  type="date"
                  required
                  value={formData.dob}
                  onChange={(e) => setFormData({ ...formData, dob: e.target.value })}
                />
              </div>
            </div>

            <div className="form-grid">
              <div className="form-group">
                <label>Gender</label>
                <select
                  value={formData.gender}
                  onChange={(e) => setFormData({ ...formData, gender: e.target.value as Gender })}
                >
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div className="form-group">
                <label>Blood Group</label>
                <select
                  value={formData.bloodGroup}
                  onChange={(e) => setFormData({ ...formData, bloodGroup: e.target.value })}
                >
                  <option value="A+">A+</option>
                  <option value="A-">A-</option>
                  <option value="B+">B+</option>
                  <option value="B-">B-</option>
                  <option value="O+">O+</option>
                  <option value="O-">O-</option>
                  <option value="AB+">AB+</option>
                  <option value="AB-">AB-</option>
                </select>
              </div>
            </div>

            <div className="form-group">
              <label>Known Drug Allergies</label>
              <input
                type="text"
                placeholder="e.g. Penicillin, Aspirin (Leave blank if none)"
                value={formData.allergies}
                onChange={(e) => setFormData({ ...formData, allergies: e.target.value })}
              />
            </div>

            <div className="form-group">
              <label>Address</label>
              <input
                type="text"
                placeholder="Street, City"
                value={formData.address}
                onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              />
            </div>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
              {isSubmitting ? (
                <>
                  <i className="fa fa-spinner fa-spin"></i> Saving...
                </>
              ) : (
                'Save Patient'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};