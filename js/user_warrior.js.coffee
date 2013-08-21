class UserWarrior extends Base
  white_list = [
    "attack", "interact", "dart",
    "rest",   "walk",     "feel",
    "look",   "left",     "right",
    "up",     "down",     "distance_of",
    "drection_of_door",   "direction_of",
    "listen"
  ]

  warrior = null

  constructor: (iwarrior)->
    warrior = iwarrior
    return if !warrior
    white_list.forEach (field)=>
      @[field] = -> warrior[field].apply(warrior, arguments)

    @getter "health", -> warrior.health

jQuery.extend window,
  UserWarrior: UserWarrior
