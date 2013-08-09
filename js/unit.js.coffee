class Unit
  constructor: (@space)->

  property: (prop, desc)->
    Object.defineProperty @, prop, desc

  getter: (prop, func)->
    @property prop, get: func

jQuery.extend window,
  Unit: Unit
