// src/components/InventoryView.tsx
import React, { useState, useEffect } from 'react';
import type { Medicine } from '../types';
import { getAllMedicines, updateMedicineStock } from '../services/mockApi';
import { NewMedicineModal } from './NewMedicineModal';

export const InventoryView: React.FC = () => {
  const [medicines, setMedicines] = useState<Medicine[]>([]);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('ALL');
  const [isModalOpen, setIsModalOpen] = useState(false);

  const loadData = async () => {
    const list = await getAllMedicines();
    setMedicines(list);
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleQuickRestock = async (id: number, qty: number) => {
    const updated = await updateMedicineStock(id, qty);
    setMedicines((prev) => prev.map((m) => (m.id === id ? updated : m)));
  };

  // Filtered view
  const filtered = medicines.filter((m) => {
    const q = search.toLowerCase();
    const matchQuery =
      m.brandName.toLowerCase().includes(q) ||
      m.genericName.toLowerCase().includes(q) ||
      m.symptoms.some((s) => s.includes(q));

    const matchCategory = categoryFilter === 'ALL' || m.category === categoryFilter;
    return matchQuery && matchCategory;
  });

  // KPI Calculations
  const totalStockItems = medicines.reduce((sum, m) => sum + m.stockQty, 0);
  const lowStockCount = medicines.filter((m) => m.stockQty <= 20 && m.stockQty > 0).length;
  const outOfStockCount = medicines.filter((m) => m.stockQty === 0).length;

  return (
    <div className="inventory-container">
      {/* 1. KPI Cards */}
      <div className="kpi-grid">
        <div className="kpi-card">
          <div>
            <div className="kpi-label">Total Inventory Units</div>
            <div className="kpi-value">{totalStockItems.toLocaleString()}</div>
          </div>
          <div className="kpi-icon-badge kpi-icon-blue">
            <i className="fa fa-cubes"></i>
          </div>
        </div>

        <div className="kpi-card">
          <div>
            <div className="kpi-label">Low Stock (≤ 20)</div>
            <div className="kpi-value" style={{ color: 'var(--warning)' }}>{lowStockCount}</div>
          </div>
          <div className="kpi-icon-badge kpi-icon-amber">
            <i className="fa fa-exclamation-triangle"></i>
          </div>
        </div>

        <div className="kpi-card">
          <div>
            <div className="kpi-label">Out of Stock</div>
            <div className="kpi-value" style={{ color: 'var(--danger)' }}>{outOfStockCount}</div>
          </div>
          <div className="kpi-icon-badge kpi-icon-red">
            <i className="fa fa-ban"></i>
          </div>
        </div>
      </div>

      {/* 2. Control Bar */}
      <div className="inventory-controls">
        <div style={{ display: 'flex', gap: '10px', flex: 1, maxWidth: '600px' }}>
          <div className="search-input-wrapper" style={{ flex: 1 }}>
            <i className="fa fa-search search-icon-prefix"></i>
            <input
              type="text"
              className="patient-search-input"
              placeholder="Filter by brand, generic, or symptoms..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            style={{ width: '180px' }}
          >
            <option value="ALL">All Categories</option>
            <option value="Antibiotic">Antibiotics</option>
            <option value="Antipyretic / Analgesic">Antipyretics</option>
            <option value="Antacid / PPI">Antacids</option>
            <option value="Antihistamine">Antihistamines</option>
          </select>
        </div>

        <button className="btn btn-primary" onClick={() => setIsModalOpen(true)}>
          <i className="fa fa-plus"></i> Add New Medicine
        </button>
      </div>

      {/* 3. Inventory Table */}
      <div className="inventory-table-container">
        <table className="inventory-table">
          <thead>
            <tr>
              <th style={{ width: '22%' }}>Brand Name</th>
              <th style={{ width: '22%' }}>Generic Chemical Name</th>
              <th style={{ width: '18%' }}>Category</th>
              <th style={{ width: '12%' }}>Stock Status</th>
              <th style={{ width: '10%' }}>Unit Price</th>
              <th style={{ width: '16%', textAlign: 'right' }}>Quick Restock</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length > 0 ? (
              filtered.map((med) => {
                const isOutOfStock = med.stockQty === 0;
                const isLowStock = med.stockQty <= 20;

                return (
                  <tr key={med.id}>
                    <td>
                      <div style={{ fontWeight: 600 }}>{med.brandName}</div>
                      <div style={{ marginTop: '2px' }}>
                        {med.symptoms.slice(0, 3).map((sym) => (
                          <span key={sym} className="symptom-tag">{sym}</span>
                        ))}
                      </div>
                    </td>
                    <td style={{ color: 'var(--text-muted)' }}>{med.genericName}</td>
                    <td>
                      <span style={{ fontSize: '12px', background: '#f1f5f9', padding: '3px 8px', borderRadius: '4px' }}>
                        {med.category}
                      </span>
                    </td>
                    <td>
                      <span
                        className={`stock-badge ${
                          isOutOfStock ? 'stock-critical' : isLowStock ? 'stock-low' : 'stock-healthy'
                        }`}
                      >
                        {med.stockQty} units
                      </span>
                    </td>
                    <td>${med.unitPrice.toFixed(2)}</td>
                    <td style={{ textAlign: 'right' }}>
                      <button
                        type="button"
                        className="btn-restock-sm"
                        onClick={() => handleQuickRestock(med.id, 20)}
                        title="Add 20 units"
                      >
                        +20
                      </button>
                      <button
                        type="button"
                        className="btn-restock-sm"
                        onClick={() => handleQuickRestock(med.id, 50)}
                        title="Add 50 units"
                      >
                        +50
                      </button>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan={6} style={{ textAlign: 'center', padding: '30px', color: 'var(--text-muted)' }}>
                  No medicines match your filter.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <NewMedicineModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onCreated={(med) => setMedicines((prev) => [med, ...prev])}
      />
    </div>
  );
};