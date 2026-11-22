// src/services/mockApi.ts
import type { Patient, Medicine, Visit } from '../types';

let mockPatients: Patient[] = [
  {
    id: 'P-1001',
    fullName: 'Robert Chen',
    mobile: '9876543210',
    dob: '1985-06-14',
    gender: 'Male',
    bloodGroup: 'O+',
    allergies: 'Penicillin',
    address: '42 Elm Street, Springfield',
    createdAt: '2023-01-10'
  },
  {
    id: 'P-1002',
    fullName: 'Sarah Jenkins',
    mobile: '9845123456',
    dob: '1992-11-23',
    gender: 'Female',
    bloodGroup: 'A+',
    allergies: 'None',
    address: '109 Baker Avenue, Springfield',
    createdAt: '2023-03-15'
  }
];

export let mockMedicines: Medicine[] = [
  {
    id: 1,
    brandName: 'Dolo 650',
    genericName: 'Paracetamol',
    stockQty: 240,
    unitPrice: 2.5,
    category: 'Antipyretic / Analgesic',
    symptoms: ['fever', 'headache', 'body pain', 'mild fever', 'temperature']
  },
  {
    id: 2,
    brandName: 'Augmentin 625 Duo',
    genericName: 'Amoxicillin + Clavulanic Acid',
    stockQty: 45,
    unitPrice: 18.0,
    category: 'Antibiotic',
    symptoms: ['bacterial infection', 'throat infection', 'sinusitis', 'ear pain', 'tonsils']
  },
  {
    id: 3,
    brandName: 'Pan 40',
    genericName: 'Pantoprazole',
    stockQty: 180,
    unitPrice: 8.5,
    category: 'Antacid / PPI',
    symptoms: ['acidity', 'gerd', 'heartburn', 'stomach burning', 'gastric ulcer', 'indigestion']
  },
  {
    id: 4,
    brandName: 'Allegra 120mg',
    genericName: 'Fexofenadine',
    stockQty: 85,
    unitPrice: 12.0,
    category: 'Antihistamine',
    symptoms: ['allergy', 'sneezing', 'runny nose', 'skin rash', 'itching', 'hay fever']
  },
  {
    id: 5,
    brandName: 'Azithral 500',
    genericName: 'Azithromycin',
    stockQty: 12,
    unitPrice: 22.0,
    category: 'Antibiotic',
    symptoms: ['chest infection', 'bronchitis', 'severe cough', 'throat ache']
  }
];

export const searchPatients = async (query: string): Promise<Patient[]> => {
  await new Promise((r) => setTimeout(r, 100));
  const cleanQ = query.trim().toLowerCase();
  if (!cleanQ) return [];
  return mockPatients.filter(
    (p) => p.fullName.toLowerCase().includes(cleanQ) || p.mobile.includes(cleanQ) || p.dob.includes(cleanQ)
  );
};

export const createPatient = async (data: Omit<Patient, 'id' | 'createdAt'>): Promise<Patient> => {
  await new Promise((r) => setTimeout(r, 150));
  const newPatient: Patient = {
    ...data,
    id: `P-${Math.floor(1000 + Math.random() * 9000)}`,
    createdAt: new Date().toISOString().split('T')[0]
  };
  mockPatients.unshift(newPatient);
  return newPatient;
};

// Simulates Vector / Semantic Search locally
export const semanticSearchMedicines = async (query: string): Promise<Medicine[]> => {
  await new Promise((r) => setTimeout(r, 90));
  const q = query.trim().toLowerCase();
  if (!q) return [];

  return mockMedicines.filter((m) => {
    const brandMatch = m.brandName.toLowerCase().includes(q);
    const genericMatch = m.genericName.toLowerCase().includes(q);
    const categoryMatch = m.category.toLowerCase().includes(q);
    // Semantic match (symptoms vector simulation)
    const symptomMatch = m.symptoms.some((s) => s.includes(q) || q.includes(s));
    return brandMatch || genericMatch || categoryMatch || symptomMatch;
  });
};

// Saves consultation & deducts stock transactionally
export const saveConsultationVisit = async (visitData: Omit<Visit, 'id'>): Promise<{ success: boolean; visitId: string }> => {
  await new Promise((r) => setTimeout(r, 250));

  // Deduct inventory
  visitData.prescriptions.forEach((item) => {
    const med = mockMedicines.find((m) => m.id === item.medicineId);
    if (med) {
      // Calculate daily doses approx
      med.stockQty = Math.max(0, med.stockQty - item.durationDays * 2);
    }
  });

  return { success: true, visitId: `VISIT-${Date.now().toString().slice(-6)}` };
};

// Append to src/services/mockApi.ts

export const getAllMedicines = async (): Promise<Medicine[]> => {
  await new Promise((r) => setTimeout(r, 100));
  return [...mockMedicines];
};

export const updateMedicineStock = async (id: number, delta: number): Promise<Medicine> => {
  await new Promise((r) => setTimeout(r, 100));
  const med = mockMedicines.find((m) => m.id === id);
  if (!med) throw new Error('Medicine not found');
  med.stockQty = Math.max(0, med.stockQty + delta);
  return { ...med };
};

export const createMedicine = async (
  data: Omit<Medicine, 'id'>
): Promise<Medicine> => {
  await new Promise((r) => setTimeout(r, 150));
  const newMed: Medicine = {
    ...data,
    id: mockMedicines.length > 0 ? Math.max(...mockMedicines.map((m) => m.id)) + 1 : 1
  };
  mockMedicines.unshift(newMed);
  return newMed;
};