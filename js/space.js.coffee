class Space
  constructor: (level, space_data, x, y) ->
    @level = level
    @x = x
    @y = y
    @_build(space_data)
    @is_border = true if x == -1 && y == -1

  _build: (space_data) ->
    @character   = null
    @item        = null
    @shurikens = []

    unit_datas = space_data.split(',')
    for unit_data in unit_datas
      @_build_unit(unit_data)

  _build_unit: (unit_data) ->
    type_code = unit_data[0]
    switch type_code
      when 'C'
        @_build_character(unit_data)
      when 'I'
        @_build_item(unit_data)
      when 'F'
        @_build_flying_item(unit_data)

  _build_character: (unit_data) ->
    throw '一个格子不能有两个生物' if @character != null
    klass = window[unit_data[1..-1]]
    if klass
      if klass != Warrior
        @character = new klass(@)
        return
      @character = new klass(@, @level.warrior_init_shuriken_count, @level.warrior_init_key_count)

  _build_item: (unit_data) ->
    throw '一个格子不能有两个 item' if @item != null
    klass = window[unit_data[1..-1]]
    if klass
      @item = new klass(@)

  _build_flying_item: (unit_data) ->
    klass = window[unit_data[1..-1]]
    if klass
      @shurikens.push(new klass(@))

  units: ->
    units = []
    units.push(@character) if @character != null
    units.push(@item) if @item != null
    units = units.concat(@shurikens)
    return units

  range: (another_space) ->
    if this.x == another_space.x
      y_points = @_range_index_arr(this.y, another_space.y)
      return jQuery.map y_points, (y) =>
        this.level.get_space(this.x, y)

    if this.y == another_space.y
      x_points = @_range_index_arr(this.x, another_space.x)
      return jQuery.map x_points, (x) =>
        this.level.get_space(x, this.y)

    if Math.abs(this.x - another_space.x) == Math.abs(this.y - another_space.y)
      x_points = @_range_index_arr(this.x, another_space.x)
      y_points = @_range_index_arr(this.y, another_space.y)
      return jQuery.map x_points, (x, index) =>
        this.level.get_space(x, y_points[index])

    return []

  _range_index_arr: (start_index, end_index) ->
    result = [start_index...end_index]
    result.shift()
    return result

  link: (unit) ->
    unit.space = this
    if unit.constructor == Shuriken
      @shurikens.push(unit)
      return
    if unit.is_character && @character == null
      @character = unit
      return
    if !unit.is_character && @item == null
      @item = unit
      return

  unlink: (unit) ->
    if unit.constructor == Shuriken
      index = @shurikens.indexOf(unit)
      return if index == -1
      @shurikens.splice(index,1)
    else if @character == unit
      @character = null
    else if @item == unit
      @item = null

    if unit.space == this
      unit.space = null

  get_direction: (another_space) ->
    if another_space.x < @x && another_space.y == @y
      return 'left'
    if another_space.x > @x && another_space.y == @y
      return 'right'
    if another_space.x == @x && another_space.y < @y
      return 'up'
    if another_space.x == @x && another_space.y > @y
      return 'down'
    if another_space.x < @x && another_space.y < @y
      return 'left-up'
    if another_space.x < @x && another_space.y > @y
      return 'left-down'
    if another_space.x > @x && another_space.y < @y
      return 'right-up'
    if another_space.x > @x && another_space.y > @y
      return 'right-down'
    return null

  get_relative_space: (dir, distance) ->
    switch dir
      when "left-up"    then @relative(-distance, -distance)
      when "left-down"  then @relative(-distance, distance)
      when "right-up"   then @relative(distance, -distance)
      when "right-down" then @relative(distance, distance)
      when "up"         then @relative(0, -distance)
      when "down"       then @relative(0, distance)
      when "left"       then @relative(-distance, 0)
      when "right"      then @relative(distance, 0)
      else throw new Error("Invalid dir!")

  relative: (x, y)->
    @level.get_space(@x + x, @y + y)

  get_distance: (another_space) ->
    if another_space.x == @x
      return Math.abs(another_space.y - @y)
    if another_space.y == @y
      return Math.abs(another_space.x - @x)
    if Math.abs(@x - another_space.x) == Math.abs(@y - another_space.y)
      return Math.abs(@x - another_space.x)
    return null

  is_blocked: ->
    @is_border || !!@character || !!(@item && @item.constructor == Wall)

  # API
  has_enemy: ->
    return @character && @character.constructor != Warrior

  has_slime: ->
    return @character && @character.constructor == Slime

  has_tauren: ->
    return @character && @character.constructor == Tauren

  has_creeper: ->
    return @character && @character.constructor == Creeper

  has_archer: ->
    return @character && @character.constructor == Archer

  has_wizard: ->
    return @character && @character.constructor == Wizard

  has_door: ->
    return @item && @item.constructor == Door

  has_key: ->
    return @item && @item.constructor == Key

  has_lock: ->
    return @item && @item.constructor == Lock

  has_diamond: ->
    return @item && @item.constructor == Diamond

  has_wall: ->
    return @item && @item.constructor == Wall

  has_shuriken: ->
    return @shurikens.length != 0

  is_empty: ->
    @character == null && @item == null && @shurikens.length == 0


window.Space = Space
