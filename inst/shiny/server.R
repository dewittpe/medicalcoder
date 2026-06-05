server <- function(input, output, session) {
  output$icdcodes <- DT::renderDataTable(icdcodes)

  has_selection <- function(x) {
    length(x) > 0L && !is.null(x) && !identical(x, "") && !is.na(x)
  }

  # reset the radio buttons and the other selectors
  observeEvent({input$clear_radiobuttons},{
    updateRadioButtons(session = session, inputId = "icdv", selected = character(0))
    updateRadioButtons(session = session, inputId = "dx",   selected = character(0))
    for (id in c("chapter", "subchapter", "category", "subcategory", "subclassification", "subsubclassification")) {
      updateSelectInput(session = session, inputId = id, choices = character(0), selected = character(0))
    }
  })

  # update the type (diagnostic or procedure code) after the version is selected
  observeEvent(c(input$icdv), {
    req(input$icdv)
    updateRadioButtons(
      session = session,
      inputId = "dx",
      #choices = c("Diagnostic" = 1, "Procedure" = 0),
      selected = character(0)
    )
  })

  # update the chapter select
  observeEvent(c(input$dx), {
    req(input$dx)
    idx <- which(
      (comorbiditycodes[["icdv"]] == input$icdv) &
        (comorbiditycodes[["dx"]] == input$dx)
    )
    updateSelectInput(
      session = session,
      inputId = "chapter",
      choices = unique(comorbiditycodes[["chapter"]][idx]),
      selected = character(0)
    )
  })

  # update subchapter
  observeEvent(c(input$chapter), {
    req(input$chapter)
    idx <- which(
      (comorbiditycodes[["icdv"]]    == input$icdv)    &
      (comorbiditycodes[["dx"]]      == input$dx)      &
      (comorbiditycodes[["chapter"]] == input$chapter)
    )
    choices <- unique(comorbiditycodes[["subchapter"]][idx])
    updateSelectInput(
      session  = session,
      inputId  = "subchapter",
      choices  = choices,
      selected = ifelse(length(choices) > 1L, character(0L), choices)
    )
  })

  # update the category select
  observeEvent(c(input$subchapter), {
    req(input$subchapter)
    idx <- which(
      (comorbiditycodes[["icdv"]]       == input$icdv)       &
      (comorbiditycodes[["dx"]]         == input$dx)         &
      (comorbiditycodes[["chapter"]]    == input$chapter)    &
      (comorbiditycodes[["subchapter"]] == input$subchapter)
    )
    choices <- unique(comorbiditycodes[["category"]][idx])
    updateSelectInput(
      session = session,
      inputId = "category",
      choices  = choices,
      selected = ifelse(length(choices) > 1L, character(0L), choices)
    )
  })

  # update the subcategory select
  observeEvent(c(input$category), {
    req(input$category)
    idx <- which(
      (comorbiditycodes[["icdv"]]       == input$icdv)       &
      (comorbiditycodes[["dx"]]         == input$dx)         &
      (comorbiditycodes[["chapter"]]    == input$chapter)    &
      (comorbiditycodes[["subchapter"]] == input$subchapter) &
      (comorbiditycodes[["category"]]   == input$category)
    )
    choices <- unique(comorbiditycodes[["subcategory"]][idx])
    updateSelectInput(
      session = session,
      inputId = "subcategory",
      choices  = choices,
      selected = ifelse(length(choices) > 1L, character(0L), choices)
    )
  })

  # update the subclassification select
  observeEvent(c(input$subcategory), {
    req(input$subcategory)
    idx <- which(
      (comorbiditycodes[["icdv"]]        == input$icdv)       &
      (comorbiditycodes[["dx"]]          == input$dx)         &
      (comorbiditycodes[["chapter"]]     == input$chapter)    &
      (comorbiditycodes[["subchapter"]]  == input$subchapter) &
      (comorbiditycodes[["category"]]    == input$category)   &
      (comorbiditycodes[["subcategory"]] == input$subcategory)
    )
    choices <- unique(comorbiditycodes[["subclassification"]][idx])
    updateSelectInput(
      session = session,
      inputId = "subclassification",
      choices  = choices,
      selected = ifelse(length(choices) > 1L, character(0L), choices)
    )
  })

  # update the subsubclassification select
  observeEvent(c(input$subclassification), {
    req(input$subclassification)
    idx <- which(
      (comorbiditycodes[["icdv"]]              == input$icdv)              &
      (comorbiditycodes[["dx"]]                == input$dx)                &
      (comorbiditycodes[["chapter"]]           == input$chapter)           &
      (comorbiditycodes[["subchapter"]]        == input$subchapter)        &
      (comorbiditycodes[["category"]]          == input$category)          &
      (comorbiditycodes[["subcategory"]]       == input$subcategory)       &
      (comorbiditycodes[["subclassification"]] == input$subclassification)
    )
    choices <- unique(comorbiditycodes[["subsubclassification"]][idx])
    updateSelectInput(
      session = session,
      inputId = "subsubclassification",
      choices  = choices,
      selected = ifelse(length(choices) > 1L, character(0L), choices)
    )
  })

  # determine the rows of the comorbiditycodes and the icdcodes tables to
  # summarize
  rws <- reactive({
    irws <- rep(TRUE, nrow(icdcodes))
    crws <- rep(TRUE, nrow(comorbiditycodes))

    if (has_selection(input$icdv) && input$icdv %in% c(9, 10)) {
      irws <- irws & (icdcodes[["icdv"]] == input$icdv)
      crws <- crws & (comorbiditycodes[["icdv"]] == input$icdv)
    }

    if (has_selection(input$dx) && input$dx %in% c(0, 1)) {
      irws <- irws & (icdcodes[["dx"]] == input$dx)
      crws <- crws & (comorbiditycodes[["dx"]] == input$dx)
    }

    if (has_selection(input$chapter)) {
      irws <- irws & (icdcodes[["chapter"]] == input$chapter)
      crws <- crws & (comorbiditycodes[["chapter"]] == input$chapter)
    }

    if (has_selection(input$subchapter)) {
      irws <- irws & (icdcodes[["subchapter"]] == input$subchapter)
      crws <- crws & (comorbiditycodes[["subchapter"]] == input$subchapter)
    }

    if (has_selection(input$category)) {
      irws <- irws & (icdcodes[["category"]] == input$category)
      crws <- crws & (comorbiditycodes[["category"]] == input$category)
    }

    if (has_selection(input$subcategory)) {
      irws <- irws & (icdcodes[["subcategory"]] == input$subcategory)
      crws <- crws & (comorbiditycodes[["subcategory"]] == input$subcategory)
    }

    if (has_selection(input$subclassification)) {
      irws <- irws & (icdcodes[["subclassification"]] == input$subclassification)
      crws <- crws & (comorbiditycodes[["subclassification"]] == input$subclassification)
    }

    if (has_selection(input$subsubclassification)) {
      irws <- irws & (icdcodes[["subsubclassification"]] == input$subsubclassification)
      crws <- crws & (comorbiditycodes[["subsubclassification"]] == input$subsubclassification)
    }

    list(irws = irws, crws = crws)
  })

  js <- reactive({
    js <- c("icdv", "dx")

    if (!has_selection(input$icdv) || !has_selection(input$dx)) {
      js <- c("icdv", "dx")
    } else if (!has_selection(input$chapter)) {
      js <- c("icdv", "dx", "chapter")
    } else if (!has_selection(input$subchapter)) {
      js <- c("icdv", "dx", "chapter", "subchapter")
    } else if (!has_selection(input$category)) {
      js <- c("icdv", "dx", "chapter", "subchapter", "category")
    } else if (!has_selection(input$subcategory)) {
      js <- c("icdv", "dx", "chapter", "subchapter", "category", "subcategory")
    } else if (!has_selection(input$subclassification)) {
      js <- c("icdv", "dx", "chapter", "subchapter", "category", "subcategory", "subclassification")
    } else if (!has_selection(input$subsubclassification)) {
      js <- c("icdv", "dx", "chapter", "subchapter", "category", "subcategory", "subclassification", "subsubclassification")
    } else {
      js <- c("icdv", "dx", "chapter", "subchapter", "category", "subcategory", "subclassification", "subsubclassification", "full_code")
    }
    js
  })

  pccc_count_table <- reactive({

    pattern <- paste(input$pcccconditions, collapse = "|")

    if (length(input$pcccconditions) == 0 || nchar(pattern) == 0) {
      pattern <- "NOTTHING HAS BEEN SELECTED"
    }

    tab <-
      comorbiditycodes[rws()$crws, .(
        `known ICD codes` = .N,
        v3.1 = sum(grepl(pattern, pccc_v3.1)),
        v3.0 = sum(grepl(pattern, pccc_v3.0)),
        v2.1 = sum(grepl(pattern, pccc_v2.1)),
        v2.0 = sum(grepl(pattern, pccc_v2.0))
        ), keyby = eval(js())]
    for (j in c("v3.1", "v3.0", "v2.1", "v2.0")) {
      zeros <- which(tab[[j]] == 0)
      data.table::set(tab, j = j, value = as.character(tab[[j]]))
      data.table::set(tab, i = zeros, j = j, value = "")
    }
    tab[]
  })

  pccc_codes_and_condtions_table <- reactive({
    comorbiditycodes[rws()$crws, .(full_code, v3.1 = pccc_v3.1, v3.0 = pccc_v3.0, v2.1 = pccc_v2.1, v2.0 = pccc_v2.0)]
  })

  pccc_icdcode_table <- reactive({
    icdcodes[rws()$irws][, .(full_code, src, desc, known_start, known_end, assignable_start, assignable_end, desc_start, desc_end)]
  })

  output$pccccounts <- shiny::renderTable({pccc_count_table()}, hover = TRUE, align = "r")
  output$pccccodesandconditions <- DT::renderDataTable({pccc_codes_and_condtions_table()})
  output$pccccodes <- DT::renderDataTable({pccc_icdcode_table()})
}
