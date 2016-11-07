" Atomic save.  See http://vim.1045645.n5.nabble.com/Race-condition-once-again-td1211624.html
function! AtomicSave()
  let l:filename_raw = resolve(expand('<afile>'))|
  let l:tempfile_raw = l:filename_raw . '.tmp'|
  let l:filename = shellescape(l:filename_raw)|
  let l:tempfile = shellescape(l:tempfile_raw)|

  if (writefile(getline(1, '$'), l:tempfile_raw) != 0)|
    echo "error writing file"|
    return|
  endif|
  
  " chown for the cases when superuser edit someone else's file
  call system('! test -e ' . l:filename . ' || chown --reference=' . l:filename . ' ' . l:tempfile)|
  
  " it's hard to grab the perms to make this portable. see http://mywiki.wooledge.org/BashFAQ/087
  call system('! test -e ' . l:filename . ' || chmod --reference=' . l:filename . ' ' . l:tempfile)|
  if v:shell_error|
    echo "error setting permissions on temporary file: chmod returned " . v:shell_error|
    return|
  endif|
  " NOTE: vim's "rename" erroneously calls "unlink" on its target!
  " THIS DOES NOT WORK: if (rename(expand('<afile>').'.tmp', expand('<afile>')) == 0) | set nomodified | echo "error" | endif
  call system('mv ' . l:tempfile . ' ' . l:filename)|
  if v:shell_error|
    echo "error renaming file: mv returned " . v:shell_error|
  else|
    echomsg l:filename . ' written (atomically)'|
    set nomodified|
  endif|
endfunction
