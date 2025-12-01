import Link from "next/link";
import {
  Milk,
  ArrowRight,
  Users,
  Tractor,
  Droplets,
  Building2,
} from "lucide-react";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-blue-100">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-600 rounded-xl">
                <Milk className="w-6 h-6 text-white" />
              </div>
              <h1 className="text-xl font-bold text-gray-900">Leitinho</h1>
            </div>
            <Link
              href="/admin"
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              Acessar Painel
              <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
        </div>
      </header>

      {/* Hero */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="text-center mb-16">
          <h2 className="text-4xl sm:text-5xl font-bold text-gray-900 mb-4">
            Sistema de Gestão de
            <span className="text-blue-600"> Coleta de Leite</span>
          </h2>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            Gerencie produtores, fazendas, coletores e coletas de leite de forma
            simples e eficiente.
          </p>
        </div>

        {/* Features */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
            <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center mb-4">
              <Users className="w-6 h-6 text-blue-600" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">
              Produtores
            </h3>
            <p className="text-sm text-gray-600">
              Cadastre e gerencie os produtores rurais de forma centralizada.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
            <div className="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center mb-4">
              <Tractor className="w-6 h-6 text-green-600" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">
              Fazendas
            </h3>
            <p className="text-sm text-gray-600">
              Controle as fazendas e gere QR Codes para identificação rápida.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
            <div className="w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center mb-4">
              <Droplets className="w-6 h-6 text-purple-600" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">
              Coletas
            </h3>
            <p className="text-sm text-gray-600">
              Registre coletas com controle de quantidade, temperatura e
              qualidade.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200">
            <div className="w-12 h-12 bg-orange-100 rounded-xl flex items-center justify-center mb-4">
              <Building2 className="w-6 h-6 text-orange-600" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900 mb-2">
              Laticínios
            </h3>
            <p className="text-sm text-gray-600">
              Gerencie múltiplos laticínios e seus usuários vinculados.
            </p>
          </div>
        </div>

        {/* CTA */}
        <div className="text-center mt-16">
          <Link
            href="/admin"
            className="inline-flex items-center gap-2 px-8 py-4 bg-blue-600 text-white text-lg font-medium rounded-xl hover:bg-blue-700 transition-colors shadow-lg shadow-blue-600/30"
          >
            Acessar Painel Administrativo
            <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Milk className="w-5 h-5 text-blue-600" />
              <span className="font-semibold text-gray-900">Leitinho</span>
            </div>
            <p className="text-sm text-gray-500">
              © 2025 Projeto do Leitinho. Todos os direitos reservados.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
