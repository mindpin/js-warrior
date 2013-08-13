class UnitContainer
  relative: (x, y)->
    @level.get_space(@x + x, @y + y)

  receive: (action)->
    switch action.constructor
      when Explode
        @units.each (u)->
          u.remove() if u.destroyable
      when Attack
        @character.take_attack(action) if @character
      when ShurikenAttack
        shuriken = @level.warrior.draw_a_shuriken()
        @character.take_attack(action) if @character
        @space.link(shuriken)
      when Interact
        @item.take_interact(action) if @item
        if @shurikens.length > 0
          fa.take_interact(action) for fa in @shurikens

jQuery.extend window,
  UnitContainer: UnitContainer
