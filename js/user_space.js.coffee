class UserSpace extends Base
  white_list = [
    'is_empty','has'
  ]

  constructor: (space)->
    return if !space
    white_list.forEach (field)=>
      @[field] = -> space[field].apply(space, arguments)

    @getter "id", -> "#{space.x}_#{space.y}"

window.UserSpace = UserSpace
