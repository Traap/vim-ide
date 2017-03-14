if exists("g:vide_loaded") || &cp || v:version < 700
  finish
endif
let g:vide_loaded = 1

function! s:strip(string)
    return substitute(a:string, '^\s*\(.\{-}\)\s*\n\?$', '\1', '')
endfunction

function! s:SendTmuxCommand(command)
    let prefixed_command = "tmux " . a:command
    return s:strip(system(prefixed_command))
endfunction

function! s:Setup()
  call s:SendTmuxCommand("split-window -v -p 10")
  call s:SendTmuxCommand("split-window -h -p 40")
  call s:SendTmuxCommand("send-keys 'repeat git logg -6' C-m")
  call s:SendTmuxCommand("select-pane -t 2")
  call s:SendTmuxCommand("split-window -h -p 40")
  call s:SendTmuxCommand("send-keys 'repeat git status --short' C-m")
  call s:SendTmuxCommand("select-pane -t 1")
  call s:SendTmuxCommand("send-keys 'C-n' C-m")
  call s:SendTmuxCommand("send-keys 'C-h' C-m")
  call s:SendTmuxCommand("send-keys ',gs' C-m")
endfunction

function! s:TearDown()
  call s:SendTmuxCommand("")
  call s:SendTmuxCommand("select-pane -t 4")
  call s:SendTmuxCommand("send-keys 'C-c' C-m")
  call s:SendTmuxCommand("send-keys 'exit' C-m")
  call s:SendTmuxCommand("select-pane -t 3")
  call s:SendTmuxCommand("send-keys 'C-c' C-m")
  call s:SendTmuxCommand("send-keys 'exit' C-m")
  call s:SendTmuxCommand("select-pane -t 2")
  call s:SendTmuxCommand("send-keys 'exit' C-m")
  let g:_loaded = 0
endfunction

function! s:ToggleIde()
  if g:vide_is_on
    let g:vide_is_on = 0
    call s:TearDown()
  else
    let g:vide_is_on = 1 
    call s:Setup()
  endif
endfunction

function! s:DefineCommands()
  command! VideToggleIde call s:ToggleIde()
endfunction

function! s:DefineKeymaps()
  nnoremap ide :VideToggleIde<cr>
endfunction

function! s:Initialize()
  call s:DefineCommands()
  call s:DefineKeymaps()
  if g:vide_turn_ide_on
    call s:Setup()
    let g:vide_is_on = 1
  else
    let g:vide_is_on = 0
  endif
endfunction

let g:vide_turn_ide_on = 1
call s:Initialize()
