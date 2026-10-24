## Procedural neon audio synthesizer for SHADOW.exe.
## Generates pure retro-futuristic sound effects at runtime without external audio assets.
extends Node

var _player_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 8
var _pool_idx: int = 0

var sfx_move: AudioStreamWAV
var sfx_deploy: AudioStreamWAV
var sfx_flip: AudioStreamWAV
var sfx_plate: AudioStreamWAV
var sfx_door: AudioStreamWAV
var sfx_victory: AudioStreamWAV


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create pool of players
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_player_pool.append(p)

	_generate_all_sfx()


func _get_player() -> AudioStreamPlayer:
	var p := _player_pool[_pool_idx]
	_pool_idx = (_pool_idx + 1) % POOL_SIZE
	return p


func play_move() -> void:
	if sfx_move:
		var p := _get_player()
		p.stream = sfx_move
		p.volume_db = -12.0
		p.play()


func play_shadow_deploy() -> void:
	if sfx_deploy:
		var p := _get_player()
		p.stream = sfx_deploy
		p.volume_db = -6.0
		p.play()


func play_shadow_flip() -> void:
	if sfx_flip:
		var p := _get_player()
		p.stream = sfx_flip
		p.volume_db = -4.0
		p.play()


func play_plate_activate() -> void:
	if sfx_plate:
		var p := _get_player()
		p.stream = sfx_plate
		p.volume_db = -6.0
		p.play()


func play_door_open() -> void:
	if sfx_door:
		var p := _get_player()
		p.stream = sfx_door
		p.volume_db = -8.0
		p.play()


func play_victory() -> void:
	if sfx_victory:
		var p := _get_player()
		p.stream = sfx_victory
		p.volume_db = -4.0
		p.play()


# ── Sound Generation ────────────────────────────────────────────────────────

func _create_wav(samples: PackedByteArray, sample_rate: int = 22050) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = samples
	return wav


func _generate_all_sfx() -> void:
	var rate := 22050
	sfx_move = _gen_tone(rate, 0.04, 340.0, 480.0, 0.3)
	sfx_deploy = _gen_arpeggio(rate, [260.0, 390.0, 520.0, 780.0], 0.05, 0.4)
	sfx_flip = _gen_flip_sweep(rate, 0.22)
	sfx_plate = _gen_tone(rate, 0.06, 550.0, 220.0, 0.5)
	sfx_door = _gen_tone(rate, 0.12, 180.0, 320.0, 0.35)
	sfx_victory = _gen_arpeggio(rate, [330.0, 440.0, 550.0, 660.0, 880.0], 0.08, 0.5)


func _gen_tone(rate: int, duration: float, freq_start: float, freq_end: float, volume: float) -> AudioStreamWAV:
	var num_samples := int(rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(num_samples)
	var phase := 0.0

	for i in range(num_samples):
		var t := float(i) / float(num_samples)
		var freq := lerpf(freq_start, freq_end, t)
		phase += (freq * TAU) / float(rate)
		# Square wave with soft envelope
		var env := 1.0 - t
		var wave := 1.0 if sin(phase) > 0.0 else -1.0
		var sample := int(clampf(wave * env * volume * 127.0 + 128.0, 0.0, 255.0))
		bytes[i] = sample

	return _create_wav(bytes, rate)


func _gen_arpeggio(rate: int, notes: Array[float], note_dur: float, volume: float) -> AudioStreamWAV:
	var total_dur := note_dur * float(notes.size())
	var num_samples := int(rate * total_dur)
	var bytes := PackedByteArray()
	bytes.resize(num_samples)
	var phase := 0.0
	var samples_per_note := int(rate * note_dur)

	for i in range(num_samples):
		var note_idx := clampi(i / samples_per_note, 0, notes.size() - 1)
		var freq: float = notes[note_idx]
		phase += (freq * TAU) / float(rate)
		var note_t := float(i % samples_per_note) / float(samples_per_note)
		var env := 1.0 - (note_t * 0.7)
		var wave := sin(phase)
		var sample := int(clampf(wave * env * volume * 127.0 + 128.0, 0.0, 255.0))
		bytes[i] = sample

	return _create_wav(bytes, rate)


func _gen_flip_sweep(rate: int, duration: float) -> AudioStreamWAV:
	# Reverse sweep that drops then zaps up — futuristic reversal sound
	var num_samples := int(rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(num_samples)
	var phase := 0.0

	for i in range(num_samples):
		var t := float(i) / float(num_samples)
		# Frequency goes high -> low -> sharp high
		var freq := 880.0 * (1.0 - t) + 120.0 if t < 0.7 else lerpf(120.0, 1100.0, (t - 0.7) / 0.3)
		phase += (freq * TAU) / float(rate)
		var env := sin(t * PI)
		# Mixed triangle/square wave
		var wave := (2.0 * absf(2.0 * (phase / TAU - floorf(phase / TAU + 0.5))) - 1.0)
		var sample := int(clampf(wave * env * 0.45 * 127.0 + 128.0, 0.0, 255.0))
		bytes[i] = sample

	return _create_wav(bytes, rate)
