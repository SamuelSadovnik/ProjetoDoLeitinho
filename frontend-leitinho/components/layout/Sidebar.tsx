"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import {
  LayoutDashboard,
  Users,
  Tractor,
  Truck,
  Droplets,
  Building2,
  Settings,
  LogOut,
  Menu,
  X,
  Milk,
} from "lucide-react";
import { useState } from "react";

const navigation = [
  { name: "Dashboard", href: "/admin", icon: LayoutDashboard },
  { name: "Produtores", href: "/admin/produtores", icon: Users },
  { name: "Fazendas", href: "/admin/fazendas", icon: Tractor },
  { name: "Coletores", href: "/admin/coletores", icon: Truck },
  { name: "Coletas", href: "/admin/coletas", icon: Droplets },
  { name: "Laticínios", href: "/admin/laticinios", icon: Building2 },
  { name: "Configurações", href: "/admin/configuracoes", icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <>
      {/* Mobile menu button */}
      <button
        className="lg:hidden fixed top-4 left-4 z-50 p-2 bg-white rounded-lg shadow-md"
        onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
      >
        {isMobileMenuOpen ? (
          <X className="w-6 h-6 text-[#6E7F80]" />
        ) : (
          <Menu className="w-6 h-6 text-[#6E7F80]" />
        )}
      </button>

      {/* Overlay */}
      {isMobileMenuOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-black/50 z-40"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={cn(
          "fixed top-0 left-0 z-40 h-screen w-64 bg-white border-r border-gray-200 transition-transform duration-300",
          "lg:translate-x-0",
          isMobileMenuOpen ? "translate-x-0" : "-translate-x-full"
        )}
      >
        <div className="flex flex-col h-full">
          {/* Logo */}
          <div className="flex items-center gap-3 px-6 py-5 border-b border-gray-200">
            <div className="p-2 bg-[#4C9A6A] rounded-xl">
              <Milk className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-lg font-bold text-[#2C3E50]">Leitinho</h1>
              <p className="text-xs text-[#6E7F80]">Painel Admin</p>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 px-3 py-4 overflow-y-auto">
            <ul className="space-y-1">
              {navigation.map((item) => {
                const isActive =
                  pathname === item.href ||
                  (item.href !== "/admin" && pathname.startsWith(item.href));
                return (
                  <li key={item.name}>
                    <Link
                      href={item.href}
                      onClick={() => setIsMobileMenuOpen(false)}
                      className={cn(
                        "flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors",
                        isActive
                          ? "bg-[#A8D5BA]/30 text-[#4C9A6A]"
                          : "text-[#6E7F80] hover:bg-gray-100"
                      )}
                    >
                      <item.icon
                        className={cn(
                          "w-5 h-5",
                          isActive ? "text-[#4C9A6A]" : "text-[#6E7F80]"
                        )}
                      />
                      {item.name}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </nav>

          {/* Footer */}
          <div className="px-3 py-4 border-t border-gray-200">
            <button className="flex items-center gap-3 w-full px-3 py-2.5 rounded-lg text-sm font-medium text-[#6E7F80] hover:bg-gray-100 transition-colors">
              <LogOut className="w-5 h-5 text-[#6E7F80]" />
              Sair
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
