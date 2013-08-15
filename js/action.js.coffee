class ActionInfo extends Base
  constructor: (@action)->
    @action = new Idle if !@action
    @type = @action.class_name()  
    @target = @action.target
    @target_space = @action.target_space
    @landing_point = @action.landing_point
    @direction = @action.direction
    @hp_change = @action.hp_change

class Action extends Base
  steps: ->

  perform: ->
    @steps()
    if @actor
      @actor.direction = @direction if @direction
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
    @hp_change = -@actor.damage
    @target_space = @actor.space.get_relative_space(@direction, distance)
    @target_space && @target = @target_space.character
  
  steps: ->
    @target.take_attack(@) if @target

class Interact extends Action
  constructor: (@actor)->
    @target_space = @actor.space
    @item = @target_space.item
    @shurikens = @target_space.shurikens

  steps: ->
    @item.take_interact(@) if @item
    @shurikens.each (shuriken)=>
      shuriken.take_interact(@)

class Explode extends Action
  constructor: (@actor)->

  steps: ->
    @actor.get_attack_area().each (s)=>
      s.units.each (u)=>
        u.remove() if u.destroyable

class Shot extends Attack
class Magic extends Attack
class Dart extends Attack
  constructor: (@actor, @direction, @target_space, @landing_space)->
    super(arguments...)
    @hp_change = -@actor.shuriken_damage

  steps: ->
    shuriken = @actor.space.level.warrior.draw_a_shuriken()
    @target && @target.take_attack(@)
    @target_space.link(shuriken)

jQuery.extend window,
  Rest: Rest
  Idle: Idle
  Walk: Walk
  Interact: Interact
  ActionInfo: ActionInfo
  Attack: Attack
  Shot: Shot
  Magic: Magic
  Explode: Explode
  Dart: Dart
