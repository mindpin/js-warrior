class Game
  constructor: (level_data) ->
    @level = new Level level_data

  start: ->
    @level.start
