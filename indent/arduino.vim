if exists("b:did_indent")
   finish
endif
let b:did_indent = 1

" Arduino is just C with some additions, so C indentation will work fine
setlocal cindent

let b:undo_indent = "setl cin<"
