scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim


let s:DefinitionImpl = {}


function! s:DefinitionImpl.run(data) abort
    let res = nim#util#ParseV1(a:data.lines[0])
    call nim#util#JumpToLocation(res.file, res.line, res.col + 1)
endfunction


function! nim#features#definition#run() abort
    call nim#suggest#New('def', !g:nvim_nim_enable_async, 0, s:DefinitionImpl)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
