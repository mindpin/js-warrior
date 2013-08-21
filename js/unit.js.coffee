# blowupable:      可被爆炸摧毁
# destroyable:     可被攻击摧毁
# dartable:        对手里剑攻击的反应, 可为"hit", "block", "through"
# walkthroughable: 可步行穿过

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
  blowupable:      true
  dartable:        "hit"
  remove_flag:     false
  walkthroughable: false

  constructor: (@space)->
    @level = @space.level if @space

  remove: ->
    @remove_flag = true

  type: ->
    return "item" if @ instanceof Item
    "character" if @ instanceof Character

  update_link: (target)->
    @space.unlink(@) if @space
    target && target.link(@)

  is_enemy: ->
    @is_character && @class_name() != 'warrior'


jQuery.extend window,
  Base: Base
  Unit: Unit
