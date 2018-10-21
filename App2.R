library(httr)
library(shiny)
library(shinyjs)
library(tidyverse)
library(devtools)
library(reticulate)
library(RJSONIO)
library(rPython)

setwd("~/Desktop/Website")

ui <- fluidPage(
  useShinyjs(),
  navbarPage(
    "Hacking Alpha",
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
      "Subscriptions",
      checkboxInput("hideshow", "Show?", F),
      div(
        id="hello_text",
        textOutput("txt")
      )
    )
  )
)

server <- function(input, output) {
  
  output$txn <- renderDataTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
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
  
  observeEvent(input$hideshow, {
    
    if (input$hideshow == F) {
      hide(id="hello_text", anim = F)
    } else {
      show(id="hello_text", anim = F)
      output$txt <- renderText({
        "test output"
      })
    }
    
  })
  
  observeEvent(input$button, {
    python.load("analyze.py")
    python.call("analyze", file1)
  })
  
}

shinyApp(ui, server)
