"use client";

import { useEffect, useState } from "react";
import {
  Plus,
  Pencil,
  Trash2,
  Search,
  UserCheck,
  UserX,
  History,
} from "lucide-react";
import {
  Button,
  Card,
  CardContent,
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
  Badge,
  Modal,
  Input,
  LoadingPage,
} from "@/components/ui";
import { usersApi, collectorsApi } from "@/lib/api";
import {
  formatDocument,
  formatDateTime,
  capitalizeFirst,
  formatNumber,
} from "@/lib/utils";
import { User, USER_TYPES, Collection } from "@/lib/types";

export default function ColetoresPage() {
  const [loading, setLoading] = useState(true);
  const [coletores, setColetores] = useState<User[]>([]);
  const [filteredColetores, setFilteredColetores] = useState<User[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isHistoryModalOpen, setIsHistoryModalOpen] = useState(false);
  const [selectedColetor, setSelectedColetor] = useState<User | null>(null);
  const [coletorHistory, setColetorHistory] = useState<Collection[]>([]);
  const [editingColetor, setEditingColetor] = useState<User | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    document: "",
    email: "",
    passwordHash: "",
  });
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    loadColetores();
  }, []);

  useEffect(() => {
    const filtered = coletores.filter(
      (c) =>
        c.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.document?.includes(searchTerm)
    );
    setFilteredColetores(filtered);
  }, [searchTerm, coletores]);

  async function loadColetores() {
    try {
      const response = await usersApi.list();
      const allUsers = Array.isArray(response.data) ? response.data : [];
      const coletoresList = allUsers.filter(
        (u: User) => u.user?.iduserTypes === USER_TYPES.COLETOR
      );
      setColetores(coletoresList);
      setFilteredColetores(coletoresList);
    } catch (error) {
      console.error("Error loading coletores:", error);
    } finally {
      setLoading(false);
    }
  }

  async function openHistoryModal(coletor: User) {
    setSelectedColetor(coletor);
    try {
      const response = await collectorsApi.history(coletor.iduser, {
        limit: 20,
      });
      const historyData = Array.isArray(response.data) ? response.data : [];
      setColetorHistory(historyData);
      setIsHistoryModalOpen(true);
    } catch (error) {
      console.error("Error loading history:", error);
      setColetorHistory([]);
      setIsHistoryModalOpen(true);
    }
  }

  function openCreateModal() {
    setEditingColetor(null);
    setFormData({ name: "", document: "", email: "", passwordHash: "" });
    setFormErrors({});
    setIsModalOpen(true);
  }

  function openEditModal(coletor: User) {
    setEditingColetor(coletor);
    setFormData({
      name: coletor.name,
      document: coletor.document,
      email: coletor.email,
      passwordHash: "",
    });
    setFormErrors({});
    setIsModalOpen(true);
  }

  function validateForm() {
    const errors: Record<string, string> = {};
    if (!formData.name.trim()) errors.name = "Nome é obrigatório";
    if (!formData.document.trim()) errors.document = "Documento é obrigatório";
    if (!formData.email.trim()) errors.email = "Email é obrigatório";
    if (!editingColetor && !formData.passwordHash.trim()) {
      errors.passwordHash = "Senha é obrigatória";
    }
    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validateForm()) return;

    try {
      if (editingColetor) {
        await usersApi.update({
          iduser: editingColetor.iduser,
          name: formData.name,
          document: formData.document,
          email: formData.email,
          passwordHash: formData.passwordHash || editingColetor.passwordHash,
          type: USER_TYPES.COLETOR,
        });
      } else {
        await usersApi.create({
          name: formData.name,
          document: formData.document,
          email: formData.email,
          passwordHash: formData.passwordHash,
          type: USER_TYPES.COLETOR,
        });
      }
      setIsModalOpen(false);
      loadColetores();
    } catch (error) {
      console.error("Error saving coletor:", error);
    }
  }

  async function handleDelete(coletor: User) {
    if (!confirm(`Deseja realmente excluir o coletor "${coletor.name}"?`))
      return;
    try {
      await usersApi.delete(coletor.iduser);
      loadColetores();
    } catch (error) {
      console.error("Error deleting coletor:", error);
    }
  }

  async function handleToggleStatus(coletor: User) {
    try {
      if (coletor.active) {
        await usersApi.deactivate(coletor.iduser);
      } else {
        await usersApi.activate(coletor.iduser);
      }
      loadColetores();
    } catch (error) {
      console.error("Error toggling status:", error);
    }
  }

  if (loading) return <LoadingPage />;

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-[#2C3E50]">Coletores</h1>
          <p className="text-[#6E7F80] mt-1">
            Gerencie os coletores cadastrados
          </p>
        </div>
        <Button onClick={openCreateModal}>
          <Plus className="w-4 h-4 mr-2" />
          Novo Coletor
        </Button>
      </div>

      {/* Search */}
      <Card>
        <CardContent className="py-4">
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar por nome, email ou documento..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#4C9A6A]"
            />
          </div>
        </CardContent>
      </Card>

      {/* Table */}
      <Card>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Nome</TableHead>
                <TableHead>Documento</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Cadastro</TableHead>
                <TableHead className="text-right">Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredColetores.length === 0 ? (
                <TableRow>
                  <TableCell className="text-center py-8 text-[#6E7F80]">
                    Nenhum coletor encontrado
                  </TableCell>
                </TableRow>
              ) : (
                filteredColetores.map((coletor) => (
                  <TableRow key={coletor.iduser}>
                    <TableCell className="font-medium capitalize">
                      {coletor.name}
                    </TableCell>
                    <TableCell>{formatDocument(coletor.document)}</TableCell>
                    <TableCell>{coletor.email}</TableCell>
                    <TableCell>
                      <Badge variant={coletor.active ? "success" : "danger"}>
                        {coletor.active ? "Ativo" : "Inativo"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {formatDateTime(coletor.dataCadastro)}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => openHistoryModal(coletor)}
                          className="p-1.5 text-[#6E7F80] hover:text-purple-600 hover:bg-purple-50 rounded-lg transition-colors"
                          title="Histórico"
                        >
                          <History className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleToggleStatus(coletor)}
                          className="p-1.5 text-[#6E7F80] hover:text-[#4C9A6A] hover:bg-[#A8D5BA]/30 rounded-lg transition-colors"
                          title={coletor.active ? "Desativar" : "Ativar"}
                        >
                          {coletor.active ? (
                            <UserX className="w-4 h-4" />
                          ) : (
                            <UserCheck className="w-4 h-4" />
                          )}
                        </button>
                        <button
                          onClick={() => openEditModal(coletor)}
                          className="p-1.5 text-[#6E7F80] hover:text-yellow-600 hover:bg-yellow-50 rounded-lg transition-colors"
                          title="Editar"
                        >
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(coletor)}
                          className="p-1.5 text-[#6E7F80] hover:text-[#F44336] hover:bg-[#F44336]/10 rounded-lg transition-colors"
                          title="Excluir"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingColetor ? "Editar Coletor" : "Novo Coletor"}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Nome"
            id="name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            error={formErrors.name}
            placeholder="Nome completo"
          />
          <Input
            label="CPF/CNPJ"
            id="document"
            value={formData.document}
            onChange={(e) =>
              setFormData({ ...formData, document: e.target.value })
            }
            error={formErrors.document}
            placeholder="000.000.000-00"
          />
          <Input
            label="Email"
            id="email"
            type="email"
            value={formData.email}
            onChange={(e) =>
              setFormData({ ...formData, email: e.target.value })
            }
            error={formErrors.email}
            placeholder="email@exemplo.com"
          />
          <Input
            label={
              editingColetor
                ? "Nova Senha (deixe em branco para manter)"
                : "Senha"
            }
            id="passwordHash"
            type="password"
            value={formData.passwordHash}
            onChange={(e) =>
              setFormData({ ...formData, passwordHash: e.target.value })
            }
            error={formErrors.passwordHash}
            placeholder="••••••••"
          />
          <div className="flex justify-end gap-3 pt-4">
            <Button
              type="button"
              variant="secondary"
              onClick={() => setIsModalOpen(false)}
            >
              Cancelar
            </Button>
            <Button type="submit">{editingColetor ? "Salvar" : "Criar"}</Button>
          </div>
        </form>
      </Modal>

      {/* History Modal */}
      <Modal
        isOpen={isHistoryModalOpen}
        onClose={() => setIsHistoryModalOpen(false)}
        title={`Histórico - ${capitalizeFirst(selectedColetor?.name || "")}`}
        size="lg"
      >
        {coletorHistory.length === 0 ? (
          <p className="text-center text-[#6E7F80] py-8">
            Nenhuma coleta encontrada
          </p>
        ) : (
          <div className="max-h-96 overflow-y-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Fazenda</TableHead>
                  <TableHead>Quantidade</TableHead>
                  <TableHead>Temperatura</TableHead>
                  <TableHead>Data</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {coletorHistory.map((collection) => (
                  <TableRow key={collection.idcollection}>
                    <TableCell className="capitalize">
                      {collection.farm?.name}
                    </TableCell>
                    <TableCell>{formatNumber(collection.quantity)} L</TableCell>
                    <TableCell>{collection.temperature}°C</TableCell>
                    <TableCell>
                      {formatDateTime(collection.collectionDate)}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </Modal>
    </div>
  );
}
