class Game
  constructor: (level_data, options) ->
    @level = new Level(this, level_data)
    @player  = new Player()

    options = options || {}
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

class EachlineWarriorNotActionError extends Error
  constructor: ->
    super(arguments...)

class EachlineUserCat
  constructor: ()->
    @eachline_actions = []

  walk: (direction)->
    directive = new Directive('walk', [direction])
    @eachline_actions.push(directive)

  push: (direction)->
    directive = new Directive('push', [direction])
    @eachline_actions.push(directive)

  toss: (direction)->
    directive = new Directive('toss', [direction])
    @eachline_actions.push(directive)

  slap: (direction)->
    directive = new Directive('slap', [direction])
    @eachline_actions.push(directive)

  get_directive_by_round: (round)->
    @eachline_actions[round-1]
    
class Directive
  constructor: (name, args)->
    @name = name
    @args = args

  run: (cat)->
    fun = switch @name
      when 'walk'
        (c)=> c.walk(@args...)
      when 'push'
        (c)=> c.push(@args...)
      when 'toss'
        (c)=> c.toss(@args...)
      when 'slap'
        (c)=> c.slap(@args...)

    fun(cat)

jQuery.extend window,
  Game:                  Game
  DuplicateActionsError: DuplicateActionsError
  WarriorNotActionError: WarriorNotActionError
  EachlineWarriorNotActionError: EachlineWarriorNotActionError
  EachlineUserCat:       EachlineUserCat
  Directive:             Directive
