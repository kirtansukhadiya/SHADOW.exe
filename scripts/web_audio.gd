## Port of the web build's CyberAudio (Web Audio oscillators) for SHADOW.exe.
## Each effect is synthesized once into a WAV with the same waveform,
## frequency sweep and gain envelope as index.html.
extends Node

const RATE := 22050

var muted: bool = false

var _sfx: Dictionary = {}
var _pool: Array[AudioStreamPlayer] = []
var _pool_idx: int = 0
var _drone: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 8:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)

	# freq(t) and gain(t) callables mirror the exponential/linear ramps on web.
	_sfx.jump = _render(0.14, [[0.0, "square", _exp_f(150, 420, 0.12), _exp_g(0.08, 0.13)]])
	var deploy_notes: Array = []
	for i in 4:
		deploy_notes.append([i * 0.04, "sine", _const_f([220.0, 330.0, 440.0, 660.0][i]), _exp_g(0.06, 0.12), 0.14])
	_sfx.deploy = _render(0.30, deploy_notes)
	_sfx.flip = _render(0.36, [[0.0, "saw", func(t): return 800.0 * pow(120.0 / 800.0, minf(t, 0.18) / 0.18) if t < 0.18 else 120.0 * pow(600.0 / 120.0, minf(t - 0.18, 0.14) / 0.14), _exp_g(0.12, 0.35)]])
	_sfx.plate = _render(0.11, [[0.0, "triangle", _exp_f(540, 270, 0.08), _exp_g(0.12, 0.10)]])
	_sfx.door = _render(0.30, [[0.0, "saw", func(t): return lerpf(90.0, 180.0, minf(t / 0.25, 1.0)), _exp_g(0.09, 0.28)]])
	_sfx.death = _render(0.42, [[0.0, "square", _exp_f(90, 30, 0.35), _exp_g(0.18, 0.40)]])
	var chord: Array = []
	for i in 4:
		chord.append([i * 0.08, "triangle", _const_f([440.0, 554.37, 659.25, 880.0][i]), _exp_g(0.14, 0.70), 0.75])
	_sfx.victory = _render(1.0, chord)

	_drone = AudioStreamPlayer.new()
	_drone.stream = _render_drone()
	add_child(_drone)
	_drone.play()


func toggle_mute() -> bool:
	muted = !muted
	if muted:
		_drone.stop()
	else:
		_drone.play()
	return not muted


func play(name: String) -> void:
	if muted or not _sfx.has(name):
		return
	var p := _pool[_pool_idx]
	_pool_idx = (_pool_idx + 1) % _pool.size()
	p.stream = _sfx[name]
	p.play()


# ── Synthesis ────────────────────────────────────────────────────────────────

func _exp_f(f0: float, f1: float, ramp: float) -> Callable:
	return func(t): return f0 * pow(f1 / f0, minf(t, ramp) / ramp)


func _const_f(f: float) -> Callable:
	return func(_t): return f


func _exp_g(g0: float, ramp: float) -> Callable:
	return func(t): return g0 * pow(0.001 / g0, minf(t, ramp) / ramp)


static func _wave(kind: String, phase: float) -> float:
	var p := fposmod(phase, 1.0)
	match kind:
		"square": return 1.0 if p < 0.5 else -1.0
		"saw": return 2.0 * p - 1.0
		"triangle": return 4.0 * absf(p - 0.5) - 1.0
	return sin(p * TAU)


## voices: [start, wave, freq_fn, gain_fn, (optional) duration]
func _render(length: float, voices: Array) -> AudioStreamWAV:
	var n := int(length * RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	for v in voices:
		var start: float = v[0]
		var dur: float = v[4] if v.size() > 4 else length - start
		var phase := 0.0
		var i0 := int(start * RATE)
		for i in range(i0, mini(n, i0 + int(dur * RATE))):
			var t := float(i - i0) / RATE
			phase += float(v[2].call(t)) / RATE
			buf[i] += _wave(v[1], phase) * float(v[3].call(t))
	return _to_wav(buf, false)


## Ambient drone: 55 Hz sawtooth through a 140 Hz lowpass at gain 0.025, looped.
func _render_drone() -> AudioStreamWAV:
	var n := RATE  # 1 s = exactly 55 cycles, so the loop is seamless
	var buf := PackedFloat32Array()
	buf.resize(n)
	var a := 1.0 - exp(-TAU * 140.0 / RATE)
	var y := 0.0
	for pass_i in 2:  # first pass settles the filter
		for i in n:
			y += a * (_wave("saw", 55.0 * i / RATE) - y)
			if pass_i == 1:
				buf[i] = y * 0.025
	return _to_wav(buf, true)


func _to_wav(buf: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		bytes.encode_s16(i * 2, int(clampf(buf[i], -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = bytes
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = buf.size()
	return wav
