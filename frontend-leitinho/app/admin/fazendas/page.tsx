"use client";

import { useEffect, useState } from "react";
import { Plus, Pencil, Trash2, Search, QrCode, Download } from "lucide-react";
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
  Select,
  LoadingPage,
} from "@/components/ui";
import { farmsApi, usersApi } from "@/lib/api";
import { formatDateTime, capitalizeFirst } from "@/lib/utils";
import { Farm, User, USER_TYPES } from "@/lib/types";

export default function FazendasPage() {
  const [loading, setLoading] = useState(true);
  const [fazendas, setFazendas] = useState<Farm[]>([]);
  const [filteredFazendas, setFilteredFazendas] = useState<Farm[]>([]);
  const [produtores, setProdutores] = useState<User[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isQrModalOpen, setIsQrModalOpen] = useState(false);
  const [qrCodeData, setQrCodeData] = useState<string>("");
  const [selectedFarm, setSelectedFarm] = useState<Farm | null>(null);
  const [editingFazenda, setEditingFazenda] = useState<Farm | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    producerid: "",
  });
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    const filtered = fazendas.filter(
      (f) =>
        f.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        f.producer?.name?.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredFazendas(filtered);
  }, [searchTerm, fazendas]);

  async function loadData() {
    try {
      const [fazendasRes, usersRes] = await Promise.all([
        farmsApi.list(),
        usersApi.list(),
      ]);

      const fazendasData = Array.isArray(fazendasRes.data)
        ? fazendasRes.data
        : [];
      setFazendas(fazendasData);
      setFilteredFazendas(fazendasData);

      const allUsers = Array.isArray(usersRes.data) ? usersRes.data : [];
      const produtoresList = allUsers.filter(
        (u: User) => u.user?.iduserTypes === USER_TYPES.PRODUTOR
      );
      setProdutores(produtoresList);
    } catch (error) {
      console.error("Error loading data:", error);
    } finally {
      setLoading(false);
    }
  }

  function openCreateModal() {
    setEditingFazenda(null);
    setFormData({ name: "", producerid: "" });
    setFormErrors({});
    setIsModalOpen(true);
  }

  function openEditModal(fazenda: Farm) {
    setEditingFazenda(fazenda);
    setFormData({
      name: fazenda.name,
      producerid: fazenda.producer?.iduser?.toString() || "",
    });
    setFormErrors({});
    setIsModalOpen(true);
  }

  async function openQrCodeModal(fazenda: Farm) {
    setSelectedFarm(fazenda);
    try {
      const response = await farmsApi.qrcode(fazenda.idfarm);
      setQrCodeData(response.data || "");
      setIsQrModalOpen(true);
    } catch (error) {
      console.error("Error generating QR Code:", error);
    }
  }

  function validateForm() {
    const errors: Record<string, string> = {};
    if (!formData.name.trim()) errors.name = "Nome é obrigatório";
    if (!formData.producerid) errors.producerid = "Produtor é obrigatório";
    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validateForm()) return;

    try {
      if (editingFazenda) {
        await farmsApi.update({
          idfarm: editingFazenda.idfarm,
          name: formData.name,
          producerid: parseInt(formData.producerid),
        });
      } else {
        await farmsApi.create({
          name: formData.name,
          producerid: parseInt(formData.producerid),
        });
      }
      setIsModalOpen(false);
      loadData();
    } catch (error) {
      console.error("Error saving fazenda:", error);
    }
  }

  async function handleDelete(fazenda: Farm) {
    if (!confirm(`Deseja realmente excluir a fazenda "${fazenda.name}"?`))
      return;
    try {
      await farmsApi.delete(fazenda.idfarm);
      loadData();
    } catch (error) {
      console.error("Error deleting fazenda:", error);
    }
  }

  if (loading) return <LoadingPage />;

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-[#2C3E50]">Fazendas</h1>
          <p className="text-[#6E7F80] mt-1">Gerencie as fazendas cadastradas</p>
        </div>
        <Button onClick={openCreateModal}>
          <Plus className="w-4 h-4 mr-2" />
          Nova Fazenda
        </Button>
      </div>

      {/* Search */}
      <Card>
        <CardContent className="py-4">
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar por nome ou produtor..."
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
                <TableHead>Produtor</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Cadastro</TableHead>
                <TableHead className="text-right">Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredFazendas.length === 0 ? (
                <TableRow>
                  <TableCell className="text-center py-8 text-[#6E7F80]">
                    Nenhuma fazenda encontrada
                  </TableCell>
                </TableRow>
              ) : (
                filteredFazendas.map((fazenda) => (
                  <TableRow key={fazenda.idfarm}>
                    <TableCell className="font-medium capitalize">
                      {fazenda.name}
                    </TableCell>
                    <TableCell className="capitalize">
                      {fazenda.producer?.name || "-"}
                    </TableCell>
                    <TableCell>
                      <Badge variant={fazenda.active ? "success" : "danger"}>
                        {fazenda.active ? "Ativa" : "Inativa"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {formatDateTime(fazenda.dataCadastro)}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => openQrCodeModal(fazenda)}
                          className="p-1.5 text-[#6E7F80] hover:text-purple-600 hover:bg-purple-50 rounded-lg transition-colors"
                          title="QR Code"
                        >
                          <QrCode className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => openEditModal(fazenda)}
                          className="p-1.5 text-[#6E7F80] hover:text-yellow-600 hover:bg-yellow-50 rounded-lg transition-colors"
                          title="Editar"
                        >
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(fazenda)}
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
        title={editingFazenda ? "Editar Fazenda" : "Nova Fazenda"}
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input
            label="Nome"
            id="name"
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            error={formErrors.name}
            placeholder="Nome da fazenda"
          />
          <Select
            label="Produtor"
            id="producerid"
            value={formData.producerid}
            onChange={(e) =>
              setFormData({ ...formData, producerid: e.target.value })
            }
            error={formErrors.producerid}
            options={produtores.map((p) => ({
              value: p.iduser,
              label: capitalizeFirst(p.name),
            }))}
          />
          <div className="flex justify-end gap-3 pt-4">
            <Button
              type="button"
              variant="secondary"
              onClick={() => setIsModalOpen(false)}
            >
              Cancelar
            </Button>
            <Button type="submit">{editingFazenda ? "Salvar" : "Criar"}</Button>
          </div>
        </form>
      </Modal>

      {/* QR Code Modal */}
      <Modal
        isOpen={isQrModalOpen}
        onClose={() => setIsQrModalOpen(false)}
        title={`QR Code - ${selectedFarm?.name || ""}`}
      >
        <div className="flex flex-col items-center gap-4">
          {qrCodeData ? (
            <>
              <img
                src={`data:image/png;base64,${qrCodeData}`}
                alt="QR Code"
                className="w-64 h-64"
              />
              <a
                href={`data:image/png;base64,${qrCodeData}`}
                download={`qrcode-${selectedFarm?.name || "fazenda"}.png`}
                className="inline-flex items-center gap-2 px-4 py-2 bg-[#4C9A6A] text-white rounded-lg hover:bg-[#3D7B55] transition-colors"
              >
                <Download className="w-4 h-4" />
                Baixar QR Code
              </a>
            </>
          ) : (
            <p className="text-[#6E7F80]">Carregando QR Code...</p>
          )}
        </div>
      </Modal>
    </div>
  );
}
