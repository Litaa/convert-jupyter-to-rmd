
# Guideline converting .ipynb to .Rmd file

1. Put your `.ipynb` file into ipynb folder
2. Go to assets folder
3. Open and run all code on `jupyter.R`. Make sure that there's no errors when you're running the code.
4. Open and run all code on `converter.R`. Make sure that there's no errors when you're running the code.
5. After successfully running the code, converted `.ipynb` files automatically  will be in Rmd folder with `.Rmd` extension
6. Do some setting inside your .Rmd file to ensure the code be able to connect with your python environment. Here below simple setting you can do :
```{r echo=FALSE}
Sys.setenv(RETICULATE_PYTHON = "C:/<your-anaconda-path>/envs/<your-env-name>/python.exe")
library(reticulate)
py_run_string("import os")
py_run_string("os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = 'C:<your-anaconda-path>/Library/plugins/platforms'")
```

7. Run all the code by knitting into HTML file
8. All done and good luck!~
