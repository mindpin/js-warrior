jQuery ->
  jQuery.ajax
    url: "../game/body.html?#{Math.random()}"
    success: (res)->
      jQuery('body').prepend res

      jQuery.ajax
        url: "../game/api.html?#{Math.random()}"
        success: (res)->
          jQuery('.page-api').html res

      jQuery.ajax
        url: "../game/intro.html?#{Math.random()}"
        success: (res)->
          jQuery('.page-intro').html res

      jQuery.ajax
        url: "../game/control.html?#{Math.random()}"
        success: (res)->
          jQuery('.page-code-panel').html res

          path = window.location.pathname

          @editor = ace.edit("code-input")
          @editor.setTheme("ace/theme/twilight")
          @editor.setHighlightActiveLine(false)

          @editor.getSession().setMode("ace/mode/javascript")
          @editor.getSession().setTabSize(2)
          @editor.getSession().setUseWrapMode(true)

          if jQuery('.page-init-code').length > 0
            @editor.getSession().setValue jQuery('.page-init-code').val()
          else
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
          window.game = new Game(level_data, {
            'eachline': window.eachline_run
          })

          window.game.init()