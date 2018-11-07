shinyServer(
  
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
  
)
