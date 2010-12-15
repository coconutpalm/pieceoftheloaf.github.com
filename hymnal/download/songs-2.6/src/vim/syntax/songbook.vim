" Vim syntax file
" Language:     Songbook
" Last change:  2007 Sep 23

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

let s:notename = '%(LA|SI|DO|RE|MI|FA|SOL|[A-G])%([#&]|\\shrp\_A@=\s*|\\flt\_A@=\s*)='
let s:reqchord = '%(' . s:notename . '\d*%(%(maj|m|sus|dim|\+|add)\d*)*%(\/' . s:notename . ')=)'
let s:tablature = '\\gtab\{' . s:reqchord . '\}\{%(\d:|\{[^\}]\}:|:)=[0-4XO]{6}%(:[0-4XO]{6})=\}'
let s:chord = '%(' . s:reqchord . '|\(' . s:reqchord . '\)|' . s:tablature . '|)'

syntax match sbOtherCommand "\\\I*\%({[^{}]*}\)*" contained display

syntax match sbBadBeginSong "\\beginsong\%(\_A\|\%$\)\@=" contained display
syntax match sbBadEndSong "\\endsong\%(\_A\|\%$\)\@=" contained display
syntax match sbBadBeginScripture "\\beginscripture\%(\_A\|\%$\)\@=" contained display
syntax match sbBadEndScripture "\\endscripture\%(\_A\|\%$\)\@=" contained display
syntax match sbBadQuote '[^\\\n]\zs"' contained display
syntax match sbBadBrack "\[\|\]" contained display
syntax match sbBadMeasurebar ~\a|\+\_[!?.,:;'"/()\-]~hs=s+1,he=e-1 contained display
syntax match sbBadChord "[^\]]\+" contained display nextgroup=sbChordDone
syntax match sbBadLigChord "[^}]\+" contained display nextgroup=sbLigChordDone
syntax match sbBLBadChord "[^\]]\+" contained display nextgroup=sbBLChordDone

syntax match sbUnfinishedChord "\\\[" contained display nextgroup=sbFirstChord,sbBadChord
syntax match sbUnfinishedTwo "}\%({[^{}]*}\)\{,2}" contained display

syntax match sbBadAfterChord "|" contained display
syntax match sbBadAfterChord "\\measurebar\%(\_A\|\%$\)\@=" contained display
syntax match sbBadAfterChord "\\mbar{\d\+}{\d\+}" contained display

syntax match sbMeasurebar "|" contained display
syntax match sbMeasurebar "\\measurebar\%(\_A\|\%$\)\@=" contained display
syntax match sbMeasurebar "\\mbar{\d\+}{\d\+}" contained display

syntax match sbChord "\\\[\ze[^\]]*\]" contained display nextgroup=sbFirstChord,sbBadChord
execute 'syntax match sbFirstChord "\v\^=' . s:chord . '" contained display nextgroup=sbNextChord,sbChordDone,sbBadChord'
execute 'syntax match sbNextChord "\v%(\~| )' . s:chord . '" contained display nextgroup=sbNextChord,sbChordDone,sbBadChord'
syntax match sbChordDone "\]" contained display nextgroup=sbBadAfterChord
syntax match sbReplayChord "\^" contained display nextgroup=sbBadAfterChord

syntax match sbLigChord "\\m\=ch{" contained display nextgroup=sbFirstLigChord,sbBadLigChord,sbUnfinishedTwo
execute 'syntax match sbFirstLigChord "\v\^=' . s:chord . '" contained display nextgroup=sbNextLigChord,sbLigChordDone,sbBadLigChord,sbUnfinishedTwo'
execute 'syntax match sbNextLigChord "\v%(\~| )' . s:chord . '" contained display nextgroup=sbNextLigChord,sbLigChordDone,sbBadLigChord,sbUnfinishedTwo'
syntax match sbLigChordDone "}\%({[^{}|]*}\)\{3}" contained display nextgroup=sbBadAfterChord

syntax match sbBrokenLig "f|*\ze\%(\^\|\\\[[^\]]*\]\)|*\%(f\|i\|l\)" contained display nextgroup=sbBLChord
syntax match sbBrokenLig "ff|*\ze\%(\^\|\\\[[^\]]*\]\)|*\%(i\|l\)" contained display nextgroup=sbBLChord
syntax match sbBLChord "\\\[" contained display nextgroup=sbBLFirstChord,sbBLBadChord
syntax match sbBLChord "\^" contained display nextgroup=sbBrokenLigEnd
execute 'syntax match sbBLFirstChord "\v\^=' . s:chord . '" contained display nextgroup=sbBLNextChord,sbBLChordDone,sbBLBadChord'
execute 'syntax match sbBLNextChord "\v%(\~| )' . s:chord . '" contained display nextgroup=sbBLNextChord,sbBLChordDone,sbBLBadChord'
syntax match sbBLChordDone "\]" contained display nextgroup=sbBrokenLigEnd
syntax match sbBrokenLigEnd "|*f\=\%(l\|i\)\=" display contained

syntax match sbWhitespace "\s\+" contained display
syntax match sbSongCommand "\\indexentry\%(\[[^]]*\]\)\={[^{}]\+}" contained display
syntax match sbSongCommand "\\indextitleentry\%(\[[^]]*\]\)\={[^{}]\+}" contained display
syntax match sbSongCommand "\\setlicense{[^{}]*}" contained display
syntax match sbSongCommand "\\meter{\d\+}{\d\+}" contained display
syntax match sbSongCommand "\\capo{\d\+}" contained display
syntax match sbSongCommand "\\transpose{-\=\d\+}" contained display
syntax match sbSongCommand "\\chords\%(on\|off\)\%(\_A\|\%$\)\@=" contained display
syntax match sbSongCommand "\\measures\%(on\|off\)\%(\_A\|\%$\)\@=" contained display
syntax match sbSongCommand "\\\%(no\)=repchoruses\%(\_A\|\%$\)\@=" contained display
syntax match sbSongCommand "\\musicnote{[^{}]*}" contained display
syntax match sbSongCommand "\\textnote{[^{}]*}" contained display
syntax match sbSongCommand "\\meter{\d\+}{\d\+}" contained display
execute 'syntax match sbSongCommand "\v' . s:tablature . '" contained display'
syntax match sbVerseCommand "\\brk\%(\_A\|\%$\)\@=" contained display
syntax match sbVerseCommand "\\memorize\%(\_A\|\%$\)\@=" contained display
syntax match sbVerseCommand "\\rep{\d\+}" contained display
syntax match sbScripCommand "^\s*\\[AB]colon\%(\_A\|\%$\)\@=" contained display
syntax match sbScripCommand "\\strophe\%(\_A\|\%$\)\@=" contained display
syntax match sbScripCommand "\\scrip\%(in\|out\)dent\%(\_A\|\%$\)\@=" contained display
syntax match sbScripCommand "\\scitehere\%(\_A\|\%$\)\@=" contained display

let s:condname = 'chorded\|lyric\|slides\|partiallist\|songindexes\|measures\|pdfindex\|rawtext\|transcapos\|vnumbered'
syntax region sbCondBlock matchgroup=sbVerseCommand start="\\echo{" end="}" oneline transparent contained display
execute 'syntax region sbCondBlock matchgroup=sbMetaGroupCmd start="\\begin\z(\%(' . s:condname . '\)\%(only\|never\)\)\%(\_A\|\%$\)\@=" end="\\end\z1\%(\_A\|\%$\)\@=" transparent contained'
execute 'syntax region sbCondBlock matchgroup=sbMetaGroupCmd start="\\if\%(' . s:condname . '\)\%(\_A\|\%$\)\@=" end="\\fi\%(\_A\|\%$\)\@=" end="\\\%(else\%(\_A\|\%$\)\)\@=" nextgroup=sbElse transparent contained'
syntax region sbElse matchgroup=sbMetaGroupCmd start="else\%(\_A\|\%$\)\@=" end="\\fi\%(\_A\|\%$\)\@=" transparent contained

syntax cluster sbSongCommands contains=sbComment,sbVerse,sbChorus,sbBadBeginSong,sbBadBeginScripture,sbBadEndScripture,sbSongCommand,sbWhitespace,sbCondBlock,sbOtherCommand

syntax cluster sbSongContent contains=sbChord,sbLigChord,sbReplayChord,sbUnfinishedChord,sbBadBrack,sbBadBeginSong,sbBadBeginScripture,sbBadEndScripture,sbBadQuote,sbBadMeasurebar,sbComment,sbSongCommand,sbVerseCommand,sbCondBlock,sbMeasurebar,sbBrokenLig

syntax region sbVerse matchgroup=sbSubGroupCmd start="\\beginverse\*\=\ze\%(\_A\|\%$\)" end="\\endverse\ze\%(\_A\|\%$\)" contained contains=@sbSongContent
syntax region sbChorus matchgroup=sbSubGroupCmd start="\\beginchorus\ze\%(\_A\|\%$\)" end="\\endchorus\ze\%(\_A\|\%$\)" contained contains=@sbSongContent

syntax region sbSong matchgroup=sbBeginSong start="\\beginsong\%(\_A\|\%$\)\@=" end="\\endsong\%(\_A\|\%$\)\@=" contains=@sbSongCommands,sbSongTitle fold keepend
syntax match sbUnfinishedSong "\_.\{-}\\endsong\%(\_A\|\%$\)\@=" contained
syntax region sbGroup start="{" end="}" transparent contains=sbGroup contained
syntax region sbSongTitle matchgroup=sbBeginSong start="\%(\\beginsong\_s*\)\@<={" end="}\_s*" contains=sbGroup nextgroup=sbSongKeyvals,sbSongRefs skipwhite skipnl contained
syntax region sbSongRefs matchgroup=sbBeginSong start="{" end="}\_s*" contains=sbGroup nextgroup=sbSongAuthors,sbUnfinishedSong skipwhite skipnl contained
syntax region sbSongAuthors matchgroup=sbBeginSong start="{" end="}\_s*" contains=sbGroup nextgroup=sbSongCopyright,sbUnfinishedSong skipwhite skipnl contained
syntax region sbSongCopyright matchgroup=sbBeginSong start="{" end="}" contains=sbGroup contained
syntax region sbSongKeyvals matchgroup=sbBeginSong start="\[" end="\]" contains=sbKeyKnown,sbKeyOther,sbBadKeyval contained
syntax match sbBadKeyval "\_s*\zs\_[^\]]*" contained
syntax match sbKeyOther "\_s*\a\+\s*=" nextgroup=sbValue,sbValueGroup skipwhite skipnl contained
syntax match sbKeyKnown "\_s*\%(by\|sr\|cr\|li\|index\|ititle\)\s*=" nextgroup=sbValue,sbValueGroup skipwhite skipnl contained
syntax match sbValue "[^{]\@=[^,=\]]*" nextgroup=sbKeyvalOpt,sbBadKeyval skipwhite skipnl contained
syntax region sbValueGroup matchgroup=sbBeginSong start="{" end="}" contains=sbGroup nextgroup=sbKeyvalOpt,sbBadKeyval skipwhite skipnl contained
syntax match sbKeyvalOpt "\%(,\_s*\)\+" nextgroup=sbKeyKnown,sbKeyOther,sbBadKeyval skipwhite skipnl contained

syntax region sbScripture matchgroup=sbScripture start="\\beginscripture{[^{}]*}" end="\\endscripture\%(\_A\|\%$\)\@=" contains=sbScripCommand,sbComment,sbBadBeginSong,sbBadEndSong,sbBadBeginScripture,sbBadQuote fold keepend
syntax region sbComment start="%" end="$" keepend
syntax match sbOuterCommand "\\nextcol\%(\_A\|\%$\)\@="
syntax match sbOuterCommand "\\slides\%(\_A\|\%$\)\@="
syntax match sbOuterCommand "\\chords\%(on\|off\)\%(\_A\|\%$\)\@="
syntax match sbOuterCommand "\\measures\%(on\|off\)\%(\_A\|\%$\)\@="
syntax match sbOuterCommand "\\onesongcolumn\%(\_A\|\%$\)\@="
syntax match sbOuterCommand "\\twosongcolumns\%(\_A\|\%$\)\@="
syntax match sbOuterCommand "\\scripture\%(on\|off\)\%(\_A\|\%$\)\@="
syntax match sbOuterCommand "\\\%(no\)=repchoruses\%(\_A\|\%$\)\@="

syntax sync match sbSongSync grouphere NONE "\\endsong\%(\_A\|\%$\)\@="
syntax sync match sbScriptureSync grouphere NONE "\\endscripture\%(\_A\|\%$\)\@="

if !exists("g:did_songbook_syntax_inits")
  let g:did_songbook_syntax_inits = 1
  if version < 508
    command -nargs=+ HiLink hi link <args>
    command -nargs=+ HiDefn hi <args>
  else
    command -nargs=+ HiLink hi def link <args>
    command -nargs=+ HiDefn hi def <args>
  endif

  HiDefn sbBeginSong term=bold,underline ctermfg=1 gui=bold guifg=DarkBlue
  HiDefn sbSongTitle term=bold,underline ctermfg=1 gui=bold guifg=DarkBlue
  HiDefn sbSongRefs term=bold,underline ctermfg=1 gui=bold guifg=DarkBlue
  HiDefn sbSongAuthors term=bold,underline ctermfg=1 gui=bold guifg=DarkBlue
  HiDefn sbSongCopyright term=bold,underline ctermfg=1 gui=bold guifg=DarkBlue
  HiDefn sbKeyKnown term=bold,underline ctermfg=1 gui=bold guifg=DarkBlue
  HiDefn sbKeyvalOpt term=bold,underline ctermfg=1 gui=bold guifg=DarkBlue

  HiDefn sbSubGroupCmd term=bold,underline ctermfg=4 gui=bold guifg=#FF5000
  HiDefn sbMetaGroupCmd term=bold,underline ctermfg=12 gui=bold guifg=Red

  HiDefn sbChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbFirstChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbNextChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbChordDone term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbReplayChord term=bold ctermfg=2 gui=bold guifg=SeaGreen

  HiDefn sbLigChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbFirstLigChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbNextLigChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbLigChordDone term=bold ctermfg=2 gui=bold guifg=SeaGreen  

  HiDefn sbBLChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbBLFirstChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbBLNextChord term=bold ctermfg=2 gui=bold guifg=SeaGreen
  HiDefn sbBLChordDone term=bold ctermfg=2 gui=bold guifg=SeaGreen

  HiDefn sbMeasurebar ctermfg=6 gui=bold guifg=Brown
  HiDefn sbVerseCommand term=bold ctermfg=1 gui=bold guifg=SlateBlue
  HiDefn sbSongCommand term=bold ctermfg=1 gui=bold guifg=SlateBlue
  HiDefn sbScripCommand term=bold ctermfg=1 gui=bold guifg=Violet
  HiDefn sbOuterCommand term=bold ctermfg=1 gui=bold guifg=SlateBlue
  HiDefn sbScripture term=bold ctermfg=5 guifg=Purple

  HiDefn sbBrokenLig term=bold ctermbg=1 gui=bold guibg=SlateBlue
  HiDefn sbBrokenLigEnd term=bold ctermbg=1 gui=bold guibg=SlateBlue

  HiLink sbComment Comment
  HiLink sbBadChord Error
  HiLink sbBadLigChord Error
  HiLink sbBLBadChord Error
  HiLink sbUnfinishedChord Todo
  HiLink sbUnfinishedTwo Todo
  HiLink sbBadAfterChord Error
  HiLink sbBadBeginSong Error
  HiLink sbMissingArg Error
  HiLink sbBadEndSong Error
  HiLink sbBadBeginScripture Error
  HiLink sbBadEndScripture Error
  HiLink sbBadQuote Error
  HiLink sbBadBrack Error
  HiLink sbBadMeasurebar Error
  HiLink sbOtherCommand Normal
  HiLink sbChorus Normal
  HiLink sbVerse Normal
  HiLink sbSong Error
  HiLink sbBadKeyval Error

  delcommand HiLink
  delcommand HiDefn
endif

let b:current_syntax = "songbook"
