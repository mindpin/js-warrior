class Action extends Base
  constructor: (@actor, @direction)->
    @type     = @class_name()
    @distance = 1 if !@distance

  steps: ->

  perform: ->
    @set_target_space()
    return @fail() if @is_fail()
    @actor_ops().set_target()
    @steps()

  is_dart: ->
    @class_name() == "dart"
    
  set_target_space: ->
    if @actor && @direction
      @target_space = @actor.space.get_relative_space(@direction, @distance)

  set_target: ->
    if @target_space
      @target = @target_space.character
      !@target && @target = @target_space.item
    @

  actor_ops: ->
    if @actor
      @actor.direction = @direction if @direction
      @actor.level.add_action(@)
    @

  is_fail: ->
    false

  fail: ->
    @failed = true
    @actor.idle(@) if @actor
      
class Idle extends Action
  constructor: (@actor, @action)->
    super(@actor)
    @direction = @action.direction if @action

class Walk extends Action
  is_fail: ->
    !@target_space.can_walk()

  steps: ->
    @actor.update_link(@target_space)

class Rest extends Action
  constructor: (@actor, @hp_change)->
    super(@actor)

  is_fail: ->
    @actor.health >= @actor.max_health

  steps: ->
    @actor.health_delta(@hp_change)

class Attack extends Action
  constructor: (@actor, @direction, @distance)->
    super(arguments...)
    @hp_change = -@actor.damage
  
  is_fail: ->
    @target_space.units().some((u)=> !u.destroyable)

  steps: ->
    @target.take_attack(@) if @target

class Interact extends Action
  is_fail: ->
    @item = @target_space.item
    !(@item && @item.can_interact(@actor))

  steps: ->
    @item.take_interact(@) if @item

class Excited extends Action
  steps: ->
    @actor.excited = true

class Explode extends Action
  constructor: (@actor)->
    super(@actor)
    @hp_change = -10000
    @targets = @actor.get_attack_area()
      .filter((s)=> s.has_blowupable())
      .map((s)=> s.units())
      .reduce((a, b)=> a.concat b)

  steps: ->
    @targets.forEach (u)=> u.take_explode(@)

class Shot extends Attack
class Magic extends Attack
class Dart extends Attack
  constructor: (@actor, @direction, @distance)->
    super(arguments...)
    @hp_change = -@actor.shuriken_damage

  set_target_space: ->
    super()
    range = @actor.space.range(@target_space).concat([@target_space])
    blocked_space = range.filter((s)=> s.dart_stop())[0]

    if blocked_space #如果被阻挡
      if blocked_space.dart_hit()   #如果被可攻击物
        @target_space = blocked_space
      if blocked_space.dart_block() #如果被阻止物阻挡
        @target_space = [@actor.space]
          .concat(@actor.space.range(blocked_space))
          .pop()

    @landing_space = @target_space

  is_fail: ->
    !@actor.has_shuriken() ||
    @target_space == @actor.space

  steps: ->
    @shuriken = @actor.consume(Shuriken)
    @shuriken.update_link(@target_space) if !@target
    @target.take_dart(@) if @target

class Push extends Action
  target_dest_space: ->
    @target_space.get_relative_space(@direction, @distance)

  steps: ->
    @target.take_push(@)

  is_fail: ->
    !@target_space.item || !@item_dest_space().can_walk()

class Slap extends Action
  target_dest_space: ->
    @target_space.get_padding_space(@direction)

  steps: ->
    @target.take_slap(@)

  is_fail: ->
    !@target_space.item || @item_dest_space() == @target_space

class Toss extends Action
  target_dest_space: ->
    spaces = @actor.level.empty_spaces
    spaces[Math.floor(Math.random() * spaces.length)]

  is_fail: ->
    !@target_dest_space()

  steps: ->
    @target.take_toss(@)

jQuery.extend window,
  Rest:       Rest
  Walk:       Walk
  Interact:   Interact
  Attack:     Attack
  Shot:       Shot
  Magic:      Magic
  Excited:    Excited
  Explode:    Explode
  Dart:       Dart
  Idle:       Idle
  Push:       Push
  Slap:       Slap
  Toss:       Toss
