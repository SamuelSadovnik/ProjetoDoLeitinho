"use client";

import { useEffect, useState } from "react";
import { Plus, Pencil, Trash2, Search, Eye, AlertCircle } from "lucide-react";
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
import { collectionsApi, farmsApi, usersApi, animalsApi } from "@/lib/api";
import { formatDateTime, formatNumber, capitalizeFirst } from "@/lib/utils";
import { Collection, Farm, User, Animal, USER_TYPES } from "@/lib/types";

export default function ColetasPage() {
  const [loading, setLoading] = useState(true);
  const [coletas, setColetas] = useState<Collection[]>([]);
  const [filteredColetas, setFilteredColetas] = useState<Collection[]>([]);
  const [fazendas, setFazendas] = useState<Farm[]>([]);
  const [produtores, setProdutores] = useState<User[]>([]);
  const [coletores, setColetores] = useState<User[]>([]);
  const [animais, setAnimais] = useState<Animal[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
  const [selectedColeta, setSelectedColeta] = useState<Collection | null>(null);
  const [editingColeta, setEditingColeta] = useState<Collection | null>(null);
  const [formData, setFormData] = useState({
    farmid: "",
    producerid: "",
    collectorid: "",
    animalid: "1",
    quantity: "",
    temperature: "",
    acidity: "",
    producerPresent: "true",
    observations: "",
    collectionDate: "",
  });
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    const filtered = coletas.filter(
      (c) =>
        c.farm?.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.producer?.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.collector?.name?.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredColetas(filtered);
  }, [searchTerm, coletas]);

  async function loadData() {
    try {
      const [coletasRes, fazendasRes, usersRes, animaisRes] = await Promise.all(
        [
          collectionsApi.list(),
          farmsApi.list(),
          usersApi.list(),
          animalsApi.list(),
        ]
      );

      const allColetas = coletasRes.data || [];
      // Sort by date descending
      allColetas.sort(
        (a: Collection, b: Collection) =>
          new Date(b.collectionDate).getTime() -
          new Date(a.collectionDate).getTime()
      );
      setColetas(allColetas);
      setFilteredColetas(allColetas);

      setFazendas(fazendasRes.data || []);
      setAnimais(animaisRes.data || []);

      const allUsers = usersRes.data || [];
      setProdutores(
        allUsers.filter(
          (u: User) => u.user?.iduserTypes === USER_TYPES.PRODUTOR
        )
      );
      setColetores(
        allUsers.filter((u: User) => u.user?.iduserTypes === USER_TYPES.COLETOR)
      );
    } catch (error) {
      console.error("Error loading data:", error);
    } finally {
      setLoading(false);
    }
  }

  function formatDateForInput(dateString: string): string {
    if (!dateString) return "";
    const date = new Date(dateString);
    return date.toISOString().slice(0, 16);
  }

  function openCreateModal() {
    setEditingColeta(null);
    const now = new Date();
    setFormData({
      farmid: "",
      producerid: "",
      collectorid: "",
      animalid: "1",
      quantity: "",
      temperature: "",
      acidity: "",
      producerPresent: "true",
      observations: "",
      collectionDate: now.toISOString().slice(0, 16),
    });
    setFormErrors({});
    setIsModalOpen(true);
  }

  function openEditModal(coleta: Collection) {
    setEditingColeta(coleta);
    setFormData({
      farmid: coleta.farm?.idfarm?.toString() || "",
      producerid: coleta.producer?.iduser?.toString() || "",
      collectorid: coleta.collector?.iduser?.toString() || "",
      animalid: coleta.animal?.idanimal?.toString() || "1",
      quantity: coleta.quantity?.toString() || "",
      temperature: coleta.temperature?.toString() || "",
      acidity: coleta.acidity?.toString() || "",
      producerPresent: coleta.producerPresent ? "true" : "false",
      observations: coleta.observations || "",
      collectionDate: formatDateForInput(coleta.collectionDate),
    });
    setFormErrors({});
    setIsModalOpen(true);
  }

  function openDetailModal(coleta: Collection) {
    setSelectedColeta(coleta);
    setIsDetailModalOpen(true);
  }

  function validateForm() {
    const errors: Record<string, string> = {};
    if (!formData.farmid) errors.farmid = "Fazenda é obrigatória";
    if (!formData.producerid) errors.producerid = "Produtor é obrigatório";
    if (!formData.collectorid) errors.collectorid = "Coletor é obrigatório";
    if (!formData.quantity) errors.quantity = "Quantidade é obrigatória";
    if (!formData.temperature) errors.temperature = "Temperatura é obrigatória";
    if (!formData.acidity) errors.acidity = "Acidez é obrigatória";
    if (!formData.collectionDate) errors.collectionDate = "Data é obrigatória";
    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!validateForm()) return;

    try {
      const collectionDate = new Date(formData.collectionDate)
        .toISOString()
        .replace("T", " ")
        .slice(0, 19);

      if (editingColeta) {
        await collectionsApi.update({
          idcollection: editingColeta.idcollection,
          farmid: parseInt(formData.farmid),
          producerid: parseInt(formData.producerid),
          collectorid: parseInt(formData.collectorid),
          animalid: parseInt(formData.animalid),
          quantity: parseFloat(formData.quantity),
          temperature: parseFloat(formData.temperature),
          acidity: parseFloat(formData.acidity),
          producerPresent: formData.producerPresent === "true",
          observations: formData.observations,
          collectionDate,
        });
      } else {
        await collectionsApi.create({
          farmid: parseInt(formData.farmid),
          producerid: parseInt(formData.producerid),
          collectorid: parseInt(formData.collectorid),
          animalid: parseInt(formData.animalid),
          quantity: parseFloat(formData.quantity),
          temperature: parseFloat(formData.temperature),
          acidity: parseFloat(formData.acidity),
          producerPresent: formData.producerPresent === "true",
          observations: formData.observations,
          collectionDate,
        });
      }
      setIsModalOpen(false);
      loadData();
    } catch (error) {
      console.error("Error saving coleta:", error);
    }
  }

  async function handleDelete(coleta: Collection) {
    if (!confirm(`Deseja realmente excluir esta coleta?`)) return;
    try {
      await collectionsApi.delete(coleta.idcollection);
      loadData();
    } catch (error) {
      console.error("Error deleting coleta:", error);
    }
  }

  if (loading) return <LoadingPage />;

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Coletas</h1>
          <p className="text-gray-500 mt-1">Gerencie as coletas de leite</p>
        </div>
        <Button onClick={openCreateModal}>
          <Plus className="w-4 h-4 mr-2" />
          Nova Coleta
        </Button>
      </div>

      {/* Search */}
      <Card>
        <CardContent className="py-4">
          <div className="relative max-w-md">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar por fazenda, produtor ou coletor..."
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
                <TableHead>Fazenda</TableHead>
                <TableHead>Produtor</TableHead>
                <TableHead>Coletor</TableHead>
                <TableHead>Quantidade</TableHead>
                <TableHead>Temp.</TableHead>
                <TableHead>Data</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Ações</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredColetas.length === 0 ? (
                <TableRow>
                  <TableCell className="text-center py-8 text-gray-500">
                    Nenhuma coleta encontrada
                  </TableCell>
                </TableRow>
              ) : (
                filteredColetas.map((coleta) => (
                  <TableRow key={coleta.idcollection}>
                    <TableCell className="font-medium capitalize">
                      {coleta.farm?.name || "-"}
                    </TableCell>
                    <TableCell className="capitalize">
                      {coleta.producer?.name || "-"}
                    </TableCell>
                    <TableCell className="capitalize">
                      {coleta.collector?.name || "-"}
                    </TableCell>
                    <TableCell>{formatNumber(coleta.quantity)} L</TableCell>
                    <TableCell>{coleta.temperature}°C</TableCell>
                    <TableCell>
                      {formatDateTime(coleta.collectionDate)}
                    </TableCell>
                    <TableCell>
                      {coleta.edited ? (
                        <Badge variant="warning">
                          Editado ({coleta.editCount}x)
                        </Badge>
                      ) : (
                        <Badge variant="success">Original</Badge>
                      )}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => openDetailModal(coleta)}
                          className="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                          title="Detalhes"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => openEditModal(coleta)}
                          className="p-1.5 text-gray-500 hover:text-yellow-600 hover:bg-yellow-50 rounded-lg transition-colors"
                          title="Editar"
                        >
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(coleta)}
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

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingColeta ? "Editar Coleta" : "Nova Coleta"}
        size="lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Select
              label="Fazenda"
              id="farmid"
              value={formData.farmid}
              onChange={(e) =>
                setFormData({ ...formData, farmid: e.target.value })
              }
              error={formErrors.farmid}
              options={fazendas.map((f) => ({
                value: f.idfarm,
                label: capitalizeFirst(f.name),
              }))}
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
            <Select
              label="Coletor"
              id="collectorid"
              value={formData.collectorid}
              onChange={(e) =>
                setFormData({ ...formData, collectorid: e.target.value })
              }
              error={formErrors.collectorid}
              options={coletores.map((c) => ({
                value: c.iduser,
                label: capitalizeFirst(c.name),
              }))}
            />
            <Select
              label="Animal"
              id="animalid"
              value={formData.animalid}
              onChange={(e) =>
                setFormData({ ...formData, animalid: e.target.value })
              }
              options={animais.map((a) => ({
                value: a.idanimal,
                label: capitalizeFirst(a.name),
              }))}
            />
            <Input
              label="Quantidade (Litros)"
              id="quantity"
              type="number"
              step="0.01"
              value={formData.quantity}
              onChange={(e) =>
                setFormData({ ...formData, quantity: e.target.value })
              }
              error={formErrors.quantity}
              placeholder="0.00"
            />
            <Input
              label="Temperatura (°C)"
              id="temperature"
              type="number"
              step="0.1"
              value={formData.temperature}
              onChange={(e) =>
                setFormData({ ...formData, temperature: e.target.value })
              }
              error={formErrors.temperature}
              placeholder="0.0"
            />
            <Input
              label="Acidez"
              id="acidity"
              type="number"
              step="0.01"
              value={formData.acidity}
              onChange={(e) =>
                setFormData({ ...formData, acidity: e.target.value })
              }
              error={formErrors.acidity}
              placeholder="0.00"
            />
            <Select
              label="Produtor Presente"
              id="producerPresent"
              value={formData.producerPresent}
              onChange={(e) =>
                setFormData({ ...formData, producerPresent: e.target.value })
              }
              options={[
                { value: "true", label: "Sim" },
                { value: "false", label: "Não" },
              ]}
            />
            <div className="md:col-span-2">
              <Input
                label="Data da Coleta"
                id="collectionDate"
                type="datetime-local"
                value={formData.collectionDate}
                onChange={(e) =>
                  setFormData({ ...formData, collectionDate: e.target.value })
                }
                error={formErrors.collectionDate}
              />
            </div>
            <div className="md:col-span-2">
              <label
                htmlFor="observations"
                className="block text-sm font-medium text-gray-700 mb-1"
              >
                Observações
              </label>
              <textarea
                id="observations"
                rows={3}
                value={formData.observations}
                onChange={(e) =>
                  setFormData({ ...formData, observations: e.target.value })
                }
                className="w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Observações sobre a coleta..."
              />
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-4">
            <Button
              type="button"
              variant="secondary"
              onClick={() => setIsModalOpen(false)}
            >
              Cancelar
            </Button>
            <Button type="submit">{editingColeta ? "Salvar" : "Criar"}</Button>
          </div>
        </form>
      </Modal>

      {/* Detail Modal */}
      <Modal
        isOpen={isDetailModalOpen}
        onClose={() => setIsDetailModalOpen(false)}
        title="Detalhes da Coleta"
        size="lg"
      >
        {selectedColeta && (
          <div className="space-y-6">
            {selectedColeta.edited && (
              <div className="flex items-center gap-2 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                <AlertCircle className="w-5 h-5 text-yellow-600" />
                <span className="text-sm text-yellow-800">
                  Esta coleta foi editada {selectedColeta.editCount} vez(es)
                </span>
              </div>
            )}

            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-sm text-gray-500">Fazenda</p>
                <p className="font-medium capitalize">
                  {selectedColeta.farm?.name}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Produtor</p>
                <p className="font-medium capitalize">
                  {selectedColeta.producer?.name}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Coletor</p>
                <p className="font-medium capitalize">
                  {selectedColeta.collector?.name}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Animal</p>
                <p className="font-medium capitalize">
                  {selectedColeta.animal?.name}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Quantidade</p>
                <p className="font-medium">
                  {formatNumber(selectedColeta.quantity)} Litros
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Temperatura</p>
                <p className="font-medium">{selectedColeta.temperature}°C</p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Acidez</p>
                <p className="font-medium">{selectedColeta.acidity}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Produtor Presente</p>
                <p className="font-medium">
                  {selectedColeta.producerPresent ? "Sim" : "Não"}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Data da Coleta</p>
                <p className="font-medium">
                  {formatDateTime(selectedColeta.collectionDate)}
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500">Data de Cadastro</p>
                <p className="font-medium">
                  {formatDateTime(selectedColeta.dataCadastro)}
                </p>
              </div>
            </div>

            {selectedColeta.observations && (
              <div>
                <p className="text-sm text-gray-500 mb-1">Observações</p>
                <p className="p-3 bg-gray-50 rounded-lg text-sm">
                  {selectedColeta.observations}
                </p>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
