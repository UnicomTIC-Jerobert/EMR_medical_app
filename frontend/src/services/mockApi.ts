import type { Patient, Medicine } from '../types';

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
  },
  {
    id: 'P-1003',
    fullName: 'David Miller',
    mobile: '9789012345',
    dob: '1978-02-04',
    gender: 'Male',
    bloodGroup: 'B-',
    allergies: 'Sulfa drugs',
    address: '12 Riverbank Road',
    createdAt: '2023-07-20'
  }
];

export const searchPatients = async (query: string): Promise<Patient[]> => {
  await new Promise((r) => setTimeout(r, 120)); // Simulate SQLite index query time
  const cleanQ = query.trim().toLowerCase();
  if (!cleanQ) return [];

  return mockPatients.filter((p) => {
    const matchName = p.fullName.toLowerCase().includes(cleanQ);
    const matchMobile = p.mobile.includes(cleanQ);
    const matchDOB = p.dob.includes(cleanQ);
    return matchName || matchMobile || matchDOB;
  });
};

export const createPatient = async (data: Omit<Patient, 'id' | 'createdAt'>): Promise<Patient> => {
  await new Promise((r) => setTimeout(r, 200));
  const newPatient: Patient = {
    ...data,
    id: `P-${Math.floor(1000 + Math.random() * 9000)}`,
    createdAt: new Date().toISOString().split('T')[0]
  };
  mockPatients.unshift(newPatient);
  return newPatient;
};