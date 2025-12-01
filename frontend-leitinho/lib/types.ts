export interface Animal {
  idanimal: number;
  name: string;
}

export interface UserType {
  iduserTypes: number;
  name: string;
}

export interface User {
  iduser: number;
  name: string;
  document: string;
  email: string;
  passwordHash: string;
  user: UserType;
  active: boolean;
  dataCadastro: string;
}

export interface Dairy {
  iddairy: number;
  name: string;
  dataCadastro: string;
}

export interface Farm {
  idfarm: number;
  name: string;
  producer: User;
  active: boolean;
  dataCadastro: string;
}

export interface Collection {
  idcollection: number;
  animal: Animal;
  farm: Farm;
  producer: User;
  collector: User;
  quantity: number;
  temperature: number;
  acidity: number;
  producerPresent: boolean;
  observations: string;
  collectionDate: string;
  edited: boolean;
  editCount: number;
  dataCadastro: string;
}

export interface LogCollection {
  idlogCollection: number;
  collection: Collection;
  name: string;
  description: string;
  user: User;
  dataCadastro: string;
}

export interface QualityIndicator {
  idqualityIndicator: number;
  collectionId: number;
  antibiotic: string;
  fat: string;
  approved: boolean;
  quality: string;
}

export interface UserDairy {
  userDairyKey: {
    dairy: Dairy;
    user: User;
  };
}

// User Types IDs
export const USER_TYPES = {
  COLETOR: 1,
  PRODUTOR: 2,
  LATICINIO: 3,
  ADMIN: 4,
} as const;
