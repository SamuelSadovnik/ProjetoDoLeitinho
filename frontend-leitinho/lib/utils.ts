// Função auxiliar para parsear datas em diferentes formatos
function parseDate(dateString: string): Date | null {
  if (!dateString) return null;
  
  let normalized = dateString.trim();
  
  // Formato brasileiro: "dd/MM/yyyy HH:mm:ss" ou "dd/MM/yyyy HH:mm"
  if (normalized.includes('/')) {
    const parts = normalized.split(' ');
    const datePart = parts[0]; // dd/MM/yyyy
    const timePart = parts[1] || '00:00:00'; // HH:mm:ss
    
    const [day, month, year] = datePart.split('/');
    if (day && month && year) {
      // Converte para formato ISO: yyyy-MM-ddTHH:mm:ss
      normalized = `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}T${timePart}`;
    }
  }
  // Formato ISO com espaço: "yyyy-MM-dd HH:mm:ss" ou "yyyy-MM-dd HH:mm:ss.SSS"
  else if (normalized.includes(' ') && !normalized.includes('T')) {
    normalized = normalized.replace(' ', 'T');
    // Remove milissegundos se existirem
    const parts = normalized.split('.');
    if (parts.length > 1) {
      normalized = parts[0];
    }
  }
  
  const date = new Date(normalized);
  
  // Verifica se a data é válida
  if (isNaN(date.getTime())) {
    return null;
  }
  
  return date;
}

export function formatDate(dateString: string): string {
  if (!dateString) return "-";
  const date = parseDate(dateString);
  if (!date) return "Data inválida";
  return date.toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  });
}

export function formatDateTime(dateString: string): string {
  if (!dateString) return "-";
  const date = parseDate(dateString);
  if (!date) return "Data inválida";
  return date.toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export function formatCPF(cpf: string): string {
  if (!cpf) return "-";
  const cleaned = cpf.replace(/\D/g, "");
  if (cleaned.length === 11) {
    return cleaned.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, "$1.$2.$3-$4");
  }
  return cpf;
}

export function formatCNPJ(cnpj: string): string {
  if (!cnpj) return "-";
  const cleaned = cnpj.replace(/\D/g, "");
  if (cleaned.length === 14) {
    return cleaned.replace(
      /(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/,
      "$1.$2.$3/$4-$5"
    );
  }
  return cnpj;
}

export function formatDocument(doc: string): string {
  if (!doc) return "-";
  const cleaned = doc.replace(/\D/g, "");
  if (cleaned.length === 11) return formatCPF(doc);
  if (cleaned.length === 14) return formatCNPJ(doc);
  return doc;
}

export function formatNumber(num: number, decimals = 2): string {
  if (num === null || num === undefined) return "-";
  return num.toLocaleString("pt-BR", {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
}

export function capitalizeFirst(str: string): string {
  if (!str) return "";
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

export function cn(...classes: (string | undefined | null | false)[]): string {
  return classes.filter(Boolean).join(" ");
}
