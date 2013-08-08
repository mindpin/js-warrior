class Level
  constructor: (level_data) ->
    @space_profile = @_build_profile level_data

  start: ->
    for i in [1..1000]
      turn_run (space) ->
        space.perform_turn

  # 按顺序让每一个格子的所有 unit 都做一个动作
  turn_run: (fun) ->
    for floor in @space_profile
      for space in floor
        fun.call space

  _build_profile: (level_data) ->
    result = []

    for floor in level_data
      arr = []
      for space_data in floor
        space = new Space space_data
        arr.push space
      result.push arr

    return result
