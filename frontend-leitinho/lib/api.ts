const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080/api";

interface ApiResponse<T> {
  status: number;
  data: T;
  message: string;
}

async function request<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<ApiResponse<T>> {
  const url = `${API_BASE_URL}${endpoint}`;

  const config: RequestInit = {
    ...options,
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      ...options.headers,
    },
  };

  const response = await fetch(url, config);
  const data = await response.json();
  return data;
}

function toFormData(obj: Record<string, any>): string {
  return Object.entries(obj)
    .filter(
      ([_, value]) => value !== undefined && value !== null && value !== ""
    )
    .map(
      ([key, value]) =>
        `${encodeURIComponent(key)}=${encodeURIComponent(value)}`
    )
    .join("&");
}

// ==================== ADMIN ====================
export const adminApi = {
  load: () => request("/admin/load/", { method: "POST" }),
};

// ==================== ANIMALS ====================
export const animalsApi = {
  list: () => request<any[]>("/animals/"),
  get: (id: number) => request<any>(`/animals/${id}`),
  create: (data: { name: string }) =>
    request("/animals/", { method: "POST", body: toFormData(data) }),
  update: (data: { idanimal: number; name: string }) =>
    request("/animals/", { method: "PATCH", body: toFormData(data) }),
  delete: (idanimal: number) =>
    request("/animals/", { method: "DELETE", body: toFormData({ idanimal }) }),
  count: () => request<number>("/animals/contar/"),
};

// ==================== COLLECTIONS ====================
export const collectionsApi = {
  list: () => request<any[]>("/collections/"),
  get: (id: number) => request<any>(`/collections/${id}`),
  create: (data: {
    farmid: number;
    producerid: number;
    collectorid: number;
    quantity: number;
    temperature: number;
    acidity: number;
    producerPresent: boolean;
    collectionDate: string;
    animalid?: number;
    observations?: string;
  }) => request("/collections/", { method: "POST", body: toFormData(data) }),
  update: (data: {
    idcollection: number;
    farmid: number;
    producerid: number;
    collectorid: number;
    quantity: number;
    temperature: number;
    acidity: number;
    producerPresent: boolean;
    collectionDate: string;
    animalid?: number;
    observations?: string;
  }) => request("/collections/", { method: "PATCH", body: toFormData(data) }),
  delete: (idcollection: number) =>
    request("/collections/", {
      method: "DELETE",
      body: toFormData({ idcollection }),
    }),
  count: () => request<number>("/collections/contar/"),
};

// ==================== COLLECTORS ====================
export const collectorsApi = {
  history: (
    id: number,
    params?: {
      farmid?: number;
      page?: number;
      limit?: number;
      startDate?: string;
      endDate?: string;
    }
  ) => {
    const query = params ? `?${toFormData(params)}` : "";
    return request<any[]>(`/collectors/${id}/collections/history/${query}`);
  },
  stats: (producerid: number) =>
    request<any>(`/collectors/stats/?${toFormData({ producerid })}`),
};

// ==================== DAIRYS ====================
export const dairysApi = {
  list: () => request<any[]>("/dairys/"),
  get: (id: number) => request<any>(`/dairys/${id}`),
  create: (data: { name: string }) =>
    request("/dairys/", { method: "POST", body: toFormData(data) }),
  update: (data: { iddairy: number; name: string }) =>
    request("/dairys/", { method: "PATCH", body: toFormData(data) }),
  delete: (iddairy: number) =>
    request("/dairys/", { method: "DELETE", body: toFormData({ iddairy }) }),
  count: () => request<number>("/dairys/contar/"),
};

// ==================== FARMS ====================
export const farmsApi = {
  list: () => request<any[]>("/farms/"),
  get: (id: number) => request<any>(`/farms/${id}`),
  create: (data: { name: string; producerid: number }) =>
    request("/farms/", { method: "POST", body: toFormData(data) }),
  update: (data: { idfarm: number; name: string; producerid: number }) =>
    request("/farms/", { method: "PATCH", body: toFormData(data) }),
  delete: (idfarm: number) =>
    request("/farms/", { method: "DELETE", body: toFormData({ idfarm }) }),
  count: () => request<number>("/farms/contar/"),
  qrcode: (id: number) => request<string>(`/farms/qrcode/${id}`),
};

// ==================== USERS ====================
export const usersApi = {
  list: () => request<any[]>("/users/"),
  get: (id: number) => request<any>(`/users/${id}`),
  create: (data: {
    name: string;
    document: string;
    email: string;
    passwordHash: string;
    type: number;
  }) => request("/users/", { method: "POST", body: toFormData(data) }),
  update: (data: {
    iduser: number;
    name: string;
    document: string;
    email: string;
    passwordHash: string;
    type: number;
  }) => request("/users/", { method: "PATCH", body: toFormData(data) }),
  delete: (iduser: number) =>
    request("/users/", { method: "DELETE", body: toFormData({ iduser }) }),
  activate: (id: number) => request(`/users/ativar/${id}`),
  deactivate: (id: number) => request(`/users/desativar/${id}`),
  count: () => request<number>("/users/contar/"),
};

// ==================== USER TYPES ====================
export const userTypesApi = {
  list: () => request<any[]>("/usertypes/"),
  get: (id: number) => request<any>(`/usertypes/${id}`),
  count: () => request<number>("/usertypes/contar/"),
};

// ==================== PRODUCERS ====================
export const producersApi = {
  collections: (id: number) => request<any[]>(`/producers/${id}/collections/`),
  stats: (producerid: number, params?: { year?: number; month?: number }) => {
    const query = toFormData({ producerid, ...params });
    return request<any>(`/producers/stats/?${query}`);
  },
};

// ==================== QUALITY INDICATORS ====================
export const qualityIndicatorsApi = {
  list: () => request<any[]>("/qualityindicators/"),
  get: (id: number) => request<any>(`/qualityindicators/${id}`),
  create: (data: {
    collectionId: number;
    antibiotic: string;
    fat: string;
    approved: boolean;
    quality: string;
  }) =>
    request("/qualityindicators/", { method: "POST", body: toFormData(data) }),
  update: (data: {
    idqualityIndicator: number;
    collectionId: number;
    antibiotic: string;
    fat: string;
    approved: boolean;
    quality: string;
  }) =>
    request("/qualityindicators/", { method: "PATCH", body: toFormData(data) }),
  delete: (idqualityIndicator: number) =>
    request("/qualityindicators/", {
      method: "DELETE",
      body: toFormData({ idqualityIndicator }),
    }),
  count: () => request<number>("/qualityindicators/contar/"),
};

// ==================== USER DAIRY ====================
export const userDairyApi = {
  list: () => request<any[]>("/userdairy/"),
  create: (data: { dairy: number; user: number }) =>
    request("/userdairy/", { method: "POST", body: toFormData(data) }),
  delete: (dairys: number, users: number) =>
    request("/userdairy/", {
      method: "DELETE",
      body: toFormData({ dairys, users }),
    }),
  count: () => request<number>("/userdairy/contar/"),
};
