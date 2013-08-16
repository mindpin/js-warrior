class Character extends Unit
  is_character: true
  destroyable: true
  remove_flag: false
  attack_action: Attack
  action_info: new ActionInfo
  direction: "down"
  damage: 3
  health: 0

  constructor: (@space, shuriken_count, key_count)->
    super(@space)
    @max_health = @health

  in_range: (space)->
    @get_attack_area().some (s)=>
      space == s

  blocked: (space)->
    @space.range(space).some (s)=>
      s.is_blocked()

  attack: (direction, distance)->
    @ensure_not_played =>
      !distance && distance = 1
      (new @attack_action(@, direction, distance)).perform()

  health_delta: (delta)->
    result   = @health + delta
    exceeded = result > @max_health
    @health  = if exceeded then @max_health else result 

  take_attack: (atk)->
    @health_delta(atk.hp_change)
    if @health <= 0
      @remove() 

  ensure_not_played: (action)->
    throw new Error("一回合不能行动两次") if @played
    throw new Error("行动没有重置") if @action_info.type != "idle"
    action()
    @played = true

  reset_action: ->
    @action_info = new ActionInfo

  reset_played: ->
    @played = false

  get_attack_area: ->
    [
      [0, 1], [-1, 0], [1, 0], [0, -1]
    ].map((i)=> @space.relative(i...)).filter((s)=> s)

  per_turn_strategy: ->

  play: (strategy)->
    return if @remove_flag
    strategy && strategy(@)
    @per_turn_strategy()
    @reset_played()

  is_warrior: ->
    @class_name() == 'warrior'

  remove: ->
    super()
    @space.character = null


class Warrior extends Character
  items: []
  damage: 5
  shuriken_damage: 5
  health: 20

  constructor: (@space, shuriken_count, key_count)->
    super(@space)
    @shurikens = Shuriken.make(shuriken_count)
    @items = @items.concat(Key.make(key_count))
    @getter "keys",     -> @select_items Key
    @getter "diamonds", -> @select_items Diamond

  interact: ->
    @ensure_not_payed ->
      (new Interact(@)).perform()

  get_shuriken_range: ->
    [
      [0, 1], [0, 2], [0, 3],
      [0, -1], [0, -2], [0, -3],
      [1, 0], [2, 0], [3, 0],
      [-1, 0], [-2, 0], [-3, 0]
    ].map((i)=> @space.relative(i...)).filter((s)=> s)

  in_shuriken_range: (space)->
    @get_shuriken_range().some (s)=> s == space

  can_dart_space: (space)->
    @in_shuriken_range(space) && @has_shuriken()

  dart: (direction, distance)->
    @ensure_not_played =>
      dart = new Dart(@, direction, distance)

      return if !@can_dart_space(dart.target_space) #无法投掷
      range = @space.range(dart.target_space)

      if @blocked(dart.target_space) #如果被阻挡
        enemy_space = range.filter((s)=> s.character)[0]
        space = enemy_space if enemy_space #如果被怪阻挡

        wall_space = range.filter((s)=> s.constructor == Wall)[0]
        drop_space = @space.range(wall_space)[rang.length - 1]
        space = drop_space if drop_space #如果被墙阻挡
      else
        space = dart.target_space

      dart.set('landing_space', space).perform()

  has_shuriken: ->
    @shurikens.length > 0

  rest: ->
    @ensure_not_played =>
      (new Rest(@, 3)).perform()

  look: (direction)->
    target_space = @space.get_relative_space(direction, 4)
    @space.range(target_space)

  draw_a_shuriken: ->
    shuriken = @shurikens[0]
    console.log(@shurikens)
    shuriken.outof_inventory(@)
    shuriken

  walk: (direction)->
    @ensure_not_played =>
      (new Walk(@, direction)).perform()

  consume: (type)->
    index = @items.indexOf @first(type)
    return if index == -1
    @items.splice(index, 1)

  first: (type)->
    @select_items(type)[0]

  select_items: (type)->
    @items.filter (i)->
      i.constructor == type

  left: ->
    @walk("left")

  right: ->
    @walk("right")

  up: ->
    @walk("up")

  down: ->
    @walk("down")

  feel: (direction)->
    @space.get_relative_space(direction, 1)

class Enemy extends Character
  health: 12
  damage: 3
  range: 1

  can_attack_warrior: ->
    return false if @level.warrior.remove_flag
    space = @level.warrior.space
    @in_range(space) && !@blocked(space)

  per_turn_strategy: ->
    return if !@can_attack_warrior()
    direction = @space.get_direction(@level.warrior.space)
    target = @space.get_relative_space(direction, @range)
    @direction = direction
    @attack(@direction)

class Slime extends Enemy
  damage: 3
  health: 15

class Tauren extends Enemy
  damage: 3
  health: 20

class Wizard extends Enemy
  attack_action: Magic
  damage: 7
  health: 5

  get_attack_area: ->
    [
      [-1, 1], [0, 1], [1, 1],
      [-1, 0], [1, 0],
      [-1, -1], [0, -1], [1, -1],
      [-2, 0], [0, 2], [2, 0], [0, -2]  
    ].map (i)=>
      @space.relative(i...)

  per_turn_strategy: ->
    return if !@can_attack_warrior()
    direction = @space.get_direction(@level.warrior.space)
    distance = @space.get_distance(@level.warrior.space)
    @direction = direction
    @attack(@direction, distance)

class Archer extends Enemy
  attack_action: Shot
  health: 10
  damage: 3

  get_attack_area: ->
    [
      [0, 1], [0, 2], [0, 3],
      [0, -1], [0, -2], [0, -3],
      [1, 0], [2, 0], [3, 0],
      [-1, 0], [-2, 0], [-3, 0]
    ].map((i)=> @space.relative(i...)).filter((s)=> s)

  per_turn_strategy: ->
    return if !@can_attack_warrior()
    direction = @space.get_direction(@level.warrior.space)
    distance = @space.get_distance(@level.warrior.space)
    @direction = direction
    @attack(@direction, distance)

class Creeper extends Enemy
  excited: false

  get_excited_area: ->
    [
      [-1, 0], [0, 1], [1, 0], [0, -1]
    ].map (i)=>
      @space.relative(i...)

  get_attack_area: ->
    [
      [-1, 1], [0, 1], [1, 1],
      [-1, 0], [1, 0],
      [-1, -1], [0, -1], [1, -1]
    ].map((i)=> @space.relative(i...)).filter((s)=> s)

  warrior_in_excited_area: ->
    @get_excited_area().some (s)=>
      @level.warrior.space == s

  constructor: (space)->
    super(space)

  set_excited: ->
    @ensure_not_played =>
      (new Excited(@)).perform()

  explode: ->
    @ensure_not_played =>
      (new Explode(@)).perform()

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
