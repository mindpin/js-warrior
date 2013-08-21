class Game
  constructor: (level_data, warrior_shuriken_count, warrior_key_count) ->
    @level = new Level(this, level_data, warrior_shuriken_count, warrior_key_count)
    @player  = new Player()

  init: ->
    @level.init()

class DuplicateActionsError extends Error
  constructor: ->
    super(arguments...)

class WarriorNotActionError extends Error
  constructor: ->
    super(arguments...)

jQuery.extend window,
  Game:                  Game
  DuplicateActionsError: DuplicateActionsError
  WarriorNotActionError: WarriorNotActionError
