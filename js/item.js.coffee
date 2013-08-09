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
class Intrigue extends Fixed
  is_open: false

  transit: (interact)->
    interact.warrior.consume(Key)
    @is_open = true

  class_name: ->
    "lock"

class Diamond extends Pickable
class Key extends Pickable

class FlyingAxe extends Pickable
  max_num = 0

  @max_num: ->
    max_num

  picked: true

  outof_inventory: (warrior)->
    index = warrior.flying_axes.indexOf @
    warrior.flying_axes.splice(index, 1)
    @picked = false

  class_name: ->
    "hand-sword"

jQuery.extend window,
  Door: Door
  Intrigue: Intrigue
  Wall: Wall
  Key: Key
  Diamond: Diamond
  FlyingAxe: FlyingAxe
  
