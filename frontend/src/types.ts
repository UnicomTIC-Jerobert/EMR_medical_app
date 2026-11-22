// src/types.ts

export type Gender = 'Male' | 'Female' | 'Other';

export interface Patient {
  id: string;
  fullName: string;
  mobile: string;
  dob: string; // YYYY-MM-DD
  gender: Gender;
  bloodGroup: string;
  allergies?: string;
  address?: string;
  createdAt: string;
}

export interface Medicine {
  id: number;
  brandName: string;
  genericName: string;
  stockQty: number;
  unitPrice: number;
  category: string;
  symptoms: string[]; // Used for local semantic search mock
}

export interface PrescriptionItem {
  id: string;
  medicineId: number;
  medicineName: string;
  dosage: string;      // e.g. "500mg"
  frequency: string;   // e.g. "1-0-1" or "TID"
  durationDays: number;
  instructions: string;// e.g. "After food"
}

// Represents SQLite JSON column: clinical_data
export interface ClinicalData {
  bp?: string;          // e.g. "120/80"
  pulse?: string;       // e.g. "72 bpm"
  temperature?: string; // e.g. "98.6 F"
  weight?: string;      // e.g. "70 kg"
  spo2?: string;        // e.g. "98%"
  customNotes?: Record<string, string>; // Dynamic Key-Value store
}

export interface Visit {
  id: string;
  patientId: string;
  visitDate: string;
  chiefComplaints: string;
  clinicalData: ClinicalData;
  prescriptions: PrescriptionItem[];
}