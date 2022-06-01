library(shiny)

# Define UI ----
ui <- navbarPage("EndokarditisPal",
                 tabPanel("Tagebuch", 
                          sidebarLayout(
                            sidebarPanel(
                              dateInput("Datum", 
                                        label = "Datum", format="dd.mm.yyyy", language="de", weekstart=1, 
                                        min="2022-05-15", max="2022-10-15", value = Sys.Date())
                              ),
                            mainPanel(NULL, 
                                      radioButtons("fieber", "Fieber", choices = list(
                                        "Ich habe kein Fieber" = 1, "Ich habe Fieber" = 2), selected = 1
                                      ),
                            conditionalPanel(
                              condition = "input.fieber == 2", 
                              numericInput("temp", "gemessene Körpertemperatur", 37.0, min=35.0, max=42.0, step=0.1)
                            ),
                            checkboxGroupInput("symptome", "Sonstige Symptome", choices = list(
                              "Kopfschmerzen" = 1, "allgemein Abgeschlagenheit" = 2, "Appetitlosigkeit" = 3,
                              "Nachtschweiß" = 4, "Muskel- oder Gelenkschmerzen" = 5), selected = 0),
                            
                            #conditionalPanel wird nur angezeigt, wenn Medikamente hinterlegt sind
                            checkboxGroupInput("medis", "Gestern eingenommene Medikamente", choices = list(
                              "Rifampicin 600 mg (z.B. EREMFAT) 1 Tablette um 8:00" = 1,
                              "Rifampicin 600 mg (z.B. EREMFAT) 1 Tablette um 20:00" = 2
                            ), selected = 0, width = 500)
                          ))),
                 
                 # tabPanel zeigt Tage/Zeitstrahl mit auffälligen Symptomen, ggf. Fieberkurve, dokumentiert Medikamenteneinnahme
                 tabPanel("Zusammenfassung"),
                 
                 # initiale Einstellungen wie Benutzungszeitraum, Telefonnummern, Medikamenteneinnahme, Import-Möglichkeit für Arztbrief
                 tabPanel("Einstellungen"),
                 
                 # Miscellaneous
                 navbarMenu("Misc", 
                            tabPanel("Telefonnumern", 
                                     fluidPage(
                                          helpText(
                                            HTML("Dr. Herzlich                         0800-123456789<br/>
                                                Krankenhaus der Barmherzigen Tanten       0123-4556789<br/>
                                                Hausärztlicher Notdienst                  116 117<br/>
                                                Notruf / Rettungsdienst                   112")
                                          )   
                            )),
                            tabPanel("Arztbrief")
                 )
  
)

# Define Server Logic ----
server <- function(input, output) {
  
}

shinyApp(ui, server)