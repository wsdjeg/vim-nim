scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim


let s:InfoImpl = {}

function! s:New(useWeb) abort
    let result = copy(s:InfoImpl)
    let result.useWeb = a:useWeb
    return result
endfunction

function! s:InfoImpl.run(data) abort
    if len(a:data.lines) == 0
        echo 'No information found'
        return
    endif

    let res = nim#util#ParseV1(a:data.lines[0])

    if self.useWeb
        call nim#util#open_module_doc(res.location, res.lname)
    else
        echohl None
        echohl Function | echon res.lname
        echohl Comment | echon "\n » "
        echohl Type | echon res.kindstr

        if len(res.name) > 0 && res.lname != res.name
            echon "\n"
            echohl Comment | echon ' » '
            echohl Typedef | echon res.name
        end

        echohl Comment | echon "\n » "
        echohl Include | echon res.location
        echohl Comment | echon ' ('
        echohl String | echon res.file
        echohl Comment | echon ')'

        if res.doc !=# "\"\""
            echohl Comment | echon "\n » "
            echohl Normal | echon res.doc
        endif
    endif
endfunction


function! nim#features#info#web() abort
    let current_word = expand('<cword>')
    if nim#modules#isGlobalImport(current_word)
        call nim#util#open_module_doc(current_word, '')
    else
        call nim#suggest#New('def', !g:nvim_nim_enable_async, 0, s:New(1))
    endif
endfunction


function! nim#features#info#run() abort
    call nim#suggest#New('def', !g:nvim_nim_enable_async, 0, s:New(0))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
