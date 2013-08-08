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

  get_space: (x, y) ->
    try
      return @space_profile[x][y]
    catch error
      return null

  _build_profile: (level_data) ->
    result = []

    for floor,x in level_data
      arr = []
      for space_data,y in floor
        space = new Space space_data, x, y
        arr.push space
      result.push arr

    return result


window.Level = Level