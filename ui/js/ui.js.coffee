class CharacterAni
  constructor: (@game_ui, @character)->
    @CONST_W = @game_ui.CONST_W
    @$el = @character.ui_el
    @_refresh_hp_dom()

    @$game = @game_ui.$game

  _refresh_hp_dom: ->
    if @character.type() == 'character'
      if !@$hp
        @$hp = jQuery("<div class='hp'></div>")
          .appendTo(@$el)

      @$hp.html(@character.health)

  posx: ->
    @$el.data('x') * @CONST_W
  posy: ->
    @$el.data('y') * @CONST_W

  _xydelta: (dir, distance)->
    d = distance || 1

    hash = 
      'right': [ 1,  0]
      'left' : [-1,  0]
      'up'   : [ 0, -1]
      'down' : [ 0,  1]

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

  _rendered: ->
    jQuery(document).trigger 'js-warrior:render-ui-success', @character

  fireball: (dir)->
    x = @$el.data('x')
    y = @$el.data('y')

    if dir == 'right'
      # 蓄力动画
      $spark1 = jQuery('<div></div>')
        .addClass('item').addClass('spark')
        .css
          left: (x - 0.5) * @CONST_W
          top:  (y - 0.5) * @CONST_W
      $spark2 = jQuery('<div></div>')
        .addClass('item').addClass('spark')
        .css
          left: (x + 0.5) * @CONST_W
          top:  (y - 0.5) * @CONST_W
      $spark3 = jQuery('<div></div>')
        .addClass('item').addClass('spark')
        .css
          left: (x + 0.5) * @CONST_W
          top:  (y + 0.5) * @CONST_W
      $spark4 = jQuery('<div></div>')
        .addClass('item').addClass('spark')
        .css
          left: (x - 0.5) * @CONST_W
          top:  (y + 0.5) * @CONST_W

      $spark1.appendTo(@$game).animate
        left: x * @CONST_W
        top:  y * @CONST_W
        , => $spark1.remove()


      $spark2.appendTo(@$game).delay(50).animate
        left: x * @CONST_W
        top:  y * @CONST_W
        , => $spark2.remove()

      $spark3.appendTo(@$game).delay(100).animate
        left: x * @CONST_W
        top:  y * @CONST_W
        , => $spark3.remove()

      $spark4.appendTo(@$game).delay(150).animate
        left: x * @CONST_W
        top:  y * @CONST_W
        , =>
          $spark4.remove()

          new Audio("js/fireball.mp3?a").play()

          $fireball = jQuery('<div></div>')
            .addClass('item').addClass('fireball')
            .css
              left: x * @CONST_W
              top:  y * @CONST_W
            .appendTo(@$game)
            .animate
              left: (x + 3) * @CONST_W
              top:  y * @CONST_W
              , 250, =>
                $fireball.delay(300).hide 1, => $fireball.remove()

  shot: (dir, distance)->
    x = @$el.data('x')
    y = @$el.data('y')

    delta = @_xydelta(dir, distance)

    new Audio("js/arrow.mp3?a").play()


    $arrow = jQuery('<div></div>')
      .addClass('item').addClass('arrow').addClass(dir)
      .appendTo(@$game)

    $arrow
      .css
        left: @posx()
        top: @posy()
      .delay(50)
      .animate
        left: (x + delta.dx) * @CONST_W
        top:  (y + delta.dy) * @CONST_W
        easing: 'easeout'
        , 250, =>
          setTimeout =>
            $arrow.fadeOut => $arrow.remove()
          , 100

  rest: (hp_change)->
    x = @$el.data('x')
    y = @$el.data('y')  

    $hp_change_el = 
      jQuery('<div class="hp-change heal"></div>')
        .html("+#{hp_change}")
        .appendTo(@$game)

    new Audio("js/heal.mp3?a").play()
    $hp_change_el
      .css
        left: @posx()
        top: @posy()
      .animate
        left: @posx()
        top: @posy() - @CONST_W / 2
        'font-size':40
        => 
          $hp_change_el.fadeOut => $hp_change_el.remove()
          @_refresh_hp_dom()
          @_rendered()

  be_attack: (hp_change)->
    x = @$el.data('x')
    y = @$el.data('y')

    @$el
      .delay(150)
      .animate
        top: y * @CONST_W - @CONST_W / 6
        , 75
      .animate
        top: y * @CONST_W
        , 75

    if hp_change
      $damage_el = 
        jQuery('<div class="hp-change damage"></div>')
          .html(hp_change)
          .appendTo(@$game)

      $damage_el
        .css
          left: @posx()
          top: @posy()
        .animate
          left: @posx()
          top: @posy() - @CONST_W / 2
          'font-size':40
          => 
            $damage_el.fadeOut => $damage_el.remove()
            @_refresh_hp_dom()

      if @character.remove_tag
        @$el.fadeOut => @$el.remove()

  attack: (dir)->
    x = @$el.data('x')
    y = @$el.data('y')

    delta = @_xydelta(dir)
    @_change_face_dir(dir)

    new Audio("js/attack.mp3?a").play()
    @$el
      .css
        'z-index': 10
      .animate
        left: (x + delta.dx) * @CONST_W
        top:  (y + delta.dy) * @CONST_W
        , 150
      .animate
        left: x * @CONST_W
        top:  y * @CONST_W
        , 150, => 
          setTimeout =>
            @$el.css
              'z-index': ''
            @_rendered()
          , 0
            
    return @

  walk: (dir)->
    x = @$el.data('x')
    y = @$el.data('y')

    delta = @_xydelta(dir)
    @_change_face_dir(dir)

    new Audio("js/step1.mp3?ab").play()
    @$el
      .data
        x: (x + delta.dx)
        y: (y + delta.dy)

    @$el
      .animate
        left: (x + delta.dx) * @CONST_W
        top:  (y + delta.dy) * @CONST_W
        => @_rendered()

    return @


  idle: ->
    @_rendered()

class GameUi
  constructor: ->
    @CONST_W = 60
    @$game = jQuery('.page-js-warrior-game')
    @init_events()

  init_events: ->
    jQuery('.page-control-panel .btns .start').on 'click', (evt)=>
      code = jQuery('.page-control-panel textarea.code').val()
      jQuery(document).trigger 'js-warrior:start', code

    jQuery(document).on 'js-warrior:init-ui', (evt, level)=>
      @level = level
      @init()

    jQuery(document).on 'js-warrior:render-ui', (evt, character)=>
      info = character.action_info

      console.log(character.class_name(), info)
      if 'idle' == info.type
        character.ani.idle()

      if 'walk' == info.type
        character.ani.walk(info.direction)

      if 'attack' == info.type
        character.ani.attack(info.direction)
        if info.target
          info.target.ani.be_attack(info.hp_change)

      if 'rest' == info.type
        character.ani.rest(info.hp_change)

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

      # 图标
      $ui_el = jQuery('<div></div>')
        .addClass(type)
        .addClass(class_name)
        
        .data
          x: space.x
          y: space.y
        
        .css
          left: space.x * @CONST_W
          top:  space.y * @CONST_W

        .appendTo(@$game)

      unit.ui_el = $ui_el
      unit.ani = new CharacterAni(@, unit)

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