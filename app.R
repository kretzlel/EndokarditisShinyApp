#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinymanager)
source("sql.R")
source("myUI.R")
#source("test.R")

library(RMySQL)

ui <- myUI
ui <- secure_app(ui, language="de")

# Define Server Logic ----
server <- function(input, output, session) {
  output$bsa <- renderText({0.007184 * input$groesse^0.725 * input$gewicht^0.425}) # DuBois
  
  res_auth <- secure_server(
      check_credentials = function(username, password) {
        if (authenticateUser(username, password)) {
          list(result = TRUE, user_info = list(user=user$username, something=user$linkedPatient))
        } else {
          list(result = FALSE)
        }
      }
    )

  output$bsa <- renderText({0.007184 * input$groesse^0.725 * input$gewicht^0.425}) # DuBois

  observeEvent(input$submit, {
    databaseName <- "EndocarditisApp"
    table <- "Symptoms"
    
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    
    data <- c(1, format(input$Datum, "'%Y-%m-%d'"), input$fieber == 1, sum(1*(input$symptome == 1)) == 1, sum(1*(input$symptome == 3)) == 1)
    names(data) <- c("PatientId", "Date", "Fever", "Headache", "Malaise")
    
    query <- sprintf(
      "INSERT INTO %s (%s) VALUES (%s)",
      table, 
      paste(names(data), collapse = ", "),
      paste(data, collapse = ", ")
    )
    # Submit the update query and disconnect
    dbGetQuery(db, query)
    dbDisconnect(db)
    showModal(modalDialog(
      title = "Ihre Daten sind gespeichert.",
      paste0("Ihre Daten sind jetzt gespeichert"),
      easyClose = TRUE,
      footer = NULL
    ))
  })
    #output$patient <- renderText({ user$linkedPatient })
    #output$hp <- renderText({user$healthcareProvider})

    
    output$VorerkrankungenEingabeUI <- renderUI(
      if (user$healthcareProvider == 1) {
        hpUI
      } else {
        tagList(
          helpText("Hier dürfen nur Ärzte Eintragungen machen.")
        )
      }
    )
    
}

shinyApp(ui = ui, server = server)
