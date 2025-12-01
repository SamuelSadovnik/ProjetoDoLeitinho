"use client";

import { useState } from "react";
import {
  Settings,
  Database,
  RefreshCw,
  CheckCircle,
  AlertCircle,
} from "lucide-react";
import {
  Button,
  Card,
  CardHeader,
  CardTitle,
  CardContent,
} from "@/components/ui";
import { adminApi } from "@/lib/api";

export default function ConfiguracoesPage() {
  const [loadingLoad, setLoadingLoad] = useState(false);
  const [loadResult, setLoadResult] = useState<{
    success: boolean;
    message: string;
  } | null>(null);

  async function handleLoadData() {
    setLoadingLoad(true);
    setLoadResult(null);

    try {
      const response = await adminApi.load();
      setLoadResult({
        success: response.status === 202,
        message: response.message || "Dados carregados com sucesso!",
      });
    } catch (error) {
      setLoadResult({
        success: false,
        message: "Erro ao carregar dados iniciais.",
      });
    } finally {
      setLoadingLoad(false);
    }
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold text-[#2C3E50]">Configurações</h1>
        <p className="text-[#6E7F80] mt-1">Configurações do sistema</p>
      </div>

      {/* Settings Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Load Initial Data */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Database className="w-5 h-5 text-[#4C9A6A]" />
              <CardTitle>Dados Iniciais</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-[#6E7F80] mb-4">
              Carrega os dados iniciais do sistema, incluindo tipos de animais
              (vaca, cabra) e tipos de usuários (coletor, produtor, laticínio,
              admin).
            </p>

            {loadResult && (
              <div
                className={`flex items-center gap-2 p-3 rounded-lg mb-4 ${
                  loadResult.success
                    ? "bg-[#4CAF50]/20 text-[#4CAF50]"
                    : "bg-[#F44336]/20 text-[#F44336]"
                }`}
              >
                {loadResult.success ? (
                  <CheckCircle className="w-5 h-5" />
                ) : (
                  <AlertCircle className="w-5 h-5" />
                )}
                <span className="text-sm">{loadResult.message}</span>
              </div>
            )}

            <Button
              onClick={handleLoadData}
              disabled={loadingLoad}
              className="w-full"
            >
              {loadingLoad ? (
                <>
                  <RefreshCw className="w-4 h-4 mr-2 animate-spin" />
                  Carregando...
                </>
              ) : (
                <>
                  <Database className="w-4 h-4 mr-2" />
                  Carregar Dados Iniciais
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {/* System Info */}
        <Card>
          <CardHeader>
            <div className="flex items-center gap-2">
              <Settings className="w-5 h-5 text-gray-600" />
              <CardTitle>Informações do Sistema</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex justify-between py-2 border-b border-gray-100">
                <span className="text-sm text-[#6E7F80]">Versão</span>
                <span className="text-sm font-medium">1.0.0</span>
              </div>
              <div className="flex justify-between py-2 border-b border-gray-100">
                <span className="text-sm text-[#6E7F80]">Frontend</span>
                <span className="text-sm font-medium">Next.js 16</span>
              </div>
              <div className="flex justify-between py-2 border-b border-gray-100">
                <span className="text-sm text-[#6E7F80]">Backend</span>
                <span className="text-sm font-medium">Spring Boot</span>
              </div>
              <div className="flex justify-between py-2">
                <span className="text-sm text-[#6E7F80]">API URL</span>
                <span className="text-sm font-medium text-[#4C9A6A]">
                  {process.env.NEXT_PUBLIC_API_URL ||
                    "http://localhost:8080/api"}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
