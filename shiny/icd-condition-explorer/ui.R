ui <-
  dashboardPage(
    dashboardHeader(title = paste0("medicalcoder", packageVersion("medicalcoder"))),
    dashboardSidebar(
      sidebarMenu(
        id = "sidebar_tabs",
        menuItem("Overview", tabName = "overview", icon = icon("fas fa-home")),
        menuItem("ICD", tabName = "icd", icon = icon("fas fa-book-medical")),
        menuItem("PCCC", tabName = "pccc", icon = icon("fas fa-book-medical")),
        menuItem("Charlson", tabName = "charlson", icon = icon("fas fa-book-medical")),
        menuItem("Elixhauser", tabName = "elixhauser", icon = icon("fas fa-book-medical")),
        hr(),
        conditionalPanel(
          condition = "input.sidebar_tabs == 'pccc'",
          selectInput(
            inputId = "pcccconditions",
            label = "Select PCCC Condition(s)",
            choices = pccc_conditions,
            multiple = TRUE
          )
        ),
        conditionalPanel(
          condition = "input.sidebar_tabs == 'charlson'",
          selectInput(
            inputId = "charlsonconditions",
            label = "Select Charlson Condition(s)",
            choices = charlson_conditions,
            multiple = TRUE
          )
        ),
        conditionalPanel(
          condition = "input.sidebar_tabs == 'elixhauser'",
          selectInput(
            inputId = "elixhauserconditions",
            label = "Select Elixhauser Condition(s)",
            choices = elixhauser_conditions,
            multiple = TRUE
          )
        ),
        conditionalPanel(
          condition = "(input.sidebar_tabs == 'icd')",
          checkboxGroupInput(
            inputId = "icdcolumns",
            label = "Select Columns to Display",
            choices = c("icdv", "dx", "chapter", "subchapter", "category",
              "subcategory", "subclassification", "subsubclassification",
              "extension", "full_code", "src", "desc", "known_start",
              "known_end", "assignable_start", "assignable_end", "desc_start",
              "desc_end"),
            selected = c("icdv", "dx", "full_code", "src", "desc")
          )
        ),
        conditionalPanel(
          condition = "(input.sidebar_tabs != 'overview' && input.sidebar_tabs != 'icd')",
          radioButtons(
            inputId = "icdv",
            label = "ICD Version",
            choices = c(9, 10),
            selected = character(0),
            inline = TRUE
          )
        ),
        conditionalPanel(
          condition = "(input.icdv == '9' || input.icdv == '10')",
          radioButtons(
            inputId = "dx",
            label = "Diagnostic or Procedure Codes",
            choices = c("Diagnostic" = 1, "Procedure" = 0),
            selected = character(0),
            inline = TRUE
          )
        ),
        conditionalPanel(
          condition = "(input.icdv == '9' || input.icdv == '10') && (input.dx == '1' || input.dx == '0')",
          selectInput("chapter", "Select a Chapter:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "(input.icdv == '9' || input.icdv == '10') && (input.dx == '1' || input.dx == '0') && input.chapter",
          selectInput("subchapter", "Select a Subchapter:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "input.subchapter",
          selectInput("category", "Select a Category:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "input.category",
          selectInput("subcategory", "Select a Subcategory:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "input.subcategory",
          selectInput("subclassification", "Select a Subclassification:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "input.subclassification",
          selectInput("subsubclassification", "Select a Subsubclassification:", choices = NULL, multiple = FALSE)
        ),
        conditionalPanel(
          condition = "(input.sidebar_tabs != 'overview' && input.sidebar_tabs != 'icd')",
          actionButton("clear_radiobuttons", "Reset Selectors")
        )
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "overview", includeMarkdown("overview.md")),
        tabItem(tabName = "icd", DT::dataTableOutput("icdcodetable")),
        tabItem(
          tabName = "pccc",
          h1("Counts"),
          tableOutput("pccccounts"),
          h1("ICD Codes and PCCC Condition(s)"),
          DT::dataTableOutput("pccccodesandconditions"),
          h1("ICD Code Descriptions"),
          DT::dataTableOutput("pcccicdcode_table")
        ),
        tabItem(
          tabName = "charlson",
          h1("Counts"),
          tableOutput("charlsoncounts"),
          h1("ICD Codes and Charlson Condition(s)"),
          DT::dataTableOutput("charlsoncodesandconditions"),
          h1("ICD Code Descriptions"),
          DT::dataTableOutput("charlsonicdcode_table")
        ),
        tabItem(
          tabName = "elixhauser",
          h1("Counts"),
          tableOutput("elixhausercounts"),
          h1("ICD Codes and Elixhauser Condition(s)"),
          DT::dataTableOutput("elixhausercodesandconditions"),
          h1("ICD Code Descriptions"),
          DT::dataTableOutput("elixhausericdcode_table")
        )
      )
    )
  )
