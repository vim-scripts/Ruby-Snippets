"
" Ruby snippets
" Last change: July 25 2007
" Version> 0.0.4
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
" Create a Ruby representation with a list of even string parameters.
" If it's an odd number, do nothing.
"
function! s:RubySnippetsMakeHash(line)
	let tokens	= split(a:line)
	let leng		= len(tokens)
	if leng==0 || leng%2!=0
		return ""
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
	return "{".join(list,",")."}"
endfunction

"
" The hash is created using <C-F> on Insert Mode, where it will search
" for the positions of { and } and convert all the EVEN strings inside 
" the FIRST MATCHED values on a hash.  
" Like this:
"
" {1 :one 2 :two 3 :three 4 :four}
"
" will become
"
" {1=>:one,2=>:two,3=>:three,4=>:four}
"
" The { and } are mandatory, they identify a hash needing to be formatted.
" If it is an odd number, do nothing.
"
function! s:RubySnippetsHash()
	let line = getline(".")
	let ini  = match(line,'{[a-zA-Z0-9: ''""]\+}') 
	let end	= stridx(line,"}",ini+1)
	let pre  = strpart(line,0,ini)
	let pos  = strpart(line,end+1)
	let subs = strpart(line,ini+1,end-ini-1)
	let rst  = s:RubySnippetsMakeHash(subs)
	if strlen(rst)<1
		return
	endif
	call setline(line("."),pre.rst.pos)
	let posi		= getpos(".") 
	let endp		= stridx(getline("."),"}",ini+1)
	let posi[2]	= endp+1
	call setpos(".",posi)
endfunction
imap <buffer> <C-H> <ESC>:call <SID>RubySnippetsHash()<cr>
map  <buffer> <C-H> <ESC>:call <SID>RubySnippetsHash()<cr>
