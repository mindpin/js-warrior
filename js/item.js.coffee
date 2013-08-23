class Item extends Unit
  interactable: true

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
      @blowupable  && atk.class_name() == "explode" && @remove()
      @destroyable && @remove()
      atk.shuriken && atk.shuriken.update_link(atk.target_space)

  remove: ->
    super()
    @space && @space.item = null
    
class Pickable extends Item
  destroyable: true
  blowupable:  true
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
  dartable:        "block"
  blowupable:      false
  walkthroughable: true
  interactable:    false

class Wall extends Fixed
  dartable:     "block"
  blowupable:   true
  interactable: false

class Lock extends Fixed
  dartable:   "block"
  blowupable: false

  transit: (action)->
    action.actor.consume(Key)
    @remove()

class Diamond extends Pickable
class Key extends Pickable

class Shuriken extends Pickable
  dartable: "through"

  is: (shuriken)->
    @ == shuriken

  outof_inventory: (warrior)->
    warrior.item_change(@constructor, -@count)
    @picked = false

jQuery.extend window,
  Item:     Item
  Pickable: Pickable
  Fixed:    Fixed
  Door:     Door
  Lock:     Lock
  Wall:     Wall
  Key:      Key
  Diamond:  Diamond
  Shuriken: Shuriken
