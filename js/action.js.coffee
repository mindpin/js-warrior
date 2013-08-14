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
  perform: ->

class Idle extends Action
class Walk extends Action
  constructor: (@actor, @direction, @target_space)->

  perform: ->
    @actor.direction = @direction
    @target_space || @target_space = @actor.space.get_relative_space(@direction, 1)
    return if !@target_space || @target_space.character && @target_space.constructor == Wall # TODO extract this condition to space
    @actor.update_link(@target_space)
    @actor.action_info = new ActionInfo(@)

class Rest extends Action
  constructor: (@actor, @hp_change)->
class Attack extends Action
  constructor: (@actor, @direction, @target_space)->
    @hp_change = -@actor.damage
    @target_space && @target = @target_space.character
  
  perform: ->
    @actor.direction = @direction
    @target.take_attack(@) if @target
    @actor.action_info = new ActionInfo(@)

class Interact extends Action
  constructor: (@warrior)->

class Explode extends Action


class MeleeAttack extends Attack
class Shot extends Attack
class MagicAttack extends Attack
class ShurikenAttack extends Attack


jQuery.extend window,
  Rest: Rest
  Idle: Idle
  Walk: Walk
  Interact: Interact
  ActionInfo: ActionInfo
  Attack: Attack
  MeleeAttack: MeleeAttack
  Shot: Shot
  MagicAttack: MagicAttack
  Explode: Explode
  ShurikenAttack: ShurikenAttack
