function! ReturnHighlightTerm(group, term)
   " Store output of group to variable
   let output = execute('hi ' . a:group)

   " Find the term we're looking for
   return matchstr(output, a:term.'=\zs\S*')
endfunction

put ='0: '
put =g:terminal_color_0
put ='1: '
put =g:terminal_color_1
put ='2: '
put =g:terminal_color_2
put ='3: '
put =g:terminal_color_3
put ='4: '
put =g:terminal_color_4
put ='5: '
put =g:terminal_color_5
put ='6: '
put =g:terminal_color_6
put ='7: '
put =g:terminal_color_7
put ='8: '
put =g:terminal_color_8
put ='9: '
put =g:terminal_color_9
put ='10: '
put =g:terminal_color_10
put ='11: '
put =g:terminal_color_11
put ='12: '
put =g:terminal_color_12
put ='13: '
put =g:terminal_color_13
put ='14: '
put =g:terminal_color_14
put ='15: '
put =g:terminal_color_15
put ='background: '
put =ReturnHighlightTerm('Normal', 'guibg')
put ='foreground: '
put =ReturnHighlightTerm('Normal', 'guifg')
put ='cursorColor: '
put =ReturnHighlightTerm('Cursor', 'guibg')





