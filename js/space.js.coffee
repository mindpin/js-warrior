# unit_data 的编号
# 有AI的生物
# =======
# 勇士 Warrior               C0
# 小怪 Slime                 C1
# 大怪 Tauren                C2
# JJ怪 Creeper               C3
# 弓箭手 Archer              C4
# 魔法师 Wizard              C5

# 物品
# =========
# 钥匙 Key                   I0
# 机关 Lock              I1
# 门 Door                    I2
# 宝石 Diamond               I3
# 墙   Wall                  I4

# 飞行道具
# ========
# 石头（投掷物）Shuriken    F0

class Space
  constructor: (level, space_data, x, y) ->
    @level = level
    @x = x
    @y = y
    @_build(space_data)
    @units = @_build_units

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
    @character = switch unit_data
      when 'C0' then new Warrior(this) 
      when 'C1' then new Slime(this)
      when 'C2' then new Tauren(this)
      when 'C3' then new Creeper(this)
      when 'C4' then new Archer(this)
      when 'C5' then new Wizard(this)

  _build_item: (unit_data) ->
    throw '一个格子不能有两个 item' if @item != null
    @item = switch unit_data
      when 'I0' then new Key(this)
      when 'I1' then new Lock(this)
      when 'I2' then new Door(this)
      when 'I3' then new Diamond(this)
      when 'I4' then new Wall(this)

  _build_flying_item: (unit_data) ->
    flying_item = switch unit_data
      when 'F0' then new Shuriken(this)

    @shurikens.push(flying_item)

  _build_units: ->
    result = []
    result.push(@character) if @character != null
    result.push(@item) if @item != null
    result = result.concat(@shurikens)
    return result

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
    if unit.space == this
      unit.space = null
    if unit.constructor == Shuriken
      index = @shurikens.indexOf(unit)
      return if index == -1
      @shurikens.splice(index,1)
      return
    if @character == unit
      @character = null
      return
    if @item == unit
      @item = null
      return

  destroy_removed_unit: ->
    if @character != null && @character.remove_flag
      @character.space = null
      @character = null

    if @item != null && @item.remove_flag
      @item.space = null
      @item = null 

    new_shurikens = []
    for shuriken in @shurikens
      if shuriken.remove_flag
        shuriken.space = null
        continue
      new_shurikens.push(shuriken)
    @shurikens = new_shurikens

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

  get_relative_space_in_map: (dir, distance) ->
    switch dir
      when "left-up"    then @relative_in_map(-distance, -distance)
      when "left-down"  then @relative_in_map(-distance, distance)
      when "right-up"   then @relative_in_map(distance, -distance)
      when "right-down" then @relative_in_map(distance, distance)
      when "up"         then @relative_in_map(0, -distance)
      when "down"       then @relative_in_map(0, distance)
      when "left"       then @relative_in_map(-distance, 0)
      when "right"      then @relative_in_map(distance, 0)
      else throw new Error("Invalid dir!")

  relative_in_map: (x, y)->
    px = @x + x
    px = Math.max(px, 0)
    px = Math.min(px, @level.width - 1)

    py = @y + y
    py = Math.max(py, 0)
    py = Math.min(py, @level.height - 1)

    @level.get_space(px, py)

  receive: (action)->
    switch action.constructor
      when Walk, Attack, Shot
        action.perform()
      when Explode
        @units.each (u)->
          u.remove() if u.destroyable
      when ShurikenAttack
        shuriken = @level.warrior.draw_a_shuriken()
        @character.take_attack(action) if @character
        @link(shuriken)
      when Interact
        @item.take_interact(action) if @item
        if @shurikens.length > 0
          fa.take_interact(action) for fa in @shurikens

  get_distance: (another_space) ->
    if another_space.x == @x
      return Math.abs(another_space.y - @y)
    if another_space.y == @y
      return Math.abs(another_space.x - @x)
    if Math.abs(@x - another_space.x) == Math.abs(@y - another_space.y)
      return Math.abs(@x - another_space.x)
    return null

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
