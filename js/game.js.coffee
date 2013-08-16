class Game
  constructor: (level_data, warrior_shuriken_count, warrior_key_count) ->
    @level = new Level(this, level_data, warrior_shuriken_count, warrior_key_count)
    @player  = new Player()

  init: ->
    @level.init()

window.Game = Game