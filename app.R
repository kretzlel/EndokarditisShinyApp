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
                 

                 tabPanel("Vorgeschichte",
                          checkboxGroupInput("Erkrankungen", "", choices = list(
                            "Congenital heart disease" = 1,
                            "Left heart endocarditis" = 2,
                            "Right heart endocarditis" = 3,
                            "Pacemaker endocarditis" = 4,
                            "Intracardiac device" = 5,
                            "Native valve endocarditis" = 6,
                            "Prosthetic valve endocarditis" = 7
                          ), selected = 0, width = 500)
                 ),
                 
                 #tbaPanel zeigt die wichtigsten Vorerkrankungen
                 tabPanel("Vorerkrankungen",
                          wellPanel(
                          fluidRow(column(width=5,
                                          checkboxGroupInput("vorerkrankungen","Anamnese", choices = list(
                                            "Diabetes" = 1,
                                            "Hypertonus" = 2,
                                            "Koronare Herzkrankheit" = 3,
                                            "Congestive Heart Failure" = 4,
                                            "Dialyse" = 5
                                          ), selected = 0, width = 500),
                                          
                                          checkboxInput("maligne", "Maligne Grunderkrankung", FALSE),
                                          
                                          
                                          checkboxInput("fremd","Fremdmaterial", FALSE),
                                          
                                          
                                          
                                          
                                          
                          ),
                          column(width = 5,
                                 conditionalPanel(condition = "input.maligne == 1",
                                                  textInput("maligneFreitext", "Maligne Erkrankung")),
                                 
                                 conditionalPanel(condition = "input.fremd == 1",
                                                  textInput("fremd1", "Klappenersatz"),
                                                  textInput("fremd2", "Endoprothesen"),
                                                  textInput("fremd3", "Devices"),
                                                  textAreaInput("fremd4","Sonstiges Fremdmaterial")
                                                  
                                 )
                                 
                          )
                          )),
                          
                          wellPanel( fluidRow(column(width = 4,selectInput("antibiotika1", "Antibiotikum:",
                                                                c("Ampicillin",
                                                                  "Flucloxacillin",
                                                                  "Gentamicin")),
                                          
                                          selectInput("antibiotika2", NULL,
                                                      c("Ampicillin",
                                                        "Flucloxacillin",
                                                        "Gentamicin")),
                                          
                                          selectInput("antibiotika3", NULL,
                                                      c("Ampicillin",
                                                        "Flucloxacillin",
                                                        "Gentamicin")),
                                          
                                          
                                    )
                          ))
                          
                          
                          
                          
                 ),

                 # tabPanel zeigt Tage/Zeitstrahl mit auffälligen Symptomen, ggf. Fieberkurve, dokumentiert Medikamenteneinnahme
                 tabPanel("Zusammenfassung"),
                 
                 # initiale Einstellungen wie Benutzungszeitraum, Telefonnummern, Medikamenteneinnahme, Import-Möglichkeit für Arztbrief
                 tabPanel("Arztangaben", fluidPage(
                      textInput("patVorname", "Vorname Patient"),
                      textInput("patNachname", "Nachname Patient"),
                      radioButtons("geschlecht", "Geschlecht", choices = list("männlich"=1,"weiblich"=2)),
                      helpText("Body Surface Area (BSA) in qm"),
                      textOutput("bsa"),
                      numericInput("groesse", "Körpergröße in cm", 170, min=100, max=220),
                      numericInput("gewicht", "Körpergewicht in kg", 80, min=30, max=200),
                      textAreaInput("diagnosen", "Diagnosen", width='80%', height=200, placeholder="Bitte relevante Nebendiagnosen aufführen")
                    
                 )),
                 
                 # Miscellaneous
                 navbarMenu("Misc", 
                            tabPanel("Telefonnumern", 
                                     fluidPage(
                                       helpText(
                                         HTML("<table>
                                                <tr><td>Dr. Herzlich</td><td>                         0800-123456789</td>
                                                <tr><td>Krankenhaus der Barmherzigen Tanten&nbsp;&nbsp;&nbsp;</td><td>       0123-4556789</td>
                                                <tr><td>Hausärztlicher Notdienst</td><td>                  116 117</td>
                                                <tr><td>Notruf / Rettungsdienst</td><td>                   112</td>
                                                </table>")
                                       )   
                                     )),
                            tabPanel("Arztbrief")
                 )
                 
)

# Define Server Logic ----
server <- function(input, output) {
  output$bsa <- renderText({0.007184 * input$groesse^0.725 * input$gewicht^0.425}) # DuBois
}

shinyApp(ui, server)