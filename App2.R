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
  
  tags$head(tags$script(src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js")), # add jQuery min script
  useShinyjs(),
  
  navbarPage(
    
    title = "UNSUB",
    id = "navigate",
    
    tabPanel(
      title = "Upload",
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
          actionButton(
            inputId = "findsubs", 
            style="display:none;", 
            label = "Find My Subscriptions"
          ),
          tags$hr(),
          checkboxInput("header", "Header", TRUE)
        ),
        mainPanel(
          dataTableOutput("txn")
        )
      )      
    ),
    
    tabPanel(
      title = "Your Active Subscriptions",
      value = "subs_tab",
      div(
        id="hello_text",
        dataTableOutput("analyze")
      )
    )
    
  )
)


server <- function(input, output, session) {
  
  # Render data table on home page --------------
  output$txn <- renderDataTable({

    inFile <- input$file1
    
    if (is.null(inFile)) {
      
      return(NULL)
      
    } else {
    
      
      this_file <- read_csv(inFile$datapath)
      
      shinyjs::show(id="findsubs", anim=T, time=1) # reveal "Find My Subscriptions" button
      
      this_file 
      
    }
  })
  
  # Onclick redirect functionality -----------
  onclick(
    
    id = "findsubs",
    expr = {
      updateTabsetPanel(
        session, 
        inputId = "navigate", 
        selected = "subs_tab"
      )
    }

  )  
  
  # Execute the model and attach results ---------------
  observeEvent(input$button, {
    output$analyze <- renderDataTable({
      
      data <- analyze(input$file1$datapath)
                                      
    })
  })
  
}

shinyApp(ui, server)
