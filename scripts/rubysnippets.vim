"
" Ruby snippets
" Last change: July 30 2007
" Version> 0.0.8
" Maintainer: Eustáquio 'TaQ' Rangel
" License: GPL
" Thanks to: Andy Wokula and Antonio Terceiro for help and patches.
"
if exists("b:rubysnippets_ignore")
	finish
endif
let b:rubysnippets_ignore = 1
let b:rubysigncount = 1

"
"	Insert a sign on the current file. The sign can be text (>>) if you're
"	using vim on a console'or a little ruby icon if you're using GUI.
"	'
function! s:RubySnippetsInsertSign()
	exe ":sign place ".b:rubysigncount." line=".line(".")." name=rubysign file=".expand("%:p")
	let b:rubysigncount += 1
endfunction

" just enable the feature if vim was compiled with signs support
if has("signs")
	let icon_image	= "ruby.xpm"
	let icon_path	= split(&rtp,",")[0]."/pixmaps/"
	if has("win32")
		let icon_image="ruby.bmp"
	endif
	exe ":sign define rubysign text=>> linehl=Warning texthl=Error icon=".icon_path.icon_image
	map <buffer> is :call <SID>RubySnippetsInsertSign()<CR> 
	map <buffer> rs :sign unplace<CR>
endif

"
" Eats up whitespace after an abbreaviation. Adapted from an example in vim
" documentation (:h map)
"
function! s:RubySnippetsEatSpace()
   let c = nr2char(getchar(0))
   return (c =~ '\s') ? '' : c
endfunction

" Simple abbreviations
iab <buffer> <silent> begin begin<CR>rescue Exception => e<CR>end<Up><Up><End><CR><C-R>=<SID>RubySnippetsEatSpace()<CR>
iab <buffer> <silent> inject inject do \|memo,obj\|<CR>end<Up><End><CR><C-R>=<SID>RubySnippetsEatSpace()<CR>
iab <buffer> <silent> each each do \|item\|<CR>end<Up><End><CR><C-R>=<SID>RubySnippetsEatSpace()<CR>

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

" 
" Keep the current line value with the contents of the abbreviation.
" Used as a way to guess when a keyword does not need to behave the usual way
" on this script.
"
function! s:RubySnippetsKeepLine(line,expr)
	let pos	= getpos(".")
	let pre	= strpart(a:line,0,pos[2])
	let aft  = strpart(a:line,pos[2])
	call setline(line("."),pre.a:expr.aft)
	call feedkeys((strlen(a:expr)-1)."la ")
endfunction

"
" Create a indentation string with tabs, based on the
" current line indentation. It checks if the expandtab
" option is set, and if so insert space characters, if
" not, find how many tabs are inserted based on the value
" of the tabstop option.
"
function! s:RubySnippetsCreateIndentation()
	let char = &expandtab==1 ? " " : "\t"
	let qty	= indent(".") / (&expandtab==1 ? 1 : &tabstop)
	return repeat(char,qty)
endfunction

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
" It works on Insert Mode, when you type 'for' as the first string on
" the line, and <C-F> on Insert and Normal Modes.
"
function! s:RubySnippetsFor(insert)
	let line		= getline(".")
	let token	= split(line)
	let listc	= ["for","item","in","collection"]
	let indent  = s:RubySnippetsCreateIndentation() 
	if len(token)>0 && token[0]!="for" && a:insert==1
		call s:RubySnippetsKeepLine(line,"for")
		return
	endif
	if len(token)==1
		let listc[3] = token[0]
	endif
	if len(token)==2
		let listc[1] = token[0]
		let listc[3] = token[1]
	endif
	call setline(line("."),indent.join(listc))
	call append(line("."),indent."end")
	call feedkeys("o")
endfunction
iab  <buffer> for <esc>:call <SID>RubySnippetsFor(1)<cr>
map  <buffer> <C-F> :call <SID>RubySnippetsFor(0)<cr>
imap <buffer> <C-F> <ESC>:call <SID>RubySnippetsFor(0)<cr>

" 
" Used to create classes, modules and methods structures, but just
" when there is nothing more on the line.
" If there is a variable called g:rubysnippets_skip_names defined,
" it skip the structure default names automatically inserted.
"
function! s:RubySnippetsCM(expr,name)
	let line		= getline(".")
	let pos		= getpos(".")
	let indent  = s:RubySnippetsCreateIndentation() 
	let tokens	= split(line)
	if len(tokens)>0 && tokens[0]!="class"
		call s:RubySnippetsKeepLine(line,a:expr)
		return
	endif
	let name		= a:name 
	let skip		= exists("g:rubysnippets_skip_names")
	if skip 
		let name = ""
	endif
	let newl		= indent.a:expr." ".name
	call setline(line("."),newl)
	call append(line("."),indent."end")
	if skip
		call feedkeys("$a")
	else
		let pos[2]	= stridx(newl,name)
		call setpos(".",pos)
	endif
endfunction
iab <buffer> <silent> class  <esc>:call <SID>RubySnippetsCM("class","ClassName")<cr>
iab <buffer> <silent> module <esc>:call <SID>RubySnippetsCM("module","ModuleName")<cr>
iab <buffer> <silent> def    <esc>:call <SID>RubySnippetsCM("def","method_name")<cr>

"
" Create a Ruby hash representation with a list of even string parameters.
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
" The hash is created using <C-H> on Insert and Normal Modes, where it will search
" for the positions of { and } and convert all the strings PAIRS inside 
" a hash, like this:
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
	let cpos = getpos(".")								" check where the cursor is
	let flag = line[cpos[2]-1]=="{" ? "" : "b"	" if its over a { char, we need to search forward
	let ppos	= searchpairpos("{","","}",flag)		" search for the open/close pair
	if ppos[0]==0 || ppos[1]==0						" if it's not found, we just return
		return
	endif
	let ini  = flag=="b" ? ppos[1] : cpos[2]		" check the start position
	let end	= stridx(line,"}",ini+1)				" check the end position
	let subs = strpart(line,ini,end-ini)			" get the substring
	if match(subs,'[a-zA-Z0-9: ''""]\+')<0			" if there is a hash already there, return
	  return
	end 
	let pre  = strpart(line,0,ini-1)					" the substring before the hash
	let pos  = strpart(line,end+1)					" the substring after the hash
	let rst  = s:RubySnippetsMakeHash(subs)		" make the hash!
	if strlen(rst)<1										" nothing there, go away!
		return
	endif
	call setline(line("."),pre.rst.pos)				" change the current line
	let posi		= getpos(".") 
	let endp		= stridx(getline("."),"}",ini+1)
	let posi[2]	= endp+1
	call setpos(".",posi)								" position the cursor
endfunction
imap <buffer> <C-H> <ESC>:call <SID>RubySnippetsHash()<cr>
map  <buffer> <C-H> <ESC>:call <SID>RubySnippetsHash()<cr>
