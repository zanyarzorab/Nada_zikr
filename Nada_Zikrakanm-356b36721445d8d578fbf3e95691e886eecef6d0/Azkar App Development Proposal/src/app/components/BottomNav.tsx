import { Home, BookOpen, CircleDot, TrendingUp, Settings } from 'lucide-react';
import { motion } from 'motion/react';
import type { Screen } from '../App';

interface BottomNavProps {
  currentScreen: Screen;
  onNavigate: (screen: Screen) => void;
}

export function BottomNav({ currentScreen, onNavigate }: BottomNavProps) {
  const navItems = [
    { id: 'home' as Screen, icon: Home, label: 'Home' },
    { id: 'categories' as Screen, icon: BookOpen, label: 'Azkar' },
    { id: 'tasbeeh' as Screen, icon: CircleDot, label: 'Tasbeeh' },
    { id: 'statistics' as Screen, icon: TrendingUp, label: 'Progress' },
    { id: 'settings' as Screen, icon: Settings, label: 'Settings' },
  ];

  return (
    <div className="relative bg-white border-t border-gray-100">
      <nav className="flex items-center justify-around px-2 py-3">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = currentScreen === item.id;
          
          return (
            <button
              key={item.id}
              onClick={() => onNavigate(item.id)}
              className="relative flex flex-col items-center gap-1 px-4 py-2 rounded-xl transition-all"
            >
              {isActive && (
                <motion.div
                  layoutId="activeTab"
                  className="absolute inset-0 bg-emerald-50 rounded-xl"
                  transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                />
              )}
              <Icon
                size={22}
                className={`relative z-10 transition-colors ${
                  isActive ? 'text-emerald-600' : 'text-gray-400'
                }`}
                strokeWidth={isActive ? 2.5 : 2}
              />
              <span
                className={`relative z-10 text-xs transition-colors ${
                  isActive ? 'text-emerald-700 font-medium' : 'text-gray-500'
                }`}
              >
                {item.label}
              </span>
            </button>
          );
        })}
      </nav>
    </div>
  );
}
