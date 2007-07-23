"
" Ruby snippets
" Last change: July 19 2007
" Version> 0.0.1
" Maintainer: Eustáquio 'TaQ' Rangel
" License: GPL
"
if exists("b:rubysnippets_ignore")
	finish
endif
let b:rubysnippets_ignore = 1

iab <buffer> <silent> def def method_name<CR>end<Esc><Up><S-Right><Left>
iab <buffer> <silent> for for item in collection<CR>end<Esc>O
iab <buffer> <silent> begin begin<CR>rescue Exception => e<CR>end<Esc><Up>O
iab <buffer> <silent> inject inject do \|memo,obj\|<CR>end<Esc>O

let s:cam = ["class","module"]
for s:item in s:cam
	let s:expr = "iab <buffer> <silent> ".s:item." ".s:item." ".toupper(s:item[0]).strpart(s:item,1,len(s:item)-1)."Name<CR>end<Esc><Up><S-Right><Left>"
	execute s:expr
endfor

let s:blocks = ["collect","detect","each","find","find_all","map","reject","select"]
for s:item in s:blocks
	let s:expr = "iab <buffer> <silent> ".s:item." ".s:item." do \\|item\\|<CR>end<Esc>O"
	execute s:expr
endfor

iab <buffer> <silent> atr attr_reader
iab <buffer> <silent> atw attr_writer
iab <buffer> <silent> atc attr_accessor
