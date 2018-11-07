library(httr)
library(shiny)
library(shinyjs)
library(tidyverse)
library(devtools)
library(reticulate)
library(RJSONIO)
library(jsonlite)
library(stringr)

setwd("C:/Users/lange/PycharmProjects/FintechHackathon")
# conda_python("FintechHackathon")
source_python("analyze.py", convert=TRUE)
#use_virtualenv("C:/Users/lange/Miniconda3/envs/r-reticulate")

py_run_string('import pandas')

os <- import('os');
pd <- import("pandas", convert=TRUE)
np <- import("numpy")

ui <- fluidPage(
  
  tags$head(
    # jQuery
    tags$script(src="http://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"),
    # Loading icon CSS
    tags$style(".loader, .loader:before, .loader:after { background: #000000; -webkit-animation: load1 1s infinite ease-in-out; animation: load1 1s infinite ease-in-out; width: 1em; height: 4em; }
               .loader { color: #000000; text-indent: -9999em; margin: 88px auto;position: relative; font-size: 11px; -webkit-transform: translateZ(0); -ms-transform: translateZ(0); transform: translateZ(0); -webkit-animation-delay: -0.16s; animation-delay: -0.16s; }
               .loader:before, .loader:after { position: absolute; top: 0; content: ''; }
               .loader:before { left: -1.5em; -webkit-animation-delay: -0.32s; animation-delay: -0.32s; }
               .loader:after { left: 1.5em; }
               @-webkit-keyframes load1 { 0%, 80%, 100% { box-shadow: 0 0; height: 4em; } 40% { box-shadow: 0 -2em; height: 5em; } }
               @keyframes load1 { 0%, 80%, 100% { box-shadow: 0 0; height: 4em; } 40% { box-shadow: 0 -2em; height: 5em; } }
               ")
    ), 
  
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
        id="analyze_div",
        dataTableOutput("analyze")
      ),
      
      div(
        id="loader_model_results"
        , class="loader"
        , style="display:none;"
      )
      
    ),
    
    tabPanel(
      title = "Insights",
      value = "insi_tab",
      style = "display:none;",
      div(
        id = "insi_content",
        "Insights dashboard content goes HERE"
      )
    )
    
  ),
  
  # Hide loader image when data table renders
  tags$script("
    $('#analyze').on('draw.dt', function () {
        $('#loader_model_results').hide();
    });
  ")
  
)


server <- function(input, output, session) {
  
  # Render data table on home page --------------
  output$txn <- renderDataTable({
    
    inFile <- input$file1
    
    if (is.null(inFile)) {
      
      return(NULL)
      
    } else {
      
      this_file <- read_csv(inFile$datapath)[0:5]
      
      this_file$Amount <- 
        this_file$Amount %>%
        as.double()
      
      this_file$Amount <-
        sprintf("%.2f", round(this_file$Amount,2))

      shinyjs::show(id="findsubs", anim=T, time=1) # reveal "Find My Subscriptions" button
      
      return(this_file) 

    }
  })
  
  # Onclick redirect functionality -----------
  onclick(
    
    id = "findsubs",
    expr = {
      
      shinyjs::toggleState("findsubs") # disable button to prevent double clicks
      
      shinyjs::show(id="loader_model_results", anim=F) # show loading div
      
      updateTabsetPanel(
        session, 
        inputId = "navigate", 
        selected = "subs_tab"
      )
      
    }
    
  )  
  
  # Execute the model and attach results ---------------
  observeEvent(input$findsubs, {
    
    output$analyze <- renderDataTable({
      
      data <- analyze(input$file1$datapath)
      
      data_list <- jsonlite::fromJSON(data)
      
      data_out <-
        data_list$data %>%
        as_tibble() %>%
        rename(Name = V1, Amount = V2)
      
      data_out$Amount <-
        data_out$Amount %>%
        stringr::str_replace("[$]","") %>%
        as.double() %>%
        round(2)
      
      data_out$Amount <-
        sprintf("%.2f", round(data_out$Amount,2))      
      
      return(data_out)
      
    })
    
  })
  
}

shinyApp(ui, server)
