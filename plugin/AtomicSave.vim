function! AtomicSave()
  if (writefile(getline(1, '$'), expand('<afile>').'.tmp') == 0)|
    call system('if [ -f ' . shellescape(expand('<afile>')) . ' ]; then chmod --reference=' . shellescape(expand('<afile>')) . ' ' . shellescape(expand('<afile>').'.tmp') . '; fi')|
    if  v:shell_error|
      echo "error chmod file: chmod returned " v:shell_error|
    endif|

    " NOTE: vim's "rename" erroneously calls "unlink" on its target!
    " THIS DOES NOT WORK: if (rename(expand('<afile>').'.tmp', expand('<afile>')) == 0) | set nomodified | echo "error" | endif
    call system('mv ' . shellescape(expand('<afile>').'.tmp') . ' ' . shellescape(expand('<afile>')))|
    if  v:shell_error|
      echo "error renaming file: mv returned " v:shell_error|
    else|
      set nomodified|
    endif|
  else|
    echo "error writing file"|
  endif|
endfunction

" autocmd BufWriteCmd .procmailrc call AtomicSave()
