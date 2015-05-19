" ============================================================================
" File: arduino.vim
" Description: vim filetype plugin which provides support for the Arduino
" Maintainer: Evergreen
" Last Change: May 19th, 2015
" License: Vim License
" ============================================================================

" ------------------------- Script Initialization ------------------------ {{{

if exists('b:did_ftplugin')
    finish
endif

let b:did_ftplugin = 1

" ------------------------- END Script Initialization -------------------- }}}

" ------------------------- Settings ------------------------------------- {{{

if !exists('g:hardy_arduino_path')
    let g:hardy_arduino_path = 'arduino'
endif

if !exists('g:hardy_arduino_options')
    let g:hardy_arduino_options = ''
endif

if !exists('g:hardy_window_name')
    let g:hardy_window_name = '__Arduino_Info__'
endif

if !exists('g:hardy_split_direction')
    let g:hardy_split_direction = 0
endif

if !exists('g:hardy_window_size')
    let g:hardy_window_size = 15
endif

" ------------------------- END Settings --------------------------------- }}}

" ------------------------- Functions ------------------------------------ {{{

" Run arduino executable with a given command.  Returns -1 if the DISPLAY
" environment variable is not set.
function! HardyRunArduino(command)
    if !exists("$DISPLAY")
        echohl Error
        echom "Hardy:  A graphical user interface such as X must be present"
        echohl Normal
        return -1
    endif

    let l:result = system(g:hardy_arduino_path . ' ' . g:hardy_arduino_options .
                \ ' ' . a:command)

    return l:result
endfunction

" Commands for use with each split direction
let s:split_commands = [
    \ 'aboveleft ', 'belowright ', 'vertical aboveleft ', 'vertical belowright ']

" Show information in arduino window.
function! HardyShowInfo(results)
    let l:winexists = bufwinnr(g:hardy_window_name)

    " Figure out whether to create a new window, or switch to an already
    " existing window.
    if l:winexists == -1
        " Create window according to all the user set options
        if g:hardy_split_direction < 0 || g:hardy_split_direction > 3
            echohl Error
            echom printf("Hardy: '%s' is not a valid split direction.",
                        \ g:hardy_split_direction)
            echohl Normal
            let g:hardy_split_direction = 0
        endif

        if g:hardy_window_size < 0
            echohl Error
            echom printf("Hardy: '%s' is not a valid window size.",
                        \ g:hardy_window_size)
            echohl Normal
        endif

        if g:hardy_window_size > 0
            execute s:split_commands[g:hardy_split_direction] .
                        \ g:hardy_window_size . 'new '. g:hardy_window_name
        elseif g:hardy_window_size == 0
            execute s:split_commands[g:hardy_split_direction] . 'new ' .
                        \ g:hardy_window_name
        endif

        " Set all the options for the newly created buffer
        setlocal filetype=arduinoinfo
        setlocal buftype=nofile
    else
        execute l:winexists . 'wincmd w'
        " Delete everything in the buffer
        normal! ggdG
    endif

    " Insert the resulting information
    call append(0, split(a:results, '\v\n'))
endfunction

" Verify the current file using arduino --verify
function! HardyArduinoVerify()
    let l:result = HardyRunArduino('--verify ' . bufname("%"))

    call HardyShowInfo(l:result)
endfunction

" Upload the current file using arduino --upload
function! HardyArduinoUpload()
    let l:result = HardyRunArduino('--upload ' . bufname("%"))

    call HardyShowInfo(l:result)
endfunction

" ------------------------- END Functions -------------------------------- }}}

" ------------------------- Commands ------------------------------------- {{{

command! -buffer -nargs=0 ArduinoUpload call HardyArduinoUpload()
command! -buffer -nargs=0 ArduinoVerify call HardyArduinoVerify()

" ------------------------- END Commands --------------------------------- }}}

" vim: set sw=4 sts=4 et fdm=marker:
