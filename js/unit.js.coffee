class Unit
  remove_flag: false

  constructor: (@space)->
    @level = @space.level
    @warrior = @level.warrior

  property: (prop, desc)->
    Object.defineProperty @, prop, desc

  getter: (prop, func)->
    @property prop, get: func

  remove: ->
    @remove_tag = true

  type: ->
    return "item" if @ instanceof Item
    "character" if @ instanceof Character

  update_link: (target)->
    @space.unlink(@)
    target && target.link(@)

  class_name: ->
    @constructor.name.toLowerCase()

jQuery.extend window,
  Unit: Unit
