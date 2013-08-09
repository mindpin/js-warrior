class Character extends Unit
  defeated = new Event("defeated")

  is_character: true
  defeated: false
  health: 0

  constructor: (@space)->
    super(@space)
    @addEventListener "defeated", (e)->
      @space.level.destroy(@)
      @space = null
      @defeated: true

  inrange_spaces: (direction)->
    @target_space(direction, i) for i in [1..range]

  blocked: (direction)->
    @inrange_spaces(direction)

  inflict: (direction, distance, damage)->
    @ensure_not_played =>
      @target_space(direction, distance).receive(new Attack(damage))

  get_attack: (atk)->
    @health = @health - atk.damage
    @dispatchEvent(defeated) if @health <= 0

  target_space: (direction, distance)->
    switch direction
      when "up"    then @space.relative(0, distance)
      when "down"  then @space.relative(0, -distance)
      when "left"  then @space.relative(-distance, 0)
      when "right" then @space.relative(distance, 0)
      else throw new Error("Invalid direction!")

  ensure_not_played: (action)->
    throw new Error("一回合不能行动两次") if @played
    action()
    @played = true

  reset_played: ->
    @played = false

class Enemy extends Character
  range: 0

class Warrior extends Character
  flying_axes: []
  items: []

  constructor: (@space)->
    super(@space)
    @getter "keys",     -> @select_items Key
    @getter "diamonds", -> @select_items Diamonds

  interact: ->
    @ensure_not_payed ->
      @space.receive(new Interact(@))

  move: (direction)->
    @ensure_not_played =>
      target = @target_space(direction, 1)
      return if target.character
  
      @space.clear("character")
      @space = target
      @space.set_character(@)

  consume: (type)->
    index = @items.indexOf first(type)
    return if index == -1
    @items.splice(index, 1)

  first: (type)->
    @select_items(type)[0]

  select_items: (type)->
    @items.filter (i)->
      i.constructor == type

  left: ->
    @move("left")

  right: ->
    @move("right")

  up: ->
    @move("up")

  down: ->
    @move("down")

class MeleeEnemy extends Enemy
  range: 1
class RangedEnemy extends Enemy
  range: 3

class SmallMonster extends MeleeEnemy
class BigMonster extends MeleeEnemy

class Wizard extends RangedEnemy
class Archer extends RangedEnemy

jQuery.extend window,
  Character: Character
  SmallMonster: SmallMonster
  BigMonster: BigMonster
  Warrior: Warrior
