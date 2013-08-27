class Character extends Unit
  @type = 'character'
  is_character:  true
  destroyable:   true
  remove_flag:   false
  attack_action: Attack
  direction:     "down"
  damage:        3
  health:        0

  constructor: (@space, shuriken_count, key_count)->
    super(@space)
    @max_health = @health

  is_cat: ->
    @class_name() == "cat"

  in_range: (space)->
    @get_attack_area().some (s)=>
      space == s

  blocked: (space)->
    @space.range(space).some (s)=>
      !s.is_empty()

  attack: (direction, distance)->
    @ensure_not_played =>
      !distance && distance = 1
      (new @attack_action(@, direction, distance)).perform()

  idle: (action)->
    @level.add_action(new Idle(@, action))

  is_hp_exceeded: (hp)->
    hp > @max_health

  health_delta: (delta)->
    hp      = @health + delta
    @health = if @is_hp_exceeded(hp) then @max_health else hp

  take_explode: (atk)->
    @take_attack(atk)
  
  take_dart: (atk)->
    item = atk.target_space.item
    if item then item.take_dart(atk) else atk.shuriken.update_link(atk.target_space)
    @take_attack(atk)

  take_attack: (atk)->
    @health_delta(atk.hp_change)
    @remove() if @health <= 0

  ensure_not_played: (action)->
    throw new DuplicateActionsError("一回合不能行动两次") if @played
    action()
    @played = true

  reset_played: ->
    @played = false

  calculate_area: (array)->
    array.map((i)=> @space.relative(i...)).filter((s)=> s)

  attack_area_plan: [
    [0, 1], [-1, 0], [1, 0], [0, -1]
  ]

  get_attack_area: ->
    @calculate_area @attack_area_plan

  per_turn_strategy: ->

  play: (strategy)->
    return if @remove_flag
    character = if @is_warrior() then new UserWarrior(@) else @ 
    strategy && strategy(character)
    @per_turn_strategy()
    @reset_played()

  is_warrior: ->
    @class_name() == 'warrior'

  remove: ->
    super()
    @space.character = null
    prev = @prev
    next = @next
    prev.next = next
    next.prev = prev

class Warrior extends Character
  damage:          5
  shuriken_damage: 5
  health:          20
  dart_range:      3

  constructor: (@space, shuriken_count, key_count)->
    super(@space)
    @items = []
    @items = @items.concat([@create_item(Shuriken, shuriken_count)]) if shuriken_count
    @items = @items.concat([@create_item(key, key_count)]) if key_count

  find_item: (type)->
    @items.filter((i)=> i.constructor == type)[0]

  create_item: (type, count)->
    new type(null, count)

  count: (type_str)->
    type = switch type_str
      when "shuriken" then Shuriken
      when "key"      then Key
      when "diamond"  then Diamond

    result = @find_item(type)
    parseInt if result then result.count else 0

  item_change: (type, count)->
    item = @find_item(type)
    if item
      item.count += count
      item
    else
      result = @create_item(type, count)
      @items.push result; result

  interact:(direction) ->
    @ensure_not_played =>
      (new Interact(@, direction)).perform()

  shuriken_area_plan: [
    [0, 1], [0, 2], [0, 3],
    [0, -1], [0, -2], [0, -3],
    [1, 0], [2, 0], [3, 0],
    [-1, 0], [-2, 0], [-3, 0]
  ]

  get_shuriken_range: ->
    @calculate_area @shuriken_area_plan

  in_shuriken_range: (space)->
    @get_shuriken_range().some (s)=>
      s == space

  can_dart_space: (space)->
    @in_shuriken_range(space) && @has_shuriken()

  listen: ->
    @level.units().map (u)=>
      new UserSpace(u.space)

  distance_of: (user_space)->
    space = @_get_space_by_user_space(user_space)
    [@space.x - space.x, @space.y - space.y]
      .map((i)=> Math.abs(i))
      .reduce((a, b)=> a + b)

  direction_of: (user_space)->
    space = @_get_space_by_user_space(user_space)
    @space.get_direction(space)

  _get_space_by_user_space: (user_space)->
    xy = user_space.id.split('_')
    return @level.get_space(xy[0], xy[1])

  direction_of_door: ->
    @space.get_direction(@level.door.space)

  dart: (direction)->
    distance = 3
    @ensure_not_played =>
      (new Dart(@, direction, distance)).perform()

  has_shuriken: ->
    @count("shuriken") > 0

  rest: ->
    @ensure_not_played =>
      (new Rest(@, 2)).perform()

  look: (direction)->
    target_space = @space.get_relative_space(direction, 4)
    @space.range(target_space).map (space)=>
      new UserSpace(space)

  draw_a_shuriken: ->
    shuriken = @shurikens[0]
    shuriken.outof_inventory(@)
    shuriken

  walk: (direction)->
    @ensure_not_played =>
      (new Walk(@, direction)).perform()

  consume: (type)->
    @find_item(type).count -= 1
    @create_item(type, 1)

  left: ->
    @walk("left")

  right: ->
    @walk("right")

  up: ->
    @walk("up")

  down: ->
    @walk("down")

  feel: (direction)->
    new UserSpace(@space.get_relative_space(direction, 1))

class Enemy extends Character
  health: 12
  damage: 3
  range:  1

  can_attack_warrior: ->
    return false if @level.warrior.remove_flag
    space = @level.warrior.space
    @in_range(space) && !@blocked(space)

  per_turn_strategy: ->
    return @idle() if !@can_attack_warrior()
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
  damage:        7
  health:        5

  attack_area_plan: [
    [-1, 1], [0, 1], [1, 1],
    [-1, 0], [1, 0],
    [-1, -1], [0, -1], [1, -1],
    [-2, 0], [0, 2], [2, 0], [0, -2]  
  ]

  per_turn_strategy: ->
    return @idle() if !@can_attack_warrior()
    direction = @space.get_direction(@level.warrior.space)
    distance = @space.get_distance(@level.warrior.space)
    @direction = direction
    @attack(@direction, distance)

class Archer extends Enemy
  attack_action: Shot
  health: 10
  damage: 3

  attack_area_plan: [
    [0, 1], [0, 2], [0, 3],
    [0, -1], [0, -2], [0, -3],
    [1, 0], [2, 0], [3, 0],
    [-1, 0], [-2, 0], [-3, 0]
  ]

  per_turn_strategy: ->
    return @idle() if !@can_attack_warrior()
    direction = @space.get_direction(@level.warrior.space)
    distance = @space.get_distance(@level.warrior.space)
    @direction = direction
    @attack(@direction, distance)

class Creeper extends Enemy
  excited: false

  excited_area_plan: [
    [-1, 0], [0, 1], [1, 0], [0, -1]
  ]

  get_excited_area: ->
    @calculate_area @excited_area_plan

  attack_area_plan: [
    [-1, 1], [0, 1], [1, 1],
    [-1, 0], [0, 0], [1, 0],
    [-1, -1], [0, -1], [1, -1]
  ]

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

  take_attack: (atk)->
    super(atk)
    (new Explode(@)).perform() if atk.is_dart()

  per_turn_strategy: ->
    if @warrior_in_excited_area()
      return @set_excited() if !@excited
    @explode() if @excited

class Cat extends Character
  push: (direction)->
    (new Push(@, direction)).perform()

  toss: (direction)->
    (new Toss(@, direction)).perform()

  slap: (direction)->
    (new Slap(@, direction)).perform()

jQuery.extend window,
  Character: Character
  Enemy:     Enemy
  Slime:     Slime
  Tauren:    Tauren
  Creeper:   Creeper
  Wizard:    Wizard
  Archer:    Archer
  Warrior:   Warrior
  Cat:       Cat
