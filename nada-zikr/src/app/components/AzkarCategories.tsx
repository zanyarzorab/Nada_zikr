import { Sunrise, Sun, Moon, Bed, Sparkles, Heart, Clock, Star } from 'lucide-react';
import { motion } from 'motion/react';

interface AzkarCategoriesProps {
  onCategorySelect: (category: string) => void;
}

export function AzkarCategories({ onCategorySelect }: AzkarCategoriesProps) {
  const categories = [
    {
      id: 'morning',
      title: 'Morning Azkar',
      subtitle: '7 recitations',
      icon: Sunrise,
      color: 'from-amber-400 to-orange-500',
      bgColor: 'bg-orange-50',
    },
    {
      id: 'evening',
      title: 'Evening Azkar',
      subtitle: '9 recitations',
      icon: Moon,
      color: 'from-indigo-400 to-purple-500',
      bgColor: 'bg-purple-50',
    },
    {
      id: 'sleep',
      title: 'Before Sleep',
      subtitle: '5 recitations',
      icon: Bed,
      color: 'from-blue-400 to-cyan-500',
      bgColor: 'bg-blue-50',
    },
    {
      id: 'prayer',
      title: 'After Prayer',
      subtitle: '12 recitations',
      icon: Sparkles,
      color: 'from-emerald-400 to-teal-500',
      bgColor: 'bg-emerald-50',
    },
    {
      id: 'day',
      title: 'Throughout the Day',
      subtitle: '15 recitations',
      icon: Sun,
      color: 'from-yellow-400 to-amber-500',
      bgColor: 'bg-amber-50',
    },
    {
      id: 'emotions',
      title: 'Peace & Comfort',
      subtitle: '8 recitations',
      icon: Heart,
      color: 'from-pink-400 to-rose-500',
      bgColor: 'bg-pink-50',
    },
    {
      id: 'occasions',
      title: 'Special Occasions',
      subtitle: '10 recitations',
      icon: Star,
      color: 'from-violet-400 to-purple-500',
      bgColor: 'bg-violet-50',
    },
    {
      id: 'favorites',
      title: 'My Favorites',
      subtitle: '3 saved',
      icon: Clock,
      color: 'from-gray-400 to-gray-600',
      bgColor: 'bg-gray-50',
    },
  ];

  return (
    <div className="h-full overflow-y-auto bg-white">
      {/* Header */}
      <div className="sticky top-0 bg-white/80 backdrop-blur-lg border-b border-gray-100 px-6 py-6 z-10">
        <h1 className="text-2xl text-gray-900">Azkar Categories</h1>
        <p className="text-gray-600 text-sm mt-1">Choose your spiritual journey</p>
      </div>

      {/* Categories Grid */}
      <div className="px-6 py-6 pb-24">
        <div className="grid grid-cols-1 gap-3">
          {categories.map((category, index) => {
            const Icon = category.icon;
            return (
              <motion.button
                key={category.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: index * 0.05 }}
                onClick={() => onCategorySelect(category.id)}
                className={`${category.bgColor} rounded-2xl p-5 border border-gray-100 hover:shadow-md transition-all text-left`}
              >
                <div className="flex items-center gap-4">
                  <div className={`bg-gradient-to-br ${category.color} rounded-xl p-3 text-white shadow-md`}>
                    <Icon size={26} strokeWidth={2} />
                  </div>
                  <div className="flex-1">
                    <h3 className="text-gray-900 font-medium mb-1">{category.title}</h3>
                    <p className="text-gray-600 text-sm">{category.subtitle}</p>
                  </div>
                  <div className="text-gray-400">
                    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                      <path d="M7.5 15L12.5 10L7.5 5" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                    </svg>
                  </div>
                </div>
              </motion.button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
