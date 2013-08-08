class Item extends Unit
  interacted = new Event("interacted")

  constructor: (@space)->
    
class Pickable extends Item
  constructor: (@space)->
    super(@space)
    addEventListener "interacted", (e)->
      @space.clear("item")
      @space = null

  take_interact: (interact)->
    interact.warrior.items.push interact
    dispatchEvent(interacted)

class Fixed extends Item
  constructor: (@space)->
    addEventListener "interacted", (e)->
      @space.clear("item")
      @space = null

    super(@space)

  get_interact: (interact)->
    # do sth.
    dispatchEvent(interacted)

class Door extends Fixed
class Intrigue extends Fixed

class Diamond extends Pickable
class Key extends Pickable

class FlyingAxe extends Pickable
  max_num = 0

  @max_num: ->
    max_num

jQuery.extend window,
  Door: Door
