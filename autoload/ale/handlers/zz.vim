" Author: Daniel Schemala <istjanichtzufassen@gmail.com>,
"   w0rp <devw0rp@gmail.com>
"
" Description: This file implements handlers specific to Zz.

if !exists('g:ale_zz_ignore_error_codes')
    let g:ale_zz_ignore_error_codes = []
endif

function! s:FindSpan(buffer, span) abort
    if ale#path#IsBufferPath(a:buffer, a:span.file_name) || a:span.file_name is# '<anon>'
        return a:span
    endif

    " Search inside the expansion of an error, as the problem for this buffer
    " could lie inside a nested object.
    if !empty(get(a:span, 'expansion', v:null))
        return s:FindSpan(a:buffer, a:span.expansion.span)
    endif

    return {}
endfunction

function! ale#handlers#zz#HandleZzErrors(buffer, lines) abort
    let l:output = []

    for l:errorline in a:lines
        " ignore everything that is not JSON
        if l:errorline !~# '^{'
            continue
        endif

        let l:error = json_decode(l:errorline)

        if !(has_key(l:error, 'message'))
            continue
        endif

        if !(ale#path#IsBufferPath(a:buffer, l:error.file_name)) || l:error.file_name is# '<anon>'
            continue
        endif

        call add(l:output, {
        \   'lnum': l:error.line_start,
        \   'end_lnum': l:error.line_end,
        \   'col': l:error.column_start,
        \   'end_col': l:error.column_end,
        \   'text': l:error.message,
        \   'type': toupper(l:error.level[0]),
        \})
    endfor

    return l:output
endfunction
