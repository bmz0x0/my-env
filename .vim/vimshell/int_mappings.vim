"=============================================================================
" FILE: int_mappings.vim
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

function! vimshell#int_mappings#define_default_mappings()"{{{
  " Plugin key-mappings."{{{
  inoremap <buffer><silent> <Plug>(vimshell_int_previous_history)  <ESC>:<C-u>call <SID>previous_command()<CR>
  inoremap <buffer><silent> <Plug>(vimshell_int_next_history)  <ESC>:<C-u>call <SID>next_command()<CR>
  inoremap <buffer><silent> <Plug>(vimshell_int_move_head)  <ESC>:<C-u>call <SID>move_head()<CR>
  inoremap <buffer><expr> <Plug>(vimshell_int_delete_backward_line)  <SID>delete_backward_line()
  inoremap <buffer><expr> <Plug>(vimshell_int_delete_backward_word)  vimshell#interactive#get_cur_text()  == '' ? '' : "\<C-w>"
  inoremap <buffer><silent> <Plug>(vimshell_int_execute_line)       <C-g>u<ESC>:<C-u>call vimshell#execute_current_line(1)<CR>
  inoremap <buffer><silent> <Plug>(vimshell_int_interrupt)       <C-o>:<C-u>call vimshell#interactive#hang_up(bufname('%'))<CR>
  inoremap <buffer><expr> <Plug>(vimshell_int_delete_backward_char)  <SID>delete_backward_char(0)
  inoremap <buffer><expr> <Plug>(vimshell_int_another_delete_backward_char)  <SID>delete_backward_char(1)
  inoremap <buffer><expr> <Plug>(vimshell_int_history_complete)  vimshell#complete#interactive_history_complete#complete()
  inoremap <buffer><silent> <Plug>(vimshell_int_send_input)  <C-o>:call vimshell#interactive#send_input()<CR>
  inoremap <buffer><expr> <SID>(bs-ctrl-])    getline('.')[col('.') - 2] ==# "\<C-]>" ? "\<BS>" : ''
  inoremap <buffer><silent> <Plug>(vimshell_int_command_complete)  <C-o>:call <SID>command_complete()<CR>
  inoremap <buffer><expr> <Plug>(vimshell_int_delete_forward_line)  col('.') == col('$') ? "" : "\<ESC>lDa"

  nnoremap <buffer><silent> <Plug>(vimshell_int_previous_prompt)  :<C-u>call <SID>previous_prompt()<CR>
  nnoremap <buffer><silent> <Plug>(vimshell_int_next_prompt)  :<C-u>call <SID>next_prompt()<CR>
  nnoremap <buffer><silent> <Plug>(vimshell_int_execute_line)  :<C-u>call vimshell#execute_current_line(0)<CR>
  nnoremap <buffer><silent> <Plug>(vimshell_int_paste_prompt)  :<C-u>call <SID>paste_prompt()<CR>
  nnoremap <buffer><silent> <Plug>(vimshell_int_interrupt)       :<C-u>call vimshell#interactive#hang_up(bufname('%'))<CR>
  nnoremap <buffer><silent> <Plug>(vimshell_int_exit)       :<C-u>call vimshell#interactive#quit_buffer()<CR>
  nnoremap <buffer><silent> <Plug>(vimshell_int_restart_command)       :<C-u>call <SID>restart_command()<CR>
  nnoremap <buffer><expr> <Plug>(vimshell_int_change_line) vimshell#interactive#get_prompt() == '' ? 'ddO' : printf('0%dlc$', vimshell#util#strchars(vimshell#interactive#get_prompt()))
  nmap <buffer>  <Plug>(vimshell_int_delete_line) <Plug>(vimshell_int_change_line)<ESC>
  nnoremap <silent><buffer> <Plug>(vimshell_int_insert_enter)  :<C-u>call <SID>insert_enter()<CR>
  nnoremap <silent><buffer> <Plug>(vimshell_int_insert_head)  :<C-u>call <SID>insert_head()<CR>
  nnoremap <silent><buffer> <Plug>(vimshell_int_append_enter)  :<C-u>call <SID>append_enter()<CR>
  nnoremap <silent><buffer> <Plug>(vimshell_int_append_end)  :<C-u>call <SID>append_end()<CR>
  nnoremap <silent><buffer> <Plug>(vimshell_int_clear)  :<C-u>call <SID>clear()<CR>
  "}}}

  if (exists('g:vimshell_no_default_keymappings') && g:vimshell_no_default_keymappings)
    return
  endif

  " Normal mode key-mappings.
  nmap <buffer> <C-p>     <Plug>(vimshell_int_previous_prompt)
  nmap <buffer> <C-n>     <Plug>(vimshell_int_next_prompt)
  nmap <buffer> <CR>      <Plug>(vimshell_int_execute_line)
  nmap <buffer> <C-y>     <Plug>(vimshell_int_paste_prompt)
  nmap <buffer> <C-z>     <Plug>(vimshell_int_restart_command)
  nmap <buffer> <C-c>     <Plug>(vimshell_int_interrupt)
  nmap <buffer> q         <Plug>(vimshell_int_exit)
  nmap <buffer> cc         <Plug>(vimshell_int_change_line)
  nmap <buffer> dd         <Plug>(vimshell_int_delete_line)
  nmap <buffer> I         <Plug>(vimshell_int_insert_head)
  nmap <buffer> A         <Plug>(vimshell_int_append_end)
  nmap <buffer> i         <Plug>(vimshell_int_insert_enter)
  nmap <buffer> a         <Plug>(vimshell_int_append_enter)
  nmap <buffer> <C-l>     <Plug>(vimshell_int_clear)

  " Insert mode key-mappings.
  imap <buffer> <C-h>     <Plug>(vimshell_int_delete_backward_char)
  imap <buffer> <BS>     <Plug>(vimshell_int_delete_backward_char)
  imap <buffer> <C-a>     <Plug>(vimshell_int_move_head)
  imap <buffer> <C-u>     <Plug>(vimshell_int_delete_backward_line)
  imap <buffer> <C-w>     <Plug>(vimshell_int_delete_backward_word)
  imap <buffer> <C-k>     <Plug>(vimshell_int_delete_forward_line)
  imap <buffer> <C-]>               <C-]><SID>(bs-ctrl-])
  imap <buffer> <CR>      <C-]><Plug>(vimshell_int_execute_line)
  imap <buffer> <C-c>     <Plug>(vimshell_int_interrupt)
  inoremap <buffer> <expr><silent> <C-l>  unite#sources#vimshell_history#start_complete()
  imap <buffer> <C-v>  <Plug>(vimshell_int_send_input)
  inoremap <buffer> <C-n>     <C-n>
  imap <buffer><expr> <TAB>  pumvisible() ? "\<C-n>" : "\<Plug>(vimshell_int_command_complete)"
endfunction"}}}

" vimshell interactive key-mappings functions.
function! s:delete_backward_char(is_auto_select)"{{{
  if !pumvisible()
    let l:prefix = ''
  elseif a:is_auto_select || (exists('g:neocomplcache_enable_auto_select') && g:neocomplcache_enable_auto_select)
    let l:prefix = "\<C-e>"
  else
    let l:prefix = "\<C-y>"
  endif

  " Prevent backspace over prompt
  let l:cur_text = vimshell#get_cur_line()
  if !has_key(b:interactive.prompt_history, line('.')) || l:cur_text !=# b:interactive.prompt_history[line('.')]
    return l:prefix . "\<BS>"
  else
    return l:prefix
  endif
endfunction"}}}
function! s:execute_history(is_insert)"{{{
  if !has_key(b:interactive.prompt_history, line('.'))
    " Do update.
    call vimshell#interactive#execute_pty_out(a:is_insert)
  endif

  " Search prompt.
  let l:command = vimshell#interactive#get_cur_line(line('.'))

  if line('.') != line('$')
    if !has_key(b:interactive.prompt_history, line('$'))
      " Insert prompt line.
      call append(line('$'), l:command)
    else
      " Set prompt line.
      call setline(line('$'), b:interactive.prompt_history[line('$')] . l:command)
    endif
  endif

  $

  call vimshell#interactive#execute_pty_inout(a:is_insert)

  call vimshell#imdisable()
endfunction"}}}
function! s:previous_prompt()"{{{
  let l:prompts = sort(filter(map(keys(b:interactive.prompt_history), 'str2nr(v:val)'), 'v:val < line(".")'), 'vimshell#compare_number')
  if !empty(l:prompts)
    let l:pos = getpos('.')
    let l:pos[1] = l:prompts[-1]
    let l:pos[2] = len(vimshell#interactive#get_prompt()) + 1
    call setpos('.', l:pos)
  endif
endfunction"}}}
function! s:next_prompt()"{{{
  let l:prompts = sort(filter(map(keys(b:interactive.prompt_history), 'str2nr(v:val)'), 'v:val > line(".")'), 'vimshell#compare_number')
  if !empty(l:prompts)
    let l:pos = getpos('.')
    let l:pos[1] = l:prompts[0]
    let l:pos[2] = len(vimshell#interactive#get_prompt()) + 1
    call setpos('.', l:pos)
  endif
endfunction"}}}
function! s:move_head()"{{{
  call s:insert_head()
endfunction"}}}
function! s:delete_backward_line()"{{{
  if !pumvisible()
    let l:prefix = ''
  elseif exists('g:neocomplcache_enable_auto_select') && g:neocomplcache_enable_auto_select
    let l:prefix = "\<C-e>"
  else
    let l:prefix = "\<C-y>"
  endif

  let l:len = !has_key(b:interactive.prompt_history, line('.')) ?
        \ len(getline('.')) : len(substitute(vimshell#interactive#get_cur_text(), '.', 'x', 'g'))

  return l:prefix . repeat("\<BS>", l:len)
endfunction"}}}
function! vimshell#int_mappings#execute_line(is_insert)"{{{
  if !a:is_insert
    " Search cursor file.
    let l:filename = matchstr(substitute(substitute(expand('<cfile>'), '\\', '/', 'g'), ' ', '\\ ', 'g'), '\h\w*://\f\+')

    if &termencoding != '' && &encoding != &termencoding
      " Convert encoding.
      let l:filename = iconv(l:filename, &encoding, &termencoding)
    endif

    " Execute cursor file.
    if l:filename =~ '^\%(https\?\|ftp\)://'
      " Open uri.
      call vimshell#open(l:filename)
      return
    endif
  endif

  " Execute history.
  call s:execute_history(a:is_insert)
endfunction"}}}
function! s:paste_prompt()"{{{
  if !has_key(b:interactive.prompt_history, line('.'))
    return
  endif

  " Set prompt line.
  let l:cur_text = vimshell#interactive#get_cur_line(line('.'))
  call setline(line('$'), vimshell#interactive#get_prompt(line('$')) . l:cur_text)
  $
endfunction"}}}
function! s:restart_command()"{{{
  if exists('b:interactive') && !empty(b:interactive.process) && b:interactive.process.is_valid
    " Delete zombie process.
    call vimshell#interactive#force_exit()
  endif

  set modifiable
  " Clean up the screen.
  % delete _
  call vimshell#terminal#clear_highlight()

  " Initialize.
  let l:sub = vimproc#ptyopen(b:interactive.args)

  call s:default_settings()

  " Set variables.
  call extend(b:interactive, {
        \ 'process' : l:sub,
        \ 'is_secret': 0,
        \ 'prompt_history' : {},
        \ 'echoback_linenr' : 0
        \}, 'force')

  call vimshell#interactive#execute_pty_out(1)

  startinsert!
endfunction"}}}
function! s:command_complete()"{{{
  let l:prompt = vimshell#interactive#get_prompt()
  let l:command = b:interactive.command
  let l:cur_text = vimshell#interactive#get_cur_text()
  call setline('.', l:prompt)
  call vimshell#interactive#send_string(l:cur_text .
        \ (b:interactive.is_pty ? "\<TAB>" : "\<TAB>\<TAB>"))
  if !vimshell#head_match(getline('$'), l:prompt)
    " Restore prompt.
    call setline('$', l:prompt . l:cur_text . getline('$'))
    startinsert!
  endif

  let b:interactive.prompt_history[line('$')] = getline('$')
endfunction "}}}
function! s:insert_enter()"{{{
  if !has_key(b:interactive.prompt_history, line('.')) && line('.') != line('$')
    $
    startinsert!
    return
  endif

  if col('.') <= len(vimshell#interactive#get_prompt())
    if len(vimshell#interactive#get_prompt()) + 1 >= col('$')
      startinsert!
      return
    else
      let l:pos = getpos('.')
      let l:pos[2] = len(vimshell#interactive#get_prompt()) + 1
      call setpos('.', l:pos)
    endif
  endif

  startinsert
endfunction"}}}
function! s:insert_head()"{{{
  normal! 0
  call s:insert_enter()
endfunction"}}}
function! s:append_enter()"{{{
  if vimshell#check_cursor_is_end()
    call s:append_end()
  else
    normal! l
    call s:insert_enter()
  endif
endfunction"}}}
function! s:append_end()"{{{
  call s:insert_enter()
  startinsert!
endfunction"}}}
function! s:clear()"{{{
  set modifiable

  " Clean up the screen.
  if line('$') != 1
    if has_key(b:interactive.prompt_history, line('$'))
      let l:current_history = b:interactive.prompt_history[line('$')]

      let b:interactive.prompt_history = {}

      " Restore history.
      let b:interactive.prompt_history[1] = l:current_history
    else
      let b:interactive.prompt_history = {}
    endif

    1,$-1 delete _
  else
    " Clear prompt history.
    let b:interactive.prompt_history = {}
    
    % delete _
  endif
  
  let b:interactive.echoback_linenr = 0
  
  call vimshell#terminal#clear_highlight()

  call vimshell#interactive#execute_pty_out(1)

  startinsert!
endfunction"}}}

" vim: foldmethod=marker
