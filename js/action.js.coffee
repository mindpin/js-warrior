class ActionInfo
  constructor: (@type, @target, @damage, @landing_point, @direction)->

class Attack
  constructor: (@damage)->

  class_name: ->
    @constructor.name.toLowerCase()

class MeleeAttack extends Attack
class RangedAttack extends Attack
class MagicAttack extends Attack
class ShurikenAttack extends Attack

class Interact
  constructor: (@warrior)->

class Explode

jQuery.extend window,
  Interact: Interact
  ActionInfo: ActionInfo
  Attack: Attack
  MeleeAttack: MeleeAttack
  RangedAttack: RangedAttack
  MagicAttack: MagicAttack
  Explode: Explode
  ShurikenAttack: ShurikenAttack
