import { Sunrise, Sun, Moon, Clock, Flame, Star, ChevronRight, Compass } from 'lucide-react';
import { motion } from 'motion/react';
import type { Screen } from '../App';

interface HomeScreenProps {
  onNavigate: (screen: Screen) => void;
  onCategorySelect: (category: string) => void;
}

export function HomeScreen({ onNavigate, onCategorySelect }: HomeScreenProps) {
  const currentHour = new Date().getHours();
  const greeting = currentHour < 12 ? 'Good Morning' : currentHour < 18 ? 'Good Afternoon' : 'Good Evening';

  const dailyPath = [
    { id: 'morning', title: 'Morning Azkar', icon: Sunrise, completed: true, count: '7/7', color: 'from-amber-400 to-orange-500' },
    { id: 'day', title: 'Day Azkar', icon: Sun, completed: false, count: '3/12', color: 'from-blue-400 to-cyan-500' },
    { id: 'evening', title: 'Evening Azkar', icon: Moon, completed: false, count: '0/9', color: 'from-indigo-400 to-purple-500' },
  ];

  const quickActions = [
    { id: 'qibla', title: 'Qibla', icon: Compass, screen: 'qibla' as Screen },
    { id: 'prayer', title: 'Prayer Times', icon: Clock, screen: 'home' as Screen },
  ];

  return (
    <div className="h-full overflow-y-auto bg-gradient-to-b from-emerald-50 to-white">
      {/* Header */}
      <div className="px-6 pt-8 pb-6">
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <p className="text-gray-600 text-sm mb-1">{greeting}</p>
          <h1 className="text-3xl text-gray-900 mb-6">Peace be upon you</h1>
        </motion.div>

        {/* Streak Card */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className="bg-gradient-to-br from-emerald-500 to-teal-600 rounded-3xl p-6 text-white shadow-lg"
        >
          <div className="flex items-center justify-between mb-4">
            <div>
              <p className="text-emerald-100 text-sm mb-1">Current Streak</p>
              <div className="flex items-baseline gap-2">
                <span className="text-4xl">14</span>
                <span className="text-xl text-emerald-100">days</span>
              </div>
            </div>
            <div className="bg-white/20 rounded-full p-3">
              <Flame size={32} className="text-amber-200" />
            </div>
          </div>
          <div className="flex items-center gap-2 text-emerald-100 text-sm">
            <Star size={16} fill="currentColor" />
            <span>Keep it up! You're building a beautiful habit</span>
          </div>
        </motion.div>
      </div>

      {/* Daily Path */}
      <div className="px-6 mb-6">
        <h2 className="text-lg text-gray-900 mb-4">Today's Path</h2>
        <div className="space-y-3">
          {dailyPath.map((item, index) => {
            const Icon = item.icon;
            return (
              <motion.button
                key={item.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.4, delay: 0.2 + index * 0.1 }}
                onClick={() => onCategorySelect(item.id)}
                className="w-full bg-white rounded-2xl p-4 shadow-sm border border-gray-100 hover:shadow-md transition-all"
              >
                <div className="flex items-center gap-4">
                  <div className={`bg-gradient-to-br ${item.color} rounded-xl p-3 text-white`}>
                    <Icon size={24} />
                  </div>
                  <div className="flex-1 text-left">
                    <h3 className="text-gray-900 font-medium mb-1">{item.title}</h3>
                    <p className="text-gray-500 text-sm">{item.count} completed</p>
                  </div>
                  <div className="flex items-center gap-2">
                    {item.completed && (
                      <div className="bg-emerald-100 text-emerald-600 rounded-full px-3 py-1 text-xs font-medium">
                        Done
                      </div>
                    )}
                    <ChevronRight size={20} className="text-gray-400" />
                  </div>
                </div>
              </motion.button>
            );
          })}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="px-6 pb-6">
        <h2 className="text-lg text-gray-900 mb-4">Quick Access</h2>
        <div className="grid grid-cols-2 gap-3">
          {quickActions.map((action, index) => {
            const Icon = action.icon;
            return (
              <motion.button
                key={action.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: 0.5 + index * 0.1 }}
                onClick={() => onNavigate(action.screen)}
                className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 hover:shadow-md transition-all"
              >
                <div className="flex flex-col items-center gap-3">
                  <div className="bg-gray-50 rounded-full p-3">
                    <Icon size={24} className="text-gray-700" />
                  </div>
                  <span className="text-gray-900 text-sm font-medium">{action.title}</span>
                </div>
              </motion.button>
            );
          })}
        </div>
      </div>

      {/* Daily Verse */}
      <div className="px-6 pb-24">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.7 }}
          className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl p-6 border border-purple-100"
        >
          <p className="text-purple-900 text-xs uppercase tracking-wider mb-3">Verse of the Day</p>
          <p className="text-gray-800 text-lg leading-relaxed mb-3 font-serif">
            "And He is with you wherever you are."
          </p>
          <p className="text-gray-600 text-sm">— Quran 57:4</p>
        </motion.div>
      </div>
    </div>
  );
}
