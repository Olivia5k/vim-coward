" plugin/coward.vim
" Author:       Lowe Thiderman <lowe.thiderman@gmail.com>
" Source:       https://github.com/thiderman/vim-coward
"
" Automatically change $PWD to any parent directory that seems to have a VCS.
" Based partially from a tip in the CtrlP documentation, but expanded into
" something a bit more readable and maintainable.
" Name is from $(grep '^c.*w.*d$' /usr/share/cracklib/cracklib-small). :>

if exists('g:loaded_coward') || &cp || v:version < 700
  finish
endif
let g:loaded_coward = 1

let s:cpo_save = &cpo
set cpo&vim

" This would defeat the purpose of this plugin.
set noautochdir

let s:default = ['.git/', '.hg/', '.svn/', '.bzr/', '_darcs/']

" Utility functions {{{

function! s:set_working_directory()
  let current_wd = expand('%:p:h', 1)

  " Abort if we are in a special kind of buffer or have chosen to disable
  if current_wd =~ '^.\+://' || exists('b:coward_disable') || exists('g:coward_disable')
    return
  endif

  for trigger in get(g:, 'coward_extra_tokens', []) + s:default
    " Decide if we should use finddir() or findfile()
    let method = 'find' . (trigger =~ '/$' ? 'dir' : 'file')

    " The ; is for upward searching. See :he file-searching
    let dir = call(method, [trigger, current_wd . ';'])

    if dir != ''
      " Something was found! Break free!
      break
    endif
  endfo

  if dir != ''
    let target = substitute(dir, trigger.'$', '.', '')
  else
    let target = current_wd
  endif

  " Finally, do a buffer local directory change.
  exec 'lcd!' fnameescape(target)
endfunction

" }}}
" Autocommands {{{

augroup coward
  au!
  autocmd BufEnter * call s:set_working_directory()
augroup END

" }}}

let &cpo = s:cpo_save
" vim:set sw=2 sts=2:
