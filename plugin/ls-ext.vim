" https://vi.stackexchange.com/questions/4102/how-to-shorten-the-result-of-ls-to-get-only-the-file-name-and-not-the-whole-pa
" https://vim.fandom.com/wiki/Replace_a_builtin_command_using_cabbrev
" Maintainer:   Pedro Santos
" Version:      0.0.1

if exists('g:loaded_ls_ext')
	finish
endif
let g:loaded_ls_ext = 1

function! LsExt() abort
	let g:message = ''
	redir => g:message
	silent execute 'buffers'
	redir END
	let ls_lines = split(g:message, '\n')
	let index = LsExtGetCurrentBufferIndex(ls_lines)
	let line_length = LsExtGetLineLength(ls_lines)
	let select = 0
	let leave = 0
	while !select && !leave
		call LsExtDrawBuffers(ls_lines, index, line_length)
		let char = getchar()
		if char == 106
			let index = min([index + 1, len(ls_lines) - 1])
		elseif char == 107
			let index = max([index - 1, 0])
		elseif char == 13 || char == 108
			let select = 1
		else
			let leave = 1
		endif
	endwhile
	if select
		let buffer_index = matchstr(ls_lines[index], '\s*\zs\d\+\ze')
		execute 'buffer ' . buffer_index
	endif
	redraw!
endfunction

function! LsExtDrawBuffers(ls_lines, index, line_length) abort
	redraw!
	echom ':ls'
	let aux = 0
	for line in a:ls_lines
		if aux == a:index
			echohl WarningMsg
			echohl QuickFixLine
		endif
		echom printf('%-' . a:line_length . 's', line)
		if aux == a:index
			echohl None
		endif
		let aux = aux + 1
	endfor
	echohl Question
	echom 'Navigate with ''j'' and ''k'' and press ENTER or ''l'' to open the buffer'
	echohl None
endfunction

function! LsExtGetCurrentBufferIndex(ls_lines) abort
	let aux = 0
	for line in a:ls_lines
		let buffer_number = matchstr(line, '\s*\zs\d\+\ze')
		if buffer_number == bufnr('%')
			return aux
		endif
		let aux = aux + 1
	endfor
endfunction

function! LsExtGetLineLength(ls_lines) abort
	let aux = 0
	for line in a:ls_lines
		let aux = max([aux, strlen(line)])
	endfor
	return aux
endfunction

command! LS call LsExt()
:cabbrev ls <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'LS' : 'ls')<CR>
