class AniSound
  @walk: ->
    new Audio("../sound/step1.mp3").play()
  @attack: ->
    new Audio("../sound/attack.mp3").play()
  @rest: ->
    new Audio("../sound/heal.mp3").play()
  @shot: ->
    new Audio("../sound/arrow.mp3").play()
  @fireball: ->
    new Audio("../sound/fireball.mp3").play()
  @explode: ->
    new Audio("../sound/explode.mp3").play()
  @pick: ->
    new Audio("../sound/pick.mp3").play()
  @open_lock: ->
    new Audio("../sound/open_lock.mp3").play()


class UnitAni
  constructor: (@game_ui, @character)->
    @CONST_W = @game_ui.CONST_W
    @TIME = 300

    @$game = @game_ui.$game
    @jqconsole = @game_ui.jqconsole

    @type = @character.type()
    @class_name = @character.class_name()


    @$el = @_build_el()
    @_refresh_hp_dom()

  get_name: ->
    {
      'warrior': '勇者'
      'slime': '史莱姆'
      'tauren': '牛头人'
      'archer': '弓箭手'
      'wizard': '魔法师'
      'creeper': '苦力怕'
      'shuriken': '手里剑'
      'key': '钥匙'
      'diamond': '宝石'
      'wall': '墙'
    }[@class_name]

  get_dir_str: (dir)->
    {
      'up': '上'
      'down': '下'
      'left': '左'
      'right': '右'
      'left-up': '左上'
      'left-down': '左下'
      'right-up': '右上'
      'right-down': '右下'
    }[dir]

  destroy: ->
    @$el.remove()

  _build_el: ->
    # 图标
    $ui_el = jQuery('<div></div>')
      .addClass(@type)
      .addClass(@class_name)      
      .css
        left: @left()
        top:  @top()
      .appendTo(@$game)

    if @type == 'item'
      $count = jQuery('<div></div>')
        .addClass('item-count')
        .appendTo($ui_el)

      $count.html if @character.count > 0 then "×#{@character.count}" else ''


    if @class_name == 'warrior'
      @$item_counts = jQuery("<div></div>")
        .addClass('warrior-item-counts')
        .appendTo(@game_ui.$game)

      $shuriken_count = jQuery("<div><div class='icon'></div><div class='count'></div></div>")
        .addClass('shuriken')
        .appendTo(@$item_counts)

      $key_count = jQuery("<div><div class='icon'></div><div class='count'></div></div>")
        .addClass('key')
        .appendTo(@$item_counts)

      $diamond_count = jQuery("<div><div class='icon'></div><div class='count'></div></div>")
        .addClass('diamond')
        .appendTo(@$item_counts)

      @refresh_warrior_items()

    return $ui_el

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
    @jqconsole.Write "#{@get_name()}向#{@get_dir_str(dir)}走了一格"

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
    @jqconsole.Write "#{@get_name()}向#{@get_dir_str(dir)}攻击"

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
    @jqconsole.Write "#{@get_name()}向#{@get_dir_str(dir)}射箭"
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

  dart: (action)->
    dir = action.direction
    target_space = action.target_space
    target = action.target
    hp_change = action.hp_change

    AniSound.shot()
    @jqconsole.Write "#{@get_name()}向#{@get_dir_str(dir)}投掷手里剑"
    @_change_face_dir(dir)

    if target
      target.ani.be_attack(hp_change)

    $shuriken = jQuery('<div></div>')
      .addClass('item').addClass('shuriken').addClass('flying').addClass(dir)
      .appendTo(@$game)

    $shuriken
      .css
        left: @left()
        top: @top()
      .delay(0)
      .animate
        left: target_space.x * @CONST_W
        top:  target_space.y * @CONST_W
        easing: 'easeout'
        , @TIME / 2, =>
          setTimeout =>
            $shuriken.fadeOut => $shuriken.remove()

            if target_space.item
              target_space.item.ani.destroy() if target_space.item.ani
              target_space.item.ani = new UnitAni(@game_ui, target_space.item)

            @_rendered()
          , @TIME / 4

  hp_change: (change, func)->
    return if @character.type() == 'item'

    if change >= 0
      @jqconsole.Write "#{@get_name()}回复#{change}点生命值", 'heal'
      klass = 'heal'
      html = "+#{change}"
    else
      @jqconsole.Write "#{@get_name()}受到#{-change}点伤害", 'damage'
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
    @jqconsole.Write "#{@get_name()}原地休息"

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
      if @type == 'item'
        @jqconsole.Write "#{@get_name()}被摧毁了", 'remove'
      if @type == 'character'
        @jqconsole.Write "#{@get_name()}消失了", 'remove'
      @$el.fadeOut => @$el.remove()

  fireball: (dir, target, hp_change)->
    if target
      target.ani.be_attack(hp_change)

    @jqconsole.Write "#{@get_name()}向#{@get_dir_str(dir)}发射火球术"

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
    @jqconsole.Write "#{@get_name()}进入了激活状态，快躲开！"
    @$el.addClass('excited')
    setTimeout =>
      @_rendered()
    , @TIME * 2

  explode: ->
    @jqconsole.Write "#{@get_name()}爆炸了！"
    AniSound.explode()
    @$el
      .removeClass('excited')
      .addClass('explode')

    setTimeout =>
      @_rendered()
    , @TIME

  interact: (dir, item)->
    # 捡东西
    # 被捡起来的东西消失
    @_change_face_dir(dir)


    if item
      if item.class_name() == 'lock'
        AniSound.open_lock()
        item.ani.fade => @_rendered()
        @jqconsole.Write "#{@get_name()}打开了锁，消耗一把钥匙"
      else
        AniSound.pick()
        @jqconsole.Write "#{@get_name()}捡起了#{item.ani.get_name()}"
        item.ani.$el
          .addClass('picked')
          .animate
            left: @left()
            top: @top()
            =>
              item.ani.$el.remove()
              @_rendered()
    else
      @_rendered()


  fade: (func)->
    @$el.fadeOut => 
      @$el.remove()
      func() if func

  idle: (action)->
    if @class_name == 'warrior'
      if action.action.constructor == Walk
        @jqconsole.Write "#{@get_name()}想要向#{@get_dir_str(action.direction)}走，但是被挡住了"
      if action.action.constructor == Interact
        @jqconsole.Write "#{@get_name()}想要捡起#{@get_dir_str(action.direction)}边的物品，但是被挡住了"
      if action.action.constructor == Attack
        @jqconsole.Write "#{@get_name()}想要攻击#{@get_dir_str(action.direction)}边，但是被挡住了"

    @_rendered()

  _rendered: ->
    jQuery(document).trigger 'js-warrior:action-rendered'

  refresh_warrior_items: ->
    return if @class_name != 'warrior'
    @$item_counts.find('.shuriken .count').html @character.count('shuriken')
    @$item_counts.find('.key .count').html @character.count('key')
    @$item_counts.find('.diamond .count').html @character.count('diamond')

class GameUi
  constructor: (@editor, @jqconsole)->
    @CONST_W = 60
    @$game = jQuery('.page-js-warrior-game')
    @init_events()

  _run_code: ->
    $panel = jQuery('.page-code-panel')
    code = @editor.getSession().getValue()
    $panel.find('.btns').addClass('started')

    if window.eachline_run
      return jQuery(document).trigger 'js-warrior-eachline:start', code

    jQuery(document).trigger 'js-warrior:start', code

  unbind_events: ->
    $panel = jQuery('.page-code-panel')
    $panel.find('.btns .start').off 'click'
    $panel.find('.btns .stop').off 'click'

    jQuery(document).off 'js-warrior:win'
    jQuery(document).off 'js-warrior:lose'
    jQuery(document).off 'js-warrior:error'
    jQuery(document).off 'js-warrior:init-ui'
    jQuery(document).off 'js-warrior:render-ui'
    jQuery(document).off 'js-warrior:action-rendered'

    jQuery(document).off 'js-warrior-eachline:init-ui'

  init_events: ->
    @unbind_events()

    $panel = jQuery('.page-code-panel')

    $panel.find('.btns .start').on 'click', (evt)=>
      @_run_code()

    $panel.find('.btns .stop').on 'click', (evt)=>
      @stop()
      window.game.level.end()
      @$game.html('')

      @jqconsole.Reset()

      window.game_ui = new GameUi(@editor, @jqconsole)
      window.game = new Game(window.level_data, {
        'eachline': window.eachline_run
      })
      window.game.init()

      $panel.find('.btns').removeClass('started')

    jQuery(document).on 'js-warrior:win', (evt)=>
      @jqconsole.Write '你过关了！！', 'win'

    jQuery(document).on 'js-warrior:lose', (evt)=>
      if @level.key_not_enough()
        msg = '钥匙不足以打开全部的锁'
      if @level.has_diamond_destroy()
        msg = '宝石被摧毁了，'
      if @warrior.remove_flag 
        msg = '勇者被干掉了，'
      if @level.is_too_many_idles()
        msg = "闲置回合数过多，"

      @jqconsole.Write "#{msg}你失败了 :(", 'lose'

    jQuery(document).on 'js-warrior:error', (evt, error)=>
      console.log error, error.message, error.stack
      if error.constructor == WarriorNotActionError 
        return @jqconsole.Write '勇者没有进行任何行动，执行中止', 'error'
      if error.constructor == DuplicateActionsError
        return @jqconsole.Write '勇者一回合内尝试行动了两次，执行中止', 'error'
      if error.constructor == EachlineWarriorNotActionError
        return @jqconsole.Write '勇者没有进行任何行动，执行中止', 'error'

      @jqconsole.Write "程序出错: #{error.message}", 'error'

    jQuery(document).on 'js-warrior:init-ui', (evt, level)=>
      @level = level
      @init()

    jQuery(document).on 'js-warrior:render-ui', (evt)=>
      actions = @level.actions_queue
      @ani_action_queue_length = actions.length
      return @warrior.ani._rendered() if actions.length == 0


      for i in [0...actions.length]
        actions[i].next_action = actions[i + 1]

      @do_ani_action actions[0]

    jQuery(document).on 'js-warrior:action-rendered', (evt)=>
      @ani_action_queue_length--
      if @ani_action_queue_length <= 0
        jQuery(document).trigger 'js-warrior:render-ui-success'


  do_ani_action: (action)=>

    type = action.type
    ani  = action.actor.ani

    if @current_round != @level.current_round
      @current_round = @level.current_round
      @jqconsole.Write "-----第#{@current_round}回合-----", 'round'

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
      ani.dart(action)

    if 'interact' == type
      ani.interact(action.direction, action.item)

    if 'idle' == type
      ani.idle(action)

    if action.next_action
      setTimeout =>
        @do_ani_action action.next_action
      , 150

    @warrior.ani.refresh_warrior_items()

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
    @runner = setInterval =>
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

  stop: ->
    clearInterval @runner

  render: ->
    if @frame_count % 30 == 0
      jQuery('.page-js-warrior-game').toggleClass('f0')

window.GameUi = GameUi
