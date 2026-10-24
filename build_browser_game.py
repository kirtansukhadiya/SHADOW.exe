import base64
import os

with open('assets/art/spritesheet.png', 'rb') as f:
    spritesheet_b64 = base64.b64encode(f.read()).decode('utf-8')
with open('assets/art/player.gif', 'rb') as f:
    player_gif_b64 = base64.b64encode(f.read()).decode('utf-8')
with open('assets/art/ghost.gif', 'rb') as f:
    ghost_gif_b64 = base64.b64encode(f.read()).decode('utf-8')
with open('assets/art/ghost_reverse.gif', 'rb') as f:
    ghost_reverse_gif_b64 = base64.b64encode(f.read()).decode('utf-8')

html_content = f'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>SHADOW.exe // Reversal Protocol</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Orbitron:wght@600;800;900&display=swap" rel="stylesheet">
  <style>
    :root {{
      --cyan: #00f0ff;
      --cyan-dim: #00a0b0;
      --orange: #ff7700;
      --violet: #d000ff;
      --red: #ff3344;
      --bg: #03070d;
      --panel-bg: rgba(6, 14, 25, 0.92);
      --border: rgba(0, 240, 255, 0.35);
    }}
    * {{
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      user-select: none;
      -webkit-user-select: none;
    }}
    body {{
      background: radial-gradient(circle at 50% 20%, #0d1a2d 0%, #03070d 80%);
      color: #e0f4ff;
      font-family: 'Share Tech Mono', monospace;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }}

    /* Top cyber header */
    #top-nav {{
      width: 960px;
      max-width: 98vw;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 8px 14px;
      background: var(--panel-bg);
      border: 1px solid var(--border);
      border-bottom: none;
      border-radius: 6px 6px 0 0;
      box-shadow: 0 0 20px rgba(0, 240, 255, 0.1);
      font-size: 13px;
      letter-spacing: 1px;
    }}
    .nav-title {{
      display: flex;
      align-items: center;
      gap: 10px;
    }}
    .brand {{
      font-family: 'Orbitron', sans-serif;
      font-weight: 900;
      font-size: 16px;
      color: var(--cyan);
      text-shadow: 0 0 8px rgba(0, 240, 255, 0.7);
    }}
    .badge {{
      background: rgba(0, 240, 255, 0.12);
      border: 1px solid var(--cyan-dim);
      padding: 2px 7px;
      border-radius: 3px;
      color: var(--cyan);
      font-size: 11px;
      text-transform: uppercase;
    }}
    .badge.phase {{
      background: rgba(255, 119, 0, 0.15);
      border-color: var(--orange);
      color: var(--orange);
    }}
    .nav-controls {{
      display: flex;
      gap: 8px;
    }}
    .nav-btn {{
      background: rgba(0, 240, 255, 0.08);
      border: 1px solid var(--border);
      color: var(--cyan);
      font-family: 'Share Tech Mono', monospace;
      font-size: 12px;
      padding: 4px 10px;
      border-radius: 3px;
      cursor: pointer;
      transition: all 0.15s ease;
    }}
    .nav-btn:hover {{
      background: rgba(0, 240, 255, 0.25);
      border-color: var(--cyan);
      box-shadow: 0 0 10px rgba(0, 240, 255, 0.4);
    }}

    /* Viewport Frame */
    #game-container {{
      position: relative;
      width: 960px;
      height: 640px;
      max-width: 98vw;
      max-height: 65.3vw;
      background: #020408;
      border: 1px solid var(--border);
      border-radius: 0 0 6px 6px;
      box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9), 0 0 30px rgba(0, 240, 255, 0.15);
      overflow: hidden;
    }}
    canvas {{
      width: 100%;
      height: 100%;
      display: block;
      image-rendering: -webkit-optimize-contrast;
      image-rendering: crisp-edges;
      image-rendering: pixelated;
    }}

    /* CRT scanline overlay */
    #crt-overlay {{
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.25) 50%),
                  radial-gradient(circle at center, transparent 70%, rgba(0, 0, 0, 0.4) 100%);
      background-size: 100% 3px, 100% 100%;
      opacity: 0.7;
    }}

    /* Cyber bottom control bar */
    #bottom-bar {{
      width: 960px;
      max-width: 98vw;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 7px 14px;
      margin-top: 6px;
      background: rgba(5, 12, 20, 0.75);
      border: 1px solid rgba(0, 240, 255, 0.2);
      border-radius: 4px;
      font-size: 11px;
      color: #8bb3cb;
    }}
    .key-group {{
      display: inline-flex;
      align-items: center;
      gap: 5px;
      margin-right: 12px;
    }}
    .key {{
      display: inline-block;
      padding: 2px 6px;
      background: #091a2d;
      border: 1px solid #1f4f78;
      border-radius: 3px;
      color: var(--cyan);
      font-weight: bold;
      font-size: 10.5px;
      box-shadow: 0 2px 0 #000;
    }}

    /* Modal dialog */
    #modal-overlay {{
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(1, 4, 8, 0.88);
      display: none;
      align-items: center;
      justify-content: center;
      backdrop-filter: blur(4px);
      z-index: 50;
    }}
    .modal-box {{
      width: 580px;
      max-width: 90%;
      background: #06111f;
      border: 1px solid var(--cyan);
      box-shadow: 0 0 30px rgba(0, 240, 255, 0.35);
      padding: 24px;
      border-radius: 4px;
      position: relative;
    }}
    .modal-header {{
      display: flex;
      align-items: center;
      gap: 10px;
      font-family: 'Orbitron', sans-serif;
      font-size: 16px;
      color: var(--cyan);
      margin-bottom: 14px;
      border-bottom: 1px solid rgba(0, 240, 255, 0.25);
      padding-bottom: 8px;
    }}
    .modal-body {{
      font-size: 13.5px;
      line-height: 1.6;
      color: #c9e8fb;
      margin-bottom: 20px;
      white-space: pre-line;
      min-height: 80px;
    }}
    .modal-btn {{
      display: block;
      margin-left: auto;
      background: rgba(0, 240, 255, 0.15);
      border: 1px solid var(--cyan);
      color: var(--cyan);
      font-family: 'Orbitron', sans-serif;
      font-size: 13px;
      font-weight: 700;
      padding: 8px 24px;
      cursor: pointer;
      border-radius: 3px;
      transition: all 0.15s ease;
    }}
    .modal-btn:hover {{
      background: var(--cyan);
      color: #03070d;
      box-shadow: 0 0 15px var(--cyan);
    }}

    /* Glitch effect on title */
    @keyframes glitch {{
      0% {{ text-shadow: 0 0 10px rgba(0, 240, 255, 0.8); }}
      20% {{ text-shadow: -2px 0 #ff0055, 2px 0 #00ffff; }}
      40% {{ text-shadow: 2px 0 #ff0055, -2px 0 #00ffff; }}
      60% {{ text-shadow: 0 0 12px rgba(0, 240, 255, 0.9); }}
      100% {{ text-shadow: 0 0 10px rgba(0, 240, 255, 0.8); }}
    }}
    .glitch-title {{
      animation: glitch 3s infinite alternate;
    }}
  </style>
</head>
<body>

  <!-- Top Navigation & Status -->
  <div id="top-nav">
    <div class="nav-title">
      <span class="brand glitch-title">SHADOW.exe</span>
      <span class="badge" id="hud-level-badge">SYSTEM INITIALIZED</span>
      <span class="badge phase" id="hud-phase-badge">THEME: REVERSAL</span>
    </div>
    <div class="nav-controls">
      <button class="nav-btn" id="btn-menu">TITLE MENU</button>
      <button class="nav-btn" id="btn-tutorial">TUTORIAL</button>
      <button class="nav-btn" id="btn-restart">RESET [R]</button>
      <button class="nav-btn" id="btn-sound">SOUND: ON</button>
      <button class="nav-btn" id="btn-fullscreen">FULLSCREEN</button>
    </div>
  </div>

  <!-- Game Container -->
  <div id="game-container">
    <canvas id="game-canvas" width="960" height="640"></canvas>
    <div id="crt-overlay"></div>

    <!-- Interactive Terminal Modal -->
    <div id="modal-overlay">
      <div class="modal-box">
        <div class="modal-header">
          <span style="font-size:20px;">⚡</span>
          <span id="modal-title">ARCHIVE TERMINAL DATA</span>
        </div>
        <div class="modal-body" id="modal-text"></div>
        <button class="modal-btn" id="modal-close-btn">ACKNOWLEDGE [SPACE / ENTER]</button>
      </div>
    </div>
  </div>

  <!-- Cyber Key Legend -->
  <div id="bottom-bar">
    <div>
      <span class="key-group"><span class="key">A</span><span class="key">D</span> Move</span>
      <span class="key-group"><span class="key">W</span> Jump</span>
      <span class="key-group"><span class="key">SPACE</span> Deploy Shadow</span>
      <span class="key-group"><span class="key">F</span> <strong style="color:var(--orange);">Shadow Flip (REVERSE)</strong></span>
      <span class="key-group"><span class="key">E</span> Interact / Read</span>
      <span class="key-group"><span class="key">R</span> Quick Reset</span>
    </div>
    <div style="color:var(--cyan); font-weight:bold; letter-spacing:0.5px;">
      CYBER ECHO REVERSAL SIMULATION // V2.0
    </div>
  </div>

  <!-- Asset Preloader Elements (Data URIs) -->
  <div style="display:none;">
    <img id="raw-spritesheet" src="data:image/png;base64,{spritesheet_b64}" />
    <img id="raw-player-gif" src="data:image/gif;base64,{player_gif_b64}" />
    <img id="raw-ghost-gif" src="data:image/gif;base64,{ghost_gif_b64}" />
    <img id="raw-ghost-rev-gif" src="data:image/gif;base64,{ghost_reverse_gif_b64}" />
  </div>

<script>
/**
 * SHADOW.exe - Browser Engine (HTML5 Canvas + Web Audio API)
 * Theme: REVERSAL (Mandatory for solving every stage)
 *
 * Controls:
 * - Move: A / D or Left / Right Arrows
 * - Jump: W or Up Arrow (Space is strictly reserved for Shadow deployment!)
 * - Deploy Shadow: Space or E (when not near terminal)
 * - Shadow Flip: F or Q (reverses clone playback in time/space)
 * - Read Archive: E when standing near terminal
 * - Quick Restart: R
 * - Menu: Escape
 */

// --- AUDIO SYNTHESIZER (0 external files needed) ---
class CyberAudio {{
  constructor() {{
    this.ctx = null;
    this.muted = false;
    this.droneOsc = null;
  }}

  init() {{
    if (!this.ctx) {{
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioCtx();
      this.startAmbient();
    }} else if (this.ctx.state === 'suspended') {{
      this.ctx.resume();
    }}
  }}

  toggleMute() {{
    this.muted = !this.muted;
    if (this.muted && this.ctx) {{
      if (this.droneOsc) this.droneOsc.stop();
      this.droneOsc = null;
    }} else if (!this.muted) {{
      this.startAmbient();
    }}
    return !this.muted;
  }}

  startAmbient() {{
    if (this.muted || !this.ctx || this.droneOsc) return;
    try {{
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      const filter = this.ctx.createBiquadFilter();

      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(55, this.ctx.currentTime); // A1 note

      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(140, this.ctx.currentTime);

      gain.gain.setValueAtTime(0.025, this.ctx.currentTime);

      osc.connect(filter);
      filter.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start();
      this.droneOsc = osc;
    }} catch (e) {{}}
  }}

  playJump() {{
    if (this.muted || !this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'square';
    osc.frequency.setValueAtTime(150, now);
    osc.frequency.exponentialRampToValueAtTime(420, now + 0.12);
    gain.gain.setValueAtTime(0.08, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.13);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(now + 0.14);
  }}

  playDeploy() {{
    if (this.muted || !this.ctx) return;
    const notes = [220, 330, 440, 660];
    notes.forEach((freq, i) => {{
      const now = this.ctx.currentTime + (i * 0.04);
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now);
      gain.gain.setValueAtTime(0.06, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.12);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now);
      osc.stop(now + 0.14);
    }});
  }}

  playFlip() {{
    if (this.muted || !this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sawtooth';
    // Downward & upward dramatic frequency sweep for time reversal
    osc.frequency.setValueAtTime(800, now);
    osc.frequency.exponentialRampToValueAtTime(120, now + 0.18);
    osc.frequency.exponentialRampToValueAtTime(600, now + 0.32);
    gain.gain.setValueAtTime(0.12, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(now + 0.36);
  }}

  playPlate() {{
    if (this.muted || !this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'triangle';
    osc.frequency.setValueAtTime(540, now);
    osc.frequency.exponentialRampToValueAtTime(270, now + 0.08);
    gain.gain.setValueAtTime(0.12, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.1);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(now + 0.11);
  }}

  playDoor() {{
    if (this.muted || !this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'sawtooth';
    osc.frequency.setValueAtTime(90, now);
    osc.frequency.linearRampToValueAtTime(180, now + 0.25);
    gain.gain.setValueAtTime(0.09, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.28);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(now + 0.3);
  }}

  playDeath() {{
    if (this.muted || !this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = 'square';
    osc.frequency.setValueAtTime(90, now);
    osc.frequency.exponentialRampToValueAtTime(30, now + 0.35);
    gain.gain.setValueAtTime(0.18, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start();
    osc.stop(now + 0.42);
  }}

  playVictory() {{
    if (this.muted || !this.ctx) return;
    const chord = [440, 554.37, 659.25, 880];
    chord.forEach((freq, idx) => {{
      const now = this.ctx.currentTime + (idx * 0.08);
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(freq, now);
      gain.gain.setValueAtTime(0.14, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.7);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now);
      osc.stop(now + 0.75);
    }});
  }}
}}

const audio = new CyberAudio();

// --- GAME CONSTANTS & STATE ---
const CANVAS_W = 960;
const CANVAS_H = 640;
const GRAVITY = 900;
const SPEED = 240;
const JUMP_POWER = -490; // Reaches ~133px high! Effortlessly clears all tall pillars & platforms
const PLAYER_W = 24;
const PLAYER_H = 34;

const canvas = document.getElementById('game-canvas');
const ctx = canvas.getContext('2d');
const spritesheet = document.getElementById('raw-spritesheet');

const STATE = {{
  MENU: 'menu',
  PLAYING: 'playing',
  VICTORY: 'victory'
}};

let gameState = STATE.MENU;
let currentLevelIndex = 1; // 0 = Tutorial, 1 = Level 1, 2 = Level 2, 3 = Level 3
let screenShake = 0;
let deathTransition = 0;
let victoryTimer = 0;
let bannerTimer = 0;
let bannerText = '';
let bannerSub = '';

// Input Tracking
const keys = {{
  left: false,
  right: false,
  jump: false,
  deploy: false,
  flip: false,
  interact: false,
  reset: false
}};

// Particle Pool
const particles = [];
function addParticle(x, y, vx, vy, color, size, life) {{
  particles.push({{ x, y, vx, vy, color, size, life, maxLife: life }});
}}

// Level Definitions matching Godot scenes
const LEVELS = [
  // LEVEL 0: TUTORIAL PROTOCOL
  {{
    name: 'TUTORIAL PROTOCOL',
    phase: 'CALIBRATION',
    subtitle: 'SHADOW CLONE & REVERSAL REHEARSAL',
    spawn: {{ x: 80, y: 520 }},
    solids: [
      {{ x: 0, y: 550, w: 960, h: 90, color: '#0a121e', border: '#00f0ff' }}, // Main ground
      {{ x: 218, y: 520, w: 24, h: 30, color: '#142236', border: '#00f0ff' }}, // Crate
      {{ x: 325, y: 440, w: 110, h: 14, color: '#101c2e', border: '#00f0ff' }}, // Platform 1
      {{ x: 510, y: 0, w: 20, h: 470, color: '#0e1828', border: '#00f0ff' }}, // Barrier 1 overhead
      {{ x: 690, y: 0, w: 20, h: 470, color: '#0e1828', border: '#00f0ff' }}  // Barrier 2 overhead
    ],
    plates: [
      {{ id: 'p1', x: 380, y: 436, w: 48, h: 12, doors: ['d1'], releaseDelay: 0.5 }},
      {{ id: 'p2', x: 300, y: 546, w: 48, h: 12, doors: ['d2'], releaseDelay: 0.5 }}
    ],
    doors: [
      {{ id: 'd1', x: 520, y: 510, w: 16, h: 80 }},
      {{ id: 'd2', x: 700, y: 510, w: 16, h: 80 }}
    ],
    terminal: {{
      x: 150, y: 535,
      title: 'TUTORIAL PROTOCOL LOG',
      text: '1. Walk [A/D] and Jump [W] onto the raised platform to touch Plate 1.\\n' +
            '2. Return to the lower floor. Press [SPACE] to deploy your Shadow clone!\\n' +
            '3. While your shadow steps on Plate 1, pass Door 1, then press [F] to REVERSE your shadow back onto Plate 2!'
    }},
    exit: {{ x: 850, y: 510 }}
  }},

  // LEVEL 1 - DISCOVERY (THE ECHO)
  // Puzzle: Gap Void hazard! Player jumps across 3 pillars to Door 1.
  // Plate 1 is on Pillar 2 at (370, 396) -> Opens Door 1.
  // Plate 2 is back at Start on Ground Left at (110, 546) -> Opens Door 2.
  // Player deploys shadow on Pillar 2 to open Door 1, runs through Door 1 into airlock.
  // Then presses [F] (Shadow Flip)! Shadow reverses backwards all the way to Start,
  // stepping on Plate 2 to open Door 2!
  {{
    name: 'LEVEL 1 - DISCOVERY',
    phase: 'THE ECHO',
    subtitle: 'ECHO DETECTED. REVERSE SYNCHRONIZATION ACTIVE.',
    spawn: {{ x: 70, y: 520 }},
    solids: [
      {{ x: 0, y: 550, w: 180, h: 90, color: '#0a121e', border: '#00f0ff' }}, // Left Ground (start)
      {{ x: 540, y: 550, w: 420, h: 90, color: '#0a121e', border: '#00f0ff' }}, // Right Ground (airlock + exit)
      {{ x: 550, y: 0, w: 200, h: 430, color: '#0d1829', border: '#00f0ff' }}, // Overhead Airlock Roof
      // Solid cyber pillars (closed from bottom to y=640)
      {{ x: 205, y: 480, w: 90, h: 160, color: '#0c1626', border: '#00f0ff' }}, // Pillar 1
      {{ x: 315, y: 400, w: 110, h: 240, color: '#0c1626', border: '#00f0ff' }}, // Pillar 2 (High)
      {{ x: 450, y: 480, w: 80, h: 160, color: '#0c1626', border: '#00f0ff' }}  // Pillar 3
    ],
    plates: [
      {{ id: 'p1', x: 370, y: 396, w: 48, h: 12, doors: ['d1'], releaseDelay: 0.5 }}, // On Pillar 2
      {{ id: 'p2', x: 110, y: 546, w: 48, h: 12, doors: ['d2'], releaseDelay: 0.5 }}  // On Left Ground
    ],
    doors: [
      {{ id: 'd1', x: 560, y: 490, w: 18, h: 120 }},
      {{ id: 'd2', x: 740, y: 490, w: 18, h: 120 }}
    ],
    terminal: {{
      x: 150, y: 535,
      title: 'ARCHIVE 01: SYSTEM AWAKENING',
      text: 'ARCHIVE 01: SUBJECT AWAKENED IN CORRUPTED SECTOR 1.\\n' +
            'FALLING INTO THE VOID WILL RESTART YOUR SEQUENCE.\\n' +
            'COOPERATE WITH YOUR PAST: DEPLOY [SPACE] FOR DOOR 1, THEN FLIP [F] FOR DOOR 2!'
    }},
    exit: {{ x: 850, y: 500 }}
  }},

  // LEVEL 2 - DOUBT (THE OPPOSITE)
  {{
    name: 'LEVEL 2 - DOUBT',
    phase: 'THE OPPOSITE',
    subtitle: 'WARNING: ORIGINAL SIGNAL NOT FOUND.',
    spawn: {{ x: 70, y: 520 }},
    solids: [
      {{ x: 0, y: 550, w: 960, h: 90, color: '#0a121e', border: '#00f0ff' }},
      {{ x: 540, y: 0, w: 210, h: 470, color: '#0d1829', border: '#00f0ff' }}, // Overhead Roof
      {{ x: 130, y: 450, w: 100, h: 14, color: '#101c2e', border: '#00f0ff' }}, // Platform 1
      {{ x: 260, y: 350, w: 100, h: 14, color: '#101c2e', border: '#00f0ff' }}, // Platform 2
      {{ x: 390, y: 260, w: 100, h: 14, color: '#101c2e', border: '#00f0ff' }}  // Platform 3 (Top)
    ],
    plates: [
      {{ id: 'p1', x: 440, y: 256, w: 48, h: 12, doors: ['d1'], releaseDelay: 0.5 }},
      {{ id: 'p2', x: 150, y: 546, w: 48, h: 12, doors: ['d2'], releaseDelay: 0.5 }}
    ],
    doors: [
      {{ id: 'd1', x: 550, y: 510, w: 16, h: 80 }},
      {{ id: 'd2', x: 740, y: 510, w: 16, h: 80 }}
    ],
    terminal: {{
      x: 620, y: 535,
      title: 'ARCHIVE 02: SIGNAL ANOMALY',
      text: 'ARCHIVE 02: WARNING: THE SIGNAL YOU ARE TRACING DOES NOT ORIGINATE FROM YOU.\\n' +
            'WHO IS THE ARCHIVE, AND WHO IS THE PROGRAM?'
    }},
    exit: {{ x: 870, y: 510 }}
  }},

  // LEVEL 3 - REVELATION (THE ORIGINAL)
  // Triple airlock: Plate 1 (160, 546) links to BOTH Door 1 and Door 3!
  // Plate 2 (320, 356) links to Door 2!
  {{
    name: 'LEVEL 3 - REVELATION',
    phase: 'THE ORIGINAL',
    subtitle: 'IDENTITY ERROR: YOU ARE THE ECHO.',
    spawn: {{ x: 70, y: 520 }},
    solids: [
      {{ x: 0, y: 550, w: 960, h: 90, color: '#0a121e', border: '#00f0ff' }},
      {{ x: 450, y: 0, w: 20, h: 470, color: '#0d1829', border: '#00f0ff' }},
      {{ x: 670, y: 0, w: 20, h: 470, color: '#0d1829', border: '#00f0ff' }},
      {{ x: 810, y: 0, w: 20, h: 470, color: '#0d1829', border: '#00f0ff' }},
      {{ x: 130, y: 450, w: 100, h: 14, color: '#101c2e', border: '#00f0ff' }},
      {{ x: 265, y: 360, w: 110, h: 14, color: '#101c2e', border: '#00f0ff' }}
    ],
    plates: [
      {{ id: 'p1', x: 160, y: 546, w: 48, h: 12, doors: ['d1', 'd3'], releaseDelay: 0.5 }},
      {{ id: 'p2', x: 320, y: 356, w: 48, h: 12, doors: ['d2'], releaseDelay: 0.5 }}
    ],
    doors: [
      {{ id: 'd1', x: 460, y: 510, w: 16, h: 80 }},
      {{ id: 'd2', x: 680, y: 510, w: 16, h: 80 }},
      {{ id: 'd3', x: 820, y: 510, w: 16, h: 80 }}
    ],
    terminal: {{
      x: 750, y: 535,
      title: 'ARCHIVE 03: CLASSIFIED TRUTH',
      text: 'ARCHIVE 03: SYSTEM RESET PURGED THE MASTER RECORD.\\n' +
            'THE BLUE FORM IS AN EMISSION. YOU ARE THE ECHO.\\n' +
            'THE RED SHADOW WAS YOU.'
    }},
    exit: {{ x: 900, y: 510 }}
  }}
];

// --- LEVEL INSTANCE RUNTIME ---
class LevelRunner {{
  constructor(data) {{
    this.data = data;
    this.solids = data.solids;
    this.plates = data.plates.map(p => ({{
      ...p,
      isPressed: false,
      timer: 0
    }}));
    this.doors = data.doors.map(d => ({{
      ...d,
      openAmount: 0.0,
      isOpen: false
    }}));
    this.terminal = {{ ...data.terminal, triggered: false }};
    this.exit = {{ ...data.exit, rot: 0 }};

    // Player
    this.player = {{
      x: data.spawn.x,
      y: data.spawn.y,
      vx: 0,
      vy: 0,
      onGround: false,
      facing: 1,
      animTimer: 0,
      animFrame: 0,
      isDead: false
    }};

    // History Recording Buffer
    this.history = [];
    this.recording = true;

    // Platforming Polish Timers
    this.coyoteTimer = 0;
    this.jumpBufferTimer = 0;

    // Shadow Clone
    this.shadow = {{
      active: false,
      history: [],
      index: 0,
      playbackDir: 1, // 1 = forward, -1 = reversed
      x: 0,
      y: 0,
      vx: 0,
      vy: 0,
      facing: 1,
      animFrame: 0,
      isReversed: false
    }};

    this.complete = false;
  }}

  update(dt) {{
    if (this.player.isDead) return;

    // 1. Player Physics & Controls
    let moveDir = 0;
    if (keys.left) moveDir -= 1;
    if (keys.right) moveDir += 1;

    this.player.vx = moveDir * SPEED;
    this.player.vy += GRAVITY * dt;

    if (moveDir !== 0) {{
      this.player.facing = moveDir;
      this.player.animTimer += dt * 10;
      this.player.animFrame = Math.floor(this.player.animTimer) % 8;
    }} else {{
      this.player.animFrame = 0;
    }}

    // Coyote time & Jump buffering
    if (this.player.onGround) {{
      this.coyoteTimer = 0.14;
    }} else {{
      this.coyoteTimer = Math.max(0, this.coyoteTimer - dt);
    }}

    if (keys.jump) {{
      this.jumpBufferTimer = 0.16;
    }} else if (this.jumpBufferTimer > 0) {{
      this.jumpBufferTimer = Math.max(0, this.jumpBufferTimer - dt);
    }}

    // Jump execution
    if (this.jumpBufferTimer > 0 && this.coyoteTimer > 0) {{
      this.player.vy = JUMP_POWER;
      this.player.onGround = false;
      this.coyoteTimer = 0;
      this.jumpBufferTimer = 0;
      audio.playJump();
    }}

    // Horizontal Movement & Collision
    this.player.x += this.player.vx * dt;
    this.resolveCollisionsX(this.player);

    // Vertical Movement & Collision
    this.player.y += this.player.vy * dt;
    this.player.onGround = false;
    this.resolveCollisionsY(this.player);

    // Record Player State (when shadow is not active)
    if (this.recording) {{
      this.history.push({{
        x: this.player.x,
        y: this.player.y,
        vx: this.player.vx,
        vy: this.player.vy,
        facing: this.player.facing,
        animFrame: this.player.animFrame
      }});
    }}

    // Void fall death check
    if (this.player.y > 615 && !this.player.isDead) {{
      this.triggerDeath();
      return;
    }}

    // 2. Deploy Shadow Action
    if (keys.deploy && this.recording && this.history.length > 5) {{
      keys.deploy = false;
      this.deployShadow();
    }}

    // 3. Shadow Flip Action (Reversal)
    if (keys.flip && this.shadow.active) {{
      keys.flip = false;
      this.flipShadow();
    }}

    // 4. Update Shadow Clone
    if (this.shadow.active) {{
      this.updateShadow(dt);
    }}

    // 5. Update Pressure Plates
    this.updatePlates(dt);

    // 6. Update Doors (Interpolate Opening)
    this.updateDoors(dt);

    // 7. Check Terminal Proximity
    this.checkTerminal();

    // 8. Check Exit Zone
    this.checkExit();

    // Exit ring rotation
    this.exit.rot += dt * 2;
  }}

  resolveCollisionsX(entity) {{
    const halfW = PLAYER_W / 2;
    const halfH = PLAYER_H / 2;
    const allSolids = [...this.solids];

    // Closed doors act as solid walls
    for (const d of this.doors) {{
      if (d.openAmount < 0.8) {{
        allSolids.push({{
          x: d.x - d.w / 2,
          y: d.y - d.h / 2,
          w: d.w,
          h: d.h
        }});
      }}
    }}

    for (const b of allSolids) {{
      const bLeft = b.x;
      const bRight = b.x + b.w;
      const bTop = b.y;
      const bBottom = b.y + b.h;

      const pLeft = entity.x - halfW;
      const pRight = entity.x + halfW;
      const pTop = entity.y - halfH + 4;
      const pBottom = entity.y + halfH - 4;

      if (pRight > bLeft && pLeft < bRight && pBottom > bTop && pTop < bBottom) {{
        if (entity.vx > 0) {{
          entity.x = bLeft - halfW;
          entity.vx = 0;
        }} else if (entity.vx < 0) {{
          entity.x = bRight + halfW;
          entity.vx = 0;
        }}
      }}
    }}
  }}

  resolveCollisionsY(entity) {{
    const halfW = PLAYER_W / 2;
    const halfH = PLAYER_H / 2;
    const allSolids = [...this.solids];

    for (const d of this.doors) {{
      if (d.openAmount < 0.8) {{
        allSolids.push({{
          x: d.x - d.w / 2,
          y: d.y - d.h / 2,
          w: d.w,
          h: d.h
        }});
      }}
    }}

    for (const b of allSolids) {{
      const bLeft = b.x;
      const bRight = b.x + b.w;
      const bTop = b.y;
      const bBottom = b.y + b.h;

      const pLeft = entity.x - halfW + 3;
      const pRight = entity.x + halfW - 3;
      const pTop = entity.y - halfH;
      const pBottom = entity.y + halfH;

      if (pRight > bLeft && pLeft < bRight && pBottom > bTop && pTop < bBottom) {{
        if (entity.vy > 0) {{
          entity.y = bTop - halfH;
          entity.vy = 0;
          entity.onGround = true;
        }} else if (entity.vy < 0) {{
          entity.y = bBottom + halfH;
          entity.vy = 0;
        }}
      }}
    }}
  }}

  deployShadow() {{
    this.shadow.active = true;
    this.shadow.history = [...this.history];
    this.shadow.index = 0;
    this.shadow.playbackDir = 1;
    this.shadow.isReversed = false;
    this.recording = false;
    audio.playDeploy();

    // Spawn deployment particle shockwave
    for (let i = 0; i < 20; i++) {{
      const angle = (Math.PI * 2 * i) / 20;
      const spd = 80 + Math.random() * 60;
      addParticle(
        this.shadow.history[0].x,
        this.shadow.history[0].y,
        Math.cos(angle) * spd,
        Math.sin(angle) * spd,
        '#ff7700',
        3,
        0.5
      );
    }}
  }}

  flipShadow() {{
    this.shadow.playbackDir *= -1;
    this.shadow.isReversed = !this.shadow.isReversed;
    screenShake = 6;
    audio.playFlip();

    // Glowing reversal burst particles
    for (let i = 0; i < 30; i++) {{
      const angle = Math.random() * Math.PI * 2;
      const spd = 90 + Math.random() * 90;
      addParticle(
        this.shadow.x,
        this.shadow.y,
        Math.cos(angle) * spd,
        Math.sin(angle) * spd,
        this.shadow.isReversed ? '#d000ff' : '#ff7700',
        4,
        0.6
      );
    }}
  }}

  updateShadow(dt) {{
    const s = this.shadow;
    s.index += s.playbackDir;

    // Loop or latch at boundaries
    if (s.index >= s.history.length) {{
      s.index = s.history.length - 1;
    }} else if (s.index < 0) {{
      s.index = 0;
    }}

    const frame = s.history[s.index];
    if (frame) {{
      s.x = frame.x;
      s.y = frame.y;
      s.facing = (s.playbackDir === -1) ? -frame.facing : frame.facing;
      s.animFrame = frame.animFrame;
    }}

    // Trail particle
    if (Math.random() < 0.4) {{
      addParticle(
        s.x + (Math.random() - 0.5) * 10,
        s.y + (Math.random() - 0.5) * 16,
        -s.facing * 10,
        -15,
        s.isReversed ? '#d000ff' : '#ff7700',
        2.5,
        0.4
      );
    }}
  }}

  updatePlates(dt) {{
    for (const plate of this.plates) {{
      const pL = plate.x - plate.w / 2;
      const pR = plate.x + plate.w / 2;
      const pT = plate.y - plate.h / 2;
      const pB = plate.y + plate.h / 2;

      let standing = false;

      // Check player overlap
      if (
        this.player.x + PLAYER_W / 2 > pL &&
        this.player.x - PLAYER_W / 2 < pR &&
        this.player.y + PLAYER_H / 2 >= pT - 4 &&
        this.player.y - PLAYER_H / 2 < pB
      ) {{
        standing = true;
      }}

      // Check shadow overlap
      if (
        this.shadow.active &&
        this.shadow.x + PLAYER_W / 2 > pL &&
        this.shadow.x - PLAYER_W / 2 < pR &&
        this.shadow.y + PLAYER_H / 2 >= pT - 4 &&
        this.shadow.y - PLAYER_H / 2 < pB
      ) {{
        standing = true;
      }}

      if (standing) {{
        plate.timer = plate.releaseDelay;
        if (!plate.isPressed) {{
          plate.isPressed = true;
          audio.playPlate();
        }}
      }} else {{
        if (plate.timer > 0) {{
          plate.timer -= dt;
        }} else {{
          plate.isPressed = false;
        }}
      }}
    }}
  }}

  updateDoors(dt) {{
    for (const door of this.doors) {{
      // A door opens if ANY linked plate is pressed
      const shouldOpen = this.plates.some(p => p.doors.includes(door.id) && p.isPressed);

      if (shouldOpen) {{
        if (door.openAmount < 1.0) {{
          door.openAmount = Math.min(1.0, door.openAmount + dt * 3.5);
          if (door.openAmount === 1.0) audio.playDoor();
        }}
      }} else {{
        if (door.openAmount > 0.0) {{
          door.openAmount = Math.max(0.0, door.openAmount - dt * 3.5);
        }}
      }}
    }}
  }}

  checkTerminal() {{
    const dist = Math.hypot(this.player.x - this.terminal.x, this.player.y - this.terminal.y);
    if (dist < 45) {{
      if (keys.interact) {{
        keys.interact = false;
        openModal(this.terminal.title, this.terminal.text);
      }}
    }}
  }}

  checkExit() {{
    const dist = Math.hypot(this.player.x - this.exit.x, this.player.y - this.exit.y);
    if (dist < 45 && !this.complete) {{
      this.complete = true;
      audio.playVictory();
      nextLevel();
    }}
  }}

  triggerDeath() {{
    this.player.isDead = true;
    screenShake = 12;
    audio.playDeath();
    deathTransition = 0.7;

    for (let i = 0; i < 35; i++) {{
      const angle = Math.random() * Math.PI * 2;
      const spd = 60 + Math.random() * 120;
      addParticle(
        this.player.x,
        this.player.y,
        Math.cos(angle) * spd,
        Math.sin(angle) * spd,
        '#ff3344',
        3,
        0.6
      );
    }}
  }}

  draw(ctx) {{
    // 1. Draw Background Cyber Grid
    ctx.fillStyle = '#03070d';
    ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

    ctx.strokeStyle = 'rgba(0, 240, 255, 0.04)';
    ctx.lineWidth = 1;
    const gridSz = 40;
    for (let x = 0; x < CANVAS_W; x += gridSz) {{
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, CANVAS_H);
      ctx.stroke();
    }}
    for (let y = 0; y < CANVAS_H; y += gridSz) {{
      ctx.beginPath();
      ctx.moveTo(0, y);
      ctx.lineTo(CANVAS_W, y);
      ctx.stroke();
    }}

    // Hazard Void glow for pits
    ctx.fillStyle = 'rgba(255, 30, 60, 0.06)';
    ctx.fillRect(0, 590, CANVAS_W, 50);

    // 2. Draw Solids (Platforms, Pillars, Roofs)
    for (const b of this.solids) {{
      ctx.fillStyle = b.color || '#0a121e';
      ctx.fillRect(b.x, b.y, b.w, b.h);

      ctx.strokeStyle = b.border || 'rgba(0, 240, 255, 0.6)';
      ctx.lineWidth = 1.5;
      ctx.strokeRect(b.x, b.y, b.w, b.h);

      // Top edge neon accent
      ctx.strokeStyle = '#00f0ff';
      ctx.lineWidth = 2.5;
      ctx.beginPath();
      ctx.moveTo(b.x, b.y);
      ctx.lineTo(b.x + b.w, b.y);
      ctx.stroke();
    }}

    // 3. Draw Pressure Plates
    for (const p of this.plates) {{
      const active = p.isPressed;
      const pressOffset = active ? 4 : 0;
      const pL = p.x - p.w / 2;
      const pT = p.y - p.h / 2 + pressOffset;

      ctx.fillStyle = active ? '#ffaa00' : '#142336';
      ctx.fillRect(pL, pT, p.w, p.h - pressOffset);

      ctx.strokeStyle = active ? '#ffffff' : '#00f0ff';
      ctx.lineWidth = 2;
      ctx.strokeRect(pL, pT, p.w, p.h - pressOffset);

      // Plate glow halo
      if (active) {{
        ctx.shadowColor = '#ff7700';
        ctx.shadowBlur = 15;
        ctx.fillStyle = '#ff7700';
        ctx.fillRect(pL + 6, pT, p.w - 12, 3);
        ctx.shadowBlur = 0;
      }}
    }}

    // 4. Draw Airlock Blast Doors
    for (const d of this.doors) {{
      const dL = d.x - d.w / 2;
      const dT = d.y - d.h / 2;

      // Door frames (Top and Bottom housings)
      ctx.fillStyle = '#0a1626';
      ctx.fillRect(dL - 4, dT - 8, d.w + 8, 8);
      ctx.fillRect(dL - 4, dT + d.h, d.w + 8, 8);
      ctx.strokeStyle = '#00f0ff';
      ctx.lineWidth = 1;
      ctx.strokeRect(dL - 4, dT - 8, d.w + 8, 8);
      ctx.strokeRect(dL - 4, dT + d.h, d.w + 8, 8);

      // Door barrier retraction (opens upward)
      const currentH = d.h * (1.0 - d.openAmount);
      if (currentH > 2) {{
        // Solid metal door slab
        ctx.fillStyle = '#06101c';
        ctx.fillRect(dL, dT, d.w, currentH);

        // Electric forcefield beam
        ctx.shadowColor = '#ff3344';
        ctx.shadowBlur = 12;
        ctx.strokeStyle = '#ff3344';
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.moveTo(d.x, dT);
        ctx.lineTo(d.x, dT + currentH);
        ctx.stroke();
        ctx.shadowBlur = 0;

        // Energy pulses
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(dL + 2, dT + currentH);
        ctx.lineTo(dL + d.w - 2, dT + currentH);
        ctx.stroke();
      }}
    }}

    // 5. Draw Story Terminal
    const tDist = Math.hypot(this.player.x - this.terminal.x, this.player.y - this.terminal.y);
    ctx.fillStyle = '#061324';
    ctx.fillRect(this.terminal.x - 14, this.terminal.y - 32, 28, 36);
    ctx.strokeStyle = '#00f0ff';
    ctx.lineWidth = 1.5;
    ctx.strokeRect(this.terminal.x - 14, this.terminal.y - 32, 28, 36);

    // Terminal screen glow
    ctx.fillStyle = '#00f0ff';
    ctx.fillRect(this.terminal.x - 10, this.terminal.y - 28, 20, 16);

    // Indicator prompt
    if (tDist < 45) {{
      ctx.fillStyle = '#00f0ff';
      ctx.font = '11px "Share Tech Mono"';
      ctx.textAlign = 'center';
      ctx.fillText('[E] ACCESS ARCHIVE', this.terminal.x, this.terminal.y - 40);
    }}

    // 6. Draw Exit Zone Portal
    const ex = this.exit.x;
    const ey = this.exit.y;
    ctx.save();
    ctx.translate(ex, ey);

    // Outer rotating ring
    ctx.rotate(this.exit.rot);
    ctx.strokeStyle = 'rgba(0, 240, 255, 0.7)';
    ctx.lineWidth = 2.5;
    ctx.setLineDash([8, 6]);
    ctx.beginPath();
    ctx.arc(0, 0, 32, 0, Math.PI * 2);
    ctx.stroke();

    // Inner counter-rotating ring
    ctx.rotate(-this.exit.rot * 2);
    ctx.strokeStyle = 'rgba(255, 119, 0, 0.8)';
    ctx.lineWidth = 2;
    ctx.setLineDash([6, 4]);
    ctx.beginPath();
    ctx.arc(0, 0, 20, 0, Math.PI * 2);
    ctx.stroke();
    ctx.setLineDash([]);

    // Core pulsing diamond
    ctx.fillStyle = '#00f0ff';
    ctx.shadowColor = '#00f0ff';
    ctx.shadowBlur = 16;
    ctx.fillRect(-6, -6, 12, 12);
    ctx.shadowBlur = 0;
    ctx.restore();

    ctx.fillStyle = '#00f0ff';
    ctx.font = '11px "Orbitron"';
    ctx.textAlign = 'center';
    ctx.fillText('EXTRACTION PORTAL', ex, ey + 46);

    // 7. Draw Shadow Clone
    if (this.shadow.active) {{
      const row = this.shadow.isReversed ? 2 : 1;
      const frameCol = this.shadow.animFrame;
      const sx = frameCol * 32;
      const sy = row * 32;

      ctx.save();
      ctx.translate(this.shadow.x, this.shadow.y);
      if (this.shadow.facing < 0) ctx.scale(-1, 1);

      // Shadow aura glow
      ctx.shadowColor = this.shadow.isReversed ? '#d000ff' : '#ff7700';
      ctx.shadowBlur = 14;

      ctx.drawImage(
        spritesheet,
        sx, sy, 32, 32,
        -16, -16, 32, 32
      );
      ctx.shadowBlur = 0;
      ctx.restore();

      // Shadow name tag
      ctx.fillStyle = this.shadow.isReversed ? '#d000ff' : '#ff7700';
      ctx.font = '10px "Share Tech Mono"';
      ctx.textAlign = 'center';
      const label = this.shadow.isReversed ? '<< REVERSED SHADOW' : 'ECHO SHADOW >>';
      ctx.fillText(label, this.shadow.x, this.shadow.y - 24);
    }}

    // 8. Draw Player
    if (!this.player.isDead) {{
      const row = 0; // Row 0 is Player
      const frameCol = this.player.animFrame;
      const sx = frameCol * 32;
      const sy = row * 32;

      ctx.save();
      ctx.translate(this.player.x, this.player.y);
      if (this.player.facing < 0) ctx.scale(-1, 1);

      ctx.shadowColor = '#00f0ff';
      ctx.shadowBlur = 12;

      ctx.drawImage(
        spritesheet,
        sx, sy, 32, 32,
        -16, -16, 32, 32
      );
      ctx.shadowBlur = 0;
      ctx.restore();
    }}

    // 9. Draw Particle System
    for (let i = particles.length - 1; i >= 0; i--) {{
      const p = particles[i];
      p.x += p.vx * 0.016;
      p.y += p.vy * 0.016;
      p.life -= 0.016;

      if (p.life <= 0) {{
        particles.splice(i, 1);
        continue;
      }}

      const alpha = Math.max(0, p.life / p.maxLife);
      ctx.fillStyle = p.color;
      ctx.globalAlpha = alpha;
      ctx.fillRect(p.x - p.size / 2, p.y - p.size / 2, p.size, p.size);
      ctx.globalAlpha = 1.0;
    }}

    // 10. HUD On-Screen Elements
    ctx.textAlign = 'left';
    ctx.fillStyle = '#00f0ff';
    ctx.font = '13px "Orbitron"';
    ctx.fillText(`${{this.data.name}} // ${{this.data.phase}}`, 24, 32);

    ctx.fillStyle = '#8bb3cb';
    ctx.font = '12px "Share Tech Mono"';
    ctx.fillText(this.data.subtitle, 24, 50);

    // Shadow state badge
    let statusText = 'STATUS: RECORDING TRAJECTORY';
    let statusColor = '#00f0ff';
    if (this.shadow.active) {{
      if (this.shadow.isReversed) {{
        statusText = 'STATUS: SHADOW TIME-REVERSED [<<]';
        statusColor = '#d000ff';
      }} else {{
        statusText = 'STATUS: SHADOW REPLAYING [>>]';
        statusColor = '#ff7700';
      }}
    }}
    ctx.fillStyle = statusColor;
    ctx.font = '12px "Share Tech Mono"';
    ctx.fillText(statusText, 24, 70);

    // Red Death Flash Overlay
    if (this.player.isDead) {{
      ctx.fillStyle = `rgba(255, 30, 60, ${{deathTransition * 0.7}})`;
      ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

      ctx.fillStyle = '#ffffff';
      ctx.font = 'bold 24px "Orbitron"';
      ctx.textAlign = 'center';
      ctx.fillText('SIGNAL SEVERED // SEQUENCE TERMINATED', CANVAS_W / 2, CANVAS_H / 2);
      ctx.font = '14px "Share Tech Mono"';
      ctx.fillText('VOID INTEGRITY FAILURE. REBOOTING RECORD...', CANVAS_W / 2, CANVAS_H / 2 + 30);
    }}
  }}
}}

// Active Level Runner
let activeRunner = null;

function showLevelInstructions(data) {{
  const instructions =
    `OPERATIONAL INSTRUCTIONS & CONTROLS:\\n\\n` +
    `  • [W] / [↑]          JUMP across platforms & void\\n` +
    `  • [SPACE]            DEPLOY SHADOW (clone replays past recorded path)\\n` +
    `  • [F]                FLIP (REVERSES time! Rewinds shadow backward)\\n` +
    `  • [R]                RESET timeline sequence\\n` +
    `  • [A] / [D] / [←][→]  MOVE / SPRINT left and right\\n\\n` +
    `MISSION OBJECTIVE:\\n` +
    `Cooperate with your time-reversed shadow to press plates, open security blast doors, and reach the Extraction Portal.`;

  openModal(
    'PROTOCOL BRIEFING // CONTROLS & OBJECTIVE',
    instructions,
    'START GAME [SPACE / ENTER]'
  );
}}

function loadLevel(idx, showBriefing = false) {{
  currentLevelIndex = idx;
  const data = LEVELS[idx];
  activeRunner = new LevelRunner(data);

  // Update top navigation badges
  document.getElementById('hud-level-badge').innerText = data.name;
  document.getElementById('hud-phase-badge').innerText = data.phase;

  // Banner toast
  bannerText = data.name;
  bannerSub = data.subtitle;
  bannerTimer = 2.5;

  // Instructions ONLY appear before Level 1
  if (showBriefing && idx === 1 && gameState === STATE.PLAYING) {{
    showLevelInstructions(data);
  }}
}}

function nextLevel() {{
  if (currentLevelIndex < LEVELS.length - 1) {{
    loadLevel(currentLevelIndex + 1, false);
  }} else {{
    // Campaign complete -> Victory Screen
    gameState = STATE.VICTORY;
    victoryTimer = 0;
    audio.playVictory();
  }}
}}

function restartLevel() {{
  if (activeRunner) {{
    loadLevel(currentLevelIndex, false);
  }}
}}

// --- TITLE MENU & VICTORY DRAWING ---
function drawMenu(ctx, time) {{
  ctx.fillStyle = '#03070d';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  // Background Grid
  ctx.strokeStyle = 'rgba(0, 240, 255, 0.05)';
  for (let x = 0; x < CANVAS_W; x += 40) {{
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, CANVAS_H);
    ctx.stroke();
  }}

  // Title
  ctx.textAlign = 'center';
  ctx.fillStyle = '#00f0ff';
  ctx.font = '900 48px "Orbitron"';
  ctx.shadowColor = '#00f0ff';
  ctx.shadowBlur = 18;
  ctx.fillText('SHADOW.exe', CANVAS_W / 2, 120);
  ctx.shadowBlur = 0;

  // Tagline
  ctx.fillStyle = '#ff7700';
  ctx.font = '16px "Share Tech Mono"';
  ctx.fillText('\"Your shadow remembers everything you regret.\"', CANVAS_W / 2, 155);

  ctx.fillStyle = 'rgba(0, 240, 255, 0.7)';
  ctx.font = '13px "Share Tech Mono"';
  ctx.fillText('HACKATHON THEME REQUIREMENT: REVERSAL PROTOCOL', CANVAS_W / 2, 180);

  // Character Dossier Cards Preview
  const cardY = 220;
  const cardW = 240;
  const cardH = 150;

  // 1. Player Card (Cyan)
  drawCard(ctx, CANVAS_W / 2 - 270, cardY, cardW, cardH, '#00f0ff', 'CYBER PROJECTION', 'PLAYER', 0, time);

  // 2. Echo Ghost Card (Orange)
  drawCard(ctx, CANVAS_W / 2 - 120, cardY, cardW, cardH, '#ff7700', 'PAST RECORDING', 'ECHO CLONE', 1, time);

  // 3. Reversed Ghost Card (Violet)
  drawCard(ctx, CANVAS_W / 2 + 150, cardY, cardW, cardH, '#d000ff', 'REVERSED SIGNAL', 'SHADOW FLIP', 2, time);

  // Menu Options / Buttons Info
  ctx.fillStyle = '#ffffff';
  ctx.font = '18px "Orbitron"';
  ctx.fillText('PRESS [SPACE] OR CLICK BELOW TO INITIALIZE', CANVAS_W / 2, 430);

  // Interactive Button Rects
  drawMenuButton(ctx, CANVAS_W / 2 - 160, 460, 320, 44, '▶ START CAMPAIGN (LEVEL 1)', '#00f0ff');
  drawMenuButton(ctx, CANVAS_W / 2 - 160, 515, 320, 38, '📖 TUTORIAL PROTOCOL', '#ff7700');
  drawMenuButton(ctx, CANVAS_W / 2 - 160, 565, 320, 38, '⚡ STORY ARCHIVES & MANUAL', '#8bb3cb');
}}

function drawCard(ctx, x, y, w, h, color, tag, title, row, time) {{
  ctx.fillStyle = '#06111f';
  ctx.fillRect(x, y, w, h);
  ctx.strokeStyle = color;
  ctx.lineWidth = 1.5;
  ctx.strokeRect(x, y, w, h);

  // Animated sprite in center
  const frame = Math.floor(time * 6) % 8;
  ctx.save();
  ctx.translate(x + w / 2, y + 55);
  ctx.shadowColor = color;
  ctx.shadowBlur = 10;
  ctx.drawImage(spritesheet, frame * 32, row * 32, 32, 32, -24, -24, 48, 48);
  ctx.shadowBlur = 0;
  ctx.restore();

  ctx.fillStyle = color;
  ctx.font = '10px "Share Tech Mono"';
  ctx.fillText(tag, x + w / 2, y + 105);

  ctx.fillStyle = '#ffffff';
  ctx.font = 'bold 12px "Orbitron"';
  ctx.fillText(title, x + w / 2, y + 124);
}}

function drawMenuButton(ctx, x, y, w, h, text, color) {{
  ctx.fillStyle = 'rgba(0, 240, 255, 0.08)';
  ctx.fillRect(x, y, w, h);
  ctx.strokeStyle = color;
  ctx.lineWidth = 1.5;
  ctx.strokeRect(x, y, w, h);

  ctx.fillStyle = color;
  ctx.font = 'bold 13px "Orbitron"';
  ctx.textAlign = 'center';
  ctx.fillText(text, x + w / 2, y + h / 2 + 5);
}}

function drawVictory(ctx, time) {{
  ctx.fillStyle = '#020509';
  ctx.fillRect(0, 0, CANVAS_W, CANVAS_H);

  ctx.textAlign = 'center';
  ctx.fillStyle = '#00f0ff';
  ctx.font = '900 42px "Orbitron"';
  ctx.shadowColor = '#00f0ff';
  ctx.shadowBlur = 20;
  ctx.fillText('SYSTEM ESCAPE COMPLETE', CANVAS_W / 2, 150);
  ctx.shadowBlur = 0;

  ctx.fillStyle = '#ff7700';
  ctx.font = 'bold 22px "Orbitron"';
  ctx.fillText('IDENTITY VERIFIED: YOU ARE THE ECHO.', CANVAS_W / 2, 220);

  ctx.fillStyle = '#e0f4ff';
  ctx.font = '16px "Share Tech Mono"';
  ctx.fillText('The red shadow was the original entity, preserved after system reset.', CANVAS_W / 2, 280);
  ctx.fillText('You were only the projected echo sent forward.', CANVAS_W / 2, 310);
  ctx.fillText('By reversing time and cooperating with your past self,', CANVAS_W / 2, 340);
  ctx.fillText('the recursive containment cycle has shattered.', CANVAS_W / 2, 370);

  drawMenuButton(ctx, CANVAS_W / 2 - 140, 460, 280, 48, 'RETURN TO TITLE MENU', '#00f0ff');
}}

// --- MODAL DIALOG ---
const modalOverlay = document.getElementById('modal-overlay');
const modalTitle = document.getElementById('modal-title');
const modalText = document.getElementById('modal-text');
const modalCloseBtn = document.getElementById('modal-close-btn');

function openModal(title, text, btnText = 'ACKNOWLEDGE [SPACE / ENTER]') {{
  modalTitle.innerText = title;
  modalText.innerText = text;
  modalCloseBtn.innerText = btnText;
  modalOverlay.style.display = 'flex';
}}

function closeModal() {{
  modalOverlay.style.display = 'none';
  keys.left = false;
  keys.right = false;
  keys.jump = false;
  keys.deploy = false;
  keys.flip = false;
  keys.interact = false;
}}

modalCloseBtn.addEventListener('click', closeModal);

// --- INPUT EVENT LISTENERS ---
window.addEventListener('keydown', (e) => {{
  audio.init();

  if (modalOverlay.style.display === 'flex') {{
    if (e.code === 'Space' || e.code === 'Enter' || e.code === 'Escape') {{
      closeModal();
      e.preventDefault();
      return;
    }}
  }}

  if (gameState === STATE.MENU) {{
    if (e.code === 'Space' || e.code === 'Enter') {{
      gameState = STATE.PLAYING;
      loadLevel(1, true);
    }}
    return;
  }}

  if (gameState === STATE.VICTORY) {{
    if (e.code === 'Space' || e.code === 'Enter' || e.code === 'Escape') {{
      gameState = STATE.MENU;
    }}
    return;
  }}

  switch (e.code) {{
    case 'KeyA':
    case 'ArrowLeft':
      keys.left = true;
      break;
    case 'KeyD':
    case 'ArrowRight':
      keys.right = true;
      break;
    case 'KeyW':
    case 'ArrowUp':
      keys.jump = true;
      break;
    case 'Space':
      keys.deploy = true;
      e.preventDefault();
      break;
    case 'KeyF':
    case 'KeyQ':
      keys.flip = true;
      break;
    case 'KeyE':
      keys.interact = true;
      break;
    case 'KeyR':
      restartLevel();
      break;
    case 'Escape':
      gameState = STATE.MENU;
      break;
  }}
}});

window.addEventListener('keyup', (e) => {{
  switch (e.code) {{
    case 'KeyA':
    case 'ArrowLeft':
      keys.left = false;
      break;
    case 'KeyD':
    case 'ArrowRight':
      keys.right = false;
      break;
    case 'KeyW':
    case 'ArrowUp':
      keys.jump = false;
      if (activeRunner && activeRunner.player && activeRunner.player.vy < -160) {{
        activeRunner.player.vy *= 0.55;
      }}
      break;
    case 'Space':
      keys.deploy = false;
      break;
    case 'KeyF':
    case 'KeyQ':
      keys.flip = false;
      break;
    case 'KeyE':
      keys.interact = false;
      break;
  }}
}});

// Canvas Click for Menus
canvas.addEventListener('click', (e) => {{
  audio.init();
  const rect = canvas.getBoundingClientRect();
  const scaleX = CANVAS_W / rect.width;
  const scaleY = CANVAS_H / rect.height;
  const clickX = (e.clientX - rect.left) * scaleX;
  const clickY = (e.clientY - rect.top) * scaleY;

  if (gameState === STATE.MENU) {{
    // Start Campaign button
    if (clickX >= CANVAS_W / 2 - 160 && clickX <= CANVAS_W / 2 + 160 && clickY >= 460 && clickY <= 504) {{
      gameState = STATE.PLAYING;
      loadLevel(1, true);
    }}
    // Tutorial button
    else if (clickX >= CANVAS_W / 2 - 160 && clickX <= CANVAS_W / 2 + 160 && clickY >= 515 && clickY <= 553) {{
      gameState = STATE.PLAYING;
      loadLevel(0);
    }}
    // Manual / Story button
    else if (clickX >= CANVAS_W / 2 - 160 && clickX <= CANVAS_W / 2 + 160 && clickY >= 565 && clickY <= 603) {{
      openModal(
        'SHADOW.exe MANUAL // REVERSAL PROTOCOL',
        'MISSION DIRECTIVE:\\n' +
        '1. [W] or [UP] to JUMP. Space is strictly for Shadow clone deployment.\\n' +
        '2. Walk across pressure plates to open security blast doors.\\n' +
        '3. Press [SPACE] to deploy your Shadow clone, which replays your past steps.\\n' +
        '4. Press [F] for SHADOW FLIP: time-reverses the clone\\'s trajectory, sending it backward to unlock the second airlock door!\\n' +
        '5. Reaching the Extraction Portal triggers sector advance.'
      );
    }}
  }} else if (gameState === STATE.VICTORY) {{
    if (clickX >= CANVAS_W / 2 - 140 && clickX <= CANVAS_W / 2 + 140 && clickY >= 460 && clickY <= 508) {{
      gameState = STATE.MENU;
    }}
  }}
}});

// Top Navigation Buttons
document.getElementById('btn-menu').addEventListener('click', () => {{
  audio.init();
  gameState = STATE.MENU;
}});

document.getElementById('btn-tutorial').addEventListener('click', () => {{
  audio.init();
  gameState = STATE.PLAYING;
  loadLevel(0);
}});

document.getElementById('btn-restart').addEventListener('click', () => {{
  audio.init();
  restartLevel();
}});

document.getElementById('btn-sound').addEventListener('click', () => {{
  audio.init();
  const on = audio.toggleMute();
  document.getElementById('btn-sound').innerText = on ? 'SOUND: ON' : 'SOUND: OFF';
}});

document.getElementById('btn-fullscreen').addEventListener('click', () => {{
  const elem = document.getElementById('game-container');
  if (!document.fullscreenElement) {{
    elem.requestFullscreen().catch(() => {{}});
  }} else {{
    document.exitFullscreen().catch(() => {{}});
  }}
}});

// --- MAIN GAME LOOP ---
let lastTime = performance.now();

function gameLoop(now) {{
  const dt = Math.min(0.05, (now - lastTime) / 1000);
  lastTime = now;
  const timeSec = now / 1000;

  ctx.save();

  // Screen shake
  if (screenShake > 0) {{
    const ox = (Math.random() - 0.5) * screenShake * 2;
    const oy = (Math.random() - 0.5) * screenShake * 2;
    ctx.translate(ox, oy);
    screenShake = Math.max(0, screenShake - dt * 25);
  }}

  if (gameState === STATE.PLAYING) {{
    if (activeRunner) {{
      if (modalOverlay.style.display !== 'flex') {{
        activeRunner.update(dt);

        // Death transition timer
        if (activeRunner.player.isDead) {{
          deathTransition -= dt;
          if (deathTransition <= 0) {{
            restartLevel();
          }}
        }}
      }}
      activeRunner.draw(ctx);
    }}
  }} else if (gameState === STATE.MENU) {{
    drawMenu(ctx, timeSec);
  }} else if (gameState === STATE.VICTORY) {{
    drawVictory(ctx, timeSec);
  }}

  ctx.restore();

  requestAnimationFrame(gameLoop);
}}

// Initialize
loadLevel(1);
gameState = STATE.MENU;
requestAnimationFrame(gameLoop);

</script>
</body>
</html>
'''

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"index.html generated successfully! File size: {len(html_content)} bytes")
