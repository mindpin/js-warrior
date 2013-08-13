class Character extends Unit
  is_character: true
  destroyable: true
  remove_tag: false
  action_info: new ActionInfo("idle")
  direction: "down"
  damage: 3
  health: 0

  constructor: (@space)->
    super(@space)

  in_range: (space)->
    result = @get_attack_area().some (s)->
      space == s

  blocked: (space)->
    @space.range(space).some (s)->
      (s.item && s.item.constructor == Wall) || s.character

  attack: (direction, distance)->
    @ensure_not_played =>
      !distance && distance = 1
      attack = new Attack(@damage)
      @direction = direction
      target = @space.get_relative_space(direction, distance)
      target.receive(attack)
      @action_info = new ActionInfo(attack.class_name(), target.character, @damage, undefined, @direction)

  take_attack: (atk)->
    @health = @health - atk.damage
    if @health <= 0
      @remove()
      @remove_tag = true

  ensure_not_played: (action)->
    throw new Error("一回合不能行动两次") if @played
    throw new Error("行动没有重置") if @action_info.type != "idle"
    action()
    @played = true

  reset_action: ->
    @action_info = new ActionInfo("idle")

  reset_played: ->
    @played = false

  get_attack_area: ->
    [
      [-1, 1], [0, 1], [1, 1],
      [-1, 0], [1, 0],
      [-1, -1], [0, -1], [1, -1]
    ].map((i)=> @space.relative(i...)).filter((s)=> s != null)

  per_turn_strategy: ->

  play: (strategy)->
    return if @remove_tag
    strategy && strategy(@)
    @per_turn_strategy()
    @reset_played()
  is_warrior: ->
    @class_name() == 'warrior'

class Warrior extends Character
  items: []
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
        enemy_space = @shuriken_range.filter((s)=> s.character)[0]
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
      target = @space.get_relative_space(direction, 1)
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

  feel: (direction)->
    @space.get_relative_space(direction, 1)

class Enemy extends Character
  health: 12
  damage: 3
  range: 1
  attack_method: MeleeAttack

  warrior_in_range: ->
    @in_range(@level.warrior.space)

  per_turn_strategy: ->
    direction = @space.get_direction(@level.warrior.space)
    target = @space.get_relative_space(direction, @range)
    if @warrior_in_range() && !@blocked(target)
      @direction = direction
      @attack(@direction)

class Slime extends Enemy
  health: 10
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
