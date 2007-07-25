"
" Ruby snippets
" Last change: July 23 2007
" Version> 0.0.3
" Maintainer: Eustáquio 'TaQ' Rangel
" License: GPL
" Thanks to: Andy Wokula for help
"
if exists("b:rubysnippets_ignore")
	finish
endif
let b:rubysnippets_ignore = 1

" Simple abbreviations
iab <buffer> <silent> def def method_name<CR>end<Esc><Up><S-Right><Left>
iab <buffer> <silent> begin begin<CR>rescue Exception => e<CR>end<Esc><Up>O
iab <buffer> <silent> inject inject do \|memo,obj\|<CR>end<Esc>O
iab <buffer> <silent> each each do \|item\|<CR>end<Esc>O

" Classes and modules
let s:cam = ["class","module"]
for s:item in s:cam
	let s:expr = "iab <buffer> <silent> ".s:item." ".s:item." ".toupper(s:item[0]).strpart(s:item,1,len(s:item)-1)."Name<CR>end<Esc><Up><S-Right><Left>"
	execute s:expr
endfor

" One liners
let s:blocks = ["collect","detect","find","find_all","map","reject","select","partition"]
for s:item in s:blocks
	let s:hamt = hasmapto("}","i") > 0
	let s:endc = s:hamt ? "" : " }"
	let s:ins  = s:hamt ? "" : "<Esc><Left>i"
	let s:expr = "iab <buffer> <silent> ".s:item." ".s:item." {\\|item\\|".s:endc.s:ins
	execute s:expr
endfor

iab <buffer> <silent> atr attr_reader
iab <buffer> <silent> atw attr_writer
iab <buffer> <silent> atc attr_accessor

" RubySnippetsFor()
"
" Here we have a snippet to work with for.
" It works on empty lines, or lines with one or two strings, 
" where it insert a default 'for' structure and change its 
" strings checking how many strings are on the current line.
" It works like this:
"
" current line		result
" ------------		------
" <empty>			for item in collection
"						end
" @people			for item in @people
"						end
" person @people	for person in @people
"						end												
"
" It works on Insert Mode, when you type 'for' or <C-F>, and on
" Normal Mode when you type <C-F>.
"
function! s:RubySnippetsFor()
	let line		= getline(".")
	let token	= split(line)
	let listc	= ["for","item","in","collection"]
	if len(token)==1
		let listc[3] = token[0]
	endif
	if len(token)==2
		let listc[1] = token[0]
		let listc[3] = token[1]
	endif
	call setline(line("."),join(listc))
	call append(line("."),"end")
endfunction
iab  <buffer> for <esc>:call <SID>RubySnippetsFor()<cr>o
map  <buffer> <C-F> :call <SID>RubySnippetsFor()<cr>o
imap <buffer> <C-F> <ESC>:call <SID>RubySnippetsFor()<cr>o

"
" Here we have a function to get the contents of the line,
" using <C-F> on both Normal and Insert modes, tokenize it 
" using spaces, and if the result is a even number collection, 
" create a hash. Like this:
"
" 1 :one 2 :two 3 :three 4 :four 
"
" will become
"
" {1=>:one,2=>:two,3=>:three,4=>:four}
"
function! s:RubySnippetsHash()
	let line		= getline(".")
	let tokens	= split(line)
	let leng		= len(tokens)
	if leng==0 || leng%2!=0
		return
	endif
	let qtde = leng/2
	let lnum = 0
	let list = []
	let lpos = 0
	while lnum < qtde
		call add(list,tokens[lpos]."=>".tokens[lpos+1])
		let lnum = lnum+1
		let lpos = lpos+2
	endwhile
	call setline(line("."),"{".join(list,",")."}")
endfunction
map  <buffer> <C-H> <ESC>:call <SID>RubySnippetsHash()<cr>
imap <buffer> <C-H> <ESC>:call <SID>RubySnippetsHash()<cr>
