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
    <div className="min-h-screen bg-linear-to-br from-[#A8D5BA]/20 to-[#B3DDF2]/30">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-[#4C9A6A] rounded-xl">
                <Milk className="w-6 h-6 text-white" />
              </div>
              <h1 className="text-xl font-bold text-[#2C3E50]">Puro Lácteo</h1>
            </div>
            <Link
              href="/admin"
              className="inline-flex items-center gap-2 px-4 py-2 bg-[#4C9A6A] text-white rounded-lg hover:bg-[#3D7B55] transition-colors"
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
          <h2 className="text-4xl sm:text-5xl font-bold text-[#2C3E50] mb-4">
            Sistema de Gestão de
            <span className="text-[#4C9A6A]"> Coleta de Leite</span>
          </h2>
          <p className="text-lg text-[#6E7F80] max-w-2xl mx-auto">
            Gerencie produtores, fazendas, coletores e coletas de leite de forma
            simples e eficiente.
          </p>
        </div>

        {/* Features */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
            <div className="w-12 h-12 bg-[#A8D5BA]/40 rounded-xl flex items-center justify-center mb-4">
              <Users className="w-6 h-6 text-[#4C9A6A]" />
            </div>
            <h3 className="text-lg font-semibold text-[#2C3E50] mb-2">
              Produtores
            </h3>
            <p className="text-sm text-[#6E7F80]">
              Cadastre e gerencie os produtores rurais de forma centralizada.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
            <div className="w-12 h-12 bg-[#A8D5BA]/40 rounded-xl flex items-center justify-center mb-4">
              <Tractor className="w-6 h-6 text-[#4C9A6A]" />
            </div>
            <h3 className="text-lg font-semibold text-[#2C3E50] mb-2">
              Fazendas
            </h3>
            <p className="text-sm text-[#6E7F80]">
              Controle as fazendas e gere QR Codes para identificação rápida.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
            <div className="w-12 h-12 bg-[#B3DDF2]/40 rounded-xl flex items-center justify-center mb-4">
              <Droplets className="w-6 h-6 text-[#2196F3]" />
            </div>
            <h3 className="text-lg font-semibold text-[#2C3E50] mb-2">
              Coletas
            </h3>
            <p className="text-sm text-[#6E7F80]">
              Registre coletas com controle de quantidade, temperatura e
              qualidade.
            </p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-200 hover:shadow-md transition-shadow">
            <div className="w-12 h-12 bg-[#FF9800]/20 rounded-xl flex items-center justify-center mb-4">
              <Building2 className="w-6 h-6 text-[#FF9800]" />
            </div>
            <h3 className="text-lg font-semibold text-[#2C3E50] mb-2">
              Laticínios
            </h3>
            <p className="text-sm text-[#6E7F80]">
              Gerencie múltiplos laticínios e seus usuários vinculados.
            </p>
          </div>
        </div>

        {/* CTA */}
        <div className="text-center mt-16">
          <Link
            href="/admin"
            className="inline-flex items-center gap-2 px-8 py-4 bg-[#4C9A6A] text-white text-lg font-medium rounded-xl hover:bg-[#3D7B55] transition-colors shadow-lg shadow-[#4C9A6A]/30"
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
              <Milk className="w-5 h-5 text-[#4C9A6A]" />
              <span className="font-semibold text-[#2C3E50]">Puro Lácteo</span>
            </div>
            <p className="text-sm text-[#6E7F80]">
              © 2025 Projeto do Puro Lácteo. Todos os direitos reservados.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
