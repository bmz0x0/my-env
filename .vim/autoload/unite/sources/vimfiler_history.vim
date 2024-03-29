"=============================================================================
" FILE: vimfiler/history.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" Last Modified: 19 Sep 2011.
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

let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#vimfiler_history#define()"{{{
  return s:source
endfunction"}}}

let s:source = {
      \ 'name' : 'vimfiler/history',
      \ 'description' : 'candidates from vimfiler history',
      \ 'default_action' : 'lcd',
      \ 'action_table' : {},
      \ 'hooks' : {},
      \ 'is_listed' : 0,
      \ }

function! s:source.hooks.on_init(args, context)"{{{
  if &filetype !=# 'vimfiler'
    return
  endif

  let a:context.source__directories_history = b:vimfiler.directories_history
endfunction"}}}

function! s:source.gather_candidates(args, context)"{{{
  if !has_key(a:context, 'source__directories_history')
    return []
  endif

  let num = 0
  let candidates = []
  for history in map(reverse(copy(a:context.source__directories_history)),
        \ 'unite#util#substitute_path_separator(v:val)')

    call add(candidates, {
          \ 'word' : history,
          \ 'kind' : 'directory',
          \ 'action__path' : history,
          \ 'action__directory' : history,
          \ 'action__nr' : num,
          \ 'action__history' : a:context.source__directories_history,
          \ })

    let num += 1
  endfor

  return candidates
endfunction"}}}

" Actions"{{{
let s:action_table = {}

let s:action_table.delete = {
      \ 'description' : 'delete vimfiler directories history',
      \ 'is_selectable' : 1,
      \ 'is_invalidate_cache' : 1,
      \ 'is_quit' : 0,
      \ }
function! s:action_table.delete.func(candidates)"{{{
  for candidate in sort(a:candidates, 's:compare')
    call remove(candidate.action__history,
          \ candidate.action__nr)
  endfor
endfunction"}}}

let s:source.action_table['*'] = s:action_table
unlet! s:action_table
"}}}

function! s:compare(candidate_a, candidate_b)"{{{
  return a:candidate_b.action__nr - a:candidate_a.action__nr
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
