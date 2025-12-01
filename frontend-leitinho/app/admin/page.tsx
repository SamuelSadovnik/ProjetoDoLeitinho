"use client";

import { useEffect, useState } from "react";
import {
  Users,
  Tractor,
  Truck,
  Droplets,
  TrendingUp,
  Calendar,
} from "lucide-react";
import {
  StatsCard,
  Card,
  CardHeader,
  CardTitle,
  CardContent,
  LoadingPage,
} from "@/components/ui";
import { usersApi, farmsApi, collectionsApi } from "@/lib/api";
import { formatNumber, formatDateTime } from "@/lib/utils";
import { USER_TYPES, Collection, User, Farm } from "@/lib/types";

export default function AdminDashboard() {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalProdutores: 0,
    totalFazendas: 0,
    totalColetores: 0,
    totalColetas: 0,
  });
  const [recentCollections, setRecentCollections] = useState<Collection[]>([]);
  const [recentUsers, setRecentUsers] = useState<User[]>([]);

  useEffect(() => {
    loadDashboardData();
  }, []);

  async function loadDashboardData() {
    try {
      const [usersRes, farmsRes, collectionsRes] = await Promise.all([
        usersApi.list(),
        farmsApi.list(),
        collectionsApi.list(),
      ]);

      const users = Array.isArray(usersRes.data) ? usersRes.data : [];
      const farms = Array.isArray(farmsRes.data) ? farmsRes.data : [];
      const collections = Array.isArray(collectionsRes.data)
        ? collectionsRes.data
        : [];

      // Count by type
      const produtores = users.filter(
        (u: User) => u.user?.iduserTypes === USER_TYPES.PRODUTOR
      );
      const coletores = users.filter(
        (u: User) => u.user?.iduserTypes === USER_TYPES.COLETOR
      );

      setStats({
        totalProdutores: produtores.length,
        totalFazendas: farms.length,
        totalColetores: coletores.length,
        totalColetas: collections.length,
      });

      // Get recent collections (last 5)
      const sortedCollections = [...collections].sort(
        (a: Collection, b: Collection) =>
          new Date(b.dataCadastro).getTime() -
          new Date(a.dataCadastro).getTime()
      );
      setRecentCollections(sortedCollections.slice(0, 5));

      // Get recent users (last 5)
      const sortedUsers = [...users].sort(
        (a: User, b: User) =>
          new Date(b.dataCadastro).getTime() -
          new Date(a.dataCadastro).getTime()
      );
      setRecentUsers(sortedUsers.slice(0, 5));
    } catch (error) {
      console.error("Error loading dashboard:", error);
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <LoadingPage />;

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-1">Visão geral do sistema</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard
          title="Produtores"
          value={stats.totalProdutores}
          icon={Users}
        />
        <StatsCard
          title="Fazendas"
          value={stats.totalFazendas}
          icon={Tractor}
        />
        <StatsCard
          title="Coletores"
          value={stats.totalColetores}
          icon={Truck}
        />
        <StatsCard title="Coletas" value={stats.totalColetas} icon={Droplets} />
      </div>

      {/* Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Collections */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Calendar className="w-5 h-5 text-blue-600" />
              <CardTitle>Coletas Recentes</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            {recentCollections.length === 0 ? (
              <p className="text-gray-500 text-center py-4">
                Nenhuma coleta encontrada
              </p>
            ) : (
              <div className="space-y-4">
                {recentCollections.map((collection) => (
                  <div
                    key={collection.idcollection}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div>
                      <p className="font-medium text-gray-900">
                        {collection.farm?.name || "Fazenda"}
                      </p>
                      <p className="text-sm text-gray-500">
                        {collection.producer?.name || "Produtor"} •{" "}
                        {formatDateTime(collection.collectionDate)}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="font-semibold text-blue-600">
                        {formatNumber(collection.quantity)} L
                      </p>
                      <p className="text-xs text-gray-500">
                        {collection.temperature}°C
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Recent Users */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-green-600" />
              <CardTitle>Usuários Recentes</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            {recentUsers.length === 0 ? (
              <p className="text-gray-500 text-center py-4">
                Nenhum usuário encontrado
              </p>
            ) : (
              <div className="space-y-4">
                {recentUsers.map((user) => (
                  <div
                    key={user.iduser}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                        <Users className="w-5 h-5 text-blue-600" />
                      </div>
                      <div>
                        <p className="font-medium text-gray-900 capitalize">
                          {user.name}
                        </p>
                        <p className="text-sm text-gray-500">{user.email}</p>
                      </div>
                    </div>
                    <span
                      className={`px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        user.active
                          ? "bg-green-100 text-green-800"
                          : "bg-red-100 text-red-800"
                      }`}
                    >
                      {user.active ? "Ativo" : "Inativo"}
                    </span>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
