class UnitContainer
  set_character: (c)->
    @character = c

  set_item: (i)->
    throw new Error("不可以把item设置成投掷物") if i.constructor == FlyingAxe
    throw new Error("不可以重复设置item") if item
    @item = i

  add_flying_axe: (fa)->
    throw new Error("不可以把别的item放入投掷物集合") if fa.constructor != FlyingAxe
    throw new Error("超出最大投掷物限制") if flying_axes.length >= FlyingAxe.max_num()
    @flying_axes = [] if !@flying_axes
    @flying_axes.push fa

  clear: (what)->
    switch what
      when "character"   then @character   = null
      when "item"        then @item        = null
      when "flying_axes" then @flying_axes = []

  relative: (x, y)->
    @level.get_space(@x + x, @y + y)

  receive: (action)->
    switch action.constructor
      when Attack
        @character.take_attack(action) if @character
      when Interact
        @item.take_interact(action) if @item
        if @flying_axes.length > 0
          fa.get_interact(action) for fa in @flying_axes

jQuery.extend window,
  UnitContainer: UnitContainer
