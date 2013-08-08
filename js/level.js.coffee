class Level
  constructor: (level_data) ->
    @space_profile = @_build_profile level_data
    @characters = @_build_characters @space_profile

  start: ->
    for i in [1..1000]
      turn_run
        

  # 按顺序让每一个格子的所有 unit 都做一个动作
  turn_run: ->
    for character in @characters
      character.reset_played

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

  _build_characters: (space_profile) ->
    result = []
    warrior = null
    for floor in @space_profile
      for space in floor
        character = space.character
        continue if character == null

        if character.constructor == Warrior
          warrior = character
          continue
        
        result.push character

    result.unshift warrior
    return result

window.Level = Level