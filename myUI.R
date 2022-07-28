antibiotika = c(
  "",
  "Ampicillin",
  "Flucloxacillin",
  "Gentamicin",
  "Vancomycin",
  "Rifampicin",
  "Ceftriaxon",
  "Penicillin G"
)
erreger = c(
  "Staphylococcus aureus",
  "Streptococcus viridans",
  "Staphylococcus epidermidis",
  "Entercoccus faecalis",
  "Streptococcus bovis",
  "HACEK-Gruppe",
  "Pseudomonas aeruginosa",
  " Coxiella burnetii",
  "Brucellen",
  " Legionella pneumophila",
  "Apergillus spp.",
  "Candida spp."
)
material = c("aerobe Blutkultur",
             "anaerobe Blutkultur",
             "ZVK-Spitze",
             "Präparat")


# Define UI ----
myUI <- navbarPage(
  textOutput("appTitle"),
  tabPanel("Start",
    fluidPage(
      textOutput("welcomeMessage", container = tags$h3)
    )       
  ),
  tabPanel("Tagebuch",
           sidebarLayout(
             sidebarPanel(
               dateInput(
                 "Datum",
                 label = "Datum",
                 format = "dd.mm.yyyy",
                 language = "de",
                 weekstart = 1,
                 min = "2022-05-15",
                 max = Sys.Date(),
                 value = Sys.Date()
               ),
               textOutput("tagebuchGespeichert", container = tags$small),
             ),
             mainPanel(
               NULL,
               uiOutput("tagebuchEintrag")
             )
           )
        ),
  
  
  #tbaPanel zeigt die wichtigsten Vorerkrankungen, aktuelle Therapie, vorangegangene Therapien und Mikrobiologische Befunde
  
  tabPanel(
      "Vorerkrankungen Eingabe",
      uiOutput("VorerkrankungenEingabeUI")
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
    navbarMenu(
      "Misc",
      tabPanel("Telefonnumern",
               fluidPage(helpText(
                 HTML(
                   "<table>
                                                <tr><td>Dr. Herzlich</td><td>                         0800-123456789</td>
                                                <tr><td>Krankenhaus der Barmherzigen Tanten&nbsp;&nbsp;&nbsp;</td><td>       0123-4556789</td>
                                                <tr><td>Hausärztlicher Notdienst</td><td>                  116 117</td>
                                                <tr><td>Notruf / Rettungsdienst</td><td>                   112</td>
                                                </table>"
                 )
               ))),
      tabPanel("Arztbrief")
    )
    
  )
  
hpUI <- tagList (
  wellPanel(HTML("<h4>Vorerkrankungen</h4>"), fluidRow(
    column(
      width = 5,
      checkboxGroupInput(
        "vorerkrankungen",
        NULL,
        choices = list(
          "Diabetes" = 1,
          "Hypertonus" = 2,
          "Koronare Herzkrankheit" = 3,
          "Congestive Heart Failure" = 4,
          "Dialyse" = 5
        ),
        selected = 0,
        width = 500
      ),
      
      checkboxInput("maligne", "Maligne Grunderkrankung", FALSE),
      
      
      checkboxInput("fremd", "Fremdmaterial", FALSE),
      
      
      
      
      
    ),
    column(
      width = 5,
      conditionalPanel(
        condition = "input.maligne == 1",
        HTML("<h5>Maligne Erkrankung</h5>"),
        textInput("maligneFreitext", NULL)
      ),
      
      conditionalPanel(
        condition = "input.fremd == 1",
        HTML("<h5>Klappenersatz</h5>"),
        textInput("fremd1", NULL),
        HTML("<h5>Endoprothesen</h5>"),
        textInput("fremd2", NULL),
        HTML("<h5>Devices</h5>"),
        textInput("fremd3", NULL),
        HTML("<h5>sonstiges Fremdmaterial</h5>"),
        textAreaInput("fremd4", NULL)
        
      )
      
    )
  )),
  
  wellPanel(
    HTML("<h4>aktuelle Antibiotikatherapie</h4>"),
    fluidRow(
      column(
        width = 4,
        HTML("<h5>Substanz</h5>"),
        selectInput("antibiotika1",
                    NULL,
                    antibiotika),
        
        selectInput("antibiotika2",
                    NULL,
                    antibiotika,),
        
        selectInput("antibiotika3",
                    NULL,
                    antibiotika),
        
        
      ),
      column(
        width = 4,
        HTML("<h5>Dosierung</h5>"),
        textInput("dosis1", NULL),
        textInput("dosis2", NULL),
        textInput("dosis3", NULL),
      ),
      
      column(
        width = 4,
        HTML("<h5>Beginn</h5>"),
        dateInput(
          "Datum",
          label = NULL,
          format = "dd.mm.yyyy",
          language = "de",
          weekstart = 1,
          min = NULL,
          max = NULL,
          value = NULL
        ),
        dateInput(
          "Datum",
          label = NULL,
          format = "dd.mm.yyyy",
          language = "de",
          weekstart = 1,
          min = NULL,
          max = NULL,
          value = NULL
        ),
        dateInput(
          "Datum",
          label = NULL,
          format = "dd.mm.yyyy",
          language = "de",
          weekstart = 1,
          min = NULL,
          max = NULL,
          value = NULL
        )
      )
    )
  ),
  
  
  wellPanel(
    HTML("<h4>letzte Antibiotikatherapien</h4>"),
    fluidRow(
      column(
        width = 8,
        selectInput("antibiotika2",
                    NULL,
                    antibiotika,
                    multiple = TRUE),
        selectInput("antibiotika2",
                    NULL,
                    antibiotika,
                    multiple = TRUE),
        
      ),
      column(
        width = 4,
        dateRangeInput(
          "daterange1",
          NULL,
          start = NULL,
          end = NULL,
          format = "dd-mm-yyyy",
          separator = "bis",
          width = '100%'
        ),
        dateRangeInput(
          "daterange2",
          NULL,
          start = NULL,
          end = NULL,
          format = "dd-mm-yyyy",
          separator = "bis",
          width = '100%'
        ),
        
      )
    )
  ),
  
  
  
  wellPanel(
    HTML("<h4>Mikrobiologie</h4>"),
    fluidRow(
      column(
        width = 5,
        HTML("<h5>Erreger</h5>"),
        selectInput("mibi1",
                    NULL,
                    erreger,
                    multiple = TRUE),
        selectInput("mibi2",
                    NULL,
                    erreger,
                    multiple = TRUE)
      ),
      
      
      column(
        width = 5,
        HTML("<h5>Material</h5>"),
        selectInput("material1",
                    NULL,
                    material,
                    multiple = TRUE),
        selectInput("material2",
                    NULL,
                    material,
                    multiple = TRUE)
      ),
      
      
      column(
        width = 2,
        HTML("<h5>Befunddatum</h5>"),
        dateInput(
          "dateMibi1",
          NULL,
          format = "dd.mm.yyyy",
          language = "de",
          weekstart = 1,
          min =
            "2022-05-15",
          max = "2022-10-15"
        ),
        dateInput(
          "dateMibi1",
          label = NULL,
          format = "dd.mm.yyyy",
          language = "de",
          weekstart = 1,
          min = "2022-05-15",
          max = "2022-10-15"
        )
      )
    )
  )
  
)
