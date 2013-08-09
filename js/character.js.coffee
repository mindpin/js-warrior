class Character extends Unit
  is_character: true
  defeated: false
  health: 0

  constructor: (@space)->
    super(@space)
    @get_attack_area()

  get_attack_area: ->
    @attack_area = []

  blocked: (direction)->
    @inrange_spaces

  inflict: (direction, distance, damage)->
    @ensure_not_played =>
      @target_space(direction, distance).receive(new Attack(damage))

  get_attack: (atk)->
    @health = @health - atk.damage
    if @health <= 0
      @remove()
      @defeated = true

  target_space: (direction, distance)->
    switch direction
      when "up"    then @space.relative(0, -distance)
      when "down"  then @space.relative(0, distance)
      when "left"  then @space.relative(distance, 0)
      when "right" then @space.relative(-distance, 0)
      else throw new Error("Invalid direction!")

  ensure_not_played: (action)->
    throw new Error("一回合不能行动两次") if @played
    action()
    @played = true

  reset_played: ->
    @played = false

class Enemy extends Character
  range: 0

  warrior: ->
    @space.level.warrior

  warrior_in_range: ->
    @attack_area.indexOf(@warrior().space) != -1


class Warrior extends Character
  shurikens: []
  items: []
  direction: "down"

  constructor: (@space)->
    super(@space)
    @getter "keys",     -> @select_items Key
    @getter "diamonds", -> @select_items Diamonds

  interact: ->
    @ensure_not_payed ->
      @space.receive(new Interact(@))

  move: (direction)->
    @direction = direction
    @ensure_not_played =>
      target = @target_space(direction, 1)
      return if target.character
  
      @space.unlink(@)
      target.link(@)

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
  class_name: ->
    "slime"

class BigMonster extends MeleeEnemy
  class_name: ->
    "tauren"

class Wizard extends RangedEnemy
class Archer extends RangedEnemy

class Creeper extends RangedEnemy
  excited: false

jQuery.extend window,
  Character: Character
  SmallMonster: SmallMonster
  BigMonster: BigMonster
  Creeper: Creeper
  Wizard: Wizard
  Archer: Archer
  Warrior: Warrior
