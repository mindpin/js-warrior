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
    @remove_flag = true

  type: ->
    switch @constructor
      when Warrior, Wizard, Archer, Creeper, BigMonster, SmallMonster
        "character"
      when Shuriken, Door, Wall, Lock, Diamond, Key
        "item"

  class_name: ->
    @constructor.name.toLowerCase()

jQuery.extend window,
  Unit: Unit
