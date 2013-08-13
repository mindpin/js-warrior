class CharacterAni
  constructor: (@game_ui, @character)->
    @CONST_W = @game_ui.CONST_W
    @$el = @character.ui_el
    @$game = @game_ui.$game

  posx: ->
    @$el.data('x') * @CONST_W
  posy: ->
    @$el.data('y') * @CONST_W

  _xydelta: (dir)->
    hash = 
      'right': [ 1,  0]
      'left' : [-1,  0]
      'up'   : [ 0, -1]
      'down' : [ 0,  1]

    arr = hash[dir]

    return {
      dx: arr[0]
      dy: arr[1]
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

  be_attack: (damage)->
    x = @$el.data('x')
    y = @$el.data('y')

    @$el
      .delay(150)
      .animate
        top: y * @CONST_W - 10
        , 75
      .animate
        top: y * @CONST_W
        , 75

    if damage
      $damage_el = 
        jQuery('<div class="damage-num"></div>')
          .html("-#{damage}")
          .appendTo(@$game)

      $damage_el
        .css
          left: @posx()
          top: @posy() + @CONST_W / 2
        .animate
          left: @posx()
          top: @posy()
          => $damage_el.fadeOut()

      if @character.remove_tag
        @$el.fadeOut()


  attack: (dir)->
    x = @$el.data('x')
    y = @$el.data('y')

    delta = @_xydelta(dir)
    @_change_face_dir(dir)

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
          @$el.css
            'z-index': ''
          @_rendered()
            
    return @

  walk: (dir)->
    x = @$el.data('x')
    y = @$el.data('y')

    delta = @_xydelta(dir)
    @_change_face_dir(dir)

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

      if 'idle' == info.type
        character.ani.idle()

      if 'walk' == info.type
        character.ani.walk(info.direction)

      if 'attack' == info.type
        character.ani.attack(info.direction)
        if info.target
          info.target.ani.be_attack(info.damage)

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

  ani_fireball: (dir)->
    $el = @warrior.ui_el
    x = $el.data('x')
    y = $el.data('y')

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

          $fireball = jQuery('<div></div>')
            .addClass('item').addClass('fireball')
            .css
              left: x * @CONST_W
              top:  y * @CONST_W
            .appendTo(@$game)
            .animate
              left: (x + 3) * @CONST_W
              top:  y * @CONST_W
              , =>
                $fireball.delay(300).hide 1, => $fireball.remove()

window.GameUi = GameUi