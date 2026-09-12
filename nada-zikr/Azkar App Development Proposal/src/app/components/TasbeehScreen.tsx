import { useState } from 'react';
import { RotateCcw, Settings, Volume2, Vibrate } from 'lucide-react';
import { motion } from 'motion/react';

export function TasbeehScreen() {
  const [count, setCount] = useState(0);
  const [goal, setGoal] = useState(33);
  const [rounds, setRounds] = useState(0);

  const handleIncrement = () => {
    const newCount = count + 1;
    if (newCount >= goal) {
      setRounds(rounds + 1);
      setCount(0);
    } else {
      setCount(newCount);
    }
  };

  const handleReset = () => {
    setCount(0);
    setRounds(0);
  };

  const progress = (count / goal) * 100;

  return (
    <div className="h-full flex flex-col bg-gradient-to-br from-teal-50 via-emerald-50 to-cyan-50">
      {/* Header */}
      <div className="bg-white/80 backdrop-blur-lg border-b border-gray-100 px-6 py-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl text-gray-900">Tasbeeh</h1>
          <button className="p-2 rounded-full hover:bg-gray-100 transition-colors">
            <Settings size={22} className="text-gray-600" />
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col items-center justify-center px-6 pb-24">
        {/* Rounds Counter */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <p className="text-gray-600 text-sm mb-1">Completed Rounds</p>
          <div className="text-6xl text-emerald-600">{rounds}</div>
        </motion.div>

        {/* Main Counter Circle */}
        <motion.div
          whileTap={{ scale: 0.95 }}
          className="relative mb-12"
        >
          {/* Progress Ring */}
          <svg className="transform -rotate-90 w-80 h-80">
            <circle
              cx="160"
              cy="160"
              r="140"
              stroke="#e5e7eb"
              strokeWidth="12"
              fill="none"
            />
            <motion.circle
              cx="160"
              cy="160"
              r="140"
              stroke="url(#gradient)"
              strokeWidth="12"
              fill="none"
              strokeLinecap="round"
              initial={{ strokeDashoffset: 880 }}
              animate={{ strokeDashoffset: 880 - (880 * progress) / 100 }}
              style={{ strokeDasharray: 880 }}
              transition={{ duration: 0.3 }}
            />
            <defs>
              <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" stopColor="#10b981" />
                <stop offset="100%" stopColor="#14b8a6" />
              </linearGradient>
            </defs>
          </svg>

          {/* Counter Button */}
          <button
            onClick={handleIncrement}
            className="absolute inset-0 m-auto w-64 h-64 bg-gradient-to-br from-emerald-500 to-teal-600 rounded-full shadow-2xl flex flex-col items-center justify-center text-white active:scale-95 transition-transform"
          >
            <p className="text-sm text-emerald-100 mb-2">Tap to Count</p>
            <div className="text-7xl mb-2">{count}</div>
            <p className="text-emerald-100">of {goal}</p>
          </button>
        </motion.div>

        {/* Quick Actions */}
        <div className="flex items-center gap-4">
          <button
            onClick={handleReset}
            className="bg-white rounded-xl px-6 py-3 shadow-md border border-gray-200 hover:shadow-lg transition-all flex items-center gap-2"
          >
            <RotateCcw size={20} className="text-gray-700" />
            <span className="text-gray-900 font-medium">Reset</span>
          </button>

          <button className="bg-white rounded-xl p-3 shadow-md border border-gray-200 hover:shadow-lg transition-all">
            <Volume2 size={20} className="text-gray-700" />
          </button>

          <button className="bg-white rounded-xl p-3 shadow-md border border-gray-200 hover:shadow-lg transition-all">
            <Vibrate size={20} className="text-gray-700" />
          </button>
        </div>

        {/* Goal Presets */}
        <div className="mt-8 flex items-center gap-3">
          {[33, 99, 100].map((preset) => (
            <button
              key={preset}
              onClick={() => {
                setGoal(preset);
                setCount(0);
              }}
              className={`px-5 py-2 rounded-full font-medium transition-all ${
                goal === preset
                  ? 'bg-emerald-500 text-white shadow-md'
                  : 'bg-white text-gray-700 border border-gray-200 hover:border-emerald-300'
              }`}
            >
              {preset}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
