server <- function(input, output, session) {
  output$icdcodes <- DT::renderDataTable(icdcodes)

  # reset the radio buttons
  observeEvent({input$clear_radiobuttons},{
    updateRadioButtons(session, "icdv", selected = character(0))
    updateRadioButtons(session, "dx", selected = character(0))
    updateSelectInput(session, "chapter", selected = character(0))
    updateSelectInput(session, "subchapter", selected = character(0))
    updateSelectInput(session, "category", selected = character(0))
  })

  # update the chapter select
  observeEvent(c(input$icdv, input$dx), {
    req(input$icdv, input$dx) # Prevents execution before both are clicked
    idx <- which((comorbiditycodes[["icdv"]] == input$icdv) & (comorbiditycodes[["dx"]] == input$dx))
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
    updateSelectInput(
      session = session,
      inputId = "subchapter",
      choices = unique(comorbiditycodes[["subchapter"]][idx]),
      selected = character(0)
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
    updateSelectInput(
      session = session,
      inputId = "category",
      choices = unique(comorbiditycodes[["category"]][idx]),
      selected = character(0)
    )
  })

  rws <- reactive({
    irws <- rep(TRUE, nrow(icdcodes))
    crws <- rep(TRUE, nrow(comorbiditycodes))

    if (length(input$icdv) > 0L & length(input$dx) > 0L) {
      irws <- irws & (icdcodes[["icdv"]] == input$icdv)
      crws <- crws & (comorbiditycodes[["icdv"]] == input$icdv)

      irws <- irws & (icdcodes[["dx"]] == input$dx)
      crws <- crws & (comorbiditycodes[["dx"]] == input$dx)

      if (input$chapter != "") {
        irws <- irws & (icdcodes[["chapter"]] == input$chapter)
        crws <- crws & (comorbiditycodes[["chapter"]] == input$chapter)
      }
    }

    list(irws = irws, crws = crws)
  })

  pccc_count_table <- reactive({
    cat("\n\n")
    message("input$icdv: ", input$icdv)
    message("input$dx: ", input$dx)
    message("input$chapter: ", input$chapter)
    message("input$subchapter: ", input$subchapter)
    message("input$category: ", input$subchapter)

    message("length(rws()$crws): ", length(rws()$crws))


    pattern <- paste(input$pcccconditions, collapse = "|")
    if (length(input$pcccconditions) == 0 || nchar(pattern) == 0) {
      pattern <- "NOTTHING HAS BEEN SELECTED"
    }

    js <- c("icdv", "dx")

    if (is.null(input$icdv) | is.null(input$dx)) {
      js <- c("icdv", "dx")
    } else if (input$chapter == "") {
      js <- c("icdv", "dx", "chapter")
    } else if (input$chapter != "" & input$subchapter == "") {
      js <- c("icdv", "dx", "chapter", "subchapter")
    }

    #if (length(input$chapter) != "") {
    #  js <- c("icdv", "dx", "chapter", "subchapter")
    #}

    comorbiditycodes[rws()$crws, .(
      n31 = sum(grepl(pattern, pccc_v3.1)),
      n30 = sum(grepl(pattern, pccc_v3.0)),
      n21 = sum(grepl(pattern, pccc_v2.1)),
      n20 = sum(grepl(pattern, pccc_v2.0)),
      .N), keyby = js][]
  })

  pccc_icdcode_table <- reactive({
    icdcodes[rws()$irws][]
  })

  output$pccccounts <- DT::renderDataTable({pccc_count_table() })
  output$pccccodes <- DT::renderDataTable({pccc_icdcode_table() })
}
