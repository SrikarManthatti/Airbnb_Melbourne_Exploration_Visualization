#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/

  navbarPage("Melbourne_airbnb", id='nav', theme = shinytheme(theme ="yeti"),
          tabPanel("Map the Listings",
                   div(class="outer",
                       tags$head(
                         includeCSS("styles.css")
                        
                       ),
                       
                       leafletOutput("myleaflet",width="100%", height="100%"),
                       absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                                     draggable = TRUE, top = 10, left =30 , right ="auto" , bottom = "auto",
                                     width = 280, height = "auto",
                                     h2(
                                        "Listing in Melbourne"),
                                     selectInput("council",
                                                 "Select council:",
                                                 choices=council,
                                                 selected = council),
                                     
                                     checkboxGroupInput("room",
                                                        h4("Select room type:"),
                                                        choices = room_types,
                                                        selected = room_types
                                     ),
                                     sliderInput("price", h4("Price"), min = 1, 
                                                 max = 511, value = c(1, 511)),
                                     sliderInput("review",h4("Num of Reviews"), min = 0, 
                                                 max = 257, value = c(0, 257)),
                                     sliderInput("rating",h4("Scores Rating"), min = 0, 
                                                 max = 100, value = c(0, 100))
                                     
                       ),
                       absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                                     draggable = TRUE, top = 300, left ="auto" , right =20 , bottom = "auto",
                                     width = 300, height = "auto",
                                     plotOutput("histroom",height = 150),
                                     plotOutput("medprice",height = 150),
                                     plotOutput("avgrating",height = 150)
                       )
                   )
                   ),
          tabPanel("Reviews Trend over time",    
                   
                   titlePanel("Number of Reviews Over Time"),
                   fluidRow(
                     column(3,
                            h4("The graph on the left side is an interactive trend graph"),
                            br("Hover your mouse pointer on the graph to see the number of reviews"),
                            br("The X axis provides the month and Year, Y axis represents the total count of reviews"),
                            br("The range selector at the bottom csan be used to zoom any review and check clearly"),
                            br("You can also specify the roll period to see the trend clearly"),
                            
                            br(),
                            br()
                           
                            ),
                            
                     column(9,
                            dygraphOutput("dygraph")
                            
                     )
                   )),
          tabPanel("Number of Listings w.r.t Neighbourhood",    
                   fluidRow(
                     column(3,
                            h3(" Listings by Neighbourhood"),
                            br(),
                            br(),
                            br(),
                            selectInput("listformat", h4("Showing as:"), choices = c("Count","Percentage")),
                            sliderInput("listrating",h4("Scores Rating"), min = 0, 
                                        max = 100, value = c(0, 100))
                           
                            
                           
                            
                     ),
                     column(9,
                            htmlOutput("activelist",width=1000,height=600)
                           
                     )
                   )
          )
          
          
  )
  
                        
          
  

