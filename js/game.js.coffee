class Game
  constructor: (level_data, options) ->
    @level = new Level(this, level_data)
    @player  = new Player()

    @eachline_mode = options['eachline']

  init: ->
    if @eachline_mode
      @level.init_eachline()
    else
      @level.init()

class DuplicateActionsError extends Error
  constructor: ->
    super(arguments...)

class WarriorNotActionError extends Error
  constructor: ->
    super(arguments...)

class EachlineUserWarrior

  constructor: ()->
    @eachline_warrior_actions = []

  walk: (direction)->
    directive = new Directive('walk', [direction])
    @eachline_warrior_actions.push(directive)

  attack: (direction)->
    directive = new Directive('attack', [direction])
    @eachline_warrior_actions.push(directive)

  rest: ()->
    directive = new Directive('rest', [])
    @eachline_warrior_actions.push(directive)

  dart: (direction)->
    directive = new Directive('dart', [direction])
    @eachline_warrior_actions.push(directive)

  interact: (direction)->
    directive = new Directive('interact', [direction])
    @eachline_warrior_actions.push(directive)

  get_directive_by_round: (round)->
    @eachline_warrior_actions[round-1]

class Directive
  constructor: (name, args)->
    @name = name
    @args = args

  run: (warrior)->
    fun = switch @name
      when 'walk'
        (w)=> w.walk(@args...)
      when 'attack'
        (w)=> w.attack(@args...)
      when 'rest'
        (w)=> w.rest()
      when 'dart'
        (w)=> w.dart(@args...)
      when 'interact'
        (w)=> w.interact(@args...)

    fun(warrior)

jQuery.extend window,
  Game:                  Game
  DuplicateActionsError: DuplicateActionsError
  WarriorNotActionError: WarriorNotActionError
  EachlineUserWarrior:   EachlineUserWarrior
  Directive:             Directive
