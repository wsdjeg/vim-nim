scriptencoding utf-8


let s:save_cpo = &cpo
set cpo&vim


function! nim#modules#FindImportLocation() abort
    return searchpos('^import')
endfunction

function! nim#modules#HasImports() abort
    let [l, c] = nim#modules#FindImportLocation()
    return l != 0 && c == 1
endfunction

function! nim#modules#IsMultilineImport() abort
    if nim#modules#HasImports()
        let [l, c] = nim#modules#FindImportLocation()
        return indent(l + 1) > 0
    endif
    return 0
endfunction

function! nim#modules#AddImport(module) abort
    let imports = nim#modules#GetImports()
    let [begin, end] = nim#modules#ImportLineRange()
    exec ':' . begin . ',' . end . 'd'

    let idx = begin - 1
    call add(imports, a:module)
    call append(idx, 'import')
    for import in imports
        let wsstr = ''
        for wr in range(0, &sw)
            let wsstr .= ' '
        endfor

        let idx += 1
        call append(idx, wsstr . import . (idx - begin + 1 < len(imports) ? ',' : ''))
    endfor
endfunction

function! nim#modules#ImportLineRange() abort
    let [l, c] = nim#modules#FindImportLocation()
    if l == 0
        return [0, 0]
    endif

    let idx = 2
    while idx < line('$') && indent(idx) > 0
        let idx += 1
    endwhile
    return [l, idx - 1]
endfunction

function! nim#modules#GetImports() abort
    if !nim#modules#HasImports()
        return []
    endif

    let [begin, end] = nim#modules#ImportLineRange()
    let lines = getline(begin, end)
    return sort(filter(split(substitute(join(lines, ''), ',', '', 'g'), ' '), 'v:val !~# "^ *$"')[1:-1])
endfunction

function! nim#modules#ImportMap(imports) abort
    let result = {}
    for import in a:imports
        if import !~? '.*\/system\/.*' && import !~? '.*\/deprecated\/.*'
            let result[fnamemodify(import, ':t:r')] = import
        endif
    endfor
    return result
endfunction

" function! modules#FindLocalImports()
"     " return ImportMap(globpath(g:nvim_nim_deps_nim, "**/*.nim", 0, 1))
" endfunction

function! nim#modules#FindGlobalImports() abort
    return nim#modules#ImportMap(globpath(g:nvim_nim_deps_nim, '**/*.nim', 0, 1))
endfunction


function! nim#modules#moduleLocation(str) abort
    if has_key(nim#modules#FindGlobalImports(), a:str)
        return nim#modules#FindGlobalImports()[a:str]
    endif
endfunction


function! nim#modules#isGlobalImport(str) abort
    return has_key(nim#modules#FindGlobalImports(), a:str)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
