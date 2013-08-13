class Character extends Unit
  is_character: true
  destroyable: true
  defeated: false
  attack_method: Attack
  action_info: "idle"
  damage: 3
  health: 0

  constructor: (@space)->
    super(@space)

  in_range: (space)->
    @get_attack_area().some (s)->
      space == s

  blocked: (space)->
    @space.range(space).some (s)->
      (s.item && s.item.constructor == Wall) || s.character

  attack: (space)->
    @ensure_not_played =>
      @action_info = "idle"
      return if !@in_range(space)
      return if @blocked(space)
      attack = new @attack_method(@damage)
      space.receive(attack)
      @action_info = new ActionInfo(attack.class_name(), space.character, @damage)

  take_attack: (atk)->
    @health = @health - atk.damage
    if @health <= 0
      @remove()
      @defeated = true

  target_space: (direction, distance)->
    switch direction
      when "left-up"    then @space.relative(-distance, -distance)
      when "left-down"  then @space.relative(-distance, distance)
      when "right-up"   then @space.relative(distance, -distance)
      when "right-down" then @space.relative(distance, distance)
      when "up"         then @space.relative(0, -distance)
      when "down"       then @space.relative(0, distance)
      when "left"       then @space.relative(-distance, 0)
      when "right"      then @space.relative(distance, 0)
      else throw new Error("Invalid direction!")

  ensure_not_played: (action)->
    throw new Error("一回合不能行动两次") if @played
    @action_info = "idle"
    action()
    @played = true

  reset_played: ->
    @played = false

  get_attack_area: ->
    [
      [-1, 1], [0, 1], [1, 1],
      [-1, 0], [1, 0],
      [-1, -1], [0, -1], [1, -1]
    ].map((i)=> @space.relative(i...)).filter((s)=> s != null)

class Warrior extends Character
  items: []
  direction: "down"
  health: 16
  attack_method: MeleeAttack

  constructor: (@space)->
    super(@space)
    @shurikens = [new Shuriken for i in [1..Shuriken.max_num]]
    @shuriken_range = @get_shuriken_range()
    @getter "keys",     -> @select_items Key
    @getter "diamonds", -> @select_items Diamond

  interact: ->
    @ensure_not_payed ->
      @space.receive(new Interact(@))

  get_shuriken_range: ->
    [
      [0, 1], [0, 2], [0, 3],
      [0, -1], [0, -2], [0, -3],
      [1, 0], [2, 0], [3, 0],
      [-1, 0], [-2, 0], [-3, 0]
    ].map (i)=>
      @space.relative(i...)

  in_shuriken_range: (space)->
    @shuriken_range.some (s)-> s == space

  shuriken_blocked: (space)->
    @shuriken_range.some (s)->
      s.item &&
      s.item.constructor == Wall ||
      s.character
    
  shuriken: (space)->
    @ensure_not_played =>
      return if !@in_shuriken_range(space)
      shuriken_attack = new ShurikenAttack(@damage)
      if @shuriken_blocked(space)
        enemy_space = @shuriken_range.filter((s)=> s.character && s.character != @)[0]
        if enemy_space
          @action_info = new ActinInfo(shuriken_attack.class_name(), enemy_space.character, @damage, enemy_space)

          return enemy_space.receive(shuriken_attack)

        wall_space = @shuriken_range.filter((s)=> s.constructor == Wall)[0]
        range = @space.range(wall_space)
        drop_space = range[rang.length - 2]
        if drop_space
          @action_info = new ActinInfo(shuriken_attack.class_name(), undefined, undefined, drop_space)
          return drop_space.receive(shuriken_attack)
      space.receive(shuriken_attack)

  draw_a_shuriken: ->
    shuriken = @shurikens[0]
    shuriken.outof_inventory(@)
    shuriken

  move: (direction)->
    @direction = direction
    @ensure_not_played =>
      target = @target_space(direction, 1)
      return if target.character
  
      @action_info = new ActionInfo("walk")
      @action_info.direction = direction
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

  play: (strategy)->
    strategy && strategy(@)
    @reset_played()

class Enemy extends Character
  health: 12
  damage: 3
  attack_method: MeleeAttack

  warrior_in_range: ->
    @in_range(@level.warrior.space)

  per_turn_strategy: ->
    if @warrior_in_range()
      @attack(@level.warrior.space)

  play: ->
    @per_turn_strategy()
    @reset_played()

class Slime extends Enemy
class Tauren extends Enemy

class Wizard extends Enemy
  attack_method: MagicAttack

  get_attack_area: ->
    [
      [-1, 1], [0, 1], [1, 1],
      [-1, 0], [1, 0],
      [-1, -1], [0, -1], [1, -1],
      [-2, 0], [0, 2], [2, 0], [0, -2]  
    ].map (i)=>
      @space.relative(i...)

class Archer extends Enemy
  attack_method: RangedAttack

  get_attack_area: ->
    [
      [0, 1], [0, 2], [0, 3],
      [0, -1], [0, -2], [0, -3],
      [1, 0], [2, 0], [3, 0],
      [-1, 0], [-2, 0], [-3, 0]
    ].map (i)=>
      @space.relative(i...)

class Creeper extends Enemy
  excited: false

  get_excited_area: ->
    [
      [-1, 0], [0, 1], [1, 0], [0, -1]
    ].map (i)=>
      @space.relative(i...)

  warrior_in_excited_area: ->
    @excited_area.some (s)->
      @warrior.space == s

  constructor: (space)->
    super(space)
    @excited_area = @get_excited_area()

  set_excited: ->
    @ensure_not_played =>
      @excited = true
      @action_info = new ActionInfo("excited")

  explode: ->
    @attack_area.each (s)->
      explode = new Explode
      s.receive explode
      characters = @attack_area.filter((s)=> s.character).map((s)=> s.character)
      @action_info = new ActionInfo(explode.class_name(), characters)

  per_turn_strategy: ->
    if @warrior_in_excited_area()
      return @set_excited() if !@excited
      @explode()


jQuery.extend window,
  Character: Character
  Enemy: Enemy
  Slime: Slime
  Tauren: Tauren
  Creeper: Creeper
  Wizard: Wizard
  Archer: Archer
  Warrior: Warrior
