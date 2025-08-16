# Tweens2D for Godot 4

Tiny, reusable and chainable tweens for **Godot 4** to add *juice* to any `Control` or `Node2D`.

The tweens are opinionated and preconfigured with sensible defaults. Great for game jams to easily make the UI pop.

[🎬 Watch the demo on youtube](https://www.youtube.com/watch?v=AZzs3Lm6kNE)


## Install

1. Copy the files into your project wherever you want (e.g. `res://addons/tweens_2d/`).
2. Check `tweens_2d.gd` and make sure `COLOR_OVERLAY_SHADER` is set to the right location of the shader.

    ```gdscript
    const COLOR_OVERLAY_SHADER = preload("res://addons/tweens_2d/tweens_2D_color_overlay.gdshader")
    ```
3. Autoload `tweens_2d.gd` so you can access the script everywhere.


## Examples

```gdscript
# Squeeze a button on focus.
$Button.focus_entered.connect(func():
    Tweens2D.add_squeeze(get_tree().create_tween(), $Button)
)

# Animate a logo (infinite loop).
Tweens2D.add_wobble(get_tree().create_tween(), $Logo, 10, 5).set_loops(0)

# Chain animations. The icon will appear, pulse 3 times, then disappears.
var tween = get_tree().create_tween()
Tweens2D.add_appear(tween, $Icon)
Tweens2D.create_loop(tween, 3, func(loop_tween):
    Tweens2D.add_pulse(loop_tween, $Icon)
)
Tweens2D.add_disappear(tween, $Icon)
```


## Concept

All helper functions are mutators: they don’t create new `Tween` instances. Instead, they take an existing `Tween` as the first argument and append their animation steps to it. Because they mutate the passed-in tween in place, you can chain multiple helpers on the same tween without reassigning.

Use `create_loop` to repeat a subsection of the tween chain without looping the entire tween. See the example below.


## 🔎 API cheatsheet

See `tweens_2d.gd` for exact signatures & defaults.

- `add_appear(tween, target, default_scale, duration)`
- `add_disappear(tween, target, duration)`
- `add_pulse(tween, target, amount, duration)`[^1]
- `add_bob(tween, target, distance, duration, direction)`[^1]  
- `add_bounce(tween, target, distance, duration, direction)`
- `add_wobble(tween, target, angle_degrees, duration, snaps)`
- `add_squeeze(tween, target, scale_amount, duration)`
- `add_spin(tween, target, direction, duration, keep_base)`
- `add_flip(tween, target, direction, duration, halfway_callback)`
- `add_shake(tween, target, range, duration, intval, decay)`
- `add_flash(tween, target, flash_color, amount, fade_duration, hold_duration)`
- `create_loop(tween, loops, callback)`

[^1]: Suitable for looping.


## Usage notes

- **Pivot/center.** For `Control`, set `pivot_offset = size * 0.5` so scale/rotation effects are centered. For `Sprite2D`, ensure `centered` is enabled (or set a custom pivot if needed).
- **Interactive nodes.** On widgets like `Button`, avoid tweening the button node itself; it can trigger an unexpected `mouse_exited`. Tween a visual child instead (e.g., a `TextureRect` or `Label`). If needed, set the child’s `mouse_filter = MOUSE_FILTER_IGNORE`.
- **Color shader.** The included shader tints any `CanvasItem` toward a color (used by `add_flash`). It’s generic and reusable outside `Tweens2D`, and it respects existing `modulate/self_modulate`.


## 📄 License

MIT License  
Copyright (c) 2025 Bauke Regnerus
