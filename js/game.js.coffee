class Game
  constructor: (level_data) ->
    @level = new Level(this, level_data)
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
