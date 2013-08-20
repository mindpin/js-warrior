class UserSpace
  white_list = [
    'is_empty','is_blocked',
    'has_enemy','has_slime','has_tauren','has_creeper',
    'has_archer','has_wizard',
    'has_door','has_key','has_lock',
    'has_diamond','has_wall','has_shuriken'
  ]

  constructor: (space)->
    return if !space
    white_list.forEach (field)=>
      @[field] = -> space[field].apply(space, arguments)


window.UserSpace = UserSpace

  
  
  
  
  
  
  
  
  
  
  
  
  
  
