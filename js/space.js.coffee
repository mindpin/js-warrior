# unit_codes 说明在 level.js.coffe 文件头

class Space
  @build: (code) ->
    unit_codes = code.split('')
    if unit_codes.length === 0
      @units = []
    else
      @units = _build_units(unit_codes)
    return new Space(@units)

  @_build_units: (unit_codes) ->
    result = []
    for(var i = 0; i < unit_codes.length; i++){
      unit = _build_unit(unit_codes[i])
      result.push(unit)
    }
    return result

  @_build_unit: (unit_code) ->
    # TODO 需要把 unit 替换成 class
    unit = switch unit_code
      when '0' then 'warrior'
      when '1' then 'key'
      when '2' then 'intrigue'
      when '3' then 'door'
      when '4' then 'small_monster'
      when '5' then 'big_monster'
      when '6' then 'creeper'
    return unit

  constructor: (units) ->
    @units = units


  perform_turn: ->
    for(var i = 0; i < @units.length; i++){
      unit = @units[i]
      unit.perform_turn
    }
    