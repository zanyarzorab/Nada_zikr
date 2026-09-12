import { useMemo, useState } from "react";

type NodeType = "start" | "screen" | "decision" | "end";

type FlowStep = {
  label: string;
  type: NodeType;
};

const flows: Array<{ id: string; title: string; subtitle: string; steps: FlowStep[] }> = [
  {
    id: "01",
    title: "First-Time User",
    subtitle: "Opening journey from first launch to home dashboard",
    steps: [
      { label: "Open App", type: "start" },
      { label: "Splash Screen", type: "screen" },
      { label: "Welcome", type: "screen" },
      { label: "Choose Language", type: "screen" },
      { label: "Location Permission", type: "screen" },
      { label: "Notification Permission", type: "screen" },
      { label: "Select Prayer Method", type: "screen" },
      { label: "Choose Madhhab", type: "screen" },
      { label: "Guest or Sign In?", type: "decision" },
      { label: "Home Dashboard", type: "end" },
    ],
  },
  {
    id: "02",
    title: "Check Prayer Times",
    subtitle: "A simple flow to review prayer timing details",
    steps: [
      { label: "Home", type: "start" },
      { label: "Prayer", type: "screen" },
      { label: "Prayer Times", type: "screen" },
      { label: "Prayer Details", type: "screen" },
      { label: "Set Reminder", type: "screen" },
      { label: "Back to Home", type: "end" },
    ],
  },
  {
    id: "03",
    title: "Read Quran",
    subtitle: "Discovery and immersion into a reading session",
    steps: [
      { label: "Home", type: "start" },
      { label: "Continue Reading or Quran", type: "decision" },
      { label: "Surah List", type: "screen" },
      { label: "Reading Screen", type: "screen" },
      { label: "Audio", type: "screen" },
      { label: "Bookmark", type: "screen" },
      { label: "Exit", type: "end" },
    ],
  },
  {
    id: "04",
    title: "Morning Dhikr",
    subtitle: "A guided ritual flow for daily remembrance",
    steps: [
      { label: "Home", type: "start" },
      { label: "Dhikr", type: "screen" },
      { label: "Morning Dhikr", type: "screen" },
      { label: "Read Dhikr", type: "screen" },
      { label: "Play Audio", type: "screen" },
      { label: "Mark Complete", type: "screen" },
      { label: "Update Progress", type: "end" },
    ],
  },
  {
    id: "05",
    title: "Tasbeeh",
    subtitle: "From selection to goal completion and reflection",
    steps: [
      { label: "Home", type: "start" },
      { label: "Tasbeeh", type: "screen" },
      { label: "Choose Dhikr", type: "screen" },
      { label: "Counter", type: "screen" },
      { label: "Reach Goal", type: "screen" },
      { label: "Statistics Updated", type: "end" },
    ],
  },
  {
    id: "06",
    title: "AI Assistant",
    subtitle: "A conversational support path for questions and guidance",
    steps: [
      { label: "Home", type: "start" },
      { label: "AI", type: "screen" },
      { label: "Ask Question", type: "screen" },
      { label: "AI Response", type: "screen" },
      { label: "Related Topics", type: "screen" },
      { label: "Save Conversation", type: "end" },
    ],
  },
  {
    id: "07",
    title: "Learning",
    subtitle: "A knowledge journey from category to quiz completion",
    steps: [
      { label: "Home", type: "start" },
      { label: "Learning", type: "screen" },
      { label: "Choose Category", type: "screen" },
      { label: "Open Lesson", type: "screen" },
      { label: "Finish Reading", type: "screen" },
      { label: "Take Quiz", type: "end" },
    ],
  },
  {
    id: "08",
    title: "Daily Goal",
    subtitle: "A progression loop that celebrates daily completion",
    steps: [
      { label: "Open App", type: "start" },
      { label: "View Today's Goals", type: "screen" },
      { label: "Complete Prayer", type: "screen" },
      { label: "Read Quran", type: "screen" },
      { label: "Complete Dhikr", type: "screen" },
      { label: "Goal Complete", type: "screen" },
      { label: "Achievement Animation", type: "end" },
    ],
  },
];

function nodeClasses(type: NodeType, isDark: boolean) {
  const dark = {
    start: "bg-emerald-500/90 text-emerald-950 border-emerald-400/70 shadow-[0_0_0_1px_rgba(255,255,255,0.15),0_10px_30px_rgba(16,185,129,0.23)]",
    decision: "bg-amber-400/90 text-slate-900 border-amber-300/70 shadow-[0_0_0_1px_rgba(255,255,255,0.15),0_10px_30px_rgba(245,158,11,0.22)]",
    end: "bg-rose-500/90 text-white border-rose-400/70 shadow-[0_0_0_1px_rgba(255,255,255,0.15),0_10px_30px_rgba(244,63,94,0.24)]",
    screen: "bg-sky-500/85 text-white border-sky-400/70 shadow-[0_0_0_1px_rgba(255,255,255,0.12),0_10px_24px_rgba(59,130,246,0.22)]",
  };

  const light = {
    start: "bg-emerald-100 text-emerald-800 border-emerald-300 shadow-[0_0_0_1px_rgba(0,0,0,0.04),0_10px_24px_rgba(16,185,129,0.16)]",
    decision: "bg-amber-100 text-amber-900 border-amber-300 shadow-[0_0_0_1px_rgba(0,0,0,0.04),0_10px_24px_rgba(245,158,11,0.16)]",
    end: "bg-rose-100 text-rose-700 border-rose-300 shadow-[0_0_0_1px_rgba(0,0,0,0.04),0_10px_24px_rgba(244,63,94,0.16)]",
    screen: "bg-sky-100 text-sky-800 border-sky-300 shadow-[0_0_0_1px_rgba(0,0,0,0.04),0_10px_24px_rgba(59,130,246,0.14)]",
  };

  return isDark ? dark[type] : light[type];
}

function FlowNode({ step, isDark }: { step: FlowStep; isDark: boolean }) {
  const base = "flex items-center justify-center rounded-2xl border px-4 py-3 text-center text-[12px] font-semibold leading-5 min-h-[54px] min-w-[150px] max-w-[180px]";

  if (step.type === "decision") {
    return (
      <div className={`${base} rotate-45 ${nodeClasses(step.type, isDark)} bg-amber-400/90`}>
        <span className="-rotate-45 whitespace-normal">{step.label}</span>
      </div>
    );
  }

  return <div className={`${base} ${nodeClasses(step.type, isDark)}`}>{step.label}</div>;
}

export default function UserFlowsPage() {
  const [isDark, setIsDark] = useState(true);

  const themeClasses = useMemo(
    () =>
      isDark
        ? {
            shell: "min-h-screen bg-[radial-gradient(circle_at_top_left,_#103620_0%,_#072113_35%,_#020a06_100%)] text-slate-100",
            card: "rounded-[28px] border border-white/10 bg-white/8 p-6 shadow-2xl shadow-black/20 backdrop-blur-xl",
            section: "rounded-[24px] border border-white/10 bg-[#0b1f15]/80 p-5 shadow-xl shadow-black/20 backdrop-blur-xl",
            muted: "text-slate-400",
            heading: "text-white",
            pill: "border-emerald-400/30 bg-emerald-500/10 text-emerald-200",
            pill2: "border-sky-400/30 bg-sky-500/10 text-sky-200",
            pill3: "border-amber-400/30 bg-amber-400/10 text-amber-200",
            divider: "from-white/40 to-transparent",
          }
        : {
            shell: "min-h-screen bg-[linear-gradient(135deg,_#f8f7f3_0%,_#f0ebdf_55%,_#e8e0cb_100%)] text-slate-800",
            card: "rounded-[28px] border border-slate-200 bg-white/80 p-6 shadow-[0_20px_60px_rgba(15,23,42,0.08)] backdrop-blur-xl",
            section: "rounded-[24px] border border-slate-200 bg-white/75 p-5 shadow-[0_18px_45px_rgba(15,23,42,0.06)] backdrop-blur-xl",
            muted: "text-slate-500",
            heading: "text-slate-900",
            pill: "border-emerald-300 bg-emerald-50 text-emerald-700",
            pill2: "border-sky-300 bg-sky-50 text-sky-700",
            pill3: "border-amber-300 bg-amber-50 text-amber-700",
            divider: "from-slate-400/50 to-transparent",
          },
    [isDark],
  );

  return (
    <div className={themeClasses.shell}>
      <div className="mx-auto flex max-w-7xl flex-col gap-8 px-6 py-8 lg:px-10">
        <header className={themeClasses.card}>
          <div className="flex flex-col gap-4 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <p className={`text-[11px] font-semibold uppercase tracking-[0.35em] ${isDark ? "text-emerald-300/80" : "text-emerald-600"}`}>02 - User Flows</p>
              <h1 className={`mt-2 text-3xl font-semibold sm:text-4xl ${themeClasses.heading}`}>How users complete important tasks</h1>
              <p className={`mt-3 max-w-2xl text-sm leading-6 sm:text-base ${themeClasses.muted}`}>
                This page focuses on the experience logic of the product: the movement, decisions, and outcomes that guide users through key journeys.
              </p>
            </div>
            <div className="flex flex-wrap items-center gap-3">
              <button
                onClick={() => setIsDark((value) => !value)}
                className={`rounded-full border px-3 py-2 text-sm font-medium transition ${isDark ? "border-white/15 bg-white/10 text-slate-100" : "border-slate-300 bg-white/70 text-slate-700"}`}
              >
                {isDark ? "☀️ Light" : "🌙 Dark"}
              </button>
              <div className={`rounded-full border px-3 py-2 text-sm ${themeClasses.pill}`}>8 Core Flows</div>
              <div className={`rounded-full border px-3 py-2 text-sm ${themeClasses.pill2}`}>Decision-Driven</div>
              <div className={`rounded-full border px-3 py-2 text-sm ${themeClasses.pill3}`}>Presentation Ready</div>
            </div>
          </div>
        </header>

        <div className="grid gap-5 xl:grid-cols-2">
          {flows.map((flow) => (
            <section key={flow.id} className={themeClasses.section}>
              <div className="mb-5 flex items-start justify-between gap-3">
                <div>
                  <p className={`text-[10px] font-semibold uppercase tracking-[0.3em] ${themeClasses.muted}`}>Flow {flow.id}</p>
                  <h2 className={`mt-1 text-xl font-semibold ${themeClasses.heading}`}>{flow.title}</h2>
                  <p className={`mt-1 text-sm ${themeClasses.muted}`}>{flow.subtitle}</p>
                </div>
                <div className={`rounded-full border px-3 py-1 text-[11px] font-medium uppercase tracking-[0.25em] ${isDark ? "border-white/10 bg-white/6 text-slate-300" : "border-slate-200 bg-slate-50 text-slate-600"}`}>
                  {flow.steps.length} steps
                </div>
              </div>

              <div className="flex flex-col items-center gap-2">
                {flow.steps.map((step, index) => (
                  <div key={`${flow.id}-${step.label}-${index}`} className="flex flex-col items-center">
                    <FlowNode step={step} isDark={isDark} />
                    {index < flow.steps.length - 1 && <div className={`my-1 h-5 w-px bg-gradient-to-b ${themeClasses.divider}`} />}
                  </div>
                ))}
              </div>
            </section>
          ))}
        </div>
      </div>
    </div>
  );
}
