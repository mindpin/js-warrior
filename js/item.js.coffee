class Item extends Unit
  @type = 'item'
  constructor: (@space, @count)->
    @count ||= 1
    super(@space)

  is_shuriken: ->
    @class_name() == "shuriken"

  is_wall: ->
    @class_name() == "wall"

  take_attack: (atk)->
    if @is_shuriken() && atk.shuriken
      atk.target_space.item.count += atk.shuriken.count
      atk.shuriken.remove()
    else
      @destroyable && @remove()
      atk.shuriken && atk.shuriken.update_link(atk.target_space)

  remove: ->
    super()
    @space && @space.item = null
    
class Pickable extends Item
  destroyable: true
  picked:      true

  constructor: (@space, @count)->
    @picked = false if @space
    super(@space, @count)

  take_interact: (interact)->
    @into_inventory(interact.actor)
    @update_link()

  into_inventory: (actor)->
    actor.item_change(@constructor, @count)
    @remove()

class Fixed extends Item
  constructor: (@space)->
    super(@space)

  take_interact: (interact)->
    @transit(interact) if @transit

class Door extends Fixed
  blowupable: false
class Wall extends Fixed
  destroyable: true
class Lock extends Fixed
  blowupable: false
  transit: (action)->
    action.actor.consume(Key)
    @remove()

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
