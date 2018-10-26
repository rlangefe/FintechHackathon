library(httr)
library(shiny)
library(shinyjs)
library(tidyverse)
library(devtools)
library(reticulate)
library(RJSONIO)

setwd("C:/Users/lange/PycharmProjects/FintechHackathon")
conda_python("FintechHackathon")
source_python("analyze.py", convert=TRUE)
use_virtualenv("C:/Users/lange/Miniconda3/envs/r-reticulate")


py_run_string('import pandas')

os <- import('os');
pd <- import("pandas", convert=TRUE)
np <- import("numpy")

ui <- fluidPage(
  useShinyjs(),
  navbarPage(
    "UNSUB",
    tabPanel(
      "Upload",
      sidebarLayout(
        sidebarPanel(
          fileInput(
            inputId = "file1", 
            label = "Choose CSV File",
            accept = c(
              "text/csv",
              "text/comma-separated-values,text/plain",
              ".csv"
            )
          ),
          actionButton("button","Find My Subscriptions"),
          tags$hr(),
          checkboxInput("header", "Header", TRUE)
        ),
        mainPanel(
          dataTableOutput("txn")
        )
      )      
    ),
    tabPanel(
      "Your Active Subscriptions",
      # checkboxInput("hideshow", "Show?", F),
      div(
        id="hello_text",
        dataTableOutput("analyze")
      )
    )
  )
)


server <- function(input, output) {
  
  
  
  output$txn <- renderDataTable({

    inFile <- input$file1
    
    if (is.null(inFile)) {
      
      return(NULL)
      
    } else {
    
      
      this_file <- read_csv(inFile$datapath)
      
      this_file %>% 
        mutate(first = as.integer(1)) %>%
        select(first, everything())      
      
    }
  })
  
  # observeEvent(input$hideshow, {
  #   
  #   if (input$hideshow == F) {
  #     hide(id="hello_text", anim = F)
  #   } else {
  #     show(id="hello_text", anim = F)
  #     output$txt <- renderText({
  #       "test output"
  #     })
  #   }
  #   
  # })
  
  observeEvent(input$button, {
    output$analyze <- renderDataTable({
      
      data <- analyze(input$file1$datapath)
                                      
    })
  })
  
}

shinyApp(ui, server)
