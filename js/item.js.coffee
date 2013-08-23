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
    @blowupable  && atk.class_name() == "explode" && @remove()
    @destroyable && @remove()
    atk.shuriken && atk.shuriken.update_link(atk.target_space)

  remove: ->
    super()
    @space && @space.item = null
    
  can_interact: ->
    @interactable

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
  interactable: false
  constructor: (@space)->
    super(@space)

  take_interact: (interact)->
    @transit(interact) if @transit

class Door extends Fixed
  dartable:        "block"
  blowupable:      false
  walkthroughable: true

class Wall extends Fixed
  dartable:     "block"
  blowupable:   true

class Lock extends Fixed
  dartable:   "block"
  blowupable: false

  transit: (action)->
    action.actor.consume(Key)
    @remove()

  can_interact: (actor)->
    !!actor && actor.count("key") > 0

class Diamond extends Pickable
class Key extends Pickable

class Shuriken extends Pickable
  dartable: "through"

  is: (shuriken)->
    @ == shuriken

  outof_inventory: (warrior)->
    warrior.item_change(@constructor, -@count)
    @picked = false

  take_attack: (atk)->
    return super(atk) if !atk.shuriken
    atk.target_space.item.count += atk.shuriken.count
    atk.shuriken.remove()


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
