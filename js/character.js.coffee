class Character extends Unit
  defeated = new Event("defeated")

  is_character: true
  range: 1
  health: 0
  played: false

  constructor: (@space)->
    super(@space)
    addEventListener "defeated", (e)->
      @space.clear("character")
      @space = null

  inflict: (direction, range, damage)->
    ensure_not_played =>
      target_space(direction, range).receive(new Attack(damage))

  get_attack: (atk)->
    @health = @health - atk.damage
    dispatchEvent(defeated) if @health <= 0

  target_space: (direction, distance)->
    switch direction
      when "up"    then @space.relative(0, distance)
      when "down"  then @space.relative(0, -distance)
      when "left"  then @space.relative(-distance, 0)
      when "right" then @space.relative(distance, 0)
      else throw new Error("Invalid direction!")

  ensure_not_played: (action)->
    throw new Error("一回合不能行动两次") if played
    action()
    @played = true

  reset_played: ->
    @played = false

class Enemy extends Character
class Warrior extends Character
  move: (direction)->
    ensure_not_played =>
      @space.character = null
      @space = target_space(direction, 1)

class SmallMonster extends Enemy
class BigMonster extends Enemy

jQuery.extend window,
  Character: Character
  SmallMonster: SmallMonster
  BigMonster: BigMonster
  Warrior: Warrior
