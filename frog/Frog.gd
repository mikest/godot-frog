# Copyright (c) 2025 Mike Estee
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
# to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# If you prefer, you may choose to use the CC0 License instead.
# https://wiki.creativecommons.org/wiki/CC0

class_name Frog extends CharacterBody3D

@onready var player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

# accessor for readability
var playback: AnimationNodeStateMachinePlayback:
	get: return animation_tree["parameters/playback"]

const Hop := &"Hop"
const Idle := &"Idle"
const TurnRight := &"TurnRight"
const TurnLeft := &"TurnLeft"

# for tracking what loop we're in
var current_anim : StringName = &""

func _ready() -> void:
	playback.travel(Hop)

func _physics_process(delta: float) -> void:
	quaternion = quaternion * animation_tree.get_root_motion_rotation()
	velocity = quaternion * animation_tree.get_root_motion_position() / delta
	
	# use gravity when idling so we come to rest on the ground.
	# if our frog jumps off a ledge, he won't fall without this.
	if current_anim != Hop:
		velocity.y += -ProjectSettings.get_setting("physics/3d/default_gravity")
	move_and_slide()


# simple random jump direction loop
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == Hop:
		if randi_range(0,1):
			playback.travel(TurnRight)
		else:
			playback.travel(TurnLeft)

	elif anim_name == TurnRight or anim_name == TurnLeft:
		playback.travel(Hop)

	elif anim_name == Idle:
		playback.travel(Hop)


# remember what animation state we're playing
func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	current_anim = anim_name
