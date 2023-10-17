api_url <- function() "https://api.clarivate.com/apis/wos-starter/v1"

get_token <- function(key = "WOS_STARTER_KEY") {
  
  wos_token <- Sys.getenv(key)
  
  if (wos_token == "") {
    stop("Missing Web of Science API key.\n",
         "Please make sure you:\n",
         " 1. have obtained you own API key, and\n",
         " 2. have stored the API key in the `~/.Renviron` file ",
         "using the function `usethis::edit_r_environ()`.\n",
         "    Add this line: WOS_STARTER_KEY='XXX' and restart R.")
  }
  
  wos_token
}
