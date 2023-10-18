#' Download references that match a given WOS query
#' 
#' @description
#' This function sends a query to the Web Of Science Starter API 
#' (\url{https://developer.clarivate.com/apis/wos-starter}) and returns 
#' references that match this query.
#' 
#' To learn how to write a WOS query, users can read the WOS documentation 
#' available at:
#' \url{https://images.webofknowledge.com/images/help/WOK/contents.html}.
#' A list of WOS field tags is available at: 
#' \url{https://images.webofknowledge.com/images/help/WOS/hs_wos_fieldtags.html}.
#' 
#' It's strongly recommended to use the function [wos_search] before to 
#' have an idea on how many records you will download.
#' 
#' @param limit an `numeric` of length 1. The number of records to retrieve.
#'   Default is `NULL` (all possible records will be retrieved).
#' 
#' @param sleep an `numeric` of length 1. To not stress the WOS STARTER API, a 
#'   random number between 0 and `sleep` will be picked to suspend queries.
#' 
#' @inheritParams wos_search
#' 
#' @return A `data.frame` with `n` rows (where `n` is the total number of 
#' references) and the following 21 variables:
#' `uid`: the unique identifier of the reference in the Web of Science system;
#' `document_type`: the document type;
#' `title`: the title of the reference;
#' `authors`: the authors of the reference;
#' `published_year`: the published year;
#' `published_month`: the published month;
#' `source`: the title of the source (journal, book, etc.) in which the 
#'   reference was published;
#' `volume`: the volume number;
#' `issue`: the issue number;
#' `pages`: the pages range in the source;
#' `no_article`: the article number;
#' `supplement_number`: the supplement number (if applicable);
#' `special_issue`: `SI` in case of a special issue (if applicable);
#' `book_editors`: the book authors (if applicable);
#' `keywords`: the authors keywords;
#' `doi`: the Digital Object Identifier;
#' `eissn`: the Electronic International Standard Identifier Number;
#' `issn`: the International Standard Identifier Number;
#' `isbn`: International Standard Book Number.
#' `pmid`: PubMed identifier.
#' `citations`: the number of citations in the database.
#'   
#' @export
#' 
#' @examples
#' \dontrun{
#' ## Write query to retrieve references of one author ----
#' query <- "AU=(\"Casajus Nicolas\")"
#' 
#' ## Check the number of records ----
#' wos_search(query)
#' 
#' ## Download metadata of records ----
#' refs <- wos_get_records(query)
#' }

wos_get_records <- function(query, database = "WOS", limit = NULL, sleep = 1) {
  
  if (!is.null(limit)) {
    if (limit == 0) {
      stop("Argument 'limit' must be strictly positive", call. = FALSE)
    }
  }
  
  
  ## URL encoding ----
  
  query <- utils::URLencode(query, reserved = TRUE)
  
  
  ## Get total number of references ----
  
  n_refs <- wos_search(query, database)
  
  if (!is.null(limit)) {
    if (n_refs >= limit) {
      n_refs <- limit
    } else {
      limit <- n_refs
    }
  }
  
  
  ## Checks ----
  
  # if (n_refs > 100000) {
  #   stop("Number of records found exceeds WOS LITE API limit (> 100,000).\n",
  #        "Please refine your search.", call. = FALSE)
  # }
  
  if (n_refs == 0) {
    stop("No reference found")
  }
  
  
  ## Compute number of requests ----
  
  refs  <- data.frame()
  
  n_records_per_page <- 50
  
  if (!is.null(limit)) {
    if (limit <= n_records_per_page) {
      n_records_per_page <- limit
    }
  }
  
  pages <- seq(1, n_refs, by = n_records_per_page)
  
  
  for (page in pages) {
    
    
    ## Write query ----
    
    request <- paste0(api_url(), "/documents", "?db=", database, "&q=", query,
                      "&limit=", n_records_per_page, "&page=", page)
    
    
    ## Send query ----
    
    response <- httr::GET(url    = request, 
                          config = httr::add_headers(
                            `accept`   = 'application/json',
                            `X-ApiKey` = get_token()))
    
    
    ## Check response ----
    
    httr::stop_for_status(response)
    
    
    ## Extract total number of records ----
    
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    content <- jsonlite::fromJSON(content)
    
    content <- content$"hits"
    
    
    ## Convert listed df to df ----
    
    data <- data.frame(
      "uid"                = content$"uid",
      "document_type"      = list_to_df(content$"sourceTypes"),
      "title"              = list_to_df(content$"title"),
      "authors"            = unlist(lapply(content$"names"$"authors", 
                                           function(x) {
                                             if (is.null(x)) {
                                               NA
                                             } else {
                                               paste0(x[ , 1], collapse = " | ")  
                                             }})),
      "published_year"     = list_to_df(content$"source"$"publishYear"),
      "published_month"    = list_to_df(content$"source"$"publishMonth"),
      "source"             = list_to_df(content$"source"$"sourceTitle"),
      "volume"             = list_to_df(content$"source"$"volume"),
      "issue"              = list_to_df(content$"source"$"issue"),
      "pages"              = list_to_df(content$"source"$"pages"$"range"),
      "no_article"         = list_to_df(content$"source"$"articleNumber"),
      "supplement_number"  = list_to_df(content$"source"$"supplement"),
      "special_issue"      = list_to_df(content$"source"$"specialIssue"),
      "book_editors"       = unlist(lapply(content$"names"$"bookEditors", 
                                           function(x) {
                                             if (is.null(x)) {
                                               NA
                                             } else {
                                               paste0(x[ , 1], collapse = " | ")  
                                             }})),
      "keywords"           = list_to_df(content$"keywords"$"authorKeywords"),
      "doi"                = content$"identifiers"$"doi",
      "eissn"              = content$"identifiers"$"eissn",
      "issn"               = content$"identifiers"$"issn",
      "isbn"               = content$"identifiers"$"isbn",
      "pmid"               = content$"identifiers"$"pmid",
      "citations"          = unlist(lapply(content$"citations", 
                                           function(x) {
                                             ifelse(is.null(x$"count"), NA, 
                                                    x$"count")
                                             })))
    
    refs <- rbind(refs, data)
    
    
    ## Do not stress the API ----
    
    if (length(pages) > 1) Sys.sleep(sample(seq(0, sleep, by = 0.01), 1))
  }
  
  if (!is.null(limit)) refs <- refs[1:limit, ]
  
  refs
}
