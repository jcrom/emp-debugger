path = require 'path'
fs = require 'fs'
c_process = require 'child_process'
os = require 'os'
emp = require '../exports/emp'

bash_path_key = 'emp-channel-wizard.path'

rel_erl_dir = '../../erl_util/atom_pl_parse_json.erl'
rel_ebin_dir = '../../erl_util/'
emp = require '../exports/emp'
os_platform = emp.get_emp_os()

# @doc 编译状态标示 编译步骤，最多2步，
# 0标示未开始，1标示初始化path，2标示编译开始

initial_parser = (callback)->
  # console.log "init"
  initial_path()
  compile_paser(callback)


initial_path = ->
  # console.log os_platform
  if os_platform is emp.OS_DARWIN or os_platform is emp.OS_LINUX

    bash_path = atom.config.get(bash_path_key)
    # console.log bash_path
    # console.log process.env[OS_PATH]
    if bash_path is undefined
      exportsCommand = process.env.SHELL + " -lc export"
      # console.log exportsCommand
      # Run the command and update the local process environment:
      c_process.exec exportsCommand, (error, stdout, stderr) ->
        for definition in stdout.trim().split('\n')
          [key, value] = definition.split('=', 2)
          key = key.trim().split(" ").pop()
          # console.log "key:#{key}, value:#{value}"
          unless key isnt emp.OS_PATH
            process.env[key] = value
            atom.config.set(bash_path_key, value)
    else
      process.env[emp.OS_PATH] = bash_path

compile_paser = (callback)->
  # check the erl environmenr
  # console.log os_platform
  if os_platform is emp.OS_DARWIN or os_platform is emp.OS_LINUX
    c_process.exec "which erlc", (error, stdout, stderr) ->
      try
        if (error instanceof Error)
          console.warn error.message
          throw "No erl environment~"

        erl_dir = path.join(__dirname, rel_erl_dir)
        ebin_dir = path.join(__dirname, rel_ebin_dir)
        erlc_str = 'erlc -o '+ebin_dir+' '+erl_dir+' -noshell -s erlang halt'
    #
        c_process.exec erlc_str, (error, stdout, stderr) ->
          if (error instanceof Error)
            console.warn error.message
            console.log stderr
            emp.show_error("Compile erl error ~")
          else
            if callback
              callback.add_new_panel_f()
      catch err
        emp.show_error(err)
  else
    erl_dir = path.join(__dirname, rel_erl_dir)
    ebin_dir = path.join(__dirname, rel_ebin_dir)
    erlc_str = 'erlc -o '+ebin_dir+' '+erl_dir+' -noshell -s erlang halt'
    # console.log erlc_str
    c_process.exec erlc_str, (error, stdout, stderr) ->
      if (error instanceof Error)
        console.warn error.message
        console.log stderr
        emp.show_error("Compile erl error ~")
      else
        if callback
          callback.add_new_panel_f()


module.exports.remove_cha = (cha_str, cid_list) ->
  # console.log "~~---------------remove cha ~~:#{cha_str}"
  channel_conf = atom.project.channel_conf
  if !atom.project.emp_app_state
    parse_beam_dir = atom.project.parse_beam_dir
    t_erl = 'erl -pa '+parse_beam_dir+' -channel_conf '+channel_conf
    t_erl = t_erl+' -cha_id'+cha_str+" -sname testjs -run #{emp.parser_beam_file_mod} remove_channel -noshell -s erlang halt"
    c_process.exec t_erl, (error, stdout, stderr) ->
      if (error instanceof Error)
        console.log error.message
        emp.show_error(error.message)
      if stderr
        console.error "compile:#{stderr}"
  else
    tmp_pid = atom.project.emp_app_pid
    if tmp_pid
      cid_list = "[\""+cid_list.join("\",\"")+"\"]"
      erl_str = "#{emp.parser_beam_file_mod}:remove_channel(\"#{channel_conf}\", #{cid_list})."
      # console.log erl_str
      tmp_pid.stdin.write(erl_str+'\r\n')



module.exports.remove_col = (col_str, col_list) ->
  # console.log "~~---------------remove col ~~:#{col_str}"
  channel_conf = atom.project.channel_conf
  if !atom.project.emp_app_state
    parse_beam_dir = atom.project.parse_beam_dir
    t_erl = 'erl -pa '+parse_beam_dir+' -channel_conf '+channel_conf
    t_erl = t_erl+' -col_id'+col_str+' -sname testjs -run atom_pl_parse_json remove_col -noshell -s erlang halt'
    c_process.exec t_erl, (error, stdout, stderr) ->
      # console.log "compile:#{stdout}"
      if (error instanceof Error)
        console.log error.message
        emp.show_error(error.message)
      if stderr
        console.error "compile:#{stderr}"
  else
    tmp_pid = atom.project.emp_app_pid
    if tmp_pid
      col_list = "["+col_list.join(",")+"]"
      erl_str = "#{emp.parser_beam_file_mod}:remove_col(\"#{channel_conf}\", #{col_list})."
      # console.log erl_str
      tmp_pid.stdin.write(erl_str+'\r\n')

module.exports.edit_col = (col_str) ->
  # console.log "~~---------------remove col ~~:#{col_str}"
  channel_conf = atom.project.channel_conf
  parse_beam_dir = atom.project.parse_beam_dir
  t_erl = 'erl -pa '+parse_beam_dir+' -channel_conf '+channel_conf
  t_erl = t_erl+col_str+' -sname testjs -run atom_pl_parse_json edit_col -noshell -s erlang halt'
  # console.log t_erl
  c_process.exec t_erl, (error, stdout, stderr) ->
    # console.log "compile:#{stdout}"
    if (error instanceof Error)
      console.log error.message
      emp.show_error(error.message)
    if stderr
      console.error "compile:#{stderr}"

module.exports.edit_cha = (cha_str) ->
  channel_conf = atom.project.channel_conf
  parse_beam_dir = atom.project.parse_beam_dir
  t_erl = 'erl -pa '+parse_beam_dir+' -channel_conf '+channel_conf
  t_erl = t_erl+cha_str+' -sname testjs -run atom_pl_parse_json edit_cha -noshell -s erlang halt'
  # console.log t_erl
  c_process.exec t_erl, (error, stdout, stderr) ->
    # console.log "compile:#{stdout}"
    if (error instanceof Error)
      console.log error.message
      emp.show_error(error.message)
    if stderr
      console.error "compile:#{stderr}"


module.exports.initial_parser = initial_parser
module.exports.initial_path = initial_path
