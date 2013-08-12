class Attack
  constructor: (@damage)->

class MeleeAttack extends Attack
class RangedAttack extends Attack
class MagicAttack extends Attack

class Interact
  constructor: (@warrior)->

class Explode
