scriptencoding utf-8


let s:save_cpo = &cpo
set cpo&vim


function! nim#omni#item(parsed) abort
    return {
                \ 'word': a:parsed.lname,
                \ 'kind': a:parsed.kindshort . ' » ' . nim#util#SignatureStr(a:parsed.type),
                \ 'info': a:parsed.doc,
                \ 'menu': a:parsed.module,
                \ }
endfunction

function! nim#omni#item_module(name, file, type) abort
    return {
                \ 'word': a:name,
                \ 'kind': a:type,
                \ 'info': a:file,
                \ 'menu': 'module',
                \ }
endfunction

" TODO: Refactor combine (1)
function! nim#omni#nimsuggest(file, l, c) abort
    let completions = []
    let tempfile = nim#util#WriteMemfile()
    let query = 'sug ' . a:file . ';' . tempfile . ':' . a:l . ':' . a:c
    let jobcmdstr = g:nvim_nim_exec_nimsuggest . ' --threads:on --colors:off --compileOnly --experimental --v2 --stdin ' . a:file
    let fullcmd = 'echo -e "' . query . '"|' . jobcmdstr
    let completions_raw = nim#util#FilterCompletions(split(system(fullcmd), "\n"))

    for line in completions_raw
        let parsed = nim#util#ParseV2(line)
        call add(completions, nim#omni#item(parsed))
    endfor

    return completions
endfunction

function! nim#omni#modulesuggest(file, l, c, base) abort
    let modules = nim#modules#FindGlobalImports()
    let completions = []
    for module in sort(filter(keys(modules), 'v:val =~ "^" . a:base'))
        call add(completions, nim#omni#item_module(module, modules[module], 'G'))
    endfor
    return completions
endfunction

function! s:findStart() abort
    let pos = col('.')
    let cline = getline('.')

    while pos > 1
        let ch = char2nr(cline[pos - 2])
        if !((48 <= ch && ch <= 57)
                    \ || (65 <= ch && ch <= 90)
                    \ || (97 <= ch && ch <= 122)
                    \ || ch == 95)
            break
        endif
        let pos = pos - 1
    endwhile

    return pos - 1
endfunction

function! nim#omni#nim(findstart, base) abort
    if a:findstart && empty(a:base)
        return s:findStart()
    endif

    let completions = []
    let file = expand('%:p')
    let l = line('.')
    let c = col('.') - 1

    let [istart, iend] = nim#modules#ImportLineRange()
    if istart != 0 && istart <= l && l <= iend
        let completions = nim#omni#modulesuggest(file, l, c, a:base)
    else
        let completions = nim#omni#nimsuggest(file, l, c)
    endif
    return  completions
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
