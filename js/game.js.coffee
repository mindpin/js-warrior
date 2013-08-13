class Game
  constructor: (level_data) ->
    @level = new Level(this, level_data)
    @player  = new Player()

  init: ->
    @level.init()

window.Game = Game