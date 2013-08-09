class GameUi
  constructor: (@level)->
    @CONST_W = 60

    @$game = jQuery('.page-js-warrior-game')

  init: ->
    @init_map()
    @init_render()

  init_map: ->
    @_draw_ground()

    for y in [0...@level.height]
      for x in [0...@level.width]
        space = @level.get_space(x, y)
        if !space.is_empty()
          @_draw_unit space

    @$game.fadeIn(300)

  _draw_ground: ->
    css_width = @level.width * @CONST_W
    css_height = @level.height * @CONST_W

    @$game.css
      width: css_width
      height: css_height

  _draw_unit: (space)->
    pos_x = space.x * @CONST_W
    pos_y = space.y * @CONST_W
    
    if space.character
      $unit = jQuery('<div></div>')
        .addClass('character').addClass('warrior').addClass('down')
        .css
          left: pos_x
          top: pos_y
        .appendTo(@$game)

    if space.item
      $unit = jQuery('<div></div>')
        .addClass('item').addClass('key')
        .css
          left: pos_x
          top: pos_y
        .appendTo(@$game)

    if space.shurikens().length > 0
      $unit = jQuery('<div></div>')
        .addClass('item').addClass('shuriken')
        .css
          left: pos_x
          top: pos_y
        .appendTo(@$game)


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
    console.log @now
    if @frame_count % 30 == 0
      jQuery('.character').toggleClass('f0')

window.GameUi = GameUi