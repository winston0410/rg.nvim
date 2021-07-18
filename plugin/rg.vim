function! Rg() abort
    set opfunc=Search
    return 'g@'
endfunction

function! Search(type)
	execute "lua require('rg').search()"
endfunction
