// src/components/NewMedicineModal.tsx
import React, { useState } from 'react';
import type { Medicine } from '../types';
import { createMedicine } from '../services/mockApi';

interface Props {
  isOpen: boolean;
  onClose: () => void;
  onCreated: (med: Medicine) => void;
}

export const NewMedicineModal: React.FC<Props> = ({ isOpen, onClose, onCreated }) => {
  const [formData, setFormData] = useState({
    brandName: '',
    genericName: '',
    category: 'Antibiotic',
    stockQty: 100,
    unitPrice: 10.0,
    symptomsInput: ''
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.brandName || !formData.genericName) {
      alert('Please fill in Brand and Generic Name');
      return;
    }

    setIsSubmitting(true);

    // Split comma-separated symptoms into clean array for semantic indexing
    const symptoms = formData.symptomsInput
      .split(',')
      .map((s) => s.trim().toLowerCase())
      .filter(Boolean);

    const newMed = await createMedicine({
      brandName: formData.brandName,
      genericName: formData.genericName,
      category: formData.category,
      stockQty: Number(formData.stockQty),
      unitPrice: Number(formData.unitPrice),
      symptoms
    });

    setIsSubmitting(false);
    onCreated(newMed);
    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal-dialog">
        <div className="modal-header">
          <h3 style={{ fontSize: '15px', fontWeight: 600 }}>
            <i className="fa fa-plus-circle" style={{ marginRight: '8px', color: 'var(--primary)' }}></i>
            Add Medicine to Inventory
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
            <div className="form-grid">
              <div className="form-group">
                <label>Brand Name *</label>
                <input
                  required
                  placeholder="e.g. Zithromax 500"
                  value={formData.brandName}
                  onChange={(e) => setFormData({ ...formData, brandName: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Generic Chemical Name *</label>
                <input
                  required
                  placeholder="e.g. Azithromycin"
                  value={formData.genericName}
                  onChange={(e) => setFormData({ ...formData, genericName: e.target.value })}
                />
              </div>
            </div>

            <div className="form-grid">
              <div className="form-group">
                <label>Category</label>
                <select
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                >
                  <option value="Antibiotic">Antibiotic</option>
                  <option value="Antipyretic / Analgesic">Antipyretic / Analgesic</option>
                  <option value="Antacid / PPI">Antacid / PPI</option>
                  <option value="Antihistamine">Antihistamine</option>
                  <option value="Antihypertensive">Antihypertensive</option>
                  <option value="Antidiabetic">Antidiabetic</option>
                  <option value="Vitamin / Supplement">Vitamin / Supplement</option>
                </select>
              </div>

              <div className="form-group">
                <label>Initial Stock Units</label>
                <input
                  type="number"
                  min="0"
                  value={formData.stockQty}
                  onChange={(e) => setFormData({ ...formData, stockQty: Number(e.target.value) })}
                />
              </div>
            </div>

            <div className="form-group">
              <label>Unit Price ($ / ₹)</label>
              <input
                type="number"
                step="0.1"
                min="0"
                value={formData.unitPrice}
                onChange={(e) => setFormData({ ...formData, unitPrice: Number(e.target.value) })}
              />
            </div>

            <div className="form-group">
              <label>
                <i className="fa fa-magic" style={{ color: 'var(--primary)', marginRight: '4px' }}></i>
                Semantic Search Keywords & Symptoms (Comma-separated)
              </label>
              <textarea
                rows={2}
                placeholder="e.g. bacterial throat infection, severe cough, chest infection, bronchitis"
                value={formData.symptomsInput}
                onChange={(e) => setFormData({ ...formData, symptomsInput: e.target.value })}
              />
              <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                Doctors searching for any of these symptoms will match this medicine instantly.
              </span>
            </div>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn btn-secondary" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
              {isSubmitting ? 'Saving...' : 'Add Medicine'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};