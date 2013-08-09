class Item extends Unit
  constructor: (@space)->
    
class Pickable extends Item
  picked: false

  constructor: (@space)->
    super(@space)

  take_interact: (interact)->
    @into_inventory(interact.warrior)
    @space.unlink(@)

  into_inventory: (warrior)->
    warrior.items.push @
    @picked = true

class Fixed extends Item
  constructor: (@space)->
    super(@space)

  take_interact: (interact)->
    @transit(interact) if @transit

class Door extends Fixed
class Wall extends Fixed
class Lock extends Fixed
  is_open: false

  transit: (interact)->
    interact.warrior.consume(Key)
    @is_open = true

class Diamond extends Pickable
class Key extends Pickable

class Shuriken extends Pickable
  max_num = 0

  @max_num: ->
    max_num

  picked: true

  outof_inventory: (warrior)->
    index = warrior.shurikens.indexOf @
    warrior.shurikens.splice(index, 1)
    @picked = false

jQuery.extend window,
  Door: Door
  Lock: Lock
  Wall: Wall
  Key: Key
  Diamond: Diamond
  Shuriken: Shuriken
