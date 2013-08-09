jQuery ->
  class GameUi
    constructor: ->
      @init()
      @run()

    init: ->
      @fps = 120
      @interval = 1000 / @fps

      @now = Date.now()
      @last_second = Math.floor(@now / 1000)
      @frame_count = Math.ceil((@now % 1000) / @fps)

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

  new GameUi()