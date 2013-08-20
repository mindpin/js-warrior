class UserWarrior
  white_list = [
    "attack", "interact", "dart",
    "rest",   "walk",     "feel",
    "look"
  ]

  constructor: (warrior)->
    return if !warrior
    white_list.forEach (field)=>
      @[field] = -> warrior[field].apply(warrior, arguments)

jQuery.extend window,
  UserWarrior: UserWarrior
