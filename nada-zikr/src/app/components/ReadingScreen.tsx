import { useState } from 'react';
import { ArrowLeft, Volume2, Heart, Check, ChevronLeft, ChevronRight } from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

interface ReadingScreenProps {
  category: string | null;
  onBack: () => void;
}

const azkarData = {
  morning: [
    {
      id: 1,
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      transliteration: 'Aṣbaḥnā wa-aṣbaḥa l-mulku lillāh',
      translation: 'We have entered the morning and the dominion belongs to Allah',
      count: 1,
      benefit: 'Protection throughout the day',
    },
    {
      id: 2,
      arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا',
      transliteration: 'Allāhumma bika aṣbaḥnā wa-bika amsaynā',
      translation: 'O Allah, by You we enter the morning and by You we enter the evening',
      count: 1,
      benefit: 'Acknowledging Allah in all moments',
    },
    {
      id: 3,
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      transliteration: 'Subḥāna llāhi wa-biḥamdih',
      translation: 'Glory be to Allah and praise be to Him',
      count: 100,
      benefit: 'Sins forgiven',
    },
  ],
};

export function ReadingScreen({ category, onBack }: ReadingScreenProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [progress, setProgress] = useState<{ [key: number]: number }>({});
  const [isFavorite, setIsFavorite] = useState(false);

  const azkar = azkarData.morning || [];
  const currentZikr = azkar[currentIndex];

  if (!currentZikr) {
    return null;
  }

  const handleIncrement = () => {
    const current = progress[currentZikr.id] || 0;
    if (current < currentZikr.count) {
      setProgress({ ...progress, [currentZikr.id]: current + 1 });
    }
  };

  const handleNext = () => {
    if (currentIndex < azkar.length - 1) {
      setCurrentIndex(currentIndex + 1);
    }
  };

  const handlePrevious = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
    }
  };

  const currentProgress = progress[currentZikr.id] || 0;
  const isCompleted = currentProgress >= currentZikr.count;
  const progressPercentage = (currentProgress / currentZikr.count) * 100;

  return (
    <div className="h-full flex flex-col bg-gradient-to-b from-emerald-50 to-white">
      {/* Header */}
      <div className="bg-white/80 backdrop-blur-lg border-b border-gray-100 px-6 py-4">
        <div className="flex items-center justify-between">
          <button
            onClick={onBack}
            className="p-2 -ml-2 rounded-full hover:bg-gray-100 transition-colors"
          >
            <ArrowLeft size={24} className="text-gray-700" />
          </button>
          <div className="text-center">
            <p className="text-sm text-gray-600">Morning Azkar</p>
            <p className="text-xs text-gray-500 mt-1">
              {currentIndex + 1} of {azkar.length}
            </p>
          </div>
          <button
            onClick={() => setIsFavorite(!isFavorite)}
            className="p-2 -mr-2 rounded-full hover:bg-gray-100 transition-colors"
          >
            <Heart
              size={22}
              className={isFavorite ? 'text-rose-500 fill-rose-500' : 'text-gray-400'}
            />
          </button>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="px-6 py-4">
        <div className="bg-gray-100 rounded-full h-2 overflow-hidden">
          <motion.div
            className="bg-gradient-to-r from-emerald-500 to-teal-500 h-full rounded-full"
            initial={{ width: 0 }}
            animate={{ width: `${progressPercentage}%` }}
            transition={{ duration: 0.3 }}
          />
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-6">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentZikr.id}
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            transition={{ duration: 0.3 }}
            className="space-y-8"
          >
            {/* Arabic Text */}
            <div className="bg-white rounded-3xl p-8 shadow-sm border border-gray-100">
              <p className="text-3xl text-center leading-loose text-gray-900" style={{ fontFamily: 'serif' }}>
                {currentZikr.arabic}
              </p>
            </div>

            {/* Transliteration */}
            <div className="bg-blue-50 rounded-2xl p-6 border border-blue-100">
              <p className="text-sm text-blue-700 uppercase tracking-wide mb-2">Transliteration</p>
              <p className="text-lg text-blue-900 italic leading-relaxed">
                {currentZikr.transliteration}
              </p>
            </div>

            {/* Translation */}
            <div className="bg-purple-50 rounded-2xl p-6 border border-purple-100">
              <p className="text-sm text-purple-700 uppercase tracking-wide mb-2">Meaning</p>
              <p className="text-lg text-purple-900 leading-relaxed">
                {currentZikr.translation}
              </p>
            </div>

            {/* Benefit */}
            <div className="bg-amber-50 rounded-2xl p-5 border border-amber-100 flex items-start gap-3">
              <div className="bg-amber-200 rounded-full p-2 mt-0.5">
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M8 1L10.5 6L16 7L12 11L13 16L8 13.5L3 16L4 11L0 7L5.5 6L8 1Z" fill="#F59E0B"/>
                </svg>
              </div>
              <div>
                <p className="text-sm text-amber-700 font-medium mb-1">Benefit</p>
                <p className="text-amber-900">{currentZikr.benefit}</p>
              </div>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom Actions */}
      <div className="bg-white border-t border-gray-100 px-6 py-6 space-y-4">
        {/* Counter */}
        <div className="text-center">
          <p className="text-sm text-gray-600 mb-2">Recite {currentZikr.count} time{currentZikr.count > 1 ? 's' : ''}</p>
          <div className="flex items-center justify-center gap-4">
            <div className="text-center">
              <div className="flex items-baseline justify-center gap-1">
                <span className="text-4xl text-gray-900">{currentProgress}</span>
                <span className="text-xl text-gray-500">/ {currentZikr.count}</span>
              </div>
              {isCompleted && (
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  className="flex items-center justify-center gap-1 mt-2 text-emerald-600"
                >
                  <Check size={16} />
                  <span className="text-sm font-medium">Completed</span>
                </motion.div>
              )}
            </div>
          </div>
        </div>

        {/* Tap Button */}
        <button
          onClick={handleIncrement}
          disabled={isCompleted}
          className={`w-full py-5 rounded-2xl font-medium text-lg transition-all shadow-lg active:scale-95 ${
            isCompleted
              ? 'bg-emerald-100 text-emerald-700'
              : 'bg-gradient-to-r from-emerald-500 to-teal-500 text-white hover:shadow-xl'
          }`}
        >
          {isCompleted ? 'Completed ✓' : 'Tap to Count'}
        </button>

        {/* Navigation */}
        <div className="flex items-center gap-3">
          <button
            onClick={handlePrevious}
            disabled={currentIndex === 0}
            className={`flex-1 py-3 rounded-xl font-medium transition-all ${
              currentIndex === 0
                ? 'bg-gray-100 text-gray-400'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            <div className="flex items-center justify-center gap-2">
              <ChevronLeft size={20} />
              Previous
            </div>
          </button>
          <button
            onClick={handleNext}
            disabled={currentIndex === azkar.length - 1}
            className={`flex-1 py-3 rounded-xl font-medium transition-all ${
              currentIndex === azkar.length - 1
                ? 'bg-gray-100 text-gray-400'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            <div className="flex items-center justify-center gap-2">
              Next
              <ChevronRight size={20} />
            </div>
          </button>
        </div>
      </div>
    </div>
  );
}
