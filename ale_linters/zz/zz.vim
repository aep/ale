" Author: Daniel Schemala <istjanichtzufassen@gmail.com>,
" Ivan Petkov <ivanppetkov@gmail.com>
" Arvid E. Picciani <aep@exys.orgm>
" Description: invokes zz for zz files

function! ale_linters#zz#zz#GetZZExecutable(bufnr) abort
    if ale#path#FindNearestFile(a:bufnr, 'zz.toml') isnot# ''
        return 'zz'
    else
        " if there is no zz.toml file, we don't use zz even if it exists,
        " so we return '', because executable('') apparently always fails
        return ''
    endif
endfunction

function! ale_linters#zz#zz#VersionCheck(buffer) abort
    return !ale#semver#HasVersion('zz')
    \   ? 'zz --version'
    \   : ''
endfunction

function! ale_linters#zz#zz#GetCommand(buffer, version_output) abort
    let l:version = ale#semver#GetVersion('zz', a:version_output)

    let l:nearest_zzrun_prefix = ''

    let l:nearest_zzrun = ale#path#FindNearestFile(a:buffer, 'zz.toml')
    let l:nearest_zzrun_dir = fnamemodify(l:nearest_zzrun, ':h')

    if l:nearest_zzrun_dir isnot# '.'
        let l:nearest_zzrun_prefix = 'cd '. ale#Escape(l:nearest_zzrun_dir) .' && '
    endif

    let l:buffer_filename = fnamemodify(bufname(a:buffer), ':p')
    let l:buffer_filename = fnameescape(l:buffer_filename)

    return l:nearest_zzrun_prefix . 'zz '
    \   . 'check '
"\   . l:buffer_filename
endfunction

call ale#linter#Define('zz', {
\   'name': 'zz',
\   'executable_callback': 'ale_linters#zz#zz#GetZZExecutable',
\   'command_chain': [
\       {'callback': 'ale_linters#zz#zz#VersionCheck'},
\       {'callback': 'ale_linters#zz#zz#GetCommand'},
\   ],
\   'callback': 'ale#handlers#zz#HandleZzErrors',
\   'output_stream': 'both',
\   'lint_file': 1,
\})
