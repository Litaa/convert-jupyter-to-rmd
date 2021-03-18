source('assets/jupyter.R')

to_Rmd <- function(path_input = here::here('ipynb/'),
                   path_output = here::here('Rmd/')){
  filenames <- gsub(
    "\\.ipynb$","",
    list.files(path_input, pattern = "\\.ipynb$")
  )
  
  for(i in filenames){
    nb_rmd <- convert_ipynb(paste0(path_input, '/', i,'.ipynb'),
                            paste0(path_output, '/', i,'.Rmd'))
    xfun::file_string(nb_rmd)
  }
}

to_Rmd()


