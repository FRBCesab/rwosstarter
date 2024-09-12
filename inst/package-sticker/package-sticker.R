#' 
#' Create an Hexagonal Sticker for the Package
#' 

hexSticker::sticker(
  
  subplot  = here::here("inst", "package-sticker", "clarivate.png"),
  package  = "rwosstarter",
  filename = here::here("man", "figures", "package-sticker.png"),
  dpi      = 1200,
  
  p_size   = 76.0,        # Title
  u_size   = 12.0,        # URL
  p_family = "Aller_Rg",
  
  p_color  = "#f2f2f2",   # Title
  h_fill   = "#002B36",   # Background
  h_color  = "#0D1117",   # Border
  u_color  = "#f2f2f2",   # URL
  
  p_x      = 1.00,        # Title
  p_y      = 0.60,        # Title
  
  s_x      = 1.00,        # Subplot
  s_y      = 1.25,        # Subplot
  s_width  = 0.5,
  s_height = 2.5,
  
  spotlight = TRUE,
  
  l_alpha   = 0.10,
  l_width   = 3,
  l_height  = 3,
  
  asp = 0.90,
  
  url      = "https://frbcesab.github.io/rwosstarter"
)
