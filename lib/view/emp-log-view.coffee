{Disposable, CompositeDisposable} = require 'atom'
{$, $$, View, TextEditorView} = require 'atom-space-pen-views'
emp_log = require '../debugger/emp_view_log'
default_client_id = 'All'
emp = require '../exports/emp'

module.exports =
class EmpDebuggerLogView extends View
  emp_conf_view: null
  line_height: null
  line_number: null
  default_ln: null
  # state: true      #
  first_show: true #是否为第一次显示
  show_state: false # 当前 log pane 是否为显示状态
  stop_state: false
  selected_client: default_client_id

  color_arr: ["#000033", "#000066", "#000099", "#0000CC", "#0000FF",
              "#003300", "#003333", "#003366", "#003399", "#0033CC", "#0033FF",
              "#006600", "#006633", "#006666", "#006699", "#0066CC", "#0066FF",
              "#009900", "#009933", "#009966", "#009999", "#0099CC", "#0099FF",
              "#00CC00", "#00CC33", "#00CC66", "#00CC99", "#00CCCC", "#00CCFF",
              "#00FF00", "#00FF33", "#00FF66", "#00FF99", "#00FFCC", "#00FFFF",
              "#330000", "#330033", "#330066", "#330099", "#3300CC", "#3300FF",
              "#333300", "#333333", "#333366", "#333399", "#3333CC", "#3333FF",
              "#336600", "#336633", "#336666", "#336699", "#3366CC", "#3366FF",
              "#339900", "#339933", "#339966", "#339999", "#3399CC", "#3399FF",
              "#33CC00", "#33CC33", "#33CC66", "#33CC99", "#33CCCC", "#33CCFF",
              "#33FF00", "#33FF33", "#33FF66", "#33FF99", "#33FFCC", "#33FFFF",
              "#660000", "#660033", "#660066", "#660099", "#6600CC", "#6600FF",
              "#663300", "#663333", "#663366", "#663399", "#6633CC", "#6633FF",
              "#666600", "#666633", "#666666", "#666699", "#6666CC", "#6666FF",
              "#669900", "#669933", "#669966", "#669999", "#6699CC", "#6699FF",
              "#66CC00", "#66CC33", "#66CC66", "#66CC99", "#66CCCC", "#66CCFF",
              "#66FF00", "#66FF33", "#66FF66", "#66FF99", "#66FFCC", "#66FFFF",
              "#990000", "#990033", "#990066", "#990099", "#9900CC", "#9900FF",
              "#993300", "#993333", "#993366", "#993399", "#9933CC", "#9933FF",
              "#996600", "#996633", "#996666", "#996699", "#9966CC", "#9966FF",
              "#999900", "#999933", "#999966", "#999999", "#9999CC", "#9999FF",
              "#99CC00", "#99CC33", "#99CC66", "#99CC99", "#99CCCC", "#99CCFF",
              "#99FF00", "#99FF33", "#99FF66", "#99FF99", "#99FFCC", "#99FFFF",
              "#CC0000", "#CC0033", "#CC0066", "#CC0099", "#CC00CC", "#CC00FF",
              "#CC3300", "#CC3333", "#CC3366", "#CC3399", "#CC33CC", "#CC33FF",
              "#CC6600", "#CC6633", "#CC6666", "#CC6699", "#CC66CC", "#CC66FF",
              "#CC9900", "#CC9933", "#CC9966", "#CC9999", "#CC99CC", "#CC99FF",
              "#CCCC00", "#CCCC33", "#CCCC66", "#CCCC99", "#CCCCCC", "#CCCCFF",
              "#CCFF00", "#CCFF33", "#CCFF66", "#CCFF99", "#CCFFCC", "#CCFFFF",
              "#FF0000", "#FF0033", "#FF0066", "#FF0099", "#FF00CC", "#FF00FF",
              "#FF3300", "#FF3333", "#FF3366", "#FF3399", "#FF33CC", "#FF33FF",
              "#FF6600", "#FF6633", "#FF6666", "#FF6699", "#FF66CC", "#FF66FF",
              "#FF9900", "#FF9933", "#FF9966", "#FF9999", "#FF99CC", "#FF99FF",
              "#FFCC00", "#FFCC33", "#FFCC66", "#FFCC99", "#FFCCCC", "#FFCCFF",
              "#FFFF00", "#FFFF33", "#FFFF66", "#FFFF99", "#FFFFCC"]
  log_map: {}

  @content: ->
    @div class: 'emp-log-pane tool-panel pannel panel-bottom padding', =>
      # @div class: 'log-console-resize-handle', mousedown: 'resizeStarted', dblclick: 'resizeToMin'
      @div class: 'emp_bar panel-heading padded', mousedown: 'resizeStarted', dblclick: 'resizeToMin',=>
        @span 'Log From The Script Of Views: '
        @div class:'bar_div', =>
          @button class: 'btn btn_right2', click: 'clear_log', 'Clear'
          @button class: 'btn-warning btn  inline-block-tight btn_right', click: 'hide_log_view', 'Hide'
      # @ul class: 'log-console list-group', outlet:'listView'
      @div outlet:"emp_log_panel", class:'emp-log-panel',  =>
        @div outlet:"emp_log_view", id:'emp_log_view', class:'emp-log-view', =>
          @div outlet: 'emp_lineNumber', class: 'line-numbers'
          @div outlet: 'log_detail', id:'emp_log_row', class: 'emp-log-row native-key-bindings',tabindex: -1

      @div class: 'emp_footer panel-heading padded', =>
        @ul class:'foot_ul', =>
          @li class:'foot_lf_li', =>
        # @div class:'foot_div', =>
            @select outlet:"client_select", id: "client", class: '', =>
              @option value: 'test', "test"
          @li class:'foot_li', =>
            @subview 'lua_console', new TextEditorView(mini: true, attributes: {id: 'lua_console', type: 'string'},  placeholderText: 'Lua Console')



  initialize: ()->
    @line_number = 1
    @disposable = new CompositeDisposable
    @disposable.add atom.commands.add "atom-workspace","emp-debugger:view-log", => @toggle()
    # atom.commands.add "core:move-up", => console.log "this is a roll ----------"
    # @emp_log_view.on "core:move-up", =>
    @disposable.add atom.commands.add @lua_console.element, 'core:confirm', =>
      @do_send_lua()

    @disposable.add @client_select.change =>
      @selected_client = @client_select.val()
    # @emp_log_view.scrollUp (e) =>
      # console.log "up up up up up up "
    # @emp_log_view.scroll (e)=>
      # console.log e
      # console.log b
      # console.log c
      # console.log @emp_log_view
      # console.log @emp_log_view.scrollTop
      # console.log "---emp_log_view scroll"

    # @test()
  dispose: ->
    @disposable?.dispose()

  serialize: ->
    attached: @hasParent()

  destroy: ->
    @detach()

  detach: ->
    @disposable?.dispose()

  set_conf_view: (@emp_conf_view)->


  update_ln: ->
    html = ''
    # console.log @log_detail.css('height')
    # console.log @get_int(@log_detail.css('height'))
    # console.log @get_line_number_count()
    @line_number = @get_line_number_count()
    @line_number = @default_ln unless @line_number+1 >@default_ln

    for row in [1..@line_number+1]
      rowValue = " "+ row
      classes = "line-number line-number-#{row}"
      html += """<div class="#{classes}" > #{rowValue}<div class="icon-right"></div></div>"""

    # html += @update_else_ln() unless @line_number+1 >@default_ln
    # console.log @emp_lineNumber
    @emp_lineNumber[0].innerHTML = html

  update: ->
    tmp_log_map = @log_map

    for name, view_logs of tmp_log_map
      @log_detail.append $$ ->
        tmp_color = view_logs.get_color()
        @pre class: "emp-log-con", style:"color:#{tmp_color}; padding:0px;", "########################## CLIENT:#{view_logs.get_id()} ##########################"
        # @p class: "emp-log-con", style:"color:#{tmp_color};padding:0px;", "########################## CLIENT:#{view_logs.get_id()} ##########################"

        for tmp_log in view_logs.get_log()
          for log in tmp_log.split("\n")
            if log isnt "" and log isnt " "
              @pre class: "emp-log-con",style:"color:#{tmp_color};padding:0px;", "#{log}"

    # console.log @log_detail.context.scrollHeight
    # console.log
    # console.log @log_detail.indexOf
    # @log_detail.scrollToBottom()
    @emp_log_view.scrollToBottom()
    # $('#emp_log_view').stop().animate({scrollTop:@log_detail.context.scrollHeight}, 1000)

    # $("#log_content").stop().animate({
    #   scrollTop: document.getElementById("log_content").scrollHeight
    # }, 1000);

  show_live_log: (client_id, log, show_color) ->
    @do_show_live_log(client_id, log, show_color) unless @first_show

  do_show_live_log: (client_id, log, show_color)->
    # console.log "do_show_live_log"
    start_color_ln = @get_line_number_count()
    @update_log(client_id, log, show_color)
    @update_gutter(show_color, start_color_ln, client_id)

  update_gutter: (show_color, start_color_ln, client_id)->
    # console.log @log_detail.css('height')
    # console.log @get_int(@log_detail.css('height'))
    # console.log @get_line_number_count()
    end_ln = @get_line_number_count()
    start_ln = @line_number+1
    # console.log "update_gutter: s: #{start_ln} ,e: #{end_ln}"
    # console.log "ln: #{@line_number}, s: #{start_color_ln}"
    @do_update_gutter_css(start_color_ln, show_color) unless @line_number < start_color_ln
    @do_update_gutter(start_ln, end_ln, show_color, client_id) unless start_ln > end_ln


  do_update_gutter: (start, end, show_color)->
    # console.log "do_update_gutter:s: #{start} ,e: #{end}"
    @line_number = end
    html = ''
    for row in [start+1..end+1]
      rowValue = " "+ row
      classes = "line-number line-number-#{row}"
      html += """<div class="#{classes}" style="background-color:#{show_color};" > #{rowValue}<div class="icon-right"></div></div>"""
    @emp_lineNumber.append(html)

  do_update_gutter_css: (start_color_ln, show_color) ->
    # console.log "do_update_gutter_css"
    # console.log @emp_lineNumber
    chile_nodes = @emp_lineNumber.context.children
    for row in [start_color_ln..@line_number]
      chile_nodes[row].style.backgroundColor=show_color


  update_log: (client_id, log_ga, show_color)->
    @log_detail.append $$ ->
      # @pre id:"log_#{client_id}", class: "emp-log-con", style:"color:#{show_color};padding:0px;", "######################### CLIENT:#{client_id} ##########################"
      for log in log_ga.split("\n")
        # console.log "|#{log}|"
        if log isnt "" and log isnt " "
          @pre id:"log_#{client_id}",class: "emp-log-con",style:"color:#{show_color};padding:0px;", "#{log}"
    @emp_log_view.scrollToBottom()
    # $('#emp_log_view').stop().animate({scrollTop:@log_detail.context.scrollHeight}, 1000)

  store_log: (client_id, log) ->
    # console.log @log_map
    if !@log_map[client_id]
      tmp_color = @get_color()
      @log_map[client_id] = new emp_log(client_id, tmp_color)
      @refresh_conf_view(client_id, tmp_color)
      # @show_live_log(client_id, log, tmp_color)
    if !@stop_state and !@first_show and @show_state
      @log_map[client_id].put_log(log)
      # console.log "print"
      @show_live_log(client_id, log, @log_map[client_id].get_color())
    # else
      # console.log "store_log"

  store_new_log: (client_id, log_obj)->
    # console.log log_obj
    log_msg = emp.base64_decode log_obj.message
    console.log log_msg
    @store_log(client_id, log_msg)


  refresh_conf_view: (client_id, color)->
    # unless !emp_conf_view
    # console.log @emp_conf_view
    # @add_clients(client_id)
    @emp_conf_view.refresh_log_view(client_id, color) unless !@emp_conf_view

  remove_client_log: (client_id)->
    @refresh_clients()
    delete @log_map[client_id]
    # @emp_conf_view.remove_log_view(client_id) unless !@emp_conf_view

  get_line_number_count: ->
    pane_height = @get_int(@log_detail.css('height'))
    # console.log "pane height:"+pane_height
    Math.floor(pane_height/ @line_height)

  initial_height: ->
    @get_line_height() unless @line_height
    @get_default_ln() unless @default_ln

  get_line_height: ->
    tmp_height = @emp_log_panel.css('line-height')
    # console.log tmp_height
    if tmp_height isnt undefined
      @line_height = @get_int(tmp_height)
    else
      @line_height = 16

  get_default_ln: ->
    tmp_height = @emp_log_panel.css('height')
    # console.log tmp_height
    if tmp_height isnt undefined
      @default_ln = Math.floor(@get_int(tmp_height) / @line_height)
    else
      @default_ln = 1

  get_int: (css) ->
    parseInt(css.split("px")[0])

  get_color: ->
    @color_arr[Math.floor(Math.random()* @color_arr.length)]

  # use for state view

  hide_view: ->
    if @hasParent()
      if @show_state
        this.hide()
        @show_state = false
      else
        this.show()
        @show_state = true


  clear_store_log: ->
    for name, view_logs of  @log_map
      # console.log name
      view_logs.reset_log()

  #-------------------------------------------------------------------------
  get_log_store: ->
    @log_map

  # -------------------------------------------------------------------------
  # call by command
  # initial log pane
  toggle: ->
    # console.log @first_show
    if @first_show
      @first_show = false
      if @hasParent()
        @detach()
        @show_state = false
        @stop_state = false
      else
        @refresh_clients()
        @attach()
        @stop_state = false
        @show_state = true
    else
      # console.log @show_state
      if @show_state
        this.hide()
        @show_state = false
      else
        @refresh_clients()
        this.show()
        @show_state = true

  attach: ->
    # atom.workspaceView.prependToBottom(this)
    @panel = atom.workspace.addBottomPanel(item:this,visible:true)
    @disposable.add new Disposable =>
      @panel.destroy()
      @panel = null
    @initial_height()
    @update()
    @update_ln()

  # -------------------------------------------------------------------------
  # call by config vieww
  # show log pane
  show_log: ->
    # console.log "show_log"
    @refresh_clients()
    if @first_show
      @first_show = false
      @attach()
      @show_state = true
    else
      # console.log @show_state
      this.show()
      @show_state = true

  hide_log_view: ->
    if @hasParent()
      if @show_state
        this.hide()
        @show_state = false

  show_log_state: ->
    @show_state

  # -------------------------------------------------------------------------
  # clear log content in the log pane
  clear_log: ->
    # console.log 'clear_log'
    if @hasParent()
      @log_detail.context.innerHTML = ''
      @update_ln()

    @clear_store_log()



  # -------------------------------------------------------------------------
  # pause the log poutput
  stop_log: ->
    # console.log "stop_log"
    @stop_state = true

  continue_log: ->
    @stop_state = false

  get_pause_state: ->
    @stop_state

  # -------------------------------------------------------------------------
  #close and clear the log pane
  close_log_view: ->
    # console.log "close1"
    if @hasParent()
      @log_detail.context.innerHTML = ''
      @detach()
      @show_state = false
      @first_show = true
      @stop_state = false
    @clear_store_log()

  get_log_pane_state: ->
    if @first_show
      "Close"
    else
      if @show_state
        if @stop_state
          "Pause"
        else
          "Show"
      else
        "Hide"

  # -------------------------------------------------------------------------
  #日志界面高度计算处理
  resizeStarted: ->
    $(document).on('mousemove', @resizeTreeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: ->
    $(document).off('mousemove', @resizeTreeView)
    $(document).off('mouseup', @resizeStopped)

  resizeTreeView: (e) =>
    {pageY, which} = e
    # console.log e
    return @resizeStopped() unless which is 1
    height = $(document.body).height()-pageY

    return if height < 70
    # console.log height
    @height(height)
    @emp_log_panel.css("max-height", height)

  resizeToMin: ->
    height = 70
    @height(height)
    @emp_log_panel.css("max-height", height)
    @emp_log_view.scrollToBottom()

  # -------------------------------------------------------------------------
  # -------------------------------------------------------------------------
  ## @doc  Lua console
  do_send_lua: ->
    # console.log @snippet_obj
    lua_code = @lua_console.getText()?.trim()
    console.log lua_code
    @do_show_in_console(lua_code)
    console.log @selected_client
    @emp_socket_server.send_lua_console(lua_code, @selected_client)

  do_show_in_console: (lua_code) ->
    show_color = "#000033"
    start_color_ln = @get_line_number_count()
    @update_console_log(lua_code, show_color)
    @update_gutter(show_color, start_color_ln)

  update_console_log: (log_ga, show_color)->
    @log_detail.append $$ ->
      for log in log_ga.split("\n")
        # console.log "|#{log}|"
        if log isnt "" and log isnt " "
          log = "Console Input: "+log
          @pre class: "emp-log-con",style:"color:#{show_color};padding:0px;", "#{log}"
    @emp_log_view.scrollToBottom()

  refresh_clients: ->
    client_ids = @emp_socket_server.get_all_id()
    @client_select.empty()
    # client_ids.push default_client_id
    selectd_flag = false
    if client_ids.indexOf(@selected_client) < 0
      @selected_client = default_client_id

    client_ids.push default_client_id
    for tmp_id in client_ids
      if tmp_id is @selected_client
        tmp_view = @new_selec_option tmp_id, tmp_id
        @client_select.append tmp_view
        selectd_flag = true
      else
        tmp_view = @new_option tmp_id, tmp_id
        @client_select.append tmp_view

  # set_clients_map: (@emp_clients)->

  set_socket_server: (@emp_socket_server) ->

  add_clients: (client_id)->
    @client_select.append @new_option(client_id, client_id)

  new_option: (name, value=name)->
    $$ ->
      @option value: value, name

  new_selec_option: (name, value=name) ->
    $$ ->
      @option selected:'select', value: value, name

  # -------------------------------------------------------------------------

  test: ->
    @store_log("test", "\nasdasd `    asda;")
    @store_log("test", "------\nasdasd\n\n test functione")
    @store_log("test", "------\nasdasd\n\n test functione")
    @store_log("test", "------\nasdasd\n\n test functione")
    @store_log("test", "------\nasdasd\n\n test functione")
    @store_log("test", "------\nasdasd\n\n test functione")
