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

#' Fullscreen Button
#' 
#' Create a button that triggers the full screen.
#' 
#' @param ... Arguments to pass to the button `.tag`.
#' @param id Id of the button.
#' @param class Class to assign to the button.
#' @param .target Id of target element to make full screen,
#' if `NULL` makes the entire page full screen.
#' @param .type Button type, e.g.: `success`.
#' @param .tag Htmltools or shiny tag to use to create the button.
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
  id <- make_id(id)

  # class
  cl <- sprintf("btn btn-%s", .type)
  cl <- paste(cl, class)

  # script
  script <- make_script(id, .target)
  script <- wrap_script(script)

  tg <- as.character(substitute(.tag))

  if(any(tg %in% c("actionButton", "actionLink"))) {
    btn <- .tag(
      inputId = id,
      class = cl,
      ... 
    )
  } else {
    btn <- .tag(
      id = id,
      class = cl,
      ... 
    )
  }

  htmltools::tagList(
    useFs(),
    btn,
    script
  )
}


fsOnLoad <- function(
  ..., 
  .target = NULL
){

  script <- make_script_on_load(.target)
  script <- wrap_script(script)

  # script
  htmltools::tagList(
    useFs(),
    script
  )
}

make_script_on_load <- function(target){
  if(is.null(target)){
    return(
      "function onLoadFS(e){
        if (screenfull.isEnabled) {
          screenfull.request();
        }       
      };
      window.addEventListener('DOMContentLoaded', onLoadFS);
      "
    )
  }

  sprintf(
    "function onLoadFS(e){
      let element = document.getElementById('%s');
      if (screenfull.isEnabled) {
        screenfull.request(element);
      }       
    };
    window.addEventListener('DOMContentLoaded', onLoadFS);",
    target
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
  if(is.null(target)){
    return(
      sprintf(
        "document.getElementById('%s').addEventListener('click', function(){
          if (screenfull.isEnabled) {
            screenfull.request();
          }       
        });",
        id
      )
    )
  }

  sprintf(
    "document.getElementById('%s').addEventListener('click', function(){
      let element = document.getElementById('%s');
      if (screenfull.isEnabled) {
        screenfull.request(element);
      }       
    });",
    id,
    target
  )
}

wrap_script <- function(script){
  htmltools::tags$script(script)
}

make_id <- function(id){
  if(!is.null(id))
    return(id)

  id <- paste0(sample(c(1:9, letters), 35), collapse = "")
  sprintf("fs_%s", id)
}