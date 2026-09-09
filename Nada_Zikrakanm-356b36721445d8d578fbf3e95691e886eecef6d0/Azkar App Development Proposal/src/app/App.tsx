import { useState } from "react";
import {
  Moon, Star, BarChart2, Settings, ArrowLeft, CheckCircle,
  Flame, X, BookOpen, Compass
} from "lucide-react";
import quranData from "imanikurd/data/quran.json";
import tafsirRebarData from "imanikurd/data/tafsir_rebar.json";
import tafsirAsanData from "imanikurd/data/tafsir_asan.json";
import tafsirPuxtaData from "imanikurd/data/tafsir_puxta.json";
import tafsirRamanData from "imanikurd/data/tafsir_raman.json";
import tafsirHazharData from "imanikurd/data/tafsir_hazhar.json";
import tafsirZhinData from "imanikurd/data/tafsir_zhin.json";
import tafsirSanahiData from "imanikurd/data/tafsir_sanahi.json";
import tafsirMaisarData from "imanikurd/data/tafsir_maisar.json";
import tafsirTawhidData from "imanikurd/data/tafsir_tawhid.json";
import tafsirRoshnData from "imanikurd/data/tafsir_roshn.json";
import tafsirRunahiData from "imanikurd/data/tafsir_runahi.json";
import tafsirMokhtasarData from "imanikurd/data/tafsir_mokhtasar.json";
import tafsirKrdData from "imanikurd/data/tafsir_krd.json";
import UserFlowsPage from "./components/UserFlowsPage";

// ─── Types ───────────────────────────────────────────────────────────────────

type MainScreen = "home" | "categories" | "reading" | "quran" | "tasbeeh" | "statistics" | "settings";
type OverlayScreen = "onboarding" | "focus" | "names" | null;

// ─── Data ────────────────────────────────────────────────────────────────────

const MOODS = [
  { id: "grateful", label: "شاكر", english: "Grateful", emoji: "🌿" },
  { id: "anxious", label: "قلق", english: "Anxious", emoji: "☁️" },
  { id: "hopeful", label: "متفائل", english: "Hopeful", emoji: "✨" },
  { id: "tired", label: "متعب", english: "Tired", emoji: "🌙" },
  { id: "joyful", label: "سعيد", english: "Joyful", emoji: "☀️" },
  { id: "sad", label: "حزين", english: "Sad", emoji: "💧" },
];

const AZKAR_CATEGORIES = [
  { id: "morning", label: "أذكار الصباح", english: "Morning Azkar", icon: "🌅", count: 18, color: "#C9A84C" },
  { id: "evening", label: "أذكار المساء", english: "Evening Azkar", icon: "🌆", count: 15, color: "#14B8A6" },
  { id: "sleep", label: "أذكار النوم", english: "Before Sleep", icon: "🌙", count: 12, color: "#7C3AED" },
  { id: "prayer", label: "أذكار الصلاة", english: "After Prayer", icon: "🕌", count: 10, color: "#059669" },
  { id: "quran", label: "أذكار القرآن", english: "Quran Azkar", icon: "📖", count: 8, color: "#DC2626" },
  { id: "general", label: "أذكار عامة", english: "General", icon: "💫", count: 24, color: "#D97706" },
];

const NAMES_OF_ALLAH = [
  { n: 1, ar: "الرَّحْمَنُ", tr: "Ar-Rahman", en: "The Most Gracious" },
  { n: 2, ar: "الرَّحِيمُ", tr: "Ar-Rahim", en: "The Most Merciful" },
  { n: 3, ar: "الْمَلِكُ", tr: "Al-Malik", en: "The King" },
  { n: 4, ar: "الْقُدُّوسُ", tr: "Al-Quddus", en: "The Most Sacred" },
  { n: 5, ar: "السَّلَامُ", tr: "As-Salam", en: "The Source of Peace" },
  { n: 6, ar: "الْمُؤْمِنُ", tr: "Al-Mumin", en: "The Guardian of Faith" },
  { n: 7, ar: "الْمُهَيْمِنُ", tr: "Al-Muhaymin", en: "The Protector" },
  { n: 8, ar: "الْعَزِيزُ", tr: "Al-Aziz", en: "The Almighty" },
  { n: 9, ar: "الْجَبَّارُ", tr: "Al-Jabbar", en: "The Compeller" },
  { n: 10, ar: "الْمُتَكَبِّرُ", tr: "Al-Mutakabbir", en: "The Majestic" },
  { n: 11, ar: "الْخَالِقُ", tr: "Al-Khaliq", en: "The Creator" },
  { n: 12, ar: "الْبَارِئُ", tr: "Al-Bari", en: "The Maker" },
  { n: 13, ar: "الْمُصَوِّرُ", tr: "Al-Musawwir", en: "The Fashioner" },
  { n: 14, ar: "الْغَفَّارُ", tr: "Al-Ghaffar", en: "The Repeatedly Forgiving" },
  { n: 15, ar: "الْقَهَّارُ", tr: "Al-Qahhar", en: "The Subduer" },
  { n: 16, ar: "الْوَهَّابُ", tr: "Al-Wahhab", en: "The Bestower" },
  { n: 17, ar: "الرَّزَّاقُ", tr: "Ar-Razzaq", en: "The Provider" },
  { n: 18, ar: "الْفَتَّاحُ", tr: "Al-Fattah", en: "The Opener" },
  { n: 19, ar: "الْعَلِيمُ", tr: "Al-Alim", en: "The All-Knowing" },
  { n: 20, ar: "الْقَابِضُ", tr: "Al-Qabid", en: "The Restrainer" },
  { n: 21, ar: "الْبَاسِطُ", tr: "Al-Basit", en: "The Extender" },
  { n: 22, ar: "اللَّطِيفُ", tr: "Al-Latif", en: "The Subtle One" },
  { n: 23, ar: "الرَّافِعُ", tr: "Ar-Rafi", en: "The Exalter" },
  { n: 24, ar: "الْعَلِيُّ", tr: "Al-Ali", en: "The Most High" },
];

const MORNING_AZKAR = [
  {
    arabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ",
    translation: "We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah.",
    repeat: 1,
    source: "Abu Dawud",
  },
  {
    arabic: "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ",
    translation: "O Allah, by You we enter the morning and by You we enter the evening, by You we live and by You we die, and to You is the resurrection.",
    repeat: 1,
    source: "At-Tirmidhi",
  },
  {
    arabic: "سُبْحَانَ اللهِ وَبِحَمْدِهِ",
    translation: "Glory is to Allah and praise is to Him.",
    repeat: 100,
    source: "Al-Bukhari",
  },
  {
    arabic: "لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ",
    translation: "None has the right to be worshipped except Allah, alone, without partner. To Him belongs all sovereignty and praise.",
    repeat: 10,
    source: "Muslim",
  },
  {
    arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ",
    translation: "O Allah, You are my Lord, none has the right to be worshipped except You, You created me and I am Your servant.",
    repeat: 1,
    source: "Al-Bukhari",
  },
];

// Deterministic heatmap — no random per render
const HEATMAP_DATA = Array.from({ length: 84 }, (_, i) => {
  const seed = (i * 7 + 13) % 17;
  const level = seed < 5 ? 0 : seed < 9 ? 1 : seed < 13 ? 2 : seed < 16 ? 3 : 4;
  return level;
});

const QURAN_DATA = quranData as {
  surahs: Array<{
    number: number;
    englishName: string;
    name: string;
    numberOfAyahs: number;
  }>;
  ayahs: Array<{
    surah: number;
    ayah: number;
    text: string;
    juz: number;
  }>;
};

const QURAN_SURAHS = QURAN_DATA.surahs;
const QURAN_TAFSIR_OPTIONS = [
  { id: "rebar", name: "تێفسیری ڕێبەر" },
  { id: "asan", name: "تێفسیری ئاسان" },
  { id: "puxta", name: "تێفسیری پۆختە" },
  { id: "raman", name: "تێفسیری ڕامان" },
  { id: "hazhar", name: "تێفسیری هەژار" },
  { id: "zhin", name: "تێفسیری ژین" },
  { id: "sanahi", name: "تێفسیری سەنەهێ" },
  { id: "maisar", name: "تێفسیری مایسەر" },
  { id: "tawhid", name: "تێفسیری تەوەیدی" },
  { id: "roshn", name: "تێفسیری ڕۆشن" },
  { id: "runahi", name: "تێفسیری ڕوناهی" },
  { id: "mokhtasar", name: "تێفسیری مۆختەسەر" },
  { id: "krd", name: "تێفسیری کوردی" },
] as const;

const QURAN_TAFSIR_DATA = {
  rebar: tafsirRebarData as Array<{ s: number | string; a: number; t: string }>,
  asan: tafsirAsanData as Array<{ s: number | string; a: number; t: string }>,
  puxta: tafsirPuxtaData as Array<{ s: number | string; a: number; t: string }>,
  raman: tafsirRamanData as Array<{ s: number | string; a: number; t: string }>,
  hazhar: tafsirHazharData as Array<{ s: number | string; a: number; t: string }>,
  zhin: tafsirZhinData as Array<{ s: number | string; a: number; t: string }>,
  sanahi: tafsirSanahiData as Array<{ s: number | string; a: number; t: string }>,
  maisar: tafsirMaisarData as Array<{ s: number | string; a: number; t: string }>,
  tawhid: tafsirTawhidData as Array<{ s: number | string; a: number; t: string }>,
  roshn: tafsirRoshnData as Array<{ s: number | string; a: number; t: string }>,
  runahi: tafsirRunahiData as Array<{ s: number | string; a: number; t: string }>,
  mokhtasar: tafsirMokhtasarData as Array<{ s: number | string; a: number; t: string }>,
  krd: tafsirKrdData as Array<{ s: number | string; a: number; t: string }>,
};

function getSurahAyahs(surahNumber: number) {
  return QURAN_DATA.ayahs.filter((ayah) => ayah.surah === surahNumber);
}

function getTafsirForAyah(tafsirId: string, surahNumber: number, ayahNumber: number) {
  return QURAN_TAFSIR_DATA[tafsirId]?.find(
    (entry) => Number(entry.s) === surahNumber && Number(entry.a) === ayahNumber
  )?.t;
}

// ─── Small helpers ────────────────────────────────────────────────────────────

const GOLD = "#C9A84C";
const CREAM = "#F0EBE0";
const DARK = "#071A12";
const PANEL = "rgba(255,255,255,0.05)";
const PANEL_BORDER = "rgba(255,255,255,0.07)";

function amiri(extra?: string) {
  return `font-family: Amiri, serif; ${extra || ""}`;
}

function CircularArc({
  current,
  total,
  size = 40,
}: {
  current: number;
  total: number;
  size?: number;
}) {
  const r = (size - 6) / 2;
  const circ = 2 * Math.PI * r;
  const offset = circ * (1 - (total > 0 ? current / total : 0));
  const c = size / 2;
  return (
    <svg width={size} height={size} style={{ transform: "rotate(-90deg)" }}>
      <circle cx={c} cy={c} r={r} stroke="rgba(255,255,255,0.08)" strokeWidth="2.5" fill="none" />
      <circle
        cx={c} cy={c} r={r}
        stroke={GOLD}
        strokeWidth="2.5"
        fill="none"
        strokeLinecap="round"
        strokeDasharray={circ}
        strokeDashoffset={offset}
        style={{ transition: "stroke-dashoffset 0.4s ease" }}
      />
    </svg>
  );
}

// ─── Onboarding ───────────────────────────────────────────────────────────────

function OnboardingScreen({ onComplete }: { onComplete: (name: string) => void }) {
  const [step, setStep] = useState(0);
  const [name, setName] = useState("");
  const [goal, setGoal] = useState(3);

  const steps = [
    {
      title: "مرحباً بك",
      subtitle: "Welcome to Azkar",
      body: "Your daily spiritual companion for dhikr, reflection, and inner peace.",
    },
    {
      title: "بسم الله",
      subtitle: "Set Your Intention",
      body: "Tell us your name and how many sessions you want each day.",
    },
    {
      title: "جاهز؟",
      subtitle: "You're Ready",
      body: "Begin your journey with the first step of remembrance.",
    },
  ];

  return (
    <div
      className="flex flex-col h-full relative"
      style={{ background: "linear-gradient(160deg, #0D3527 0%, #0A2318 60%, #050F0A 100%)", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      {/* Ambient star dots */}
      {[...Array(18)].map((_, i) => (
        <div
          key={i}
          className="absolute rounded-full"
          style={{
            width: i % 3 === 0 ? "2px" : "1.5px",
            height: i % 3 === 0 ? "2px" : "1.5px",
            left: `${(i * 17 + 5) % 95}%`,
            top: `${(i * 11 + 3) % 55}%`,
            background: GOLD,
            opacity: 0.2 + (i % 4) * 0.1,
          }}
        />
      ))}

      {/* Crescent */}
      <div className="flex justify-center pt-14 pb-2">
        <div className="relative w-24 h-24">
          <div className="w-24 h-24 rounded-full" style={{ background: `radial-gradient(circle at 38% 38%, ${GOLD}, #6B4E10)` }} />
          <div className="absolute top-1.5 right-1.5 w-20 h-20 rounded-full" style={{ background: "#0D3527" }} />
          <div className="absolute bottom-1 right-3 w-2 h-2 rounded-full" style={{ background: GOLD, opacity: 0.6 }} />
        </div>
      </div>

      {/* Step dots */}
      <div className="flex justify-center gap-2 mb-6">
        {steps.map((_, i) => (
          <div
            key={i}
            className="rounded-full transition-all duration-300"
            style={{
              width: i === step ? "22px" : "7px",
              height: "7px",
              background: i === step ? GOLD : "rgba(201,168,76,0.25)",
            }}
          />
        ))}
      </div>

      {/* Content */}
      <div className="flex-1 px-7 flex flex-col">
        <div className="text-center mb-7">
          <h1
            className="text-4xl font-bold mb-1"
            style={{ fontFamily: "Amiri, serif", color: GOLD }}
          >
            {steps[step].title}
          </h1>
          <p className="text-base font-semibold" style={{ color: CREAM }}>{steps[step].subtitle}</p>
          <p className="mt-2 text-sm leading-relaxed" style={{ color: "rgba(240,235,224,0.55)" }}>
            {steps[step].body}
          </p>
        </div>

        {step === 1 && (
          <div className="space-y-4">
            <div>
              <p className="text-xs font-semibold tracking-widest mb-2" style={{ color: "rgba(240,235,224,0.45)" }}>YOUR NAME</p>
              <input
                type="text"
                placeholder="e.g. Ahmad"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full px-4 py-3 rounded-2xl text-sm outline-none"
                style={{
                  background: "rgba(255,255,255,0.07)",
                  border: `1px solid rgba(201,168,76,0.3)`,
                  color: CREAM,
                  fontFamily: "Plus Jakarta Sans, sans-serif",
                }}
              />
            </div>
            <div>
              <p className="text-xs font-semibold tracking-widest mb-3" style={{ color: "rgba(240,235,224,0.45)" }}>
                DAILY GOAL — {goal} session{goal > 1 ? "s" : ""}
              </p>
              <div className="flex gap-2">
                {[1, 2, 3, 5, 7].map((n) => (
                  <button
                    key={n}
                    onClick={() => setGoal(n)}
                    className="flex-1 py-2 rounded-xl text-sm font-semibold transition-all"
                    style={{
                      background: goal === n ? GOLD : "rgba(255,255,255,0.07)",
                      color: goal === n ? DARK : "rgba(240,235,224,0.6)",
                      border: goal === n ? "none" : "1px solid rgba(201,168,76,0.15)",
                    }}
                  >
                    {n}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {step === 2 && (
          <div
            className="rounded-2xl p-5"
            style={{ background: "rgba(201,168,76,0.07)", border: "1px solid rgba(201,168,76,0.2)" }}
          >
            <p className="text-xs font-semibold tracking-widest mb-3" style={{ color: "rgba(240,235,224,0.4)" }}>
              FIRST DHIKR OF THE DAY
            </p>
            <p
              className="text-2xl text-right leading-loose"
              style={{ fontFamily: "Amiri, serif", color: GOLD, direction: "rtl", lineHeight: "2.3" }}
            >
              بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ
            </p>
            <p className="text-xs mt-2" style={{ color: "rgba(240,235,224,0.45)" }}>
              In the Name of Allah, the Most Gracious, the Most Merciful
            </p>
          </div>
        )}
      </div>

      {/* CTA */}
      <div className="px-7 pb-8 pt-4">
        <button
          onClick={() => {
            if (step < steps.length - 1) setStep(step + 1);
            else onComplete(name.trim() || "Beloved");
          }}
          className="w-full py-4 rounded-2xl font-bold text-base transition-all active:scale-95"
          style={{ background: `linear-gradient(135deg, ${GOLD}, #A8853A)`, color: DARK }}
        >
          {step === steps.length - 1 ? "Begin My Journey →" : "Continue"}
        </button>
      </div>
    </div>
  );
}

// ─── Focus Mode ───────────────────────────────────────────────────────────────

function FocusModeScreen({ onClose }: { onClose: () => void }) {
  const [count, setCount] = useState(0);
  const target = 33;
  const [flash, setFlash] = useState(false);
  const [toastMsg, setToastMsg] = useState<string | null>(null);

  const inRound = count % target;
  const progress = inRound / target;
  const size = 230;
  const r = (size - 14) / 2;
  const circ = 2 * Math.PI * r;
  const offset = circ * (1 - progress);

  const handleTap = () => {
    const next = count + 1;
    setCount(next);
    setFlash(true);
    setTimeout(() => setFlash(false), 200);
    if (next % target === 0) {
      const msg = next === 33 ? "سبحان الله ×33" : next === 66 ? "الحمد لله ×33" : next === 99 ? "الله أكبر ×33 — Masha Allah" : `${next} — Masha Allah`;
      setToastMsg(msg);
      setTimeout(() => setToastMsg(null), 2500);
    }
  };

  return (
    <div
      className="flex flex-col h-full items-center"
      style={{ background: "#040C07", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      {/* Header */}
      <div className="w-full flex items-center justify-between px-6 pt-8 pb-4">
        <button
          onClick={onClose}
          className="w-10 h-10 flex items-center justify-center rounded-full"
          style={{ background: "rgba(255,255,255,0.05)" }}
        >
          <X size={16} color="rgba(240,235,224,0.5)" />
        </button>
        <p className="text-xs font-semibold tracking-widest" style={{ color: "rgba(240,235,224,0.3)" }}>
          FOCUS MODE
        </p>
        <div className="w-10" />
      </div>

      {/* Milestone toast */}
      <div
        className="absolute top-20 px-5 py-2 rounded-full text-sm font-semibold z-10 transition-all duration-500"
        style={{
          background: "rgba(201,168,76,0.12)",
          border: "1px solid rgba(201,168,76,0.35)",
          color: GOLD,
          opacity: toastMsg ? 1 : 0,
          transform: toastMsg ? "translateY(0)" : "translateY(-10px)",
          pointerEvents: "none",
          fontFamily: "Amiri, serif",
        }}
      >
        {toastMsg || "✦"}
      </div>

      {/* Dhikr label */}
      <div className="flex-1 flex flex-col items-center justify-center">
        <p
          className="text-5xl mb-1 text-center"
          style={{ fontFamily: "Amiri, serif", color: GOLD, direction: "rtl" }}
        >
          سُبْحَانَ اللهِ
        </p>
        <p className="text-xs mb-10" style={{ color: "rgba(240,235,224,0.35)" }}>
          Glory is to Allah
        </p>

        {/* Tap ring */}
        <button
          onClick={handleTap}
          className="relative flex items-center justify-center cursor-pointer select-none"
          style={{ width: size, height: size }}
        >
          <div
            className="absolute inset-0 rounded-full transition-all duration-200"
            style={{
              background: `radial-gradient(circle, rgba(201,168,76,${flash ? 0.14 : 0.05}) 0%, transparent 70%)`,
              transform: flash ? "scale(1.06)" : "scale(1)",
            }}
          />
          <svg width={size} height={size} className="absolute" style={{ transform: "rotate(-90deg)" }}>
            <circle cx={size / 2} cy={size / 2} r={r} stroke="rgba(255,255,255,0.04)" strokeWidth="2" fill="none" />
            <circle
              cx={size / 2} cy={size / 2} r={r}
              stroke={GOLD} strokeWidth="2" fill="none" strokeLinecap="round"
              strokeDasharray={circ} strokeDashoffset={offset}
              style={{ transition: "stroke-dashoffset 0.25s ease" }}
            />
          </svg>
          <div className="flex flex-col items-center z-10">
            <span className="text-7xl font-light" style={{ color: CREAM, fontVariantNumeric: "tabular-nums", letterSpacing: "-2px" }}>
              {inRound === 0 && count > 0 ? target : inRound}
            </span>
            <span className="text-xs mt-1" style={{ color: "rgba(240,235,224,0.25)" }}>tap to count</span>
          </div>
        </button>
      </div>

      {/* Footer stats */}
      <div className="w-full px-6 pb-8">
        <div
          className="flex justify-around py-3 rounded-2xl"
          style={{ background: "rgba(255,255,255,0.04)" }}
        >
          {[
            { label: "Round", val: Math.floor(count / target) + 1 },
            { label: "Target", val: target, gold: true },
            { label: "Total", val: count },
          ].map((s, i) => (
            <div key={i} className="text-center">
              <p className="text-xs" style={{ color: "rgba(240,235,224,0.35)" }}>{s.label}</p>
              <p className="font-semibold" style={{ color: s.gold ? GOLD : CREAM }}>{s.val}</p>
            </div>
          ))}
          <button
            onClick={() => setCount(0)}
            className="px-3 rounded-xl text-xs font-medium"
            style={{ color: "rgba(240,235,224,0.35)", background: "rgba(255,255,255,0.04)" }}
          >
            Reset
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── 99 Names ─────────────────────────────────────────────────────────────────

function NamesOfAllahScreen({ onBack }: { onBack: () => void }) {
  const [selected, setSelected] = useState<typeof NAMES_OF_ALLAH[0] | null>(null);

  return (
    <div
      className="flex flex-col h-full"
      style={{ background: "linear-gradient(180deg, #0B2D1E 0%, #071A12 100%)", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      {/* Header */}
      <div className="flex items-center gap-3 px-5 pt-8 pb-3">
        <button
          onClick={onBack}
          className="w-9 h-9 flex items-center justify-center rounded-full flex-shrink-0"
          style={{ background: PANEL }}
        >
          <ArrowLeft size={16} color={CREAM} />
        </button>
        <div>
          <h2 className="font-bold" style={{ color: CREAM }}>Asmaul Husna</h2>
          <p className="text-xs" style={{ color: "rgba(240,235,224,0.45)" }}>The 99 Beautiful Names of Allah</p>
        </div>
      </div>

      {/* Arabic heading */}
      <p
        className="text-3xl px-5 mb-4 text-right"
        style={{ fontFamily: "Amiri, serif", color: GOLD, direction: "rtl" }}
      >
        أسماء الله الحسنى
      </p>

      {/* Grid */}
      <div className="flex-1 overflow-y-auto px-4 pb-2" style={{ scrollbarWidth: "none" }}>
        <div className="grid grid-cols-2 gap-2.5">
          {NAMES_OF_ALLAH.map((name) => {
            const isSelected = selected?.n === name.n;
            return (
              <button
                key={name.n}
                onClick={() => setSelected(isSelected ? null : name)}
                className="p-4 rounded-2xl text-left transition-all active:scale-95"
                style={{
                  background: isSelected ? "rgba(201,168,76,0.13)" : PANEL,
                  border: `1px solid ${isSelected ? "rgba(201,168,76,0.4)" : PANEL_BORDER}`,
                }}
              >
                <div className="flex justify-between items-center mb-2">
                  <span
                    className="text-xs font-semibold px-1.5 py-0.5 rounded"
                    style={{ background: "rgba(201,168,76,0.12)", color: GOLD }}
                  >
                    {name.n}
                  </span>
                </div>
                <p
                  className="text-xl text-right mb-1 leading-loose"
                  style={{ fontFamily: "Amiri, serif", color: GOLD, direction: "rtl" }}
                >
                  {name.ar}
                </p>
                <p className="text-xs font-semibold" style={{ color: CREAM }}>{name.tr}</p>
                <p className="text-xs" style={{ color: "rgba(240,235,224,0.45)" }}>{name.en}</p>
              </button>
            );
          })}
          <div
            className="col-span-2 py-4 rounded-2xl flex items-center justify-center"
            style={{ background: "rgba(255,255,255,0.02)", border: "1px dashed rgba(201,168,76,0.18)" }}
          >
            <p className="text-sm" style={{ color: "rgba(240,235,224,0.3)" }}>+ 75 more names</p>
          </div>
        </div>
      </div>

      {/* Selected detail */}
      {selected && (
        <div className="px-4 pb-4">
          <div
            className="p-4 rounded-2xl"
            style={{ background: "rgba(201,168,76,0.08)", border: "1px solid rgba(201,168,76,0.3)" }}
          >
            <div className="flex justify-between items-center mb-1">
              <span className="text-xs font-semibold tracking-widest" style={{ color: GOLD }}>NAME #{selected.n}</span>
              <button onClick={() => setSelected(null)}><X size={13} color="rgba(240,235,224,0.4)" /></button>
            </div>
            <p
              className="text-4xl text-center py-2"
              style={{ fontFamily: "Amiri, serif", color: GOLD, direction: "rtl" }}
            >
              {selected.ar}
            </p>
            <p className="text-center text-sm font-semibold mt-1" style={{ color: CREAM }}>{selected.tr}</p>
            <p className="text-center text-xs mt-0.5" style={{ color: "rgba(240,235,224,0.55)" }}>{selected.en}</p>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Home ─────────────────────────────────────────────────────────────────────

function HomeScreen({
  onNavigate,
  userName,
  onOpenFocus,
  onOpenNames,
}: {
  onNavigate: (s: MainScreen) => void;
  userName: string;
  onOpenFocus: () => void;
  onOpenNames: () => void;
}) {
  const [selectedMood, setSelectedMood] = useState<string | null>(null);
  const [ramadan, setRamadan] = useState(false);
  const hour = new Date().getHours();
  const [greeting, greetingEn] =
    hour < 12
      ? ["صباح الخير", "Good Morning"]
      : hour < 17
      ? ["طاب نهارك", "Good Afternoon"]
      : ["مساء الخير", "Good Evening"];

  return (
    <div
      className="flex flex-col h-full overflow-y-auto"
      style={{ background: "linear-gradient(160deg, #0D3527 0%, #0A2318 100%)", scrollbarWidth: "none", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      {/* Header */}
      <div className="px-5 pt-10 pb-5">
        <div className="flex justify-between items-start">
          <div>
            <p className="text-xs font-semibold tracking-widest mb-1" style={{ color: "rgba(240,235,224,0.4)" }}>
              {greetingEn.toUpperCase()}
            </p>
            <h1 className="text-2xl font-bold" style={{ color: CREAM }}>{userName}</h1>
            <p className="text-3xl mt-0.5" style={{ fontFamily: "Amiri, serif", color: GOLD, direction: "rtl" }}>
              {greeting}
            </p>
          </div>
          <div
            className="flex flex-col items-center px-3 py-2.5 rounded-2xl"
            style={{ background: "rgba(249,115,22,0.1)", border: "1px solid rgba(249,115,22,0.2)" }}
          >
            <Flame size={18} color="#F97316" />
            <span className="text-xl font-bold mt-0.5" style={{ color: CREAM }}>14</span>
            <span className="text-xs font-medium" style={{ color: "rgba(240,235,224,0.45)" }}>streak</span>
          </div>
        </div>
      </div>

      {/* Mood bar */}
      <div className="px-5 mb-5">
        <p className="text-xs font-semibold tracking-widest mb-3" style={{ color: "rgba(240,235,224,0.4)" }}>
          HOW DO YOU FEEL TODAY?
        </p>
        <div className="flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth: "none" }}>
          {MOODS.map((mood) => (
            <button
              key={mood.id}
              onClick={() => setSelectedMood(mood.id === selectedMood ? null : mood.id)}
              className="flex flex-col items-center px-3 py-2 rounded-2xl flex-shrink-0 transition-all active:scale-95"
              style={{
                background: selectedMood === mood.id ? "rgba(201,168,76,0.18)" : PANEL,
                border: `1px solid ${selectedMood === mood.id ? "rgba(201,168,76,0.5)" : "transparent"}`,
              }}
            >
              <span className="text-lg">{mood.emoji}</span>
              <span
                className="text-xs mt-0.5"
                style={{ fontFamily: "Amiri, serif", color: selectedMood === mood.id ? GOLD : "rgba(240,235,224,0.55)" }}
              >
                {mood.label}
              </span>
            </button>
          ))}
        </div>
        {selectedMood && (
          <p className="text-xs mt-2" style={{ color: "rgba(240,235,224,0.45)" }}>
            ✦ Showing azkar for your{" "}
            <span style={{ color: GOLD }}>{MOODS.find((m) => m.id === selectedMood)?.english}</span> mood
          </p>
        )}
      </div>

      {/* Daily path */}
      <div className="px-5 mb-5">
        <div className="flex justify-between items-center mb-3">
          <p className="text-xs font-semibold tracking-widest" style={{ color: "rgba(240,235,224,0.4)" }}>
            TODAY&apos;S PATH
          </p>
          <span className="text-xs font-semibold" style={{ color: GOLD }}>2 of 3</span>
        </div>
        <div className="space-y-2">
          {[
            { label: "Morning Azkar", arabic: "أذكار الصباح", done: true, target: "categories" as MainScreen },
            { label: "Tasbeeh (33×)", arabic: "تسبيح", done: true, target: "tasbeeh" as MainScreen },
            { label: "Evening Azkar", arabic: "أذكار المساء", done: false, target: "categories" as MainScreen },
          ].map((item, i) => (
            <button
              key={i}
              onClick={() => onNavigate(item.target)}
              className="w-full flex items-center gap-3 px-4 py-3 rounded-2xl transition-all active:scale-95"
              style={{
                background: item.done ? "rgba(201,168,76,0.07)" : PANEL,
                border: `1px solid ${item.done ? "rgba(201,168,76,0.18)" : PANEL_BORDER}`,
              }}
            >
              <div
                className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0"
                style={{ background: item.done ? "rgba(201,168,76,0.18)" : "rgba(255,255,255,0.07)" }}
              >
                {item.done && <CheckCircle size={13} color={GOLD} />}
              </div>
              <div className="flex-1 text-left">
                <p
                  className="text-sm font-medium"
                  style={{ color: item.done ? "rgba(240,235,224,0.4)" : CREAM, textDecoration: item.done ? "line-through" : "none" }}
                >
                  {item.label}
                </p>
              </div>
              <p
                className="text-sm flex-shrink-0"
                style={{ fontFamily: "Amiri, serif", color: item.done ? "rgba(201,168,76,0.5)" : GOLD, direction: "rtl" }}
              >
                {item.arabic}
              </p>
            </button>
          ))}
        </div>
      </div>

      {/* Quick access grid */}
      <div className="px-5 mb-5">
        <p className="text-xs font-semibold tracking-widest mb-3" style={{ color: "rgba(240,235,224,0.4)" }}>
          QUICK ACCESS
        </p>
        <div className="grid grid-cols-2 gap-3">
          {[
            {
              label: "Focus Mode",
              sub: "Distraction-free",
              emoji: "🧘",
              accent: "#14B8A6",
              action: onOpenFocus,
            },
            {
              label: "99 Names",
              sub: "Asmaul Husna",
              emoji: "✦",
              accent: GOLD,
              action: onOpenNames,
            },
            {
              label: "Azkar",
              sub: "All categories",
              emoji: "📿",
              accent: "#7C3AED",
              action: () => onNavigate("categories"),
            },
            {
              label: "Streaks",
              sub: "Your progress",
              emoji: "🔥",
              accent: "#F97316",
              action: () => onNavigate("statistics"),
            },
          ].map((card, i) => (
            <button
              key={i}
              onClick={card.action}
              className="p-4 rounded-2xl text-left transition-all active:scale-95"
              style={{
                background: `linear-gradient(135deg, ${card.accent}18, ${card.accent}07)`,
                border: `1px solid ${card.accent}30`,
              }}
            >
              <div
                className="w-9 h-9 rounded-xl flex items-center justify-center mb-3 text-lg"
                style={{ background: `${card.accent}20` }}
              >
                {card.emoji}
              </div>
              <p className="font-bold text-sm" style={{ color: CREAM }}>{card.label}</p>
              <p className="text-xs mt-0.5" style={{ color: "rgba(240,235,224,0.45)" }}>{card.sub}</p>
            </button>
          ))}
        </div>
      </div>

      {/* Ramadan toggle */}
      <div className="px-5 mb-8">
        <button
          onClick={() => setRamadan(!ramadan)}
          className="w-full flex items-center gap-3 px-4 py-4 rounded-2xl transition-all"
          style={{
            background: ramadan ? "rgba(201,168,76,0.12)" : "rgba(255,255,255,0.04)",
            border: `1px solid ${ramadan ? "rgba(201,168,76,0.3)" : "rgba(255,255,255,0.06)"}`,
          }}
        >
          <span className="text-2xl">🌙</span>
          <div className="flex-1 text-left">
            <p className="text-sm font-semibold" style={{ color: ramadan ? GOLD : CREAM }}>Ramadan Mode</p>
            <p className="text-xs" style={{ color: "rgba(240,235,224,0.45)" }}>
              {ramadan ? "Special Ramadan azkar enabled" : "Enable for Ramadan azkar & times"}
            </p>
          </div>
          <div
            className="w-12 h-6 rounded-full relative flex-shrink-0 transition-all"
            style={{ background: ramadan ? GOLD : "rgba(255,255,255,0.1)" }}
          >
            <div
              className="absolute top-0.5 w-5 h-5 rounded-full transition-all"
              style={{ background: ramadan ? DARK : "rgba(240,235,224,0.4)", left: ramadan ? "26px" : "2px" }}
            />
          </div>
        </button>
      </div>
    </div>
  );
}

// ─── Categories ───────────────────────────────────────────────────────────────

function CategoriesScreen({ onSelect, onBack }: { onSelect: (cat: string) => void; onBack: () => void }) {
  const [activeEmotion, setActiveEmotion] = useState<string | null>(null);

  return (
    <div
      className="flex flex-col h-full"
      style={{ background: "linear-gradient(180deg, #0B2D1E 0%, #071A12 100%)", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      <div className="flex items-center gap-3 px-5 pt-8 pb-4">
        <button
          onClick={onBack}
          className="w-9 h-9 flex items-center justify-center rounded-full flex-shrink-0"
          style={{ background: PANEL }}
        >
          <ArrowLeft size={16} color={CREAM} />
        </button>
        <h2 className="font-bold text-lg" style={{ color: CREAM }}>Azkar Categories</h2>
      </div>

      {/* Emotion chips */}
      <div className="px-5 mb-4">
        <p className="text-xs font-semibold tracking-widest mb-2" style={{ color: "rgba(240,235,224,0.4)" }}>
          FILTER BY FEELING
        </p>
        <div className="flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth: "none" }}>
          {MOODS.map((mood) => (
            <button
              key={mood.id}
              onClick={() => setActiveEmotion(mood.id === activeEmotion ? null : mood.id)}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-full flex-shrink-0 text-xs font-semibold transition-all"
              style={{
                background: activeEmotion === mood.id ? "rgba(201,168,76,0.18)" : PANEL,
                border: `1px solid ${activeEmotion === mood.id ? "rgba(201,168,76,0.45)" : "transparent"}`,
                color: activeEmotion === mood.id ? GOLD : "rgba(240,235,224,0.55)",
              }}
            >
              {mood.emoji} {mood.english}
            </button>
          ))}
        </div>
      </div>

      {/* List */}
      <div className="flex-1 overflow-y-auto px-5 pb-4 space-y-2.5" style={{ scrollbarWidth: "none" }}>
        {AZKAR_CATEGORIES.map((cat) => (
          <button
            key={cat.id}
            onClick={() => onSelect(cat.id)}
            className="w-full flex items-center gap-4 p-4 rounded-2xl transition-all active:scale-95"
            style={{ background: PANEL, border: `1px solid ${PANEL_BORDER}` }}
          >
            <div
              className="w-12 h-12 rounded-2xl flex items-center justify-center flex-shrink-0 text-2xl"
              style={{ background: `${cat.color}18` }}
            >
              {cat.icon}
            </div>
            <div className="flex-1 text-left">
              <p className="font-semibold text-sm" style={{ color: CREAM }}>{cat.english}</p>
              <p
                className="text-base mt-0.5"
                style={{ fontFamily: "Amiri, serif", color: cat.color, direction: "rtl" }}
              >
                {cat.label}
              </p>
            </div>
            <span
              className="text-xs font-bold px-2.5 py-1 rounded-full flex-shrink-0"
              style={{ background: `${cat.color}18`, color: cat.color }}
            >
              {cat.count}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}

// ─── Quran ───────────────────────────────────────────────────────────────────

function QuranScreen({ onBack }: { onBack: () => void }) {
  const [selectedSurah, setSelectedSurah] = useState(1);
  const [selectedTafsirId, setSelectedTafsirId] = useState("rebar");
  const [ayahIndex, setAyahIndex] = useState(0);

  const surah = QURAN_SURAHS.find((item) => item.number === selectedSurah) ?? QURAN_SURAHS[0];
  const ayahs = getSurahAyahs(selectedSurah);
  const currentAyah = ayahs[ayahIndex] ?? ayahs[0];
  const selectedTafsir = QURAN_TAFSIR_OPTIONS.find((option) => option.id === selectedTafsirId) ?? QURAN_TAFSIR_OPTIONS[0];
  const tafsirText = currentAyah
    ? getTafsirForAyah(selectedTafsirId, selectedSurah, currentAyah.ayah) ??
      "This tafsir is not available for the selected ayah yet."
    : "No ayah available.";

  const handleSelectSurah = (surahNumber: number) => {
    setSelectedSurah(surahNumber);
    setAyahIndex(0);
  };

  return (
    <div
      className="flex flex-col h-full"
      style={{ background: "linear-gradient(180deg, #0B2D1E 0%, #071A12 100%)", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      <div className="flex items-center gap-3 px-5 pt-8 pb-4">
        <button
          onClick={onBack}
          className="w-9 h-9 flex items-center justify-center rounded-full flex-shrink-0"
          style={{ background: PANEL }}
        >
          <ArrowLeft size={16} color={CREAM} />
        </button>
        <div className="flex-1">
          <h2 className="font-bold text-lg" style={{ color: CREAM }}>Quran</h2>
          <p className="text-xs" style={{ color: "rgba(240,235,224,0.45)" }}>
            {surah?.englishName ?? "Al-Fatihah"}
          </p>
        </div>
      </div>

      <div className="px-5 mb-4">
        <div className="grid grid-cols-2 gap-2 rounded-2xl p-2" style={{ background: "rgba(255,255,255,0.03)" }}>
          <div className="rounded-xl p-3 text-center" style={{ background: "rgba(201,168,76,0.08)" }}>
            <div className="text-xl font-bold" style={{ color: GOLD }}>{QURAN_SURAHS.length}</div>
            <div className="text-[10px] uppercase tracking-[0.2em]" style={{ color: "rgba(240,235,224,0.45)" }}>Surahs</div>
          </div>
          <div className="rounded-xl p-3 text-center" style={{ background: "rgba(201,168,76,0.08)" }}>
            <div className="text-xl font-bold" style={{ color: GOLD }}>6236</div>
            <div className="text-[10px] uppercase tracking-[0.2em]" style={{ color: "rgba(240,235,224,0.45)" }}>Ayahs</div>
          </div>
        </div>
      </div>

      <div className="px-5 mb-4">
        <p className="text-[10px] font-semibold tracking-[0.25em] mb-2" style={{ color: "rgba(240,235,224,0.4)" }}>
          KURDISH TAFSIR
        </p>
        <div className="flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth: "none" }}>
          {QURAN_TAFSIR_OPTIONS.map((option) => {
            const isActive = option.id === selectedTafsirId;
            return (
              <button
                key={option.id}
                onClick={() => setSelectedTafsirId(option.id)}
                className="px-3 py-2 rounded-full text-[11px] font-semibold flex-shrink-0 transition-all"
                style={{
                  background: isActive ? "rgba(201,168,76,0.18)" : PANEL,
                  border: `1px solid ${isActive ? "rgba(201,168,76,0.45)" : "transparent"}`,
                  color: isActive ? GOLD : "rgba(240,235,224,0.55)",
                }}
              >
                {option.name}
              </button>
            );
          })}
        </div>
      </div>

      <div className="px-5 mb-4">
        <p className="text-[10px] font-semibold tracking-[0.25em] mb-2" style={{ color: "rgba(240,235,224,0.4)" }}>
          SURAHS
        </p>
        <div className="flex gap-2 overflow-x-auto pb-2" style={{ scrollbarWidth: "none" }}>
          {QURAN_SURAHS.map((item) => {
            const active = item.number === selectedSurah;
            return (
              <button
                key={item.number}
                onClick={() => handleSelectSurah(item.number)}
                className="px-3 py-2 rounded-xl text-left flex-shrink-0 min-w-[130px]"
                style={{
                  background: active ? "rgba(201,168,76,0.16)" : "rgba(255,255,255,0.04)",
                  border: `1px solid ${active ? "rgba(201,168,76,0.45)" : "rgba(255,255,255,0.05)"}`,
                }}
              >
                <div className="text-[10px]" style={{ color: "rgba(240,235,224,0.5)" }}>{item.number}</div>
                <div className="font-bold text-sm" style={{ color: CREAM }}>{item.englishName}</div>
                <div className="text-[11px]" style={{ fontFamily: "Amiri, serif", color: GOLD, direction: "rtl" }}>{item.name}</div>
              </button>
            );
          })}
        </div>
      </div>

      <div className="flex-1 px-5 pb-5 overflow-y-auto">
        <div className="rounded-3xl p-4 mb-4" style={{ background: "rgba(255,255,255,0.04)", border: `1px solid ${PANEL_BORDER}` }}>
          <div className="flex items-center justify-between mb-3">
            <div>
              <div className="text-[10px] uppercase tracking-[0.2em]" style={{ color: "rgba(240,235,224,0.45)" }}>
                Surah {surah.number}
              </div>
              <div className="text-lg font-bold" style={{ color: CREAM }}>{surah.englishName}</div>
            </div>
            <div className="text-xs px-2 py-1 rounded-full" style={{ background: "rgba(201,168,76,0.12)", color: GOLD }}>
              {ayahs.length} verses
            </div>
          </div>
          <div className="text-right mb-2" style={{ fontFamily: "Amiri, serif", color: GOLD, fontSize: "26px", direction: "rtl", lineHeight: 2 }}>
            {currentAyah?.text ?? ""}
          </div>
          <div className="text-xs" style={{ color: "rgba(240,235,224,0.5)" }}>
            Ayah {currentAyah?.ayah ?? 1} • Juz {currentAyah?.juz ?? 1}
          </div>
        </div>

        <div className="rounded-3xl p-4 mb-4" style={{ background: "rgba(201,168,76,0.05)", border: `1px solid rgba(201,168,76,0.18)` }}>
          <div className="mb-2 text-[10px] uppercase tracking-[0.25em]" style={{ color: GOLD }}>
            {selectedTafsir.name}
          </div>
          <p className="text-sm leading-relaxed" style={{ color: CREAM, lineHeight: 1.8 }}>
            {tafsirText}
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => setAyahIndex((value) => Math.max(0, value - 1))}
            disabled={ayahIndex === 0}
            className="flex-1 py-3 rounded-xl font-medium"
            style={{
              background: ayahIndex === 0 ? "rgba(255,255,255,0.04)" : "rgba(255,255,255,0.08)",
              color: ayahIndex === 0 ? "rgba(240,235,224,0.25)" : CREAM,
            }}
          >
            Previous Ayah
          </button>
          <button
            onClick={() => setAyahIndex((value) => Math.min(ayahs.length - 1, value + 1))}
            disabled={ayahIndex >= ayahs.length - 1}
            className="flex-1 py-3 rounded-xl font-medium"
            style={{
              background: ayahIndex >= ayahs.length - 1 ? "rgba(255,255,255,0.04)" : "rgba(201,168,76,0.12)",
              color: ayahIndex >= ayahs.length - 1 ? "rgba(240,235,224,0.25)" : GOLD,
            }}
          >
            Next Ayah
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Reading ──────────────────────────────────────────────────────────────────

function ReadingScreen({ category, onBack }: { category: string | null; onBack: () => void }) {
  if (category === "quran") {
    return <QuranScreen onBack={onBack} />;
  }

  const [currentIndex, setCurrentIndex] = useState(0);
  const [repeatCount, setRepeatCount] = useState(0);
  const [completed, setCompleted] = useState(false);
  const azkar = MORNING_AZKAR;
  const current = azkar[currentIndex];
  const done = repeatCount >= current.repeat;

  const handleAction = () => {
    if (!done) {
      const next = repeatCount + 1;
      setRepeatCount(next);
      if (next >= current.repeat && currentIndex === azkar.length - 1) {
        setCompleted(true);
      }
    } else if (currentIndex < azkar.length - 1) {
      setCurrentIndex(currentIndex + 1);
      setRepeatCount(0);
    } else {
      setCompleted(true);
    }
  };

  if (completed) {
    return (
      <div
        className="flex flex-col h-full items-center justify-center px-8"
        style={{ background: "linear-gradient(160deg, #0D3527 0%, #071A12 100%)", fontFamily: "Plus Jakarta Sans, sans-serif" }}
      >
        <div
          className="w-20 h-20 rounded-full flex items-center justify-center mb-6"
          style={{ background: "rgba(201,168,76,0.12)", border: `2px solid rgba(201,168,76,0.4)` }}
        >
          <span className="text-3xl">✦</span>
        </div>
        <p className="text-4xl font-bold text-center mb-1" style={{ fontFamily: "Amiri, serif", color: GOLD }}>
          أحسنت!
        </p>
        <p className="text-xl font-bold mb-2" style={{ color: CREAM }}>Masha Allah!</p>
        <p className="text-sm text-center leading-relaxed mb-8" style={{ color: "rgba(240,235,224,0.5)" }}>
          You have completed the Morning Azkar. May Allah accept it from you.
        </p>
        <button
          onClick={onBack}
          className="px-8 py-3 rounded-2xl font-bold transition-all active:scale-95"
          style={{ background: `linear-gradient(135deg, ${GOLD}, #A8853A)`, color: DARK }}
        >
          Back to Categories
        </button>
      </div>
    );
  }

  return (
    <div
      className="flex flex-col h-full"
      style={{ background: "linear-gradient(180deg, #0B2D1E 0%, #071A12 100%)", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      {/* Header */}
      <div className="flex items-center gap-3 px-5 pt-8 pb-3">
        <button
          onClick={onBack}
          className="w-9 h-9 flex items-center justify-center rounded-full flex-shrink-0"
          style={{ background: PANEL }}
        >
          <ArrowLeft size={16} color={CREAM} />
        </button>
        <div className="flex-1">
          <h2 className="font-bold" style={{ color: CREAM }}>Morning Azkar</h2>
          <p className="text-xs" style={{ color: "rgba(240,235,224,0.45)" }}>
            {currentIndex + 1} of {azkar.length}
          </p>
        </div>
        <div className="relative">
          <CircularArc current={currentIndex + (done ? 1 : 0)} total={azkar.length} size={44} />
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-xs font-bold" style={{ color: GOLD }}>{currentIndex + 1}</span>
          </div>
        </div>
      </div>

      {/* Progress dots */}
      <div className="flex gap-1.5 justify-center mb-5 px-5">
        {azkar.map((_, i) => (
          <div
            key={i}
            className="rounded-full transition-all duration-300"
            style={{
              width: i === currentIndex ? "20px" : "6px",
              height: "6px",
              background: i < currentIndex ? GOLD : i === currentIndex ? GOLD : "rgba(255,255,255,0.12)",
            }}
          />
        ))}
      </div>

      {/* Arabic card */}
      <div className="flex-1 flex flex-col px-5">
        <div
          className="p-6 rounded-3xl mb-4"
          style={{ background: "rgba(255,255,255,0.04)", border: `1px solid ${PANEL_BORDER}` }}
        >
          <p
            className="text-2xl text-right leading-loose"
            style={{ fontFamily: "Amiri, serif", color: GOLD, direction: "rtl", lineHeight: "2.3" }}
          >
            {current.arabic}
          </p>
        </div>

        {/* Translation */}
        <p className="text-sm leading-relaxed px-1 mb-1" style={{ color: "rgba(240,235,224,0.65)" }}>
          {current.translation}
        </p>
        <p className="text-xs px-1 mb-4" style={{ color: "rgba(240,235,224,0.3)" }}>
          Source: {current.source}
        </p>

        <div className="flex-1" />

        {/* Repeat tracker */}
        <div className="flex items-center gap-2 mb-4">
          <div className="flex gap-1.5 flex-wrap">
            {[...Array(Math.min(current.repeat, 10))].map((_, i) => (
              <div
                key={i}
                className="rounded-full transition-all"
                style={{
                  width: "8px",
                  height: "8px",
                  background: i < repeatCount ? GOLD : "rgba(255,255,255,0.1)",
                }}
              />
            ))}
          </div>
          {current.repeat > 10 && (
            <span className="text-xs" style={{ color: "rgba(240,235,224,0.4)" }}>×{current.repeat}</span>
          )}
          <span className="text-xs ml-auto" style={{ color: "rgba(240,235,224,0.35)" }}>
            {repeatCount}/{current.repeat}
          </span>
        </div>
      </div>

      {/* Action */}
      <div className="px-5 pb-6">
        <button
          onClick={handleAction}
          className="w-full py-4 rounded-2xl font-bold text-base transition-all active:scale-95"
          style={{
            background: done ? `linear-gradient(135deg, ${GOLD}, #A8853A)` : "rgba(201,168,76,0.1)",
            color: done ? DARK : GOLD,
            border: done ? "none" : "1px solid rgba(201,168,76,0.3)",
          }}
        >
          {done
            ? currentIndex < azkar.length - 1
              ? "Next Dhikr →"
              : "Complete ✓"
            : `Recite (${repeatCount}/${current.repeat})`}
        </button>
      </div>
    </div>
  );
}

// ─── Tasbeeh ──────────────────────────────────────────────────────────────────

function TasbeehScreen() {
  const [count, setCount] = useState(0);
  const [activeDhikr, setActiveDhikr] = useState(0);
  const target = 33;
  const inRound = count % target;
  const rounds = Math.floor(count / target);

  const dhikrList = ["سُبْحَانَ اللهِ", "الْحَمْدُ لِلَّهِ", "اللهُ أَكْبَرُ", "لَا إِلَهَ إِلَّا اللهُ"];

  return (
    <div
      className="flex flex-col h-full items-center"
      style={{ background: "linear-gradient(160deg, #0D3527 0%, #071A12 100%)", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      <div className="w-full px-5 pt-8 pb-4">
        <h2 className="text-xl font-bold" style={{ color: CREAM }}>Tasbeeh</h2>
        <p className="text-xs" style={{ color: "rgba(240,235,224,0.45)" }}>Digital prayer beads</p>
      </div>

      {/* Dhikr chips */}
      <div className="w-full px-5 mb-5">
        <div className="flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth: "none" }}>
          {dhikrList.map((d, i) => (
            <button
              key={i}
              onClick={() => { setActiveDhikr(i); setCount(0); }}
              className="px-3.5 py-2 rounded-full flex-shrink-0 text-sm transition-all"
              style={{
                fontFamily: "Amiri, serif",
                background: activeDhikr === i ? "rgba(201,168,76,0.2)" : PANEL,
                color: activeDhikr === i ? GOLD : "rgba(240,235,224,0.55)",
                border: `1px solid ${activeDhikr === i ? "rgba(201,168,76,0.45)" : "transparent"}`,
                direction: "rtl",
              }}
            >
              {d}
            </button>
          ))}
        </div>
      </div>

      {/* Big button */}
      <div className="flex-1 flex flex-col items-center justify-center">
        <button
          onClick={() => setCount((c) => c + 1)}
          className="relative w-52 h-52 rounded-full flex items-center justify-center transition-all active:scale-95"
          style={{
            background: "radial-gradient(circle at 38% 38%, #1A4535, #0A2318)",
            boxShadow: `0 0 70px rgba(201,168,76,0.08), inset 0 1px 0 rgba(255,255,255,0.04)`,
            border: "2px solid rgba(201,168,76,0.12)",
          }}
        >
          <div className="text-center">
            <p className="text-7xl font-light" style={{ color: GOLD, fontVariantNumeric: "tabular-nums", letterSpacing: "-2px" }}>
              {inRound}
            </p>
            <p className="text-xs mt-1" style={{ color: "rgba(240,235,224,0.25)" }}>tap to count</p>
          </div>
        </button>

        {/* Rhythm milestone dots */}
        <div className="flex gap-2 mt-7">
          {[...Array(11)].map((_, i) => (
            <div
              key={i}
              className="rounded-full transition-all duration-200"
              style={{
                width: "8px",
                height: "8px",
                background: i * 3 < inRound ? GOLD : "rgba(255,255,255,0.1)",
                transform: i * 3 === inRound - 1 ? "scale(1.4)" : "scale(1)",
              }}
            />
          ))}
        </div>
        <p className="text-xs mt-2" style={{ color: "rgba(240,235,224,0.25)" }}>milestone every 11</p>
      </div>

      {/* Stats */}
      <div className="w-full px-5 pb-6">
        <div className="flex gap-2.5">
          {[
            { label: "Rounds", val: rounds, gold: false },
            { label: "Target", val: target, gold: true },
            { label: "Total", val: count, gold: false },
          ].map((s, i) => (
            <div
              key={i}
              className="flex-1 py-3 rounded-2xl text-center"
              style={{ background: PANEL }}
            >
              <p className="text-xl font-bold" style={{ color: s.gold ? GOLD : CREAM }}>{s.val}</p>
              <p className="text-xs" style={{ color: "rgba(240,235,224,0.35)" }}>{s.label}</p>
            </div>
          ))}
          <button
            onClick={() => setCount(0)}
            className="flex-1 py-3 rounded-2xl text-center"
            style={{ background: PANEL }}
          >
            <p className="text-xs font-semibold" style={{ color: "rgba(240,235,224,0.4)" }}>Reset</p>
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Statistics ───────────────────────────────────────────────────────────────

function StatisticsScreen() {
  const levelColors = ["#0D3527", "rgba(201,168,76,0.18)", "rgba(201,168,76,0.38)", "rgba(201,168,76,0.65)", GOLD];

  return (
    <div
      className="flex flex-col h-full overflow-y-auto"
      style={{ background: "linear-gradient(180deg, #0B2D1E 0%, #071A12 100%)", scrollbarWidth: "none", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      <div className="px-5 pt-8 pb-5">
        <h2 className="text-xl font-bold" style={{ color: CREAM }}>Statistics</h2>
        <p className="text-xs" style={{ color: "rgba(240,235,224,0.45)" }}>Your spiritual journey</p>
      </div>

      {/* Stat cards */}
      <div className="flex gap-2.5 px-5 mb-5">
        {[
          { label: "Current Streak", val: "14", unit: "days", emoji: "🔥" },
          { label: "Best Streak", val: "31", unit: "days", emoji: "✦" },
          { label: "Sessions", val: "204", unit: "total", emoji: "📿" },
        ].map((s, i) => (
          <div
            key={i}
            className="flex-1 p-3.5 rounded-2xl text-center"
            style={{ background: PANEL, border: `1px solid ${PANEL_BORDER}` }}
          >
            <span className="text-xl">{s.emoji}</span>
            <p className="text-2xl font-bold mt-1" style={{ color: GOLD }}>{s.val}</p>
            <p className="text-xs font-medium" style={{ color: "rgba(240,235,224,0.4)" }}>{s.unit}</p>
          </div>
        ))}
      </div>

      {/* Heatmap */}
      <div className="px-5 mb-5">
        <p className="text-xs font-semibold tracking-widest mb-3" style={{ color: "rgba(240,235,224,0.4)" }}>
          CONSISTENCY MAP — 12 WEEKS
        </p>
        <div
          className="p-4 rounded-2xl"
          style={{ background: "rgba(255,255,255,0.03)", border: `1px solid ${PANEL_BORDER}` }}
        >
          <div className="grid gap-1.5" style={{ gridTemplateColumns: "repeat(12, 1fr)" }}>
            {HEATMAP_DATA.map((level, i) => (
              <div
                key={i}
                className="rounded-sm aspect-square"
                style={{ background: levelColors[level] }}
              />
            ))}
          </div>
          <div className="flex justify-between items-center mt-3">
            <span className="text-xs" style={{ color: "rgba(240,235,224,0.25)" }}>12w ago</span>
            <div className="flex items-center gap-1">
              <span className="text-xs" style={{ color: "rgba(240,235,224,0.25)" }}>Less</span>
              {levelColors.map((c, i) => (
                <div key={i} className="w-2.5 h-2.5 rounded-sm" style={{ background: c }} />
              ))}
              <span className="text-xs" style={{ color: "rgba(240,235,224,0.25)" }}>More</span>
            </div>
            <span className="text-xs" style={{ color: "rgba(240,235,224,0.25)" }}>Today</span>
          </div>
        </div>
      </div>

      {/* Milestone badges */}
      <div className="px-5 mb-6">
        <p className="text-xs font-semibold tracking-widest mb-3" style={{ color: "rgba(240,235,224,0.4)" }}>
          MILESTONES
        </p>
        <div className="flex gap-3 overflow-x-auto pb-1" style={{ scrollbarWidth: "none" }}>
          {[
            { label: "7 Days", icon: "🌱", sub: "First week", earned: true },
            { label: "14 Days", icon: "🌿", sub: "Two weeks", earned: true },
            { label: "30 Days", icon: "🌳", sub: "One month", earned: false },
            { label: "100 Days", icon: "⭐", sub: "Century", earned: false },
          ].map((b, i) => (
            <div
              key={i}
              className="flex flex-col items-center px-4 py-4 rounded-2xl flex-shrink-0"
              style={{
                background: b.earned ? "rgba(201,168,76,0.1)" : "rgba(255,255,255,0.03)",
                border: `1px solid ${b.earned ? "rgba(201,168,76,0.3)" : PANEL_BORDER}`,
                opacity: b.earned ? 1 : 0.5,
                minWidth: "80px",
              }}
            >
              <span className="text-2xl mb-2">{b.icon}</span>
              <p className="text-xs font-bold" style={{ color: b.earned ? GOLD : "rgba(240,235,224,0.4)" }}>
                {b.label}
              </p>
              <p className="text-xs mt-0.5" style={{ color: "rgba(240,235,224,0.3)" }}>{b.sub}</p>
              {b.earned && (
                <span
                  className="text-xs font-semibold mt-1.5 px-2 py-0.5 rounded-full"
                  style={{ background: "rgba(201,168,76,0.15)", color: GOLD }}
                >
                  Earned
                </span>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Weekly breakdown */}
      <div className="px-5 mb-6">
        <p className="text-xs font-semibold tracking-widest mb-3" style={{ color: "rgba(240,235,224,0.4)" }}>
          THIS WEEK
        </p>
        <div
          className="p-4 rounded-2xl"
          style={{ background: PANEL, border: `1px solid ${PANEL_BORDER}` }}
        >
          <div className="flex justify-between items-end h-20">
            {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day, i) => {
              const heights = [60, 85, 40, 100, 75, 90, 55];
              const isToday = i === 3;
              return (
                <div key={day} className="flex flex-col items-center gap-1.5 flex-1">
                  <div
                    className="w-5 rounded-sm transition-all"
                    style={{
                      height: `${heights[i]}%`,
                      background: isToday ? GOLD : "rgba(201,168,76,0.25)",
                      borderRadius: "3px 3px 0 0",
                    }}
                  />
                  <p className="text-xs" style={{ color: isToday ? GOLD : "rgba(240,235,224,0.3)", fontSize: "10px" }}>
                    {day}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── Settings ─────────────────────────────────────────────────────────────────

function SettingsScreen({ onOpenStatistics }: { onOpenStatistics: () => void }) {
  const [notifications, setNotifications] = useState(true);
  const [showArabic, setShowArabic] = useState(true);
  const [darkMode] = useState(true);
  const [vibration, setVibration] = useState(true);

  const Toggle = ({ val, onChange }: { val: boolean; onChange: () => void }) => (
    <button
      onClick={onChange}
      className="w-12 h-6 rounded-full relative flex-shrink-0 transition-all duration-200"
      style={{ background: val ? GOLD : "rgba(255,255,255,0.1)" }}
    >
      <div
        className="absolute top-0.5 w-5 h-5 rounded-full transition-all duration-200"
        style={{ background: val ? DARK : "rgba(240,235,224,0.45)", left: val ? "26px" : "2px" }}
      />
    </button>
  );

  return (
    <div
      className="flex flex-col h-full overflow-y-auto"
      style={{ background: "linear-gradient(180deg, #0B2D1E 0%, #071A12 100%)", scrollbarWidth: "none", fontFamily: "Plus Jakarta Sans, sans-serif" }}
    >
      <div className="px-5 pt-8 pb-5">
        <h2 className="text-xl font-bold" style={{ color: CREAM }}>Settings</h2>
      </div>

      {/* Profile card */}
      <div className="px-5 mb-5">
        <div
          className="flex items-center gap-4 p-4 rounded-2xl"
          style={{ background: "rgba(201,168,76,0.07)", border: "1px solid rgba(201,168,76,0.18)" }}
        >
          <div
            className="w-12 h-12 rounded-2xl flex items-center justify-center text-2xl flex-shrink-0"
            style={{ background: "rgba(201,168,76,0.15)" }}
          >
            🌿
          </div>
          <div>
            <p className="font-bold" style={{ color: CREAM }}>Ahmad</p>
            <p className="text-xs" style={{ color: "rgba(240,235,224,0.45)" }}>14-day streak · 204 sessions</p>
          </div>
        </div>
      </div>

      {/* Toggles */}
      <div className="px-5 space-y-2.5 mb-5">
        {[
          { label: "Daily Reminders", sub: "Morning & evening notifications", val: notifications, fn: () => setNotifications(!notifications) },
          { label: "Show Arabic Text", sub: "Display original Arabic", val: showArabic, fn: () => setShowArabic(!showArabic) },
          { label: "Dark Mode", sub: "Always on for spiritual atmosphere", val: darkMode, fn: () => {} },
          { label: "Haptic Feedback", sub: "Vibrate on tasbeeh tap", val: vibration, fn: () => setVibration(!vibration) },
        ].map((s, i) => (
          <div
            key={i}
            className="flex items-center justify-between px-4 py-3.5 rounded-2xl"
            style={{ background: PANEL }}
          >
            <div>
              <p className="text-sm font-semibold" style={{ color: CREAM }}>{s.label}</p>
              <p className="text-xs mt-0.5" style={{ color: "rgba(240,235,224,0.4)" }}>{s.sub}</p>
            </div>
            <Toggle val={s.val} onChange={s.fn} />
          </div>
        ))}
      </div>

      <div className="px-5 mb-4">
        <button
          onClick={onOpenStatistics}
          className="w-full py-3 rounded-2xl font-semibold"
          style={{ background: "rgba(201,168,76,0.12)", border: "1px solid rgba(201,168,76,0.28)", color: GOLD }}
        >
          View Statistics
        </button>
      </div>

      {/* About */}
      <div className="px-5 mb-8">
        <div
          className="p-4 rounded-2xl text-center"
          style={{ background: PANEL, border: `1px solid ${PANEL_BORDER}` }}
        >
          <p className="text-2xl mb-1" style={{ fontFamily: "Amiri, serif", color: GOLD }}>أذكار</p>
          <p className="text-xs font-semibold" style={{ color: CREAM }}>Azkar App v1.0</p>
          <p className="text-xs mt-0.5" style={{ color: "rgba(240,235,224,0.35)" }}>A spiritual companion for daily dhikr</p>
        </div>
      </div>
    </div>
  );
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

function BottomNav({ current, onNavigate }: { current: MainScreen; onNavigate: (s: MainScreen) => void }) {
  const items: { id: MainScreen; icon: React.ReactNode; label: string }[] = [
    { id: "home", icon: <Moon size={19} />, label: "Home" },
    { id: "categories", icon: <BookOpen size={19} />, label: "Azkar" },
    { id: "tasbeeh", icon: <span style={{ fontSize: 19, lineHeight: 1 }}>📿</span>, label: "Tasbeeh" },
    { id: "quran", icon: <BookOpen size={19} />, label: "Quran" },
    { id: "settings", icon: <Settings size={19} />, label: "Settings" },
  ];

  return (
    <div
      className="flex items-center justify-around px-1 py-3"
      style={{ background: "#071A12", borderTop: "1px solid rgba(255,255,255,0.06)" }}
    >
      {items.map((item) => {
        const active = current === item.id;
        return (
          <button
            key={item.id}
            onClick={() => onNavigate(item.id)}
            className="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all"
            style={{ color: active ? GOLD : "rgba(240,235,224,0.3)" }}
          >
            {item.icon}
            <span className="text-xs font-medium">{item.label}</span>
            {active && (
              <div className="w-1 h-1 rounded-full" style={{ background: GOLD }} />
            )}
          </button>
        );
      })}
    </div>
  );
}

// ─── App Root ─────────────────────────────────────────────────────────────────

export default function App() {
  const [overlay, setOverlay] = useState<OverlayScreen>("onboarding");
  const [mainScreen, setMainScreen] = useState<MainScreen>("home");
  const [userName, setUserName] = useState("Beloved");
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [showUserFlows] = useState(false);

  const handleOnboardingComplete = (name: string) => {
    setUserName(name);
    setOverlay(null);
  };

  const handleCategorySelect = (cat: string) => {
    setSelectedCategory(cat);
    if (cat === "quran") {
      setMainScreen("quran");
      return;
    }
    setMainScreen("reading");
  };

  if (showUserFlows) {
    return <UserFlowsPage />;
  }

  // Overlays take full screen
  if (overlay === "onboarding") {
    return (
      <div className="h-screen w-full flex items-center justify-center" style={{ background: "#040C07" }}>
        <div
          className="relative w-full max-w-sm rounded-3xl overflow-hidden shadow-2xl"
          style={{ height: "min(90vh, 750px)" }}
        >
          <OnboardingScreen onComplete={handleOnboardingComplete} />
        </div>
      </div>
    );
  }

  if (overlay === "focus") {
    return (
      <div className="h-screen w-full flex items-center justify-center" style={{ background: "#040C07" }}>
        <div
          className="relative w-full max-w-sm rounded-3xl overflow-hidden shadow-2xl"
          style={{ height: "min(90vh, 750px)" }}
        >
          <FocusModeScreen onClose={() => setOverlay(null)} />
        </div>
      </div>
    );
  }

  if (overlay === "names") {
    return (
      <div className="h-screen w-full flex items-center justify-center" style={{ background: "#040C07" }}>
        <div
          className="relative w-full max-w-sm rounded-3xl overflow-hidden shadow-2xl"
          style={{ height: "min(90vh, 750px)" }}
        >
          <NamesOfAllahScreen onBack={() => setOverlay(null)} />
        </div>
      </div>
    );
  }

  const renderMain = () => {
    switch (mainScreen) {
      case "home":
        return (
          <HomeScreen
            onNavigate={setMainScreen}
            userName={userName}
            onOpenFocus={() => setOverlay("focus")}
            onOpenNames={() => setOverlay("names")}
          />
        );
      case "categories":
        return <CategoriesScreen onSelect={handleCategorySelect} onBack={() => setMainScreen("home")} />;
      case "reading":
        return <ReadingScreen category={selectedCategory} onBack={() => setMainScreen("categories")} />;
      case "quran":
        return <QuranScreen onBack={() => setMainScreen("home")} />;
      case "tasbeeh":
        return <TasbeehScreen />;
      case "statistics":
        return <StatisticsScreen />;
      case "settings":
        return <SettingsScreen onOpenStatistics={() => setMainScreen("statistics")} />;
      default:
        return (
          <HomeScreen
            onNavigate={setMainScreen}
            userName={userName}
            onOpenFocus={() => setOverlay("focus")}
            onOpenNames={() => setOverlay("names")}
          />
        );
    }
  };

  return (
    <div
      className="h-screen w-full flex items-center justify-center"
      style={{ background: "linear-gradient(135deg, #040C07 0%, #0A2318 100%)" }}
    >
      <div
        className="relative w-full max-w-sm flex flex-col rounded-3xl overflow-hidden shadow-2xl"
        style={{ height: "min(90vh, 750px)" }}
      >
        <div className="flex-1 overflow-hidden">{renderMain()}</div>
        <BottomNav current={mainScreen} onNavigate={setMainScreen} />
      </div>
    </div>
  );
}
