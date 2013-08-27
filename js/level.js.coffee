class Level
  constructor: (game, level_data) ->
    @warrior_init_shuriken_count = @_get_init_warrior_item_count(level_data, 'IShuriken')
    @warrior_init_key_count = @_get_init_warrior_item_count(level_data, 'IKey')
    @game = game
    @space_profile = @_build_profile(level_data.map)
    @_build_warrior()
    @_build_door()
    @_build_character_chain()

    @max_diamond_count = @diamond_count_in_floor()
    @height = @space_profile.length
    @width = @space_profile[0].length
    @actions_queue = []

  _get_init_warrior_item_count: (level_data, name)->
    return 0 if !level_data.items
    count = 0
    level_data.items.filter((item)=>
      item.split(/x|X/)[0] == name).forEach (item)=>
        count += item.split(/x|X/)[1] || 1
    return count

  add_action: (action)->
    @actions_queue.push(action)

  enemies: ->
    return @units().filter (unit)=>
      unit.is_enemy()

  diamond_count_in_floor: ->
    count = 0
    @units().forEach (unit)=>
      if unit.class_name() == 'diamond' && !unit.picked
        count += unit.count
    return count

  key_count_in_floor: ->
    count = 0
    @units().forEach (unit)=>
      if unit.class_name() == 'key' && !unit.picked
        count += unit.count
    return count

  closed_lock_count: ->
    count = 0
    @units().forEach (unit)=>
      if unit.class_name() == 'lock'
        count += unit.count
    return count

  has_diamond_destroy: ->
    count = @warrior.count('diamond') + @diamond_count_in_floor()
    return @max_diamond_count > count

  key_not_enough: ->
    count = @warrior.count('key') + @key_count_in_floor()
    return @closed_lock_count() > count
  
  all_lock_opened: ->
    return @closed_lock_count() == 0

  all_diamond_is_picked: ->
    return @max_diamond_count == @warrior.count('diamond')

  passed: ->
    @warrior.space == @door.space && 
    @all_diamond_is_picked() && 
    @all_lock_opened()

  failed: ->
    @has_diamond_destroy() || 
    @key_not_enough() || 
    @warrior.remove_flag ||
    @is_too_many_idles()

  end: ->
    jQuery(document).off 'js-warrior:pause'
    jQuery(document).off 'js-warrior:resume'
    jQuery(document).off 'js-warrior:start'
    jQuery(document).off 'js-warrior:render-ui-success'
    jQuery(document).off 'js-warrior-eachline:start'

  init_eachline: ->
    @eachline_user_cat = new EachlineUserCat()
    jQuery(document).on 'js-warrior-eachline:start', (event, user_input)=>
      @current_round = 0
      eval(user_input)
      game.player.run(@eachline_user_cat)
      @current_character = @warrior
      @_eachline_run()

    jQuery(document).trigger('js-warrior:init-ui', this)

  _eachline_run: ()->
    @actions_queue = []
    if !@current_character || @current_character.is_warrior() || @warrior.remove_flag
      @current_round += 1
      return jQuery(document).trigger('js-warrior:win') if @passed()
      return jQuery(document).trigger('js-warrior:lose') if @failed()

    if @current_character.is_warrior()
      try
        directive = @eachline_user_cat.get_directive_by_round(@current_round)
        throw new EachlineWarriorNotActionError('勇士没有行动') if !directive
        play_turn = => 
          directive.run(arguments[0])
        @current_character.play(play_turn)
        @_record_warrior_continuous_idle_count()
        if @actions_queue.length == 0
          throw new WarriorNotActionError('没有任何行动') 
      catch e
        return jQuery(document).trigger('js-warrior:error',e)
    else
      @current_character.play()

    jQuery(document).one 'js-warrior:render-ui-success', ()=>
      @current_character = @current_character.next
      return if @pausing
      @_eachline_run()
    jQuery(document).trigger('js-warrior:render-ui')

  init: ->
    jQuery(document).on 'js-warrior:pause', =>
      @pausing = true
    jQuery(document).on 'js-warrior:resume', =>
      @pausing = false
      @_character_run()
    jQuery(document).on 'js-warrior:start', (event, user_input)=>
      @current_round = 0
      @pausing = false
      eval(user_input)
      @current_character = @warrior
      @_character_run()

    jQuery(document).trigger('js-warrior:init-ui', this)

  is_too_many_idles: ->
    @warrior_continuous_idle_count > 10

  _record_warrior_continuous_idle_count: ->
    if @actions_queue.length == 1 && @actions_queue[0].type == 'idle'
      @warrior_continuous_idle_count ||= 0
      @warrior_continuous_idle_count += 1
    else
      @warrior_continuous_idle_count ||= 0

  _character_run: ()->

    @actions_queue = []
    if !@current_character || @current_character.is_warrior() || @warrior.remove_flag
      @current_round += 1
      return jQuery(document).trigger('js-warrior:win') if @passed()
      return jQuery(document).trigger('js-warrior:lose') if @failed()

    # console.log('logic new action')
    # console.log(cs)
    # console.log(character)
    if @current_character.is_warrior()
      try
        play_turn = => @game.player.play_turn(arguments...)
        @current_character.play(play_turn)
        @_record_warrior_continuous_idle_count()
        if @actions_queue.length == 0
          throw new WarriorNotActionError('没有任何行动') 
      catch e
        return jQuery(document).trigger('js-warrior:error',e)
    else
      @current_character.play()

    jQuery(document).one 'js-warrior:render-ui-success', ()=>
      @current_character = @current_character.next
      return if @pausing
      @_character_run()
    jQuery(document).trigger('js-warrior:render-ui')

  characters: ->
    result = []
    result.push(@warrior)
    result = result.concat(@enemies())
    return result

  get_space: (x, y) ->
    try
      s = @space_profile[y][x]
    catch error
    s = new BorderSpace(this, x, y) if !s
    return s
    
  _build_profile: (level_map_data) ->
    result = []

    for floor,y in level_map_data
      arr = []
      for space_data,x in floor
        space = new Space(this, space_data, x, y)
        arr.push(space)
      result.push(arr)

    return result

  empty_spaces: ->
    result = []
    for floor in @space_profile
      for space in floor
        result.push(space) if space.is_empty()
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

  _build_character_chain: ->
    characters = @characters()
    prev_character = characters[characters.length-1]
    for character in @characters()
      character.prev = prev_character
      prev_character.next = character
      prev_character = character

window.Level = Level