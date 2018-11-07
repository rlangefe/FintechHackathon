library(httr)
library(shiny)
library(shinyjs)
library(tidyverse)
library(devtools)
library(reticulate)
library(RJSONIO)
library(jsonlite)
library(stringr)
 
source_python("analyze.py", convert=TRUE)

py_run_string('import pandas')

os <- import('os');
pd <- import("pandas", convert=TRUE)
np <- import("numpy")
