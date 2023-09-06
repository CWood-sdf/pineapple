  " Comment
  function! IsHexColorLight(hexColor) abort
    let l:raw_color = trim(a:color, '#')
    let l:r = str2nr(substitute(l:raw_color, '(.{2}).{4}', '1', 'g'), 16)
    let l:g = str2nr(substitute(l:raw_color, '.{2}(.{2}).{2}', '1', 'g'), 16)
    let l:b = str2nr(substitute(l:raw_color, '.{4}(.{2})', '1', 'g'), 16)
    let l:lightness = ((l:r * 299) + (l:g * 587) + (l:b * 114)) / 1000
    return l:lightness > 155
  endfunction
