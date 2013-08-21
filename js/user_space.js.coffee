class UserSpace
  white_list = [
    'is_empty','has'
  ]

  constructor: (space)->
    return if !space
    white_list.forEach (field)=>
      @[field] = -> space[field].apply(space, arguments)


window.UserSpace = UserSpace

  
  
  
  
  
  
  
  
  
  
  
  
  
  
