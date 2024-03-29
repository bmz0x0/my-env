"=============================================================================
" FILE: parser.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 30 May 2011.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

function! vimshell#parser#check_script(script)"{{{
  " Parse check only.
  " Split statements.
  for l:statement in vimproc#parser#split_statements(a:script)
    let l:args = vimproc#parser#split_args(l:statement)
  endfor
endfunction"}}}
function! vimshell#parser#eval_script(script, context)"{{{
  " Split statements.
  let l:statements = vimproc#parser#parse_statements(a:script)
  let l:max = len(l:statements)

  let l:context = a:context
  let l:context.is_single_command = (l:context.is_interactive && l:max == 1)

  let i = 0
  while i < l:max
    try
      let l:ret =  s:execute_statement(l:statements[i].statement, a:context)
    catch /^exe: Process started./
      " Change continuation.
      let b:vimshell.continuation = {
            \ 'statements' : l:statements[i : ], 'context' : a:context,
            \ 'script' : a:script,
            \ }
      return 1
    endtry

    let l:condition = l:statements[i].condition
    if (l:condition ==# 'true' && l:ret)
          \ || (l:condition ==# 'false' && !l:ret)
      break
    endif

    let i += 1
  endwhile

  " Call postexec hook.
  call vimshell#hook#call('postexec', l:context, a:script)

  return 0
endfunction"}}}
function! vimshell#parser#execute_command(commands, context)"{{{
  if empty(a:commands)
    return 0
  endif

  let l:internal_commands = vimshell#available_commands()

  let l:commands = a:commands
  let l:program = l:commands[0].args[0]
  let l:args = l:commands[0].args[1:]
  let l:fd = l:commands[0].fd
  let l:context = a:context
  let l:context.fd = l:fd

  " Check pipeline.
  if has_key(l:internal_commands, l:program)
        \ && l:internal_commands[l:program].kind ==# 'execute'
    " Execute execute commands.
    let l:commands[0].args = l:args
    return l:internal_commands[l:program].execute(l:commands, l:context)
  elseif a:commands[-1].args[-1] =~ '&$'
    " Convert to internal bg command.
    let l:commands[-1].args[-1] = l:commands[-1].args[-1][:-2]
    if l:commands[-1].args[-1] == ''
      " Delete empty arg.
      call remove(l:commands[-1].args, -1)
    endif

    return l:internal_commands['bg'].execute(l:commands, l:context)
  elseif len(a:commands) > 1
    if a:commands[-1].args[0] == 'less'
      " Execute less(Syntax sugar).
      let l:commands = a:commands[: -2]
      if !empty(a:commands[-1].args[1:])
        let l:commands[0].args = a:commands[-1].args[1:] + l:commands[0].args
      endif
      return l:internal_commands['less'].execute(l:commands, l:context)
    else
      " Execute external commands.
      return l:internal_commands['exe'].execute(a:commands, l:context)
    endif
  else"{{{
    let l:line = join(a:commands[0].args)
    let l:dir = substitute(substitute(l:line, '^\~\ze[/\\]', substitute($HOME, '\\', '/', 'g'), ''), '\\\(.\)', '\1', 'g')
    let l:command = vimshell#get_command_path(l:program)
    let l:ext = fnamemodify(l:program, ':e')

    " Check internal commands.
    if has_key(l:internal_commands, l:program)"{{{
      " Internal commands.
      return l:internal_commands[l:program].execute(l:program, l:args, l:fd, a:context)
      "}}}
    elseif isdirectory(l:dir)"{{{
      " Directory.
      " Change the working directory like zsh.

      " Call internal cd command.
      return vimshell#execute_internal_command('cd', [l:dir], l:fd, a:context)
      "}}}
    elseif !empty(l:ext) && has_key(g:vimshell_execute_file_list, l:ext)
      " Suffix execution.
      let l:args = extend(split(g:vimshell_execute_file_list[l:ext]), a:commands[0].args)
      let l:commands = [ { 'args' : l:args, 'fd' : l:fd } ]
      return vimshell#parser#execute_command(l:commands, a:context)
    elseif l:command != '' || executable(l:program)
      let l:args = insert(l:args, l:program)

      if has_key(g:vimshell_terminal_commands, l:program)
            \ && g:vimshell_terminal_commands[l:program]
        " Execute terminal commands.
        return l:internal_commands['texe'].execute(a:commands, l:context)
      else
        " Execute external commands.
        return l:internal_commands['exe'].execute(a:commands, l:context)
      endif
    else
      throw printf('Error: File "%s" is not found.', l:program)
    endif
  endif"}}}
endfunction
"}}}
function! vimshell#parser#execute_continuation(is_insert)"{{{
  if empty(b:vimshell.continuation)
    return
  endif

  " Execute pipe.
  call vimshell#interactive#execute_pipe_out()

  if b:interactive.process.is_valid
    return 1
  endif

  let b:vimshell.system_variables['status'] = b:interactive.status
  let l:ret = b:interactive.status

  let l:statements = b:vimshell.continuation.statements
  let l:condition = l:statements[0].condition
  if (l:condition ==# 'true' && l:ret)
        \ || (l:condition ==# 'false' && !l:ret)
    " Exit.
    let b:vimshell.continuation.statements = []
  endif

  if l:ret != 0
    " Print exit value.
    let l:context = b:vimshell.continuation.context
    if b:interactive.cond ==# 'signal'
      let l:message = printf('vimshell: %s %d(%s) "%s"', b:interactive.cond, b:interactive.status,
            \ vimshell#interactive#decode_signal(b:interactive.status), b:interactive.cmdline)
    else
      let l:message = printf('vimshell: %s %d "%s"', b:interactive.cond, b:interactive.status, b:interactive.cmdline)
    endif

    call vimshell#error_line(l:context.fd, l:message)
  endif

  " Execute rest commands.
  let l:statements = l:statements[1:]
  let l:max = len(l:statements)
  let l:context = b:vimshell.continuation.context

  let i = 0

  while i < l:max
    try
      let l:ret = s:execute_statement(l:statements[i].statement, l:context)
    catch /^exe: Process started./
      " Change continuation.
      let b:vimshell.continuation.statements = l:statements[i : ]
      let b:vimshell.continuation.context = l:context
      return 1
    endtry

    let l:condition = l:statements[i].condition
    if (l:condition ==# 'true' && l:ret)
          \ || (l:condition ==# 'false' && !l:ret)
      break
    endif

    let i += 1
  endwhile

  if b:interactive.syntax !=# &filetype
    " Set highlight.
    let l:start = searchpos('^' . vimshell#escape_match(vimshell#get_prompt()), 'bWen')[0]
    if l:start > 0
      call s:highlight_with(l:start + 1, line('$'), b:interactive.syntax)
    endif

    let b:interactive.syntax = &filetype
  endif

  " Call postexec hook.
  call vimshell#hook#call('postexec', l:context, b:vimshell.continuation.script)

  let b:vimshell.continuation = {}
  if line('.') == line('$')
    call vimshell#print_prompt(l:context)
    call vimshell#start_insert(a:is_insert)
  else
    call search('^' . vimshell#escape_match(vimshell#get_prompt()), 'We')
    stopinsert
  endif
endfunction
"}}}
function! s:execute_statement(statement, context)"{{{
  let l:statement = vimshell#parser#parse_alias(a:statement)

  " Call preexec filter.
  let l:statement = vimshell#hook#call_filter('preexec', a:context, l:statement)

  let l:program = vimshell#parser#parse_program(l:statement)

  let l:internal_commands = vimshell#available_commands()
  if l:program =~ '^\s*:'
    " Convert to vexe special command.
    let l:fd = { 'stdin' : '', 'stdout' : '', 'stderr' : '' }
    let l:commands = [ { 'args' : split(substitute(l:statement, '^:', 'vexe ', '')), 'fd' : l:fd } ]
  elseif has_key(l:internal_commands, l:program)
        \ && l:internal_commands[l:program].kind ==# 'special'
    " Special commands.
    let l:fd = { 'stdin' : '', 'stdout' : '', 'stderr' : '' }
    let l:commands = [ { 'args' : split(l:statement), 'fd' : l:fd } ]
  else
    let l:commands = vimproc#parser#parse_pipe(l:statement)
  endif

  return vimshell#parser#execute_command(l:commands, a:context)
endfunction
"}}}

" Parse helper.
function! vimshell#parser#parse_alias(statement)"{{{
  let l:pipes = []

  for l:statement in vimproc#parser#split_pipe(a:statement)
    " Get program.
    let l:statement = s:parse_galias(l:statement)
    let l:program = matchstr(l:statement, vimshell#get_program_pattern())
    if l:program  == ''
      throw 'Error: Invalid command name.'
    endif

    if exists('b:vimshell') && has_key(b:vimshell.alias_table, l:program) && !empty(b:vimshell.alias_table[l:program])
      " Expand alias.
      let l:args = vimproc#parser#split_args_through(l:statement[matchend(l:statement, vimshell#get_program_pattern()) :])
      let l:statement = s:recursive_expand_alias(l:program, l:args)
    endif

    call add(l:pipes, l:statement)
  endfor

  return join(l:pipes, '|')
endfunction"}}}
function! vimshell#parser#parse_program(statement)"{{{
  " Get program.
  let l:program = matchstr(a:statement, vimshell#get_program_pattern())
  if l:program  == ''
    throw 'Error: Invalid command name.'
  endif

  if l:program != '' && l:program[0] == '~'
    " Parse tilde.
    let l:program = substitute($HOME, '\\', '/', 'g') . l:program[1:]
  endif

  return l:program
endfunction"}}}
function! s:parse_galias(script)"{{{
  if !exists('b:vimshell')
    return a:script
  endif

  let l:script = a:script
  let l:max = len(l:script)
  let l:args = []
  let l:arg = ''
  let i = 0
  while i < l:max
    if l:script[i] == '\'
      " Escape.
      let i += 1

      if i > l:max
        throw 'Exception: Join to next line (\).'
      endif

      let l:arg .= '\' .  l:script[i]
      let i += 1
    elseif l:script[i] != ' '
      let l:arg .= l:script[i]
      let i += 1
    else
      " Space.
      if l:arg != ''
        call add(l:args, l:arg)
      endif

      let l:arg = ''

      let i += 1
    endif
  endwhile

  if l:arg != ''
    call add(l:args, l:arg)
  endif

  " Expand global alias.
  let i = 0
  for l:arg in l:args
    if has_key(b:vimshell.galias_table, l:arg)
      let l:args[i] = b:vimshell.galias_table[l:arg]
    endif

    let i += 1
  endfor

  return join(l:args)
endfunction"}}}
function! s:recursive_expand_alias(alias_name, args)"{{{
  " Recursive expand alias.
  let l:alias = b:vimshell.alias_table[a:alias_name]
  let l:expanded = {}
  while 1
    let l:key = vimproc#parser#split_args(l:alias)[-1]
    if has_key(l:expanded, l:alias) || !has_key(b:vimshell.alias_table, l:alias)
      break
    endif

    let l:expanded[l:alias] = 1
    let l:alias = b:vimshell.alias_table[l:alias]
  endwhile

  " Expand variables.
  let l:script = ''

  let i = 0
  let l:max = len(l:alias)
  let l:args = insert(copy(a:args), a:alias_name)
  try
    while i < l:max
      let l:matchlist = matchlist(l:alias,
            \'^$$args\(\[\d\+\%(:\%(\d\+\)\?\)\?\]\)\?', i)
      if empty(l:matchlist)
        let l:script .= l:alias[i]
        let i += 1
      else
        let l:index = l:matchlist[1]

        if l:index == ''
          " All args.
          let l:script .= join(l:args[1:])
        elseif l:index =~ '^\[\d\+\]$'
          let l:script .= get(l:args, l:index[1: -2], '')
        else
          " Some args.
          let l:script .= join(eval('l:args' . l:index))
        endif

        let i += len(l:matchlist[0])
      endif
    endwhile
  endtry

  if l:script ==# l:alias
    let l:script .= ' ' . join(a:args)
  endif

  return l:script
endfunction"}}}

" Misc.
function! vimshell#parser#check_wildcard()"{{{
  let l:args = vimshell#get_current_args()
  return !empty(l:args) && l:args[-1] =~ '[[*?]\|^\\[()|]'
endfunction"}}}
function! vimshell#parser#getopt(args, optsyntax)"{{{
  " Initialize.
  let l:optsyntax = a:optsyntax
  if !has_key(l:optsyntax, 'noarg')
    let l:optsyntax['noarg'] = []
  endif
  if !has_key(l:optsyntax, 'noarg_short')
    let l:optsyntax['noarg_short'] = []
  endif
  if !has_key(l:optsyntax, 'arg1')
    let l:optsyntax['arg1'] = []
  endif
  if !has_key(l:optsyntax, 'arg1_short')
    let l:optsyntax['arg1_short'] = []
  endif
  if !has_key(l:optsyntax, 'arg=')
    let l:optsyntax['arg='] = []
  endif

  let l:args = []
  let l:options = {}
  for l:arg in a:args
    let l:found = 0

    for l:opt in l:optsyntax['arg=']
      if vimshell#head_match(l:arg, l:opt.'=')
        let l:found = 1

        " Get argument value.
        let l:options[l:opt] = l:arg[len(l:opt.'='):]

        break
      endif
    endfor
    if l:found
      " Next argument.
      continue
    endif

    if !l:found
      call add(l:args, l:arg)
    endif
  endfor

  return [l:args, l:options]
endfunction"}}}
function! s:highlight_with(start, end, syntax)"{{{
  let l:cnt = get(b:, 'highlight_count', 0)
  if globpath(&runtimepath, 'syntax/' . a:syntax . '.vim') == ''
    return
  endif
  unlet! b:current_syntax
  let l:save_isk= &l:iskeyword  " For scheme.
  execute printf('syntax include @highlightWith%d syntax/%s.vim',
        \              l:cnt, a:syntax)
  let &l:iskeyword = l:save_isk
  execute printf('syntax region highlightWith%d start=/\%%%dl/ end=/\%%%dl$/ '
        \            . 'contains=@highlightWith%d,VimShellError',
        \             l:cnt, a:start, a:end, l:cnt)
  let b:highlight_count = l:cnt + 1
endfunction"}}}

" vim: foldmethod=marker
