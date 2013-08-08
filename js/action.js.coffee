class Attack
  constructor: (@damage)->

class Interact
  constructor: (@warrior)->

class MeleeAttack extends Attack

class RangedAttack extends Attack
  ranged: true
