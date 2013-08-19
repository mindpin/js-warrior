class AniSound
  @walk: ->
    new Audio("/sound/step1.mp3").play()
  @attack: ->
    new Audio("/sound/attack.mp3").play()
  @rest: ->
    new Audio("/sound/heal.mp3").play()
  @shot: ->
    new Audio("/sound/arrow.mp3").play()
  @fireball: ->
    new Audio("/sound/fireball.mp3").play()
  @explode: ->
    new Audio("/sound/explode.mp3").play()


class UnitAni
  constructor: (@game_ui, @character)->
    @CONST_W = @game_ui.CONST_W
    @TIME = 300

    @$game = @game_ui.$game

    @type = @character.type()
    @class_name = @character.class_name()


    @$el = @_build_el()
    @_refresh_hp_dom()


  _build_el: ->
    # 图标
    $ui_el = jQuery('<div></div>')
      .addClass(@type)
      .addClass(@class_name)      
      .css
        left: @left()
        top:  @top()
      .appendTo(@$game)

  _refresh_hp_dom: ->
    if @character.type() == 'character'
      if !@$hp
        @$hp = jQuery("<div class='hp'></div>")
          .appendTo(@$el)

        @$hpbar = jQuery("<div class='hpbar'><div class='p'></div></div>")
          .appendTo(@$el)

      @$hp.html(@character.health)
      percent = (@character.health * 100.0 / @character.max_health) + '%'
      @$hpbar.find('.p').css('width', percent)
    
  left: ->
    @character.space.x * @CONST_W
  top: ->
    @character.space.y * @CONST_W

  walk: (dir)->
    @_change_face_dir(dir)
    AniSound.walk()
    @$el
      .animate
        left: @left()
        top:  @top()
        @TIME, => @_rendered()

  attack: (dir, target, hp_change)->
    if target
      target.ani.be_attack(hp_change)

    delta = @_xydelta(dir)
    @_change_face_dir(dir)

    AniSound.attack()
    @$el
      .css
        'z-index': 10
      .animate
        left: @left() + delta.dx * @CONST_W
        top:  @top() + delta.dy * @CONST_W
        , @TIME / 2
      .animate
        left: @left()
        top:  @top()
        , @TIME / 2, => 
          @$el.css
            'z-index': ''
          @_rendered()

  _xydelta: (dir, distance)->
    d = distance || 1

    hash = 
      'right': [ 1,  0]
      'left' : [-1,  0]
      'up'   : [ 0, -1]
      'down' : [ 0,  1]
      'left-up'    : [-1, -1]
      'left-down'  : [-1,  1]
      'right-up'   : [ 1, -1]
      'right-down' : [ 1,  1]

    arr = hash[dir]

    return {
      dx: arr[0] * d
      dy: arr[1] * d
    }

  _change_face_dir: (dir)->
    @$el
      .removeClass('up')
      .removeClass('down')
      .removeClass('left')
      .removeClass('right')
      .addClass(dir)

  shot: (dir, target, hp_change)->
    if target
      target.ani.be_attack(hp_change)

    AniSound.shot()
    @_change_face_dir(dir)

    $arrow = jQuery('<div></div>')
      .addClass('item').addClass('arrow').addClass(dir)
      .appendTo(@$game)

    $arrow
      .css
        left: @left()
        top: @top()
      .delay(0)
      .animate
        left: target.ani.left()
        top:  target.ani.top()
        easing: 'easeout'
        , @TIME / 2, =>
          setTimeout =>
            $arrow.fadeOut => $arrow.remove()
            @_rendered()
          , @TIME / 4

  dart: (dir, target, hp_change)->
    if target
      target.ani.be_attack(hp_change)

    AniSound.shot()
    @_change_face_dir(dir)

    $arrow = jQuery('<div></div>')
      .addClass('item').addClass('shuriken').addClass('flying').addClass(dir)
      .appendTo(@$game)

    $arrow
      .css
        left: @left()
        top: @top()
      .delay(0)
      .animate
        left: target.ani.left()
        top:  target.ani.top()
        easing: 'easeout'
        , @TIME / 2, =>
          setTimeout =>
            $arrow.fadeOut => $arrow.remove()
            @_rendered()
          , @TIME / 4

  hp_change: (change, func)->
    return if @character.type() == 'item'

    if change >= 0
      klass = 'heal'
      html = "+#{change}"
    else
      klass = 'damage'
      html = change

    $el = jQuery("<div class='hp-change'></div>")
      .addClass(klass)
      .html(html)
      .css
        left: @left()
        top: @top()
      .appendTo(@$game)

    $el
      .animate
        left: @left()
        top: @top() - @CONST_W / 2
        'font-size': 40
        => 
          $el.fadeOut => $el.remove()
          @_refresh_hp_dom()
          func() if func

  rest: (hp_change)->
    AniSound.rest()

    @hp_change hp_change, =>
      @_rendered()

  be_attack: (hp_change)->
    @$el
      .delay(@TIME / 2)
      .animate
        top: @top() - @CONST_W / 6
        , @TIME / 4
      .animate
        top: @top()
        , @TIME / 4

    @hp_change hp_change


    if @character.remove_flag
      @$el.fadeOut => @$el.remove()

  fireball: (dir, target, hp_change)->
    if target
      target.ani.be_attack(hp_change)

    # 蓄力动画
    $spark1 = jQuery('<div></div>')
      .addClass('item').addClass('spark')
      .css
        left: @left() - @CONST_W / 2
        top:  @top() - @CONST_W / 2
    $spark2 = jQuery('<div></div>')
      .addClass('item').addClass('spark')
      .css
        left: @left() + @CONST_W / 2
        top:  @top() - @CONST_W / 2
    $spark3 = jQuery('<div></div>')
      .addClass('item').addClass('spark')
      .css
        left: @left() + @CONST_W / 2
        top:  @top() + @CONST_W / 2
    $spark4 = jQuery('<div></div>')
      .addClass('item').addClass('spark')
      .css
        left: @left() - @CONST_W / 2
        top:  @top() - @CONST_W / 2

    $spark1.appendTo(@$game).animate
      left: @left()
      top:  @top()
      150, => $spark1.remove()
    $spark2.appendTo(@$game).delay(25).animate
      left: @left()
      top:  @top()
      125, => $spark2.remove()
    $spark3.appendTo(@$game).delay(50).animate
      left: @left()
      top:  @top()
      100, => $spark3.remove()
    $spark4.appendTo(@$game).delay(75).animate
      left: @left()
      top:  @top()
      75, =>
        AniSound.fireball()
        $spark4.remove()
        $fireball = jQuery('<div></div>')
          .addClass('item').addClass('fireball')
          .css
            left: @left()
            top:  @top()
          .appendTo(@$game)
          .animate
            left: target.ani.left()
            top:  target.ani.top()
            , 150, =>
              @_rendered()
              $fireball.delay(300).hide 1, => $fireball.remove()

  excited: ->
    @$el.addClass('excited')
    setTimeout =>
      @_rendered()
    , @TIME * 2

  explode: ->
    AniSound.explode()
    @$el
      .removeClass('excited')
      .addClass('explode')

    setTimeout =>
      @_rendered()
    , @TIME

  idle: ->
    @_rendered()

  _rendered: ->
    # jQuery(document).trigger 'js-warrior:render-ui-success', @character
    jQuery(document).trigger 'js-warrior:action-rendered'

class GameUi
  constructor: ->
    @CONST_W = 60
    @$game = jQuery('.page-js-warrior-game')
    @init_events()

  init_events: ->
    jQuery('.page-control-panel .btns .start').on 'click', (evt)=>
      code = jQuery('.page-control-panel textarea.code').val()
      jQuery(document).trigger 'js-warrior:start', code

    jQuery(document).on 'js-warrior:win', (evt)=>
      alert('你过关了！！')

    jQuery(document).on 'js-warrior:lose', (evt)=>
      alert('你失败了 :(')

    jQuery(document).on 'js-warrior:init-ui', (evt, level)=>
      @level = level
      @init()

    jQuery(document).on 'js-warrior:render-ui', (evt)=>
      actions = @level.actions_queue
      console.log actions
      return @warrior.ani.idle() if actions.length == 0

      @ani_action_queue_length = actions.length

      for i in [0...actions.length]
        actions[i].next_action = actions[i + 1]

      @do_ani_action actions[0]

    jQuery(document).on 'js-warrior:action-rendered', (evt)=>
      @ani_action_queue_length--

      if @ani_action_queue_length <= 0
        jQuery(document).trigger 'js-warrior:render-ui-success'


  do_ani_action: (action)=>
    # console.log action, action.type

    type = action.type
    ani  = action.actor.ani

    if 'walk' == type
      ani.walk(action.direction)

    if 'attack' == type
      ani.attack(action.direction, action.target, action.hp_change)

    if 'rest' == type
      ani.rest(action.hp_change)

    if 'shot' == type
      ani.shot(action.direction, action.target, action.hp_change)

    if 'magic' == type
      ani.fireball(action.direction, action.target, action.hp_change)

    if 'excited' == type
      ani.excited()

    if 'explode' == type
      ani.explode()
      for target in action.targets
        if target.ani
          target.ani.be_attack(action.hp_change)

    if 'dart' == type
      ani.dart(action.direction, action.target, action.hp_change)

    if action.next_action
      setTimeout =>
        @do_ani_action action.next_action
      , 150


      # if info.target
      #   alert('creeper 爆炸') if info.target.class_name() == "creeper"
      #   info.target.ani.be_attack(info.hp_change)
      # jQuery(document).trigger 'js-warrior:render-ui-success', character

      # if 'interact' == info.type
      #   console.log info.targets
      #   jQuery(document).trigger 'js-warrior:render-ui-success', character



  init: ->
    @init_map()
    @init_render()

    return this

  init_map: ->
    @_draw_ground()

    for y in [0...@level.height]
      for x in [0...@level.width]
        space = @level.get_space(x, y)
        if !space.is_empty()
          @_draw_units space

    @$game.fadeIn(300)

  _draw_ground: ->
    @max_x = @level.width - 1
    @max_y = @level.height - 1

    css_width = @level.width * @CONST_W
    css_height = @level.height * @CONST_W

    @$game.css
      width: css_width
      height: css_height

  _draw_units: (space)->
    
    for unit in space.units()
      class_name = unit.class_name()
      type = unit.type()

      if class_name == 'warrior'
        @warrior = unit 

      unit.ani = new UnitAni(@, unit)

  init_render: ->
    @fps = 120
    @interval = 1000 / @fps

    @now = Date.now()
    @last_second = Math.floor(@now / 1000)
    @frame_count = Math.ceil((@now % 1000) / @fps)

    @run()

  run: ->
    setInterval =>
      @now = Date.now()
      second = Math.floor(@now / 1000)
      mill_second = @now % 1000

      if second != @last_second
        @frame_count = 0
        @last_second = second

      if @frame_count < @fps && mill_second >= @frame_count * @interval
        @frame_count++

        @render()
    , 1

  render: ->
    if @frame_count % 30 == 0
      jQuery('.page-js-warrior-game').toggleClass('f0')

window.GameUi = GameUi