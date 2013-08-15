class Level
  constructor: (game, level_data) ->
    @game = game
    @space_profile = @_build_profile(level_data)
    @units   = @_refresh_units()
    @warrior = @_build_warrior(@units)
    @door    = @_build_door(@units)

    @max_diamond_count = @diamonds_in_floor().length
    @height = @space_profile.length
    @width = @space_profile[0].length

  enemies: ->
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
      if unit.constructor == Lock && unit.is_open
        result.push(unit)
    return result

  close_intrigues: ->
    result = []
    for unit in @units
      if unit.constructor == Lock && !unit.is_open
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

  passed: ->
    @warrior.space == @door.space && @all_diamond_is_picked() && @all_intrigue_open()

  failed: ->
    @has_diamond_destroy() || @key_not_enough() || @warrior.remove_flag

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
      @destroy_removed_unit()
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
    

  destroy_removed_unit: ->
    for floor in @space_profile
      for space in floor
        space.destroy_removed_unit()
    @units = @_refresh_units()

  _build_profile: (level_data) ->
    result = []

    for floor,y in level_data
      arr = []
      for space_data,x in floor
        space = new Space(this, space_data, x, y)
        arr.push(space)
      result.push(arr)

    return result

  _refresh_units: () ->
    result = []
    for floor in @space_profile
      for space in floor
        character = space.character
        item = space.item
        shurikens = space.shurikens
        result.push(character) if character != null
        result.push(item)      if item      != null
        result = result.concat(shurikens) if shurikens.length != 0

    return result

  _build_warrior: (units) ->
    for unit in @units
      return unit if unit.constructor == Warrior

  _build_door: (units) ->
    for unit in @units
      return unit if unit.constructor == Door

window.Level = Level