# unit_data 的编号
# warrior        -> 0
# key            -> 1
# intrigue       -> 2
# door           -> 3
# small_monster  -> 4
# big_monster    -> 5
# creeper        -> 6

class Space
  constructor: (space_data) ->
    @units = @_build space_data

  perform_turn: ->
    for unit in @units
      unit.perform_turn

  _build: (space_data) ->
    unit_datas = space_data.split ''
    return [] if unit_datas.length == 0
    return @_build_units unit_datas

  _build_units: (unit_datas) ->
    result = []
    for unit_data in unit_datas
      unit = @_build_unit unit_data
      result.push unit

    return result

  _build_unit: (unit_data) ->
    # TODO 需要把 unit 替换成 class
    unit = switch unit_data
      when '0' then 'warrior'
      when '1' then 'key'
      when '2' then 'intrigue'
      when '3' then 'door'
      when '4' then 'small_monster'
      when '5' then 'big_monster'
      when '6' then 'creeper'
    return unit


    