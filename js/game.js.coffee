class Game
  constructor: (level_data) ->
    @level = new Level(this, level_data)
    @player  = new Player()

  start: ->
    @level.start()

window.Game = Game