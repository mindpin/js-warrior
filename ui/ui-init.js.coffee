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

          path = window.location.pathname

          @editor = ace.edit("code-input")
          @editor.setTheme("ace/theme/twilight")
          @editor.setHighlightActiveLine(false)

          @editor.getSession().setMode("ace/mode/javascript")
          @editor.getSession().setTabSize(2)
          @editor.getSession().setUseWrapMode(true)

          # 读取本地保存代码
          if localStorage[path]
            @editor.getSession().setValue localStorage[path]

          # 定期保存代码到本地存储
          setInterval =>
            code = @editor.getSession().getValue()
            localStorage[path] = code
          , 100

          @jqconsole = jQuery('.page-log .console').jqconsole('这里是 js-warrior 的日志：', '> ')

          window.game_ui = new GameUi(@editor, @jqconsole)
          window.game = new Game(level_data)
          window.game.init()