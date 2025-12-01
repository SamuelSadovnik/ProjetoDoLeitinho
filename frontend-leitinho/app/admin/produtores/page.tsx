"use client";

import { useEffect, useState } from "react";
import { Plus, Pencil, Trash2, Search, UserCheck, UserX } from "lucide-react";
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
import { usersApi, userTypesApi } from "@/lib/api";
import { formatDocument, formatDateTime, capitalizeFirst } from "@/lib/utils";
import { User, USER_TYPES } from "@/lib/types";

export default function ProdutoresPage() {
  const [loading, setLoading] = useState(true);
  const [produtores, setProdutores] = useState<User[]>([]);
  const [filteredProdutores, setFilteredProdutores] = useState<User[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingProdutor, setEditingProdutor] = useState<User | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    document: "",
    email: "",
    passwordHash: "",
  });
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    loadProdutores();
  }, []);

  useEffect(() => {
    const filtered = produtores.filter(
      (p) =>
        p.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.document?.includes(searchTerm)
    );
    setFilteredProdutores(filtered);
  }, [searchTerm, produtores]);

  async function loadProdutores() {
    try {
      const response = await usersApi.list();
      const allUsers = response.data || [];
      const produtoresList = allUsers.filter(
        (u: User) => u.user?.iduserTypes === USER_TYPES.PRODUTOR
      );
      setProdutores(produtoresList);
      setFilteredProdutores(produtoresList);
    } catch (error) {
      console.error("Error loading produtores:", error);
    } finally {
      setLoading(false);
    }
  }

  function openCreateModal() {
    setEditingProdutor(null);
    setFormData({ name: "", document: "", email: "", passwordHash: "" });
    setFormErrors({});
    setIsModalOpen(true);
  }

  function openEditModal(produtor: User) {
    setEditingProdutor(produtor);
    setFormData({
      name: produtor.name,
      document: produtor.document,
      email: produtor.email,
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
    if (!editingProdutor && !formData.passwordHash.trim()) {
      errors.passwordHash = "Senha é obrigatória";
    }
    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validateForm()) return;

    try {
      if (editingProdutor) {
        await usersApi.update({
          iduser: editingProdutor.iduser,
          name: formData.name,
          document: formData.document,
          email: formData.email,
          passwordHash: formData.passwordHash || editingProdutor.passwordHash,
          type: USER_TYPES.PRODUTOR,
        });
      } else {
        await usersApi.create({
          name: formData.name,
          document: formData.document,
          email: formData.email,
          passwordHash: formData.passwordHash,
          type: USER_TYPES.PRODUTOR,
        });
      }
      setIsModalOpen(false);
      loadProdutores();
    } catch (error) {
      console.error("Error saving produtor:", error);
    }
  }

  async function handleDelete(produtor: User) {
    if (!confirm(`Deseja realmente excluir o produtor "${produtor.name}"?`))
      return;
    try {
      await usersApi.delete(produtor.iduser);
      loadProdutores();
    } catch (error) {
      console.error("Error deleting produtor:", error);
    }
  }

  async function handleToggleStatus(produtor: User) {
    try {
      if (produtor.active) {
        await usersApi.deactivate(produtor.iduser);
      } else {
        await usersApi.activate(produtor.iduser);
      }
      loadProdutores();
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
          <h1 className="text-2xl font-bold text-gray-900">Produtores</h1>
          <p className="text-gray-500 mt-1">
            Gerencie os produtores cadastrados
          </p>
        </div>
        <Button onClick={openCreateModal}>
          <Plus className="w-4 h-4 mr-2" />
          Novo Produtor
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
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
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
              {filteredProdutores.length === 0 ? (
                <TableRow>
                  <TableCell className="text-center py-8 text-gray-500">
                    Nenhum produtor encontrado
                  </TableCell>
                </TableRow>
              ) : (
                filteredProdutores.map((produtor) => (
                  <TableRow key={produtor.iduser}>
                    <TableCell className="font-medium capitalize">
                      {produtor.name}
                    </TableCell>
                    <TableCell>{formatDocument(produtor.document)}</TableCell>
                    <TableCell>{produtor.email}</TableCell>
                    <TableCell>
                      <Badge variant={produtor.active ? "success" : "danger"}>
                        {produtor.active ? "Ativo" : "Inativo"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {formatDateTime(produtor.dataCadastro)}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => handleToggleStatus(produtor)}
                          className="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                          title={produtor.active ? "Desativar" : "Ativar"}
                        >
                          {produtor.active ? (
                            <UserX className="w-4 h-4" />
                          ) : (
                            <UserCheck className="w-4 h-4" />
                          )}
                        </button>
                        <button
                          onClick={() => openEditModal(produtor)}
                          className="p-1.5 text-gray-500 hover:text-yellow-600 hover:bg-yellow-50 rounded-lg transition-colors"
                          title="Editar"
                        >
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(produtor)}
                          className="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
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

      {/* Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingProdutor ? "Editar Produtor" : "Novo Produtor"}
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
              editingProdutor
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
            <Button type="submit">
              {editingProdutor ? "Salvar" : "Criar"}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
