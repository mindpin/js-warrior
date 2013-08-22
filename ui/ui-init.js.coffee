jQuery ->
  jQuery.ajax
    url: 'body.html'
    success: (res)->
      jQuery('body').prepend res

      jQuery.ajax
        url: 'api.html'
        success: (res)->
          jQuery('.page-api').html res

      jQuery.ajax
        url: 'intro.html'
        success: (res)->
          jQuery('.page-intro').html res

      jQuery.ajax
        url: "control.html?#{Math.random()}"
        success: (res)->
          jQuery('.page-code-panel').html res

          window.game_ui = new GameUi()
          window.game = new Game(level_data)
          window.game.init()