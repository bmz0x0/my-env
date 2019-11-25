" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software
" Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

function! Navi()
  if &ft ==? "c" || &ft ==? "cpp"
    vimgrep /^[^ \t#/\\*]\+[0-9A-Za-z_ :\t\\*]\+([^;]*$/j %
  elseif &ft ==? "lisp" 
    " defun のみ検索
    vimgrep /^[ \t]*(defun[ \t]\+.*$/j %
    " Emacs Lisp (defvar なども検索) 
    "vimgrep /^[ \t]*(defun[ \t]\+.*$/j %
  elseif &ft ==? "perl"
    vimgrep /^[ \t]*sub[ \t]\+.*$/j %
  elseif &ft ==? "ruby"
    vimgrep /^[ \t]*\(class\|module\|def\|alias\)[ \t]\+.*$/j %
  elseif &ft ==? "python"
    vimgrep /^[ \t]*\(class\|def\)[ \t]\+.*$/j %
  elseif &ft ==? "javascript"
    vimgrep /^[ \t]*function[ \t]\|[a-zA-Z_$][a-zA-Z0-9_$]*[ \t]*[=:][ \t]*function[ \t]*(/j %
  elseif &ft ==? "sh"
    vimgrep /^[ \t]*\(\h\w*[ \t]*()\|function[ \t]\+\h\w*\)/j %
  elseif &ft ==? "html"
    vimgrep /\c^\([ \t]*<h[123456].*\|[ \t]*<head.*\|[ \t]*<body.*\|[ \t]*<form.*\)$/j %
  elseif &ft ==? ""
    "Text (「1.」型の箇条書き)
    vimgrep /^[ \t]*[1234567890]\+[\.]\+.*$/j %
  elseif &ft ==? "tex"
    vimgrep /^\(\\chapter.*\|\\section.*\|\\subsection.*\|\\subsubsection.*\)$/j %
  elseif &ft ==? "pascal" 
    vimgrep /\c^procedure.*$/j %
  elseif &ft ==? "java"
    vimgrep /^[ \t]*[^#/\*=]\+[0-9a-zA-Z_ \t\*,.()]\+{[^;]*$/j %
  elseif &ft ==? "vb"
    vimgrep /\c^\(private\|public\|sub\|function\)[ \t]\+.*$/j %
  elseif &ft ==? "diff"
    "diff (unified format)
    vimgrep /^@@[0-9 \t,+-]\+@@$/j %
  else
    echo "This filetype is not supported."
  endif
  cw
endfunction
