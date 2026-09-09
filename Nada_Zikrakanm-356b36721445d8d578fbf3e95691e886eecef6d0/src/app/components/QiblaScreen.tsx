import { useState } from 'react';
import { Navigation, MapPin, Loader } from 'lucide-react';
import { motion } from 'motion/react';

export function QiblaScreen() {
  const [isCalibrating, setIsCalibrating] = useState(false);
  const [qiblaDirection] = useState(145); // Mock angle for demonstration

  return (
    <div className="h-full flex flex-col bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
      {/* Header */}
      <div className="bg-white/80 backdrop-blur-lg border-b border-gray-100 px-6 py-6">
        <h1 className="text-2xl text-gray-900">Qibla Direction</h1>
        <div className="flex items-center gap-2 mt-2 text-gray-600">
          <MapPin size={16} />
          <p className="text-sm">Mecca, Saudi Arabia</p>
        </div>
      </div>

      {/* Main Compass */}
      <div className="flex-1 flex flex-col items-center justify-center px-6 pb-24">
        {/* Location Info */}
        <div className="bg-white rounded-2xl px-6 py-4 shadow-sm border border-gray-100 mb-8">
          <div className="flex items-center justify-between gap-8">
            <div className="text-center">
              <p className="text-xs text-gray-600 mb-1">Distance</p>
              <p className="text-lg text-gray-900">1,234 km</p>
            </div>
            <div className="w-px h-10 bg-gray-200" />
            <div className="text-center">
              <p className="text-xs text-gray-600 mb-1">Direction</p>
              <p className="text-lg text-gray-900">{qiblaDirection}° NE</p>
            </div>
          </div>
        </div>

        {/* Compass */}
        <div className="relative w-80 h-80 mb-8">
          {/* Outer Ring */}
          <motion.div
            className="absolute inset-0 rounded-full border-8 border-gray-200 bg-white shadow-2xl"
            animate={{ rotate: 0 }}
          >
            {/* Cardinal Directions */}
            <div className="absolute top-4 left-1/2 -translate-x-1/2 text-gray-900 font-bold">N</div>
            <div className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-500">E</div>
            <div className="absolute bottom-4 left-1/2 -translate-x-1/2 text-gray-500">S</div>
            <div className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-500">W</div>

            {/* Degree Markers */}
            {Array.from({ length: 36 }).map((_, i) => (
              <div
                key={i}
                className="absolute w-0.5 h-3 bg-gray-300 top-2 left-1/2 origin-bottom"
                style={{
                  transform: `translateX(-50%) rotate(${i * 10}deg) translateY(150px)`,
                }}
              />
            ))}
          </motion.div>

          {/* Qibla Indicator */}
          <motion.div
            className="absolute inset-0 flex items-center justify-center"
            animate={{ rotate: qiblaDirection }}
            transition={{ type: "spring", stiffness: 100, damping: 15 }}
          >
            <div className="flex flex-col items-center">
              <div className="bg-gradient-to-b from-emerald-500 to-emerald-600 rounded-full p-4 shadow-lg">
                <Navigation size={32} className="text-white" fill="white" />
              </div>
              <div className="w-1 h-24 bg-gradient-to-b from-emerald-500 to-transparent rounded-full" />
            </div>
          </motion.div>

          {/* Center Dot */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-4 h-4 bg-emerald-500 rounded-full border-2 border-white shadow-lg" />
        </div>

        {/* Calibration Button */}
        <button
          onClick={() => setIsCalibrating(true)}
          className="bg-white rounded-2xl px-8 py-4 shadow-md border border-gray-200 hover:shadow-lg transition-all flex items-center gap-3"
        >
          {isCalibrating ? (
            <>
              <Loader size={20} className="text-emerald-600 animate-spin" />
              <span className="text-gray-900 font-medium">Calibrating...</span>
            </>
          ) : (
            <>
              <div className="w-3 h-3 bg-emerald-500 rounded-full" />
              <span className="text-gray-900 font-medium">Compass Calibrated</span>
            </>
          )}
        </button>

        {/* Instructions */}
        <div className="mt-8 bg-blue-50 rounded-2xl p-5 border border-blue-100 max-w-sm">
          <p className="text-sm text-blue-900 leading-relaxed">
            Hold your device flat and rotate until the green arrow points upward to face the Qibla direction.
          </p>
        </div>
      </div>
    </div>
  );
}
