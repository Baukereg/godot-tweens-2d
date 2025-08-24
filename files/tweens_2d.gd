extends Node


## IMPORTANT: make sure this path is set to the right location of the shader.
const COLOR_OVERLAY_SHADER = preload("res://tweens_2D_color_overlay.gdshader")


## Helper function used to scale animation variables to respect the target's scale.
func _get_amplitude(target) -> float:
	return max(abs(target.scale.x), abs(target.scale.y))
	
	
## Creates an animation that scales the target down to zero.
## [code]duration: float = 0.4[/code][br]
func add_disappear(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"duration": 0.4
	})
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(target, "scale", Vector2.ZERO, options.duration)
	return tween

	
## Creates an animation that scales the target from zero to its default scale.
## [code]default_scale: Vector2 = Vector2.ONE[/code][br]
## [code]duration: float = 1.0[/code][br]
func add_appear(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"default_scale": Vector2.ONE,
		"duration": 1.0
	})
	tween.tween_callback(func(): target.scale = Vector2.ZERO)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(target, "scale", options.default_scale, options.duration)
	return tween
	
	
## Creates an animation that pulses like a heartbeat. Options:[br]
## [code]amount: float = 1.3[/code][br]
## [code]duration: float = 0.4[/code][br]
func add_pulse(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"amount": 1.3,
		"duration": 0.4
	})
	var default_scale:Vector2 = target.scale
	var up_scale:Vector2 = default_scale * options.amount
	
	var duration_up:float = options.duration * 0.5
	var duration_down:float = options.duration * 0.5

	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(target, "scale", up_scale, duration_up)
	tween.tween_property(target, "scale", default_scale, duration_down)
	return tween
	
	
## Creates an animation that bobs the target in a given direction. Options:[br]
## [code]distance: float = 20.0[/code][br]
## [code]duration: float = 0.4[/code][br]
## [code]direction: Vector2 = Vector2.UP[/code]
func add_bob(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"distance": 20.0,
		"duration": 0.4,
		"direction": Vector2.UP
	})
	assert([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].has(options.direction),
		"direction should be either Vector2.UP, Vector2.DOWN, Vector2.LEFT or Vector2.RIGHT")
	
	var default_position:Vector2 = target.position
	var offset:Vector2 = Vector2.ZERO
	match options.direction:
		Vector2.UP: offset.y = -options.distance
		Vector2.DOWN: offset.y = options.distance
		Vector2.LEFT: offset.x = -options.distance
		Vector2.RIGHT: offset.x = options.distance
	offset *= _get_amplitude(target)
	
	var duration_up:float = options.duration * 0.5
	var duration_down:float = options.duration * 0.5
	
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(target, "position", default_position + offset, duration_up)
	tween.tween_property(target, "position", default_position, duration_down)
	return tween


## Creates an animation that makes the target bounce in a given direction. Options:[br]
## [code]distance: float = 20.0[/code][br]
## [code]duration: float = 0.8[/code][br]
## [code]direction: Vector2 = Vector2.UP[/code]
func add_bounce(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"distance": 20.0,
		"duration": 0.8,
		"direction": Vector2.UP
	})
	assert([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].has(options.direction),
		"direction should be either Vector2.UP, Vector2.DOWN, Vector2.LEFT or Vector2.RIGHT")
	
	var default_position:Vector2 = target.position
	var default_scale:Vector2 = target.scale
	var up_offset:Vector2 = Vector2.ZERO
	var down_offset:Vector2 = Vector2.ZERO
	match options.direction:
		Vector2.UP:
			up_offset.y = -options.distance
			down_offset.y = options.distance * 0.9
		Vector2.DOWN:
			up_offset.y = options.distance
			down_offset.y = -options.distance * 0.9
		Vector2.LEFT:
			up_offset.x = -options.distance
			down_offset.x = options.distance * 0.9
		Vector2.RIGHT:
			up_offset.x = options.distance
			down_offset.x = -options.distance * 0.9
	var amp:float = _get_amplitude(target)
	up_offset *= amp
	down_offset *= amp

	var duration_up:float = options.duration * 0.3
	var duration_down:float = options.duration * 0.3
	var duration_rebound:float = options.duration * 0.2
	var duration_settle:float = options.duration * 0.2
	
	# Up.
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "position", default_position + up_offset, duration_up)
	match options.direction:
		Vector2.UP, Vector2.DOWN: tween.parallel().tween_property(target, "scale", default_scale * Vector2(0.9, 1.1), duration_up)
		Vector2.LEFT, Vector2.RIGHT: tween.parallel().tween_property(target, "scale", default_scale * Vector2(1.1, 0.9), duration_up)
	# Down.
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(target, "position", default_position + down_offset, duration_down)
	match options.direction:
		Vector2.UP, Vector2.DOWN: tween.parallel().tween_property(target, "scale", default_scale * Vector2(1.2, 0.8), duration_down)
		Vector2.LEFT, Vector2.RIGHT: tween.parallel().tween_property(target, "scale", default_scale * Vector2(0.8, 1.2), duration_down)
	# Rebound.
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(target, "position", default_position + up_offset * 0.15, duration_rebound)
	match options.direction:
		Vector2.UP, Vector2.DOWN: tween.parallel().tween_property(target, "scale", default_scale * Vector2(1.0, 1.1), duration_rebound)
		Vector2.LEFT, Vector2.RIGHT: tween.parallel().tween_property(target, "scale", default_scale * Vector2(1.1, 1.0), duration_rebound)
	# Settle.
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "position", default_position, duration_settle)
	tween.parallel().tween_property(target, "scale", default_scale, duration_settle)
	return tween
	
	
## Creates an animation that makes the target wobble from right to left. Options:[br]
## [code]angle_degrees: float = 30.0[/code][br]
## [code]duration: float = 1.0[/code][br]
## [code]snaps: int = 3[/code]
func add_wobble(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"angle_degrees": 30.0,
		"duration": 1.0,
		"snaps": 3
	})
	var default_rotation:float = target.rotation_degrees
	var step:float = options.duration / float(options.snaps * 2 + 1)
	
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	var deg:float = options.angle_degrees
	for i in range(options.snaps):
		var dir:float = 1.0 if (i % 2) == 0 else -1.0
		tween.tween_property(target, "rotation_degrees", default_rotation + dir * deg, step)
		deg *= 0.6  # Decay factor.
	tween.tween_property(target, "rotation_degrees", default_rotation, step)
	return tween


## Creates an animation that squeezes the target like a squeeze ball. Options:[br]
## [code]duration: float = 0.8[/code][br]
## [code]max_scale: float = 1.2[/code][br]
## [code]min_scale: floar = 0.2[/code]
func add_squeeze(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"duration": 0.8,
		"max_scale": 1.2,
		"min_scale": 0.2
	})
	var default_scale:Vector2 = target.scale
	
	var horizontal_scale:Vector2 = Vector2(options.max_scale, options.min_scale) * default_scale
	var vertical_scale:Vector2 = Vector2(options.min_scale, options.max_scale * 1.2) * default_scale
	
	var duration_down:float = options.duration * 0.2
	var duration_up:float = options.duration * 0.2
	var duration_settle:float = options.duration * 0.6
	
	# Down.
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(target, "scale", horizontal_scale, duration_down)
	# Up.
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target, "scale", vertical_scale, duration_up)
	# Settle.
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(target, "scale", default_scale, duration_settle)
	return tween


## Creates an animation that spins the target around. Options:[br]
## [code]direction: int = 1[/code][br]
## [code]duration: float = 0.8[/code][br]
## [code]keep_base: bool = false[/code][br]
## [code]num_of_spins: int = 1[/code]
func add_spin(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"direction": 1,
		"duration": 0.8,
		"keep_base": false,
		"num_of_spins": 1
	})
	assert([-1, 1].has(options.direction), "direction should be either -1 or 1")
	
	var default_rotation:float = target.rotation_degrees if options.keep_base else 0
	target.rotation_degrees = default_rotation
	
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(target, "rotation_degrees", default_rotation + (360 * options.num_of_spins) * options.direction, options.duration)
	tween.tween_callback(func(): target.rotation_degrees = default_rotation)
	return tween


## Creates an animation that flips the target like a card. Options:[br]
## [code]axis: Vector2 = Vector2.UP[/code][br]
## [code]duration: float = 0.6[/code][br]
## [code]halfway_callback: Callable[/code][br]
func add_flip(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"axis": Vector2.UP,
		"duration": 0.6,
		"halfway_callback": Callable()
	})
	assert([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].has(options.axis),
		"axis should be either Vector2.UP, Vector2.DOWN, Vector2.LEFT or Vector2.RIGHT")
	
	var default_scale:Vector2 = target.scale
	
	var duration_close:float = options.duration * 0.5
	var duration_open:float = options.duration * 0.5
	
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "scale", options.axis.abs() * default_scale, duration_close)
	tween.tween_callback(options.halfway_callback)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(target, "scale", default_scale, duration_open)
	return tween
	
	
## Creates an animation that shakes the target around. Options:[br]
## [code]range: float = 10.0[/code][br]
## [code]duration: float = 1.0[/code][br]
## [code]intval: float = 0.02[/code][br]
## [code]decay: float = 1.0[/code][br]
func add_shake(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"range": 10.0,
		"duration": 1.0,
		"intval": 0.02,
		"decay": 1.0
	})
	var center:Vector2 = target.position
	var num_of_moves:int = max(1, int(round(options.duration / max(0.0001, options.intval))))
	var shake_range:float = options.range * _get_amplitude(target)
	
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	for i in range(num_of_moves):
		var dir:Vector2 = Vector2.UP.rotated(randf() * TAU)
		var next:Vector2 = center + dir * shake_range
		shake_range *= options.decay
		tween.tween_property(target, "position", next, options.intval)
	tween.tween_property(target, "position", center, options.intval)
	return tween
	
	
## Creates an animated color flash over the target.
## A new shader material will be assigned to the target, and removed afterwards. Options:[br]
## [code]flash_color: Color = Color.WHITE[/code][br]
## [code]amount: float = 0.8[/code][br]
## [code]fade_duration: float = 0.2[/code][br]
## [code]hold_duration: float = 0[/code][br]
func add_flash(tween:Tween, target, options:Dictionary = {}) -> Tween:
	options.merge({
		"flash_color": Color.WHITE,
		"amount": 0.8,
		"fade_duration": 0.2,
		"hold_duration": 0
	})
	assert(target.material == null, "target should not have a material assigned yet")
	
	tween.tween_callback(func():
		target.material = ShaderMaterial.new()
		target.material.shader = COLOR_OVERLAY_SHADER
		target.material.set_shader_parameter("color", options.flash_color)
	)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(func(value: float): target.material.set_shader_parameter("amount", value), 0.0, options.amount, options.fade_duration * 0.35)
	if options.hold_duration > 0:
		tween.tween_interval(options.hold_duration)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_method(func(value: float): target.material.set_shader_parameter("amount", value), options.amount, 0.0, options.fade_duration * 0.65)
	tween.tween_callback(func(): target.material = null)
	
	return tween
	
	
## Creates a loop within a longer sequence of chained tweens.
## The "main" tween is paused and a seperate loop tween is created.
## It's passed to the callback, for any tweens to be added.
## Once the loop tween has finished, the main tween will resume.
func create_loop(tween:Tween, loops:int, callback:Callable):
	tween.tween_callback(func():
		tween.pause()
		var loop_tween:Tween = get_tree().create_tween().set_loops(loops)
		callback.call(loop_tween)
		await loop_tween.finished
		tween.play()
	)
