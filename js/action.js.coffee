class ActionInfo extends Base
  constructor: (@action)->
    @action        = new Idle if !@action
    @type          = @action.class_name()  
    @target        = @action.target
    @targets       = @action.targets
    @target_space  = @action.target_space
    @landing_point = @action.landing_point
    @direction     = @action.direction
    @hp_change     = @action.hp_change
    @lock          = @action.lock

class Action extends Base
  steps: ->

  perform: ->
    @steps()
    if @actor
      @actor.direction   = @direction if @direction
      @actor.action_info = new ActionInfo(@)
    
class Idle extends Action
class Walk extends Action
  constructor: (@actor, @direction)->
    @target_space = @actor.space.get_relative_space(direction, 1)

  steps: ->
    @actor.direction = @direction
    return if !@target_space || @target_space.is_blocked()
    @actor.update_link(@target_space)

class Rest extends Action
  constructor: (@actor, @hp_change)->

  steps: ->
    @actor.health_delta(@hp_change)

class Attack extends Action
  constructor: (@actor, @direction, @distance)->
    @hp_change    = -@actor.damage
    @target_space = @actor.space.get_relative_space(@direction, distance)
    @target_space && @target = @target_space.character
  
  steps: ->
    @target.take_attack(@) if @target

class Interact extends Action
  constructor: (@actor)->
    @target_space = @actor.space
    @item         = @target_space.item
    @lock         = @target_space.lock
    @shurikens    = @target_space.shurikens
    @targets      = [@item, @lock].concat(@shurikens).filter((i)=> i)

  steps: ->
    @targets.forEach (i)=>
      i.take_interact(@)

class Excited extends Action
  constructor: (@actor)->

  steps: ->
    @actor.excited = true

class Explode extends Action
  constructor: (@actor)->
    @hp_change = -10000
    @targets = @actor.get_attack_area()
      .map (s)=> 
        s.units().filter((u)=> u.destroyable)
      .reduce((a, b)=> a.concat b)

  steps: ->
    @actor.get_attack_area().forEach (s)=>
      s.units().forEach (u)=>
        u.health_delta(@hp_change) if u.is_character
        u.remove() if u.destroyable

class Shot extends Attack
class Magic extends Attack
class Dart extends Attack
  constructor: (@actor, @direction, @distance)->
    super(arguments...)
    @hp_change = -@actor.shuriken_damage

  steps: ->
    shuriken = @actor.space.level.warrior.draw_a_shuriken()
    @target_space.link(shuriken)
    @target && @target.take_attack(@)

jQuery.extend window,
  Rest:       Rest
  Idle:       Idle
  Walk:       Walk
  Interact:   Interact
  ActionInfo: ActionInfo
  Attack:     Attack
  Shot:       Shot
  Magic:      Magic
  Excited:    Excited
  Explode:    Explode
  Dart:       Dart
