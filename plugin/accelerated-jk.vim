if exists('g:accelerated-jk_loaded') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

lua require('accelerated-jk').setup()
let g:accelerated_jk_loaded = 1

let &cpo = s:save_cpo
unlet s:save_cpo
