class ActionInfo extends Base
  constructor: (@action)->
    @action = new Idle if !@action
    @type = @action.class_name()  
    @target = @action.target
    @target_space = @action.target_space
    @landing_point = @action.landing_point
    @direction = @action.direction
    @damage = @action.damage

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
class Attack extends Action
  constructor: (@actor, @direction, @target_space)->
    @damage = @actor.damage
    @target = @target_space.character
  
  perform: ->
    @actor.direction = @direction
    @target.take_attack(@) if @target
    @actor.action_info = new ActionInfo(@)

class Interact extends Action
  constructor: (@warrior)->

class Explode extends Action


class MeleeAttack extends Attack
class RangedAttack extends Attack
class MagicAttack extends Attack
class ShurikenAttack extends Attack


jQuery.extend window,
  Idle: Idle
  Walk: Walk
  Interact: Interact
  ActionInfo: ActionInfo
  Attack: Attack
  MeleeAttack: MeleeAttack
  RangedAttack: RangedAttack
  MagicAttack: MagicAttack
  Explode: Explode
  ShurikenAttack: ShurikenAttack
