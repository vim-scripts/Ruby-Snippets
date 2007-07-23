"
" Ruby snippets
" Last change: July 19 2007
" Version> 0.0.2
" Maintainer: Eustáquio 'TaQ' Rangel
" License: GPL
"
if exists("b:rubysnippets_ignore")
	finish
endif
let b:rubysnippets_ignore = 1

" simple abbreviations
iab <buffer> <silent> def def method_name<CR>end<Esc><Up><S-Right><Left>
iab <buffer> <silent> for for item in collection<CR>end<Esc>O
iab <buffer> <silent> begin begin<CR>rescue Exception => e<CR>end<Esc><Up>O
iab <buffer> <silent> inject inject do \|memo,obj\|<CR>end<Esc>O
iab <buffer> <silent> each each do \|item\|<CR>end<Esc>O

" classes and modules
let s:cam = ["class","module"]
for s:item in s:cam
	let s:expr = "iab <buffer> <silent> ".s:item." ".s:item." ".toupper(s:item[0]).strpart(s:item,1,len(s:item)-1)."Name<CR>end<Esc><Up><S-Right><Left>"
	execute s:expr
endfor

" one liners
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
