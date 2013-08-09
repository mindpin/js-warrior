class Level
  constructor: (level_data) ->
    @space_profile = @_build_profile(level_data)
    @units   = @_build_units(@space_profile)
    @warrior = @_build_warrior(@units)
    @door    = @_build_door(@units)

    @max_diamond_count = @diamonds_in_floor().length
    @height = @space_profile.length
    @width = @space_profile[0].length

  characters: ->
    result = []
    for unit in @units
      if unit.is_character && unit.constructor != Warrior
        result.push(unit)
    return result

  diamonds_in_floor: ->
    result = []
    for unit in @units
      if unit.constructor == Diamond && !unit.picked
        result.push(unit)
    return result

  keys_in_floor: ->
    result = []
    for unit in @units
      if unit.constructor == Key && !unit.picked
        result.push(unit) 
    return result

  open_intrigues: ->
    result = []
    for unit in @units
      if unit.constructor == Intrigue && unit.is_open
        result.push(unit)
    return result

  close_intrigues: ->
    result = []
    for unit in @units
      if unit.constructor == Intrigue && !unit.is_open
        result.push(unit)
    return result

  has_diamond_destroy: ->
    count = @warrior.diamonds.length + @diamonds_in_floor().length
    return @max_diamond_count > count

  key_not_enough: ->
    count = @warrior.keys.length + @keys_in_floor().length
    return @open_intrigues().length > count
  
  all_intrigue_open: ->
    return @close_intrigues().length == 0

  all_diamond_is_picked: ->
    return @max_diamond_count == @warrior.diamonds.length

  start: ->
    for i in [1..1000]
      @destroy_removed_unit()
      @turn_run()
        
  passed: ->
    @warrior.space == @door.space && @all_diamond_is_picked() && @all_intrigue_open()

  failed: ->
    @has_diamond_destroy() || @key_not_enough() || @warrior.remove_flag 

  # 让每一个 生物 都行动一次
  turn_run: ->
    @warrior.reset_played()
    for character in @characters
      character.reset_played()

  get_space: (x, y) ->
    try
      return @space_profile[y][x]
    catch error
      return null

  destroy_removed_unit: ->
    for floor in @space_profile
      for space in floor
        space.destroy_removed_unit()
    @units = @_build_units(@space_profile)

  _build_profile: (level_data) ->
    result = []

    for floor,x in level_data
      arr = []
      for space_data,y in floor
        space = new Space(this, space_data, x, y)
        arr.push(space)
      result.push(arr)

    return result

  _build_units: (space_profile) ->
    result = []
    for floor in @space_profile
      for space in floor
        character = space.character
        item = space.item
        flying_axes = space.flying_axes
        result.push(character) if character != null
        result.push(item)      if item      != null
        result.concat(flying_axes) if flying_axes.length != 0

    return result

  _build_warrior: (units) ->
    for unit in @units
      return unit if unit.constructor == Warrior

  _build_door: (units) ->
    for unit in @units
      return unit if unit.constructor == Door

window.Level = Level