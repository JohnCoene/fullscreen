#' Dependencies
#' 
#' Include dependencies, place anywhere in the shiny UI.
#' 
#' @importFrom htmltools htmlDependency
#' 
#' @noRd
#' @keywords internal
useFs <- function(){
  htmlDependency(
    "fullscreen",
    version = utils::packageVersion("fullscreen"),
    src = "assets",
    package = "fullscreen",
    script = c(
      "screenfull.min.js",
      "fs.js"
    )
  )
}

#' Fullscreen Triggers
#' 
#' Create a button or a link that triggers the fullscreen.
#' 
#' @param ... Arguments to pass to the button `.tag`.
#' @param id Id of the button.
#' @param class Class to assign to the button.
#' @param .target Id of target element to make full screen,
#' if `NULL` makes the entire page full screen.
#' @param .type Button type, e.g.: `success`.
#' @param .tag Htmltools or shiny tag to use to create the button.
#' Default to `<a>`.
#' 
#' @examples 
#' library(shiny)
#' 
#' ui <- fluidPage(
#' 	h1("Hello fullscreen"),
#' 	fsButton("Make fullscreen")
#' )
#' 
#' server <- function(...){}
#' 
#' if(interactive())
#'  shinyApp(ui, server)
#' 
#' @name fsTrigger
#' @export 
fsButton <- function(
  ..., 
  id = NULL,
  class = NULL,
  .target = NULL, 
  .type = "default", 
  .tag = htmltools::a
){
  # id
  id <- ensure_id(id)

  # class
  cl <- sprintf("btn btn-%s", .type)
  cl <- paste(cl, class)

  # script
  script <- make_script(id, .target)
  script <- wrap_script(script)

  tg <- as.character(substitute(.tag))

  args <- list(class = cl, ...)
  if(any(tg %in% c("actionButton", "actionLink"))) {
    args[["inputId"]] <- id
  } else {
    args[["id"]] <- id
  }

  btn <- do.call(.tag, args)

  htmltools::tagList(
    useFs(),
    btn,
    script
  )
}

#' @rdname fsTrigger
#' @export 
fsLink <- function(
  ..., 
  id = NULL,
  class = NULL,
  .target = NULL, 
  .tag = htmltools::a
){
  # id
  id <- ensure_id(id)

  # class
  cl <- paste0("", class)

  # script
  script <- make_script(id, .target)
  script <- wrap_script(script)

  tg <- as.character(substitute(.tag))

  args <- list(class = cl, ...)
  if(any(tg %in% c("actionButton", "actionLink"))) {
    args[["inputId"]] <- id
  } else {
    args[["id"]] <- id
  }

  btn <- do.call(.tag, args)

  htmltools::tagList(
    useFs(),
    btn,
    script
  )
}

#' Fullscreen Server
#' 
#' Trigger a full screen from the server.
#' 
#' @param target Id of target element to make full screen,
#' if `NULL` makes the entire page full screen.
#' @param session A valid shiny session.
#' 
#' @examples 
#' library(shiny)
#' 
#' ui <- fluidPage(
#' 	h1("Hello fullscreen"),
#' 	actionButton(
#' 		"fs",
#' 		"Fullscreen via server"
#' 	)
#' )
#' 
#' server <- function(input, output, session){
#' 	observeEvent(input$fs,{
#' 		fs_server()
#' 	})
#' }
#' 
#' if(interactive())
#'  shinyApp(ui, server)
#' 
#' @export
fs_server <- function(
  target = NULL, 
  session = shiny::getDefaultReactiveDomain()
){
  session$sendCustomMessage(
    'fs-trigger', 
    list(
      target = target
    )
  )
}

#' Create Script for Button
#' 
#' @param id Id of button.
#' @param target Target element
#' 
#' @keywords internal
make_script <- function(id, target){
  if(is.null(target))
    target <- 'null'
  else 
    target <- sprintf("'%s'", target)

  sprintf(
    "fsTrigger('%s', %s)",
    id,
    target
  )
}

# Wrap script in tag
wrap_script <- function(script){
  htmltools::tags$script(script)
}

#' Generate a Random Id
#' 
#' @param id Id, if `NULL` one is generated.
#' 
#' @keywords internal
ensure_id <- function(id = NULL){
  if(!is.null(id))
    return(id)

  id <- paste0(sample(c(1:9, letters), 35), collapse = "")
  sprintf("fs_%s", id)
}