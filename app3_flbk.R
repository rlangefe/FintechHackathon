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

ui <- fluidPage( # create page
  tags$head(tags$script(src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js")), # add jQuery min script
  useShinyjs(), # initialize shinyjs
  navbarPage( # create navbar
    title = "UNSUB", # website title on navbar
    id = "navigate", # id for tabset
    tabPanel( # first panel
      title = "Upload", # text that appears in navbar
      sidebarLayout( # content - sidebar layout
        sidebarPanel( 
          fileInput( # file box
            inputId = "file1", # set id attribute
            label = "Choose CSV File", # text that appears in upload box
            accept = c(
              "text/csv",
              "text/comma-separated-values,text/plain",
              ".csv"
            )
          ),
          actionButton(
            inputId="findsubs",
            style="display:none;",
            label="Find My Subscriptions"
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
        dataTableOutput("companies")
      )
    ),
    
    tags$script("
      $('#txn').on('draw.dt', function () {
        alert('table loaded');
      });
    ")
  )
)

server <- function(input, output, session) {
  
  # Render data table on home page --------------
  output$txn <- 
    renderDataTable({
      inFile <- input$file1
    
      if (is.null(inFile)) {
        return(NULL)
      } else {
        this_file <- read_csv(inFile$datapath) # read in data
        shinyjs::show(id="findsubs", anim=T, time=1) # reveal "Find My Subscriptions" button
        this_file   
      }
    
    })
  
  # Onclick redirect functionality -----------
  onclick(
    id = "findsubs", 
    expr = {
      # alert("yolo") 
      updateTabsetPanel(
        session, 
        inputId = "navigate", 
        selected = "subs_tab")
    }
  )
  
  # Generate sample subscriptions -------------
  observeEvent(input$findsubs, {
    output$companies <- renderDataTable(
      expr = {
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
      }
    )
    
  })
  
  # End Server ----------------------
}

shinyApp(ui, server)
