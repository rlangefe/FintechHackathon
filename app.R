library(httr)
library(shiny)
library(tidyverse)
library(devtools)

setwd("C:/Users/gleas/Google Drive/Coding/R/")

ui <- fluidPage(
  navbarPage(
    "Hacking Alpha",
    tabPanel(
      "Upload Page",
      sidebarLayout(
        sidebarPanel(
          fileInput("file1", "Choose CSV File",
                    accept = c(
                      "text/csv",
                      "text/comma-separated-values,text/plain",
                      ".csv")
          ),
          tags$hr(),
          checkboxInput("header", "Header", TRUE)
        ),
        mainPanel(
          tableOutput("txn")
        )
      )      
    ),
    tabPanel(
      "Panel 2",
      textOutput("txt")
    )
  )
)

server <- function(input, output) {
  output$txn <- renderTable({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    this_file <- read_csv(inFile$datapath)
    
    this_file %>% 
      mutate(first = as.integer(1)) %>%
      select(first, everything())
  })
  
  output$txt <- renderText({
    "Hey how's it going?"
  })
}

shinyApp(ui, server)