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

ui <- myUI
ui <- secure_app(ui, language="de")


server <- function(input, output, session) {
  
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
      showModal(modalDialog(
        title = "Data saved.",
        paste0("Your data should be saved now."),
        easyClose = TRUE,
        footer = NULL
      )) })
    
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
