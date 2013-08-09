class Level
  constructor: (level_data) ->
    @space_profile = @_build_profile level_data
    @characters = @_build_characters @space_profile
    @warrior = @_build_warrior @space_profile

  start: ->
    for i in [1..1000]
      turn_run
        

  # 让每一个 生物 都行动一次
  turn_run: ->
    @warrior.reset_played
    for character in @characters
      character.reset_played

  get_space: (x, y) ->
    try
      return @space_profile[y][x]
    catch error
      return null

  _build_profile: (level_data) ->
    result = []

    for floor,x in level_data
      arr = []
      for space_data,y in floor
        space = new Space this, space_data, x, y
        arr.push space
      result.push arr

    return result

  _build_characters: (space_profile) ->
    result = []
    for floor in @space_profile
      for space in floor
        character = space.character
        continue if character == null || character.constructor == Warrior
        result.push character

    return result

  _build_warrior: (space_profile) ->
    for floor in @space_profile
      for space in floor
        character = space.character
        if character != null && character.constructor == Warrior
          return character

window.Level = Level