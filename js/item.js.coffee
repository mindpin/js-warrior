class Item extends Unit
  interactable: true

  @type = 'item'
  constructor: (@space, @count)->
    @count ||= 1
    super(@space)

  take_attack: (atk)->
    @destroyable && @remove()

  take_explode: (atk)->
    @blowupable && @remove()

  take_dart: (atk)->
    @destroyable && @remove()
    atk.shuriken.update_link(atk.target_space)

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

  take_dart: (atk)->
    atk.target_space.item.count += atk.shuriken.count
    atk.shuriken.remove()

class Klubok extends Item
  pushable: true
  tossable: true
  slapable: true

  take_push: (push)->
    push.target.update_link(push.target_dest_space())
    
  take_toss: (toss)->
    toss.target.update_link(toss.target_dest_space())

  take_slap: (slap)->
    slap.target.update_link(slap.target_dest_space())

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
