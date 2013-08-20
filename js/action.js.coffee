class Action extends Base
  constructor: ->
    @type = @class_name()

  steps: ->

  perform: ->
    if @actor
      @actor.direction = @direction if @direction
      @actor.level.add_action(@)
    @steps()

  is_dart: ->
    @class_name() == "dart"
    
class Walk extends Action
  constructor: (@actor, @direction)->
    super()
    @target_space = @actor.space.get_relative_space(direction, 1)

  blocked: ->
    warrior_blocked = @target_space.item &&
      @actor.is_warrior() &&
      !@target_space.has_door()

    !@target_space || @target_space.is_blocked() || warrior_blocked

  steps: ->
    return if @blocked()
    @actor.update_link(@target_space)

class Rest extends Action
  constructor: (@actor, @hp_change)->
    super()

  steps: ->
    @actor.health_delta(@hp_change)

class Attack extends Action
  constructor: (@actor, @direction, @distance)->
    super()
    @hp_change    = -@actor.damage
    @target_space = @actor.space.get_relative_space(@direction, distance)
    @target_space && @target = @target_space.character
  
  steps: ->
    @target.take_attack(@) if @target

class Interact extends Action
  constructor: (@actor, @direction)->
    super()
    @target_space = @actor.space.get_relative_space(@direction, 1)
    @item         = @target_space.item
    @lock         = @target_space.lock

  steps: ->
    @actor.direction = @direction
    @item.take_interact(@) if @item

class Excited extends Action
  constructor: (@actor)->
    super()

  steps: ->
    @actor.excited = true

class Explode extends Action
  constructor: (@actor)->
    super()
    @hp_change = -10000
    @targets = @actor.get_attack_area()
      .map (s)=> 
        s.units().filter((u)=> u.destroyable)
      .reduce((a, b)=> a.concat b)

  steps: ->
    @targets.forEach (u)=>
      u.health_delta(@hp_change) if u.is_character
      u.remove() if u.destroyable

class Shot extends Attack
class Magic extends Attack
class Dart extends Attack
  bla = 0

  constructor: (@actor, @direction, @distance)->
    super(arguments...)
    @hp_change = -@actor.shuriken_damage

  steps: ->
    item = @target_space.item

    if !item
      @shuriken.update_link(@target_space)
    else
      if item.is_shuriken()
        @target_space.item.count += @shuriken.count
      else
        @target_space.item.remove()
        @shuriken.update_link(@target_space)

    @target && @target.take_attack(@)
    bla +=1


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
