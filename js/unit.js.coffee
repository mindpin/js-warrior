class Unit
  remove_flag: false

  constructor: (@space)->

  property: (prop, desc)->
    Object.defineProperty @, prop, desc

  getter: (prop, func)->
    @property prop, get: func

  remove: ->
    @remove_flag = true

jQuery.extend window,
  Unit: Unit
