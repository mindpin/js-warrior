# unit_data 的编号
# 有AI的生物
# =======
# 勇士 Warrior               C0
# 小怪 SmallMonster          C1
# 大怪 BigMonster            C2
# JJ怪 Creeper               C3
# 弓箭手 Archer              C4
# 魔法师 Wizard              C5

# 物品
# =========
# 钥匙 Key                   I0
# 机关 Intrigue              I1
# 门 Door                    I2
# 宝石 Diamond               I3
# 墙   Wall                  I4

# 飞行道具
# ========
# 石头（投掷物）FlyingAxe    F0

class Space
  jQuery.extend this::, UnitContainer::

  constructor: (space_data,x,y) ->
    @x = x
    @y = y
    @_build space_data

  _build: (space_data) ->
    @character   = null
    @item        = null
    @flying_axes = []

    unit_datas = space_data.split ','
    for unit_data in unit_datas
      @_build_unit unit_data

  _build_unit: (unit_data) ->
    type_code = unit_data[0]
    switch type_code
      when 'C'
        @_build_character unit_data
      when 'I'
        @_build_item unit_data
      when 'F'
        @_build_flying_item unit_data

  _build_character: (unit_data) ->
    throw '一个格子不能有两个生物' if @character != null
    @character = switch unit_data
      when 'C0' then new Warrior this
      when 'C1' then new SmallMonster this
      when 'C2' then new BigMonster this
      when 'C3' then new Creeper this
      when 'C4' then new Archer this
      when 'C5' then new Wizard this

  _build_item: (unit_data) ->
    throw '一个格子不能有两个 item' if @item != null
    @item = switch unit_data
      when 'I0' then new Key this
      when 'I1' then new Intrigue this
      when 'I2' then new Door this
      when 'I3' then new Diamond this
      when 'I4' then new Wall this

  _build_flying_item: (unit_data) ->
    flying_item = switch unit_data
      when 'F0' then new FlyingAxe this

    @flying_axes.push flying_item


window.Space = Space
