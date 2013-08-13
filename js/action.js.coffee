class Attack
  constructor: (@damage)->

class MeleeAttack extends Attack
class RangedAttack extends Attack
class MagicAttack extends Attack
class ShurikenAttack extends Attack

class Interact
  constructor: (@warrior)->

class Explode

jQuery.extend window,
  Attack: Attack
  MeleeAttack: MeleeAttack
  RangedAttack: RangedAttack
  MagicAttack: MagicAttack
  Explode: Explode
  ShurikenAttack: ShurikenAttack
