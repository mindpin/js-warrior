# profiles 的编号
# warrior        -> 0
# key            -> 1
# intrigue       -> 2
# door           -> 3
# small_monster  -> 4
# big_monster    -> 5
# creeper        -> 6

class Level
  @profiles = [
    # 第一个 level
    [
      ['','','','',''],
      ['','','','3',''],
      ['','','','4',''],
      ['','0','','',''],
      ['','','','','']
    ]
  ]

  @build: (level_number) ->
    return new Level(@profiles[level_number-1])


  constructor: (profile) ->
    @space_profile = build_profile(profile)

  build_profile: (profile) ->
    result = []
    for(var i = 0; i < profile.length; i++){
      floor = profile[i]
      arr = []
      for(var j = 0; j < floor.length; j++){
        space = Space.build(floor[j])
        arr.push(space)
      }
      result.push(arr)
    }
    return result

  start: ->
    for(var i = 0; i < 1000; i++){
      turn_run (space) ->
        space.perform_turn
    }

  # 按顺序让每一个格子的所有 unit 都做一个动作
  turn_run: (fun) ->
    for(var i = 0; i < @space_profile.length; i++){
      floor = @space_profile[i]
      for(var j = 0; j < floor.length; j++){
        space = floor[j]
        fun.call(space)
      }
    }