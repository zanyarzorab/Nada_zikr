import { Flame, TrendingUp, Clock, Target, Calendar } from 'lucide-react';
import { motion } from 'motion/react';

export function StatisticsScreen() {
  const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const weekData = [85, 100, 70, 100, 90, 100, 60];

  const stats = [
    { label: 'Current Streak', value: '14', unit: 'days', icon: Flame, color: 'from-orange-400 to-red-500' },
    { label: 'Total Dhikr', value: '2,847', unit: 'times', icon: Target, color: 'from-emerald-400 to-teal-500' },
    { label: 'Time Spent', value: '24', unit: 'hours', icon: Clock, color: 'from-blue-400 to-cyan-500' },
    { label: 'Best Streak', value: '21', unit: 'days', icon: TrendingUp, color: 'from-purple-400 to-pink-500' },
  ];

  const achievements = [
    { title: 'First Steps', description: 'Complete your first Azkar', unlocked: true },
    { title: '7 Day Streak', description: 'Maintain a 7-day streak', unlocked: true },
    { title: '30 Day Warrior', description: 'Complete 30 consecutive days', unlocked: false },
    { title: '1000 Dhikr', description: 'Recite 1000 times total', unlocked: true },
  ];

  return (
    <div className="h-full overflow-y-auto bg-gradient-to-b from-purple-50 to-white">
      {/* Header */}
      <div className="sticky top-0 bg-white/80 backdrop-blur-lg border-b border-gray-100 px-6 py-6 z-10">
        <h1 className="text-2xl text-gray-900">Your Progress</h1>
        <p className="text-gray-600 text-sm mt-1">Keep up the amazing work!</p>
      </div>

      {/* Stats Grid */}
      <div className="px-6 py-6">
        <div className="grid grid-cols-2 gap-3 mb-6">
          {stats.map((stat, index) => {
            const Icon = stat.icon;
            return (
              <motion.div
                key={stat.label}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: index * 0.05 }}
                className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100"
              >
                <div className={`bg-gradient-to-br ${stat.color} w-10 h-10 rounded-xl flex items-center justify-center mb-3`}>
                  <Icon size={20} className="text-white" />
                </div>
                <div className="flex items-baseline gap-1 mb-1">
                  <span className="text-2xl text-gray-900">{stat.value}</span>
                  <span className="text-sm text-gray-500">{stat.unit}</span>
                </div>
                <p className="text-xs text-gray-600">{stat.label}</p>
              </motion.div>
            );
          })}
        </div>

        {/* Weekly Activity */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 mb-6"
        >
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-lg text-gray-900">This Week</h2>
              <p className="text-sm text-gray-600 mt-1">Daily completion rate</p>
            </div>
            <div className="bg-emerald-50 text-emerald-700 rounded-full px-3 py-1 text-sm font-medium">
              87% avg
            </div>
          </div>

          {/* Bar Chart */}
          <div className="flex items-end justify-between gap-2 h-32 mb-3">
            {weekData.map((value, index) => (
              <div key={index} className="flex-1 flex flex-col items-center gap-2">
                <motion.div
                  initial={{ height: 0 }}
                  animate={{ height: `${value}%` }}
                  transition={{ duration: 0.5, delay: 0.3 + index * 0.05 }}
                  className={`w-full rounded-lg ${
                    value === 100
                      ? 'bg-gradient-to-t from-emerald-400 to-emerald-500'
                      : 'bg-gradient-to-t from-blue-300 to-blue-400'
                  }`}
                />
                <span className="text-xs text-gray-600">{weekDays[index]}</span>
              </div>
            ))}
          </div>
        </motion.div>

        {/* Monthly Calendar */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 mb-6"
        >
          <div className="flex items-center gap-2 mb-4">
            <Calendar size={20} className="text-gray-700" />
            <h2 className="text-lg text-gray-900">March 2026</h2>
          </div>
          <div className="grid grid-cols-7 gap-2">
            {Array.from({ length: 31 }).map((_, i) => {
              const isCompleted = i < 28;
              const isToday = i === 27;
              return (
                <div
                  key={i}
                  className={`aspect-square rounded-lg flex items-center justify-center text-sm ${
                    isToday
                      ? 'bg-emerald-500 text-white font-bold ring-2 ring-emerald-300'
                      : isCompleted
                      ? 'bg-emerald-100 text-emerald-700'
                      : 'bg-gray-50 text-gray-400'
                  }`}
                >
                  {i + 1}
                </div>
              );
            })}
          </div>
        </motion.div>

        {/* Achievements */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.5 }}
          className="pb-24"
        >
          <h2 className="text-lg text-gray-900 mb-4">Achievements</h2>
          <div className="space-y-3">
            {achievements.map((achievement, index) => (
              <div
                key={index}
                className={`rounded-2xl p-5 border ${
                  achievement.unlocked
                    ? 'bg-gradient-to-r from-amber-50 to-yellow-50 border-amber-200'
                    : 'bg-gray-50 border-gray-200'
                }`}
              >
                <div className="flex items-start gap-4">
                  <div
                    className={`w-12 h-12 rounded-full flex items-center justify-center ${
                      achievement.unlocked ? 'bg-amber-400' : 'bg-gray-300'
                    }`}
                  >
                    <span className="text-2xl">
                      {achievement.unlocked ? '🏆' : '🔒'}
                    </span>
                  </div>
                  <div className="flex-1">
                    <h3
                      className={`font-medium mb-1 ${
                        achievement.unlocked ? 'text-amber-900' : 'text-gray-500'
                      }`}
                    >
                      {achievement.title}
                    </h3>
                    <p
                      className={`text-sm ${
                        achievement.unlocked ? 'text-amber-700' : 'text-gray-500'
                      }`}
                    >
                      {achievement.description}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </div>
  );
}
