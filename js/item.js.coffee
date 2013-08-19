class Item extends Unit
  constructor: (@space, @count)->
    @count ||= 0
    super(@space)

  is_shuriken: ->
    @class_name() == "shuriken"

  remove: ->
    super()
    if @is_shuriken()
      @space.shurikens = @space.shurikens
        .filter((shuriken)=> @is(shuriken))
      return
    @space.item = null
    
class Pickable extends Item
  destroyable: true
  picked: true

  constructor: (@space)->
    if @space
      super(@space)
      @picked = false

  take_interact: (interact)->
    @into_inventory(interact.actor)
    @update_link()

  into_inventory: (actor)->
    actor.item_change(@constructor, @count)
    @remove()
    @picked = true

class Fixed extends Item
  constructor: (@space)->
    super(@space)

  take_interact: (interact)->
    @transit(interact) if @transit

class Door extends Fixed
class Wall extends Fixed
  destroyable: true
class Lock extends Fixed
  is_open: false

  transit: (action)->
    action.actor.consume(Key)
    @is_open = true

class Diamond extends Pickable
class Key extends Pickable

class Shuriken extends Pickable
  is: (shuriken)->
    @ == shuriken

  outof_inventory: (warrior)->
    warrior.item_change(@constructor, -@count)
    @picked = false

jQuery.extend window,
  Item: Item
  Pickable: Pickable
  Fixed: Fixed
  Door: Door
  Lock: Lock
  Wall: Wall
  Key: Key
  Diamond: Diamond
  Shuriken: Shuriken
