class ActionInfo
  #constructor: (@type, @target, @damage, @landing_point, @direction)->

  constructor: (@action)->
    @action = new Idle if !@action
    @type = @action.class_name()  
    @target = @action.target
    @landing_point = @action.landing_point
    @direction = @action.direction
    @damage = @action.damage

class BaseAction
  set: (field, value)->
    @[field] = value
    @

  class_name: ->
    @constructor.name.toLowerCase()

class Idle extends BaseAction
class Walk extends BaseAction

class Attack extends BaseAction
  constructor: (@damage)->


class MeleeAttack extends Attack
class RangedAttack extends Attack
class MagicAttack extends Attack
class ShurikenAttack extends Attack

class Interact extends BaseAction
  constructor: (@warrior)->

class Explode extends BaseAction

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
