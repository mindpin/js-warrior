class Level
  constructor: (game, level_data) ->
    @game = game
    @space_profile = @_build_profile(level_data)
    @_build_warrior()
    @_build_door()

    @max_diamond_count = @diamonds_in_floor().length
    @height = @space_profile.length
    @width = @space_profile[0].length

  enemies: ->
    return @units().filter (unit)=>
      unit.is_enemy()

  diamonds_in_floor: ->
    return @units().filter (unit)=>
      unit.class_name() == 'diamond' && !unit.picked

  keys_in_floor: ->
    return @units().filter (unit)=>
      unit.class_name() == 'key' && !unit.picked

  opened_locks: ->
    return @units().filter (unit)=>
      unit.class_name() == 'lock' && unit.is_open

  closed_locks: ->
    return @units().filter (unit)=>
      unit.class_name() == 'lock' && !unit.is_open

  has_diamond_destroy: ->
    count = @warrior.diamonds.length + @diamonds_in_floor().length
    return @max_diamond_count > count

  key_not_enough: ->
    count = @warrior.keys.length + @keys_in_floor().length
    return @closed_locks().length > count
  
  all_locks_opened: ->
    return @closed_locks().length == 0

  all_diamond_is_picked: ->
    return @max_diamond_count == @warrior.diamonds.length

  passed: ->
    @warrior.space == @door.space && 
    @all_diamond_is_picked() && 
    @all_locks_opened()

  failed: ->
    @has_diamond_destroy() || 
    @key_not_enough() || 
    @warrior.remove_flag

  init: ->
    jQuery(document).on 'js-warrior:pause', =>
      @pausing = true
    jQuery(document).on 'js-warrior:resume', =>
      @pausing = false
      @_character_run(@current_index+1)
    jQuery(document).on 'js-warrior:start', (event, user_input)=>
      @current_round = 0
      @pausing = false
      eval(user_input)
      @turn_run()
    jQuery(document).trigger('js-warrior:init-ui', this)

  # 让每一个 生物 都行动一次
  turn_run: ->
    @current_round += 1
    @current_index = 0
    @_character_run(0)

  is_turn_end: ->
    return @current_index == @characters().length

  _character_run: (index)->
    character = @get_character_by_index(index)

    if character && character.is_warrior()
      return jQuery(document).trigger('js-warrior:win') if @passed()
      return jQuery(document).trigger('js-warrior:lose') if @failed()

    @current_index = index
    if @is_turn_end()
      @turn_run()
      return
    # console.log('logic new action')
    # console.log(cs)
    # console.log(character)
    if character.constructor == Warrior
      character.play(@game.player.play_turn)
    else
      character.play()

    jQuery(document).one 'js-warrior:render-ui-success', (event, character)=>
      character.reset_action()
      return if @pausing
      @_character_run(index+1)

    jQuery(document).trigger('js-warrior:render-ui', character)

  characters: ->
    result = []
    result.push(@warrior)
    result = result.concat(@enemies())
    return result

  get_character_by_index: (index)->
    return @characters()[index]
    
  get_space: (x, y) ->
    try
      s = @space_profile[y][x]
    catch error
    s = new Space(this, '', -1, -1) if !s
    return s
    
  _build_profile: (level_data) ->
    result = []

    for floor,y in level_data
      arr = []
      for space_data,x in floor
        space = new Space(this, space_data, x, y)
        arr.push(space)
      result.push(arr)

    return result

  units: () ->
    result = []
    for floor in @space_profile
      for space in floor
        result = result.concat(space.units())
    return result

  _build_warrior: ->
    for unit in @units()
      if unit.constructor == Warrior
        @warrior = unit
        return

  _build_door: ->
    for unit in @units()
      if unit.constructor == Door
        @door = unit
        return

window.Level = Level