class UnitContainer
  relative: (x, y)->
    @level.get_space(@x + x, @y + y)

  receive: (action)->
    switch action.constructor
      when Attack
        @character.take_attack(action) if @character
      when Interact
        @item.take_interact(action) if @item
        if @flying_axes.length > 0
          fa.take_interact(action) for fa in @flying_axes

jQuery.extend window,
  UnitContainer: UnitContainer
