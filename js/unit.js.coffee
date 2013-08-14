class Base
  set: (field, value)->
    @[field] = value
    @

  property: (prop, desc)->
    Object.defineProperty @, prop, desc

  getter: (prop, func)->
    @property prop, get: func

  class_name: ->
    name = @constructor.name
    re   = /[A-Z]/g
    fn   = (c)-> "_#{c}"
    underscored = name[0] + name.slice(1, name.length).replace(/[A-Z]/g, fn)
    underscored.toLowerCase()

class Unit extends Base
  remove_flag: false

  constructor: (@space)->
    @level = @space.level

  remove: ->
    @remove_flag = true

  type: ->
    return "item" if @ instanceof Item
    "character" if @ instanceof Character

  update_link: (target)->
    @space.unlink(@)
    target && target.link(@)


jQuery.extend window,
  Base: Base
  Unit: Unit
