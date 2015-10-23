if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufNewFile,BufRead *.amk setf amk
augroup END
augroup filetypedetect
  au! BufNewFile,BufRead *.mamk setf mamk
augroup END
