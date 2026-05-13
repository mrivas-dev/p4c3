/* p4ce — Home Dashboard variations */

// ─────────────────────────────────────────────────────────────
// Tokens (shared)
// ─────────────────────────────────────────────────────────────
const T = {
  bg:        'oklch(0.155 0.005 250)',
  bgDeep:    'oklch(0.12  0.005 250)',
  surf:      'oklch(0.205 0.006 250)',
  surfHi:    'oklch(0.245 0.006 250)',
  line:      'oklch(0.27  0.005 250)',
  lineSoft:  'oklch(0.225 0.005 250)',
  text:      'oklch(0.97  0.005 90)',
  textDim:   'oklch(0.80  0.005 90)',
  muted:     'oklch(0.55  0.010 250)',
  dim:       'oklch(0.40  0.010 250)',
  lime:      'oklch(0.86  0.20 124)',
  limeDeep:  'oklch(0.70  0.18 124)',
  limeInk:   'oklch(0.18  0.05 124)',
  red:       'oklch(0.70  0.18 25)',
  amber:     'oklch(0.82  0.16 78)',
  green:     'oklch(0.78  0.16 145)',
};

const fontSans    = '"Geist", -apple-system, system-ui, sans-serif';
const fontDisplay = '"Antonio", "Geist", system-ui, sans-serif';
const fontMono    = '"JetBrains Mono", ui-monospace, monospace';

// ─────────────────────────────────────────────────────────────
// Tiny shared atoms
// ─────────────────────────────────────────────────────────────
function StatusOverlay({ dark = true }) {
  // The IOSDevice already paints a status bar via IOSStatusBar internally?
  // No — only when title is provided. Render one explicitly.
  return <IOSStatusBar dark={dark} />;
}

function Tag({ children, color = T.muted, bg, style }) {
  return (
    <span style={{
      fontFamily: fontMono,
      fontSize: 10, letterSpacing: 1.6, textTransform: 'uppercase',
      color, background: bg, padding: bg ? '3px 7px' : 0,
      borderRadius: 4, fontWeight: 500,
      ...style,
    }}>{children}</span>
  );
}

function ReadinessRing({ score = 8, size = 56, stroke = 4, label = true }) {
  const r = (size - stroke) / 2;
  const C = 2 * Math.PI * r;
  const pct = score / 10;
  const color = score >= 7 ? T.lime : score >= 5 ? T.amber : T.red;
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size/2} cy={size/2} r={r} stroke={T.line} strokeWidth={stroke} fill="none" />
        <circle cx={size/2} cy={size/2} r={r} stroke={color} strokeWidth={stroke} fill="none"
          strokeDasharray={C} strokeDashoffset={C * (1 - pct)} strokeLinecap="round" />
      </svg>
      {label && (
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: fontDisplay, fontWeight: 700, fontSize: size * 0.42, color,
          letterSpacing: -0.5,
        }}>{score}</div>
      )}
    </div>
  );
}

// 4-bar readiness "EQ" style indicator — health-y, not numerical
function ReadinessBars({ score = 8, height = 36, gap = 3, width = 56 }) {
  const cells = 10;
  const color = score >= 7 ? T.lime : score >= 5 ? T.amber : T.red;
  const cellW = (width - gap * (cells - 1)) / cells;
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap, height, width }}>
      {Array.from({ length: cells }).map((_, i) => {
        const on = i < score;
        const h = height * (0.35 + 0.07 * i);
        return (
          <div key={i} style={{
            width: cellW, height: h, borderRadius: 1.5,
            background: on ? color : T.line,
            transition: 'background 200ms',
          }}/>
        );
      })}
    </div>
  );
}

function TabBar({ active = 'home', variant = 'default' }) {
  const items = [
    { id: 'home', label: 'Home', icon: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
        <path d="M4 11.5L12 5l8 6.5V20a1 1 0 01-1 1h-5v-6h-4v6H5a1 1 0 01-1-1v-8.5z"
              stroke="currentColor" strokeWidth="1.7" strokeLinejoin="round"/>
      </svg>
    )},
    { id: 'log', label: 'Log', icon: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
        <path d="M3 12h3l2-6 4 12 3-9 2 3h4" stroke="currentColor" strokeWidth="1.7"
              strokeLinecap="round" strokeLinejoin="round"/>
      </svg>
    )},
    { id: 'program', label: 'Program', icon: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
        <rect x="4" y="4" width="16" height="16" rx="2" stroke="currentColor" strokeWidth="1.7"/>
        <path d="M4 9h16M9 4v16" stroke="currentColor" strokeWidth="1.7"/>
      </svg>
    )},
    { id: 'analytics', label: 'Analytics', icon: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
        <path d="M5 19V11M10 19V5M15 19v-6M20 19v-9" stroke="currentColor"
              strokeWidth="1.7" strokeLinecap="round"/>
      </svg>
    )},
  ];
  return (
    <div style={{
      position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 30,
      paddingBottom: 28, paddingTop: 10,
      background: variant === 'brutal' ? T.bgDeep : `linear-gradient(to top, ${T.bg} 70%, transparent)`,
      borderTop: variant === 'brutal' ? `1px solid ${T.line}` : 'none',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-around', padding: '0 8px' }}>
        {items.map((it) => {
          const on = it.id === active;
          return (
            <div key={it.id} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
              padding: '6px 10px', minWidth: 56,
              color: on ? T.text : T.dim,
            }}>
              {it.icon}
              <span style={{
                fontFamily: fontSans, fontSize: 10, letterSpacing: 0.4,
                fontWeight: on ? 600 : 500,
              }}>{it.label}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// V1 — NOTEBOOK
// Editorial training-journal: heavy typography, generous space,
// monospace metadata, single signal accent only on the CTA.
// ─────────────────────────────────────────────────────────────
function DashV1() {
  return (
    <div style={{
      width: '100%', height: '100%', background: T.bg, color: T.text,
      fontFamily: fontSans, position: 'relative', overflow: 'hidden',
      display: 'flex', flexDirection: 'column',
    }}>
      <StatusOverlay />
      {/* Top meta */}
      <div style={{
        marginTop: 54, padding: '12px 24px 0',
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      }}>
        <div style={{ fontFamily: fontMono, fontSize: 11, letterSpacing: 1.4, color: T.muted }}>
          TUE · 12 MAY · WK 19
        </div>
        <div style={{
          width: 30, height: 30, borderRadius: 999, background: T.surf,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: fontSans, fontSize: 11, fontWeight: 600, color: T.textDim,
          border: `1px solid ${T.line}`,
        }}>RK</div>
      </div>

      {/* TODAY hero */}
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 6 }}>
          <Tag color={T.muted}>Today</Tag>
          <div style={{ flex: 1, height: 1, background: T.lineSoft }}/>
          <Tag color={T.lime}>Metcon</Tag>
        </div>
        <div style={{
          fontFamily: fontDisplay, fontWeight: 700, fontSize: 76, lineHeight: 0.92,
          letterSpacing: -1.5, color: T.text, marginTop: 8,
        }}>
          Diane
        </div>
        <div style={{
          fontFamily: fontDisplay, fontWeight: 500, fontSize: 22, lineHeight: 1.1,
          color: T.textDim, letterSpacing: 0.5, marginTop: 6,
        }}>
          21–15–9
        </div>
        <div style={{
          fontFamily: fontMono, fontSize: 11, letterSpacing: 1.3, color: T.muted,
          marginTop: 12, textTransform: 'uppercase',
        }}>
          Deadlift 102kg <span style={{ color: T.dim }}>·</span> HSPU <span style={{ color: T.dim }}>·</span> Target sub-8:00
        </div>
      </div>

      {/* Quick stats — editorial inline */}
      <div style={{
        margin: '28px 24px 0',
        paddingTop: 18, paddingBottom: 18,
        borderTop: `1px solid ${T.lineSoft}`,
        borderBottom: `1px solid ${T.lineSoft}`,
        display: 'grid', gridTemplateColumns: '1fr 1fr auto', gap: 14,
        alignItems: 'end',
      }}>
        <div>
          <div style={{ fontFamily: fontMono, fontSize: 9.5, letterSpacing: 1.4, color: T.muted, marginBottom: 4 }}>VOLUME · WK</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 30, fontWeight: 600, lineHeight: 1, letterSpacing: -0.5 }}>
            12,480<span style={{ fontSize: 14, color: T.muted, marginLeft: 4 }}>kg</span>
          </div>
        </div>
        <div>
          <div style={{ fontFamily: fontMono, fontSize: 9.5, letterSpacing: 1.4, color: T.muted, marginBottom: 4 }}>STREAK</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 30, fontWeight: 600, lineHeight: 1, letterSpacing: -0.5 }}>
            23<span style={{ fontSize: 14, color: T.muted, marginLeft: 4 }}>d</span>
          </div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4 }}>
          <div style={{ fontFamily: fontMono, fontSize: 9.5, letterSpacing: 1.4, color: T.muted }}>READINESS</div>
          <ReadinessBars score={8} width={64} height={28} />
        </div>
      </div>

      {/* Last session */}
      <div style={{ padding: '18px 24px 0' }}>
        <div style={{ fontFamily: fontMono, fontSize: 9.5, letterSpacing: 1.4, color: T.muted, marginBottom: 6 }}>
          LAST · MON 11 MAY
        </div>
        <div style={{ fontFamily: fontSans, fontSize: 16, fontWeight: 500, color: T.textDim, lineHeight: 1.35 }}>
          Heavy Snatch + EMOM 12
        </div>
        <div style={{
          marginTop: 10, display: 'flex', alignItems: 'baseline', gap: 8,
          fontFamily: fontDisplay,
        }}>
          <span style={{ fontFamily: fontMono, fontSize: 10, letterSpacing: 1.3, color: T.muted }}>TOP LIFT</span>
          <span style={{ fontSize: 22, fontWeight: 600, letterSpacing: -0.3 }}>Snatch</span>
          <span style={{ fontSize: 22, fontWeight: 700, color: T.lime, letterSpacing: -0.3 }}>92<span style={{ fontSize: 13, color: T.lime, opacity: 0.7 }}>kg</span></span>
          <span style={{ fontFamily: fontMono, fontSize: 10, color: T.dim }}>+2kg PR</span>
        </div>
      </div>

      <div style={{ flex: 1 }} />

      {/* CTA — bottom 40%, dominant */}
      <div style={{ padding: '0 20px 96px' }}>
        <button style={{
          width: '100%', height: 88, borderRadius: 22, border: 'none',
          background: T.lime, color: T.limeInk,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '0 28px', cursor: 'pointer',
          boxShadow: `0 10px 30px -8px ${T.lime}55`,
          fontFamily: fontDisplay,
        }}>
          <div style={{ textAlign: 'left' }}>
            <div style={{ fontFamily: fontMono, fontSize: 10, letterSpacing: 1.6, fontWeight: 600, opacity: 0.7 }}>READY · 5:42 AM</div>
            <div style={{ fontSize: 30, fontWeight: 700, letterSpacing: 0.5, lineHeight: 1, marginTop: 4 }}>START WORKOUT</div>
          </div>
          <svg width="34" height="34" viewBox="0 0 34 34">
            <circle cx="17" cy="17" r="16" fill={T.limeInk} fillOpacity="0.18"/>
            <path d="M14 11l8 6-8 6V11z" fill={T.limeInk}/>
          </svg>
        </button>
      </div>

      <TabBar active="home" />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// V2 — SCOREBOARD
// Dense, data-forward. Readiness ring is the health indicator
// at top right. Stats tiles. Last session as a compact strip.
// ─────────────────────────────────────────────────────────────
function DashV2() {
  return (
    <div style={{
      width: '100%', height: '100%', background: T.bg, color: T.text,
      fontFamily: fontSans, position: 'relative', overflow: 'hidden',
      display: 'flex', flexDirection: 'column',
    }}>
      <StatusOverlay />

      {/* Hero card — workout */}
      <div style={{
        margin: '54px 16px 0', padding: '18px 18px 20px',
        background: T.surf, borderRadius: 22,
        position: 'relative',
      }}>
        {/* Top row: greeting + readiness ring */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <div style={{ fontFamily: fontMono, fontSize: 10.5, letterSpacing: 1.6, color: T.muted, textTransform: 'uppercase' }}>
              Tue 12 May · 5:42 AM
            </div>
            <div style={{ fontFamily: fontSans, fontSize: 14, color: T.textDim, marginTop: 4, fontWeight: 500 }}>
              Morning, Ryan
            </div>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
            <ReadinessRing score={8} size={50} stroke={3.5} />
            <div style={{ fontFamily: fontMono, fontSize: 8.5, letterSpacing: 1.4, color: T.green, fontWeight: 600 }}>PRIMED</div>
          </div>
        </div>

        {/* divider */}
        <div style={{ height: 1, background: T.lineSoft, margin: '14px -18px 14px' }}/>

        <div style={{ display: 'flex', alignItems: 'baseline', gap: 10, marginBottom: 4 }}>
          <Tag color={T.lime} bg="oklch(0.86 0.20 124 / 0.12)">Metcon · Benchmark</Tag>
        </div>
        <div style={{
          fontFamily: fontDisplay, fontWeight: 700, fontSize: 68, lineHeight: 0.95,
          letterSpacing: -1.4, color: T.text, marginTop: 8,
        }}>Diane</div>
        <div style={{
          fontFamily: fontDisplay, fontWeight: 500, fontSize: 18, color: T.textDim,
          letterSpacing: 0.4, marginTop: 6,
        }}>21–15–9 · Deadlift 102kg · HSPU</div>
      </div>

      {/* Stats tiles */}
      <div style={{
        margin: '16px 16px 0',
        display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10,
      }}>
        <div style={{ background: T.surf, borderRadius: 16, padding: '14px 16px' }}>
          <div style={{ fontFamily: fontMono, fontSize: 9.5, letterSpacing: 1.4, color: T.muted, marginBottom: 6 }}>VOLUME · WEEK</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 30, fontWeight: 700, lineHeight: 1, letterSpacing: -0.5 }}>
            12,480<span style={{ fontSize: 13, color: T.muted, marginLeft: 4 }}>kg</span>
          </div>
          {/* tiny spark */}
          <svg width="100%" height="14" viewBox="0 0 100 14" preserveAspectRatio="none" style={{ marginTop: 8 }}>
            <polyline points="0,10 14,8 28,9 42,5 56,7 70,4 84,5 100,2"
              fill="none" stroke={T.lime} strokeWidth="1.4" strokeLinecap="round"/>
          </svg>
        </div>
        <div style={{ background: T.surf, borderRadius: 16, padding: '14px 16px' }}>
          <div style={{ fontFamily: fontMono, fontSize: 9.5, letterSpacing: 1.4, color: T.muted, marginBottom: 6 }}>STREAK</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 30, fontWeight: 700, lineHeight: 1, letterSpacing: -0.5 }}>
            23<span style={{ fontSize: 13, color: T.muted, marginLeft: 4 }}>days</span>
          </div>
          {/* 7 dots representing this week */}
          <div style={{ display: 'flex', gap: 5, marginTop: 10 }}>
            {[1,1,1,1,1,1,0].map((on,i) => (
              <div key={i} style={{
                width: 8, height: 8, borderRadius: 2,
                background: on ? T.lime : T.line,
              }}/>
            ))}
          </div>
        </div>
      </div>

      {/* Last session strip */}
      <div style={{
        margin: '12px 16px 0', padding: '14px 16px',
        background: T.surf, borderRadius: 16,
        display: 'flex', alignItems: 'center', gap: 14,
      }}>
        <div style={{
          width: 44, height: 44, borderRadius: 12,
          background: T.surfHi, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', flexShrink: 0,
        }}>
          <div style={{ fontFamily: fontDisplay, fontSize: 18, fontWeight: 700, lineHeight: 1 }}>11</div>
          <div style={{ fontFamily: fontMono, fontSize: 8, letterSpacing: 1.2, color: T.muted, marginTop: 2 }}>MAY</div>
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: fontMono, fontSize: 9.5, letterSpacing: 1.4, color: T.muted, marginBottom: 3 }}>LAST SESSION</div>
          <div style={{ fontFamily: fontSans, fontSize: 14, fontWeight: 500, color: T.text }}>Heavy Snatch + EMOM 12</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 14, color: T.lime, marginTop: 2, fontWeight: 600 }}>
            Snatch 92kg <span style={{ color: T.muted, fontFamily: fontMono, fontSize: 10 }}>· +2KG PR</span>
          </div>
        </div>
        <svg width="8" height="14" viewBox="0 0 8 14">
          <path d="M1 1l6 6-6 6" stroke={T.dim} strokeWidth="1.6" fill="none" strokeLinecap="round"/>
        </svg>
      </div>

      <div style={{ flex: 1 }}/>

      {/* CTA */}
      <div style={{ padding: '0 16px 96px' }}>
        <button style={{
          width: '100%', height: 76, borderRadius: 20, border: 'none',
          background: T.lime, color: T.limeInk,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 14,
          cursor: 'pointer', fontFamily: fontDisplay,
          boxShadow: `0 10px 30px -8px ${T.lime}55`,
        }}>
          <svg width="26" height="26" viewBox="0 0 26 26">
            <path d="M9 6l11 7-11 7V6z" fill={T.limeInk}/>
          </svg>
          <span style={{ fontSize: 26, fontWeight: 700, letterSpacing: 1.5 }}>START WORKOUT</span>
        </button>
      </div>

      <TabBar active="home" />
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// V3 — BRUTALIST FULL-BLEED START
// Workout name fills the lower half AS the Start surface.
// Stats stay tight up top. One-tap commitment.
// ─────────────────────────────────────────────────────────────
function DashV3() {
  return (
    <div style={{
      width: '100%', height: '100%', background: T.bg, color: T.text,
      fontFamily: fontSans, position: 'relative', overflow: 'hidden',
      display: 'flex', flexDirection: 'column',
    }}>
      <StatusOverlay />

      {/* Header */}
      <div style={{
        marginTop: 54, padding: '14px 22px 0',
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      }}>
        <div>
          <div style={{ fontFamily: fontMono, fontSize: 10, letterSpacing: 1.6, color: T.muted, textTransform: 'uppercase' }}>p4ce · home</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 22, fontWeight: 600, marginTop: 2, letterSpacing: -0.3 }}>
            Tue, 12 May
          </div>
        </div>
        <ReadinessRing score={8} size={48} stroke={3.5} />
      </div>

      {/* Stats — minimal row, no boxes, vertical bars between */}
      <div style={{
        margin: '22px 22px 0', display: 'flex', alignItems: 'stretch', gap: 0,
        borderTop: `1px solid ${T.lineSoft}`, borderBottom: `1px solid ${T.lineSoft}`,
        padding: '14px 0',
      }}>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: fontMono, fontSize: 9, letterSpacing: 1.4, color: T.muted, marginBottom: 4 }}>VOL · WK</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 24, fontWeight: 700, lineHeight: 1, letterSpacing: -0.5 }}>
            12.4<span style={{ fontSize: 11, color: T.muted, marginLeft: 2 }}>T</span>
          </div>
        </div>
        <div style={{ width: 1, background: T.lineSoft }}/>
        <div style={{ flex: 1, paddingLeft: 16 }}>
          <div style={{ fontFamily: fontMono, fontSize: 9, letterSpacing: 1.4, color: T.muted, marginBottom: 4 }}>STREAK</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 24, fontWeight: 700, lineHeight: 1, letterSpacing: -0.5 }}>
            23<span style={{ fontSize: 11, color: T.muted, marginLeft: 2 }}>D</span>
          </div>
        </div>
        <div style={{ width: 1, background: T.lineSoft }}/>
        <div style={{ flex: 1, paddingLeft: 16, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <div style={{ fontFamily: fontMono, fontSize: 9, letterSpacing: 1.4, color: T.muted }}>READY</div>
          <ReadinessBars score={8} width={70} height={20} gap={2.5}/>
        </div>
      </div>

      {/* Last session as quiet meta line */}
      <div style={{
        padding: '14px 22px 0',
        display: 'flex', alignItems: 'baseline', gap: 8, justifyContent: 'space-between',
      }}>
        <div>
          <div style={{ fontFamily: fontMono, fontSize: 9, letterSpacing: 1.4, color: T.muted, marginBottom: 2 }}>LAST · MON</div>
          <div style={{ fontFamily: fontSans, fontSize: 13, color: T.textDim, fontWeight: 500 }}>Heavy Snatch + EMOM 12</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontFamily: fontMono, fontSize: 9, letterSpacing: 1.4, color: T.muted, marginBottom: 2 }}>TOP LIFT</div>
          <div style={{ fontFamily: fontDisplay, fontSize: 18, fontWeight: 700, letterSpacing: -0.3 }}>
            Snatch <span style={{ color: T.lime }}>92<span style={{ fontSize: 10, opacity: 0.7 }}>kg</span></span>
          </div>
        </div>
      </div>

      <div style={{ flex: 1 }}/>

      {/* Full-bleed START — workout name IS the button */}
      <div style={{ padding: '0 16px 96px' }}>
        <button style={{
          display: 'block', width: '100%', textAlign: 'left',
          background: T.lime, color: T.limeInk,
          border: 'none', borderRadius: 24, padding: '22px 22px 20px',
          cursor: 'pointer', fontFamily: fontDisplay,
          boxShadow: `0 14px 40px -10px ${T.lime}66`,
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{
              fontFamily: fontMono, fontSize: 10, letterSpacing: 1.8, fontWeight: 700,
              color: T.limeInk, opacity: 0.7,
            }}>TODAY · METCON</span>
            <span style={{
              fontFamily: fontMono, fontSize: 10, letterSpacing: 1.6, fontWeight: 700,
              color: T.limeInk, opacity: 0.7,
            }}>~8:00</span>
          </div>
          <div style={{
            fontSize: 72, fontWeight: 700, lineHeight: 0.92,
            letterSpacing: -1.6, marginTop: 4,
          }}>Diane</div>
          <div style={{
            fontFamily: fontDisplay, fontSize: 18, fontWeight: 500,
            letterSpacing: 0.3, marginTop: 4, color: T.limeInk, opacity: 0.85,
          }}>21–15–9 · Deadlift · HSPU</div>
          <div style={{
            marginTop: 14, display: 'flex', alignItems: 'center', gap: 10,
            paddingTop: 14, borderTop: `1px solid ${T.limeInk}22`,
          }}>
            <svg width="22" height="22" viewBox="0 0 22 22">
              <circle cx="11" cy="11" r="10" fill={T.limeInk}/>
              <path d="M9 7l6 4-6 4V7z" fill={T.lime}/>
            </svg>
            <span style={{
              fontFamily: fontDisplay, fontSize: 18, fontWeight: 700, letterSpacing: 1.5,
              color: T.limeInk,
            }}>TAP TO START</span>
          </div>
        </button>
      </div>

      <TabBar active="home" variant="brutal" />
    </div>
  );
}

Object.assign(window, { DashV1, DashV2, DashV3, T, ReadinessRing, ReadinessBars });
