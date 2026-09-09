import { Bell, Volume2, Vibrate, Moon, Languages, Info, Heart, Share2, ChevronRight } from 'lucide-react';
import { motion } from 'motion/react';

export function SettingsScreen() {
  const settingsSections = [
    {
      title: 'Preferences',
      items: [
        { icon: Bell, label: 'Notifications', description: 'Smart reminders', hasToggle: true, enabled: true },
        { icon: Volume2, label: 'Audio', description: 'Recitation & sounds', hasToggle: true, enabled: true },
        { icon: Vibrate, label: 'Vibration', description: 'Haptic feedback', hasToggle: true, enabled: false },
        { icon: Moon, label: 'Dark Mode', description: 'Appearance', hasToggle: true, enabled: false },
      ],
    },
    {
      title: 'Content',
      items: [
        { icon: Languages, label: 'Language', description: 'English', hasToggle: false },
      ],
    },
    {
      title: 'Support',
      items: [
        { icon: Heart, label: 'Rate Us', description: 'Share your feedback', hasToggle: false },
        { icon: Share2, label: 'Share App', description: 'Invite friends', hasToggle: false },
        { icon: Info, label: 'About', description: 'Version 1.0.0', hasToggle: false },
      ],
    },
  ];

  return (
    <div className="h-full overflow-y-auto bg-gradient-to-b from-gray-50 to-white">
      {/* Header */}
      <div className="sticky top-0 bg-white/80 backdrop-blur-lg border-b border-gray-100 px-6 py-6 z-10">
        <h1 className="text-2xl text-gray-900">Settings</h1>
        <p className="text-gray-600 text-sm mt-1">Customize your experience</p>
      </div>

      {/* Profile Card */}
      <div className="px-6 py-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-gradient-to-br from-emerald-500 to-teal-600 rounded-3xl p-6 text-white shadow-lg mb-6"
        >
          <div className="flex items-center gap-4 mb-4">
            <div className="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center text-2xl backdrop-blur-sm">
              👤
            </div>
            <div className="flex-1">
              <h2 className="text-xl mb-1">Guest User</h2>
              <p className="text-emerald-100 text-sm">14 days streak • 2,847 dhikr</p>
            </div>
          </div>
          <button className="w-full bg-white/20 backdrop-blur-sm rounded-xl py-3 text-white font-medium hover:bg-white/30 transition-colors">
            Create Account (Optional)
          </button>
        </motion.div>

        {/* Settings Sections */}
        {settingsSections.map((section, sectionIndex) => (
          <motion.div
            key={section.title}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, delay: 0.1 + sectionIndex * 0.1 }}
            className="mb-6"
          >
            <h3 className="text-sm text-gray-600 uppercase tracking-wider mb-3 px-1">
              {section.title}
            </h3>
            <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
              {section.items.map((item, itemIndex) => {
                const Icon = item.icon;
                return (
                  <button
                    key={itemIndex}
                    className={`w-full px-5 py-4 flex items-center gap-4 hover:bg-gray-50 transition-colors ${
                      itemIndex !== section.items.length - 1 ? 'border-b border-gray-100' : ''
                    }`}
                  >
                    <div className="bg-gray-100 rounded-xl p-2.5">
                      <Icon size={20} className="text-gray-700" />
                    </div>
                    <div className="flex-1 text-left">
                      <p className="text-gray-900 font-medium mb-0.5">{item.label}</p>
                      <p className="text-gray-500 text-sm">{item.description}</p>
                    </div>
                    {item.hasToggle ? (
                      <div
                        className={`w-12 h-7 rounded-full transition-colors relative ${
                          item.enabled ? 'bg-emerald-500' : 'bg-gray-300'
                        }`}
                      >
                        <div
                          className={`absolute top-1 w-5 h-5 bg-white rounded-full transition-all shadow-sm ${
                            item.enabled ? 'left-6' : 'left-1'
                          }`}
                        />
                      </div>
                    ) : (
                      <ChevronRight size={20} className="text-gray-400" />
                    )}
                  </button>
                );
              })}
            </div>
          </motion.div>
        ))}

        {/* Prayer Times Widget */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-2xl p-6 border border-blue-100 mb-24"
        >
          <h3 className="text-gray-900 font-medium mb-4">Today's Prayer Times</h3>
          <div className="space-y-3">
            {[
              { name: 'Fajr', time: '5:42 AM', isPast: true },
              { name: 'Dhuhr', time: '12:35 PM', isPast: true },
              { name: 'Asr', time: '3:48 PM', isNext: true },
              { name: 'Maghrib', time: '6:21 PM', isPast: false },
              { name: 'Isha', time: '7:45 PM', isPast: false },
            ].map((prayer) => (
              <div
                key={prayer.name}
                className={`flex items-center justify-between px-4 py-3 rounded-xl ${
                  prayer.isNext
                    ? 'bg-blue-500 text-white'
                    : 'bg-white text-gray-900'
                }`}
              >
                <span className={`font-medium ${prayer.isPast && !prayer.isNext ? 'text-gray-500' : ''}`}>
                  {prayer.name}
                </span>
                <span className={`${prayer.isPast && !prayer.isNext ? 'text-gray-500' : ''}`}>
                  {prayer.time}
                </span>
              </div>
            ))}
          </div>
        </motion.div>
      </div>
    </div>
  );
}
