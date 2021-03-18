# ipynb convert -----------------------------------------------------------
convert_ipynb <- function(input, output = xfun::with_ext(input, 'Rmd')){
  json <- jsonlite::fromJSON(input, simplifyDataFrame = FALSE)
  lang <- json$metadata$kernelspec$language
  res <- character()
  for (cell in json$cells) {
    if (length(src <- unlist(cell$source)) == 0) next  # empty cell
    src <- gsub('\n$', '', src)
    src <- switch(
      cell$cell_type,
      code = cell_chunk(src, lang, cell$metadata),
      raw  = cell_raw(src, cell$metadata$format),
      src
    )
    res <- c(res, src, '')
  }
  # title <- gsub("\\.ipynb$|[[:digit:]]+.","",input)
  # title <- gsub("\\_"," ",title)
  # 
  # res <- c(paste0('# ',title,'\n'), res)
  xfun::write_utf8(res, output)
  invisible(output)
}


# convert an ipynb cell to an Rmd chunk

cell_chunk <- function(x, lang, meta = list()) {
  if (length(x) == 0) return()
  # warn against line magics
  if (length(i <- grep(r_line_magics, x)) > 0) warning(
    'Detected the following probable line magics. They do not work in R Markdown.\n\n',
    paste(' ', x[i], collapse = '\n'), call. = FALSE
  )
  # replace cell magics with knitr language engines
  if (grepl(r <- '^%%([[:alnum:]]+)\\s*$', x[1])) {
    lang <- gsub(r, '\\1', x[1]); x <- x[-1]
  }
  if (lang == 'markdown') return(x)
  opts <- c('', meta$name)  # cell name (if defined) to chunk label
  meta <- meta$jupyter  # convert some jupyter cell metadata to chunk options
  opts <- c(
    opts, if (isTRUE(meta$source_hidden)) 'echo=FALSE',
    if (isTRUE(meta$outputs_hidden)) 'results="hide"'
  )
  c(sprintf('```{%s%s}', adjust_lang(lang), paste(opts, collapse = ', ')), x, '```')
}

line_magics <- c(
  'alias', 'alias_magic', 'autoawait', 'autocall', 'automagic',
  'autosave', 'bookmark', 'cat', 'cd', 'clear', 'colors', 'conda',
  'config', 'connect_info', 'cp', 'debug', 'dhist', 'dirs', 'doctest_mode',
  'ed', 'edit', 'env', 'gui', 'hist', 'history', 'killbgscripts',
  'ldir', 'less', 'lf', 'lk', 'll', 'load', 'load_ext', 'loadpy',
  'logoff', 'logon', 'logstart', 'logstate', 'logstop', 'ls', 'lsmagic',
  'lx', 'macro', 'magic', 'man', 'matplotlib', 'mkdir', 'more',
  'mv', 'notebook', 'page', 'pastebin', 'pdb', 'pdef', 'pdoc',
  'pfile', 'pinfo', 'pinfo2', 'pip', 'popd', 'pprint', 'precision',
  'prun', 'psearch', 'psource', 'pushd', 'pwd', 'pycat', 'pylab',
  'qtconsole', 'quickref', 'recall', 'rehashx', 'reload_ext', 'rep',
  'rerun', 'reset', 'reset_selective', 'rm', 'rmdir', 'run', 'save',
  'sc', 'set_env', 'store', 'sx', 'system', 'tb', 'time', 'timeit',
  'unalias', 'unload_ext', 'who', 'who_ls', 'whos', 'xdel', 'xmode'
)

r_line_magics <- paste0('^%?(', paste(line_magics, collapse = '|'), ')($|\\s)')

# convert raw text/html and text/latex cells to raw ```{=format}` Markdown blocks
cell_raw <- function(x, fmt) {
  if (length(fmt) != 1) return()
  fmt <- switch(fmt, 'text/html' = 'html', 'text/latex' = 'latex')
  if (length(fmt) == 0) return()
  c(sprintf('```{=%s}', fmt), x, '```')
}

# adjust some cell magic names to knitr's engine names
adjust_lang <- function(x) {
  if (x == 'R') return('r')
  if (x == 'javascript') return('js')
  # use raw HTML/LaTeX blocks for Pandoc's Markdown
  if (tolower(x) %in% c('html', 'latex')) return(paste0('=', tolower(x)))
  x
}
