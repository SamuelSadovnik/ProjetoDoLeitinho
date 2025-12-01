"use client";

import { useEffect, useState } from "react";
import { Plus, Pencil, Trash2, Search, Users } from "lucide-react";
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
  Modal,
  Input,
  LoadingPage,
} from "@/components/ui";
import { dairysApi, userDairyApi, usersApi } from "@/lib/api";
import { formatDateTime, capitalizeFirst } from "@/lib/utils";
import { Dairy, UserDairy, User } from "@/lib/types";

export default function LaticiniosPage() {
  const [loading, setLoading] = useState(true);
  const [laticinios, setLaticinios] = useState<Dairy[]>([]);
  const [filteredLaticinios, setFilteredLaticinios] = useState<Dairy[]>([]);
  const [userDairies, setUserDairies] = useState<UserDairy[]>([]);
  const [users, setUsers] = useState<User[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isUsersModalOpen, setIsUsersModalOpen] = useState(false);
  const [selectedLaticinio, setSelectedLaticinio] = useState<Dairy | null>(
    null
  );
  const [editingLaticinio, setEditingLaticinio] = useState<Dairy | null>(null);
  const [formData, setFormData] = useState({ name: "" });
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    const filtered = laticinios.filter((l) =>
      l.name?.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredLaticinios(filtered);
  }, [searchTerm, laticinios]);

  async function loadData() {
    try {
      const [laticiniosRes, userDairyRes, usersRes] = await Promise.all([
        dairysApi.list(),
        userDairyApi.list(),
        usersApi.list(),
      ]);

      const laticiniosData = Array.isArray(laticiniosRes.data)
        ? laticiniosRes.data
        : [];
      setLaticinios(laticiniosData);
      setFilteredLaticinios(laticiniosData);
      const userDairyData = Array.isArray(userDairyRes.data)
        ? userDairyRes.data
        : [];
      setUserDairies(userDairyData);
      const usersData = Array.isArray(usersRes.data) ? usersRes.data : [];
      setUsers(usersData);
    } catch (error) {
      console.error("Error loading data:", error);
    } finally {
      setLoading(false);
    }
  }

  function getLatinicoUsers(dairyId: number): User[] {
    const dairyUserIds = userDairies
      .filter((ud) => ud.userDairyKey?.dairy?.iddairy === dairyId)
      .map((ud) => ud.userDairyKey?.user?.iduser);
    return users.filter((u) => dairyUserIds.includes(u.iduser));
  }

  function openCreateModal() {
    setEditingLaticinio(null);
    setFormData({ name: "" });
    setFormErrors({});
    setIsModalOpen(true);
  }

  function openEditModal(laticinio: Dairy) {
    setEditingLaticinio(laticinio);
    setFormData({ name: laticinio.name });
    setFormErrors({});
    setIsModalOpen(true);
  }

  function openUsersModal(laticinio: Dairy) {
    setSelectedLaticinio(laticinio);
    setIsUsersModalOpen(true);
  }

  function validateForm() {
    const errors: Record<string, string> = {};
    if (!formData.name.trim()) errors.name = "Nome é obrigatório";
    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validateForm()) return;

    try {
      if (editingLaticinio) {
        await dairysApi.update({
          iddairy: editingLaticinio.iddairy,
          name: formData.name,
        });
      } else {
        await dairysApi.create({ name: formData.name });
      }
      setIsModalOpen(false);
      loadData();
    } catch (error) {
      console.error("Error saving laticinio:", error);
    }
  }

  async function handleDelete(laticinio: Dairy) {
    if (!confirm(`Deseja realmente excluir o laticínio "${laticinio.name}"?`))
      return;
    try {
      await dairysApi.delete(laticinio.iddairy);
      loadData();
    } catch (error) {
      console.error("Error deleting laticinio:", error);
    }
  }

  if (loading) return <LoadingPage />;

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-[#2C3E50]">Laticínios</h1>
          <p className="text-[#6E7F80] mt-1">
            Gerencie os laticínios cadastrados
          </p>
        </div>
        <Button onClick={openCreateModal}>
          <Plus className="w-4 h-4 mr-2" />
          Novo Laticínio
        </Button>
      </div>

      {/* Search */}
      <Card>
        <CardContent className="py-4">
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar por nome..."
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
                <TableHead>Usuários Vinculados</TableHead>
                <TableHead>Cadastro</TableHead>
                <TableHead className="text-right">Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredLaticinios.length === 0 ? (
                <TableRow>
                  <TableCell className="text-center py-8 text-[#6E7F80]">
                    Nenhum laticínio encontrado
                  </TableCell>
                </TableRow>
              ) : (
                filteredLaticinios.map((laticinio) => {
                  const dairyUsers = getLatinicoUsers(laticinio.iddairy);
                  return (
                    <TableRow key={laticinio.iddairy}>
                      <TableCell className="font-medium capitalize">
                        {laticinio.name}
                      </TableCell>
                      <TableCell>
                        <span className="px-2.5 py-0.5 bg-[#A8D5BA]/40 text-[#4C9A6A] rounded-full text-xs font-medium">
                          {dairyUsers.length} usuário(s)
                        </span>
                      </TableCell>
                      <TableCell>
                        {formatDateTime(laticinio.dataCadastro)}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center justify-end gap-2">
                          <button
                            onClick={() => openUsersModal(laticinio)}
                            className="p-1.5 text-[#6E7F80] hover:text-[#4C9A6A] hover:bg-[#A8D5BA]/30 rounded-lg transition-colors"
                            title="Ver Usuários"
                          >
                            <Users className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => openEditModal(laticinio)}
                            className="p-1.5 text-[#6E7F80] hover:text-yellow-600 hover:bg-yellow-50 rounded-lg transition-colors"
                            title="Editar"
                          >
                            <Pencil className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleDelete(laticinio)}
                            className="p-1.5 text-[#6E7F80] hover:text-[#F44336] hover:bg-[#F44336]/10 rounded-lg transition-colors"
                            title="Excluir"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingLaticinio ? "Editar Laticínio" : "Novo Laticínio"}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Nome"
            id="name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            error={formErrors.name}
            placeholder="Nome do laticínio"
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
              {editingLaticinio ? "Salvar" : "Criar"}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Users Modal */}
      <Modal
        isOpen={isUsersModalOpen}
        onClose={() => setIsUsersModalOpen(false)}
        title={`Usuários - ${capitalizeFirst(selectedLaticinio?.name || "")}`}
      >
        {selectedLaticinio && (
          <>
            {getLatinicoUsers(selectedLaticinio.iddairy).length === 0 ? (
              <p className="text-center text-[#6E7F80] py-8">
                Nenhum usuário vinculado a este laticínio
              </p>
            ) : (
              <div className="space-y-3">
                {getLatinicoUsers(selectedLaticinio.iddairy).map((user) => (
                  <div
                    key={user.iduser}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium capitalize">{user.name}</p>
                      <p className="text-sm text-[#6E7F80]">{user.email}</p>
                    </div>
                    <span
                      className={`px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        user.active
                          ? "bg-[#4CAF50]/20 text-[#4CAF50]"
                          : "bg-[#F44336]/20 text-[#F44336]"
                      }`}
                    >
                      {user.active ? "Ativo" : "Inativo"}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </>
        )}
      </Modal>
    </div>
  );
}
