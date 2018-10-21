library(httr)
library(shiny)
library(shinyjs)
library(tidyverse)
library(devtools)
library(reticulate)
# library(RJSONIO)

# setwd("C:/Users/gleas/Google Drive/Coding/R/FintechHackathon-master/FintechHackathon-master")
# use_virtualenv('C:/Users/gleas/Google Drive/Coding/R/FintechHackathon-master/FintechHackathon-master', required = TRUE)
# source_python("analyze.py")

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
          actionButton(
            input="button",
            label="Find My Subscriptions"
          ),
          # div(
          #   id="in_method",
          #   textOutput("in_txt")
          # ),
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
        dataTableOutput("companies")
      )
    )
  )
)

server <- function(input, output) {
  
  output$txn <- 
    renderDataTable({
      inFile <- input$file1
    
      if (is.null(inFile)) {
        return(NULL)
      } else {
        this_file <- read_csv(inFile$datapath)
        this_file   
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
    output$companies <- renderDataTable({
        tibble(
          companyname = c(
            "Spotify"
            ,"bouqs flower"
            ,"Hulu"
            ,"Hello fresh classic plan"
            ,"blue apron"
            ,"Gym membership"
            ,"Tinder Plus"
            ,"Camfed donation"
            ,"sephora monthly box"
            ,"Home Chef"
            ,"Amazon Prime"
            ,"Verizon Plan"
            ,"Love Food snack pack"
            ,"Grocery Delivery"
            ,"ESPN"
            ,"costco membership"
            ,"Netflix"
            ,"iCloud"
            ,"Kindle Unlimited"
            ,"dropbox plus"
            ,"Pandora Plus"
            ,"Fill Oil Refill"
            ,"ebay"
            ,"Cell Phone Plan"
            ,"HeadSpace"
            ,"Dollar Shave clube"
            ,"Wix Unlimited"
          )
        )
    })
  })
  
}

shinyApp(ui, server)