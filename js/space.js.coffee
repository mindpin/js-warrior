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
  jQuery.extend this::, UnitContainer::

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
    result.concat(@shurikens)
    return result

  range: (another_space) ->
    if this.x == another_space.x
      y_points = @_range_index_arr(this.y, another_space.y)
      return jQuery.map y_points, (y)->
        this.level.get_space(this.x, y)

    if this.y == another_space.y
      x_points = @_range_index_arr(this.x, another_space.x)
      return jQuery.map x_points, (x)->
        this.level.get_space(x, this.y)

    if this.x - another_space.x == this.y -another_space.y
      x_points = @_range_index_arr(this.x, another_space.x)
      y_points = @_range_index_arr(this.y, another_space.y)
      return jQuery.map x_points, (x, index)->
        this.level.get_space(x, y_points[index])

    return []

  _range_index_arr: (start_index, end_index) ->
    return [start_index..end_index]

  is_empty: ->
    @character == null && @item == null && @shurikens.length == 0

  link: (unit) ->
    unit.space = this
    if unit.constructor == FlyingAxe
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
    if unit.constructor == FlyingAxe
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
    if @character != null && @character.remove_tag
      @character.space = null
      @character = null

    if @item != null && @item.remove_tag
      @item.space = null
      @item = null 

    new_shurikens = []
    for shuriken in @shurikens
      if shuriken.remove_tag
        shuriken.space = null
        continue
      new_shurikens.push(shuriken)
    @shurikens = new_shurikens

window.Space = Space
