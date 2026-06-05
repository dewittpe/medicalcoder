ui <-
  dashboardPage(
    dashboardHeader(title = paste0("medicalcoder", packageVersion("medicalcoder"))),
    dashboardSidebar(
      sidebarMenu(
        id = "sidebar_tabs",
        #menuItem("ICD Codes", tabName = "icd", icon = icon("fas fa-book-medical")),
        menuItem("PCCC", tabName = "pccc", icon = icon("fas fa-home")),
        conditionalPanel(
          condition = "input.sidebar_tabs == 'pccc'",
          selectInput(
            inputId = "pcccconditions",
            label = "Select PCCC Condition(s)",
            choices = pccc_conditions,
            multiple = TRUE
          )
        ),
        radioButtons(
          inputId = "icdv",
          label = "ICD Version",
          choices = c(9, 10),
          selected = character(0),
          inline = TRUE
        ),
        radioButtons(
          inputId = "dx",
          label = "", #"Diagnostic or Procedure Codes",
          choices = c("Diagnostic" = 1, "Procedure" = 0),
          selected = character(0),
          inline = TRUE
        ),
        actionButton("clear_radiobuttons", "Reset Radio Buttons"),
        conditionalPanel(
          condition = "(input.icdv == '9' || input.icdv == '10') && (input.dx == '1' || input.dx == '0')",
          selectInput("chapter", "Select a Chapter:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "(input.chapter != '')",
          selectInput("subchapter", "Select a Subhapter:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "(input.subchapter != '')",
          selectInput("category", "Select a Category:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "(input.category != '')",
          selectInput("subcategory", "Select a Category:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "(input.subcategory != '')",
          selectInput("subclassification", "Select a Category:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "(input.subclassification != '')",
          selectInput("subsubclassification", "Select a Category:", choices = NULL, multiple = FALSE)
        )
      )
    ),
    dashboardBody(
      tabItems(
        #tabItem(tabName = "icd", DT::dataTableOutput("icdcodes")),
        tabItem(
          tabName = "pccc",
          h1("Counts"),
          DT::dataTableOutput("pccccounts"),
          h1("Codes"),
          DT::dataTableOutput("pccccodes")
        )
      )
    )
  )

