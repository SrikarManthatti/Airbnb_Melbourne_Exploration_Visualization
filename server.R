#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

function(input, output){
  dfInput <- reactive({
    df <- mel_airbnb %>%
      filter(neighbourhood %in% input$council,
             room_type %in% input$room,
             price >=input$price[1],
             price<=input$price[2],
             number_of_reviews >=input$review[1],
             number_of_reviews <=input$review[2],
             review_scores_rating>=input$rating[1],
             review_scores_rating<=input$rating[2])
  })
  
  pricedata<-reactive({
    df<-dfInput()%>%
      group_by(room_type)%>%
      summarise(med_price=median(price))
  })
  ratingdata<-reactive({
    df<-dfInput()%>%
      group_by(room_type)%>%
      summarise(avg_rating=mean(review_scores_rating))
  })
  
  #dfInput <- reactive({mel_airbnb %>% filter(neighbourhood == input$council)})
output$myleaflet <- renderLeaflet({
  #new_data <- dfInput()
  m <- leaflet(data = dfInput())%>%setView(lat=-37.8139992, lng = 144.9633179,zoom = 10)%>%addProviderTiles(providers$OpenStreetMap.HOT)%>%  
    addCircles(~longitude, ~latitude, color = ~pal(room_type), opacity = 1, radius = 5, popup = ~paste(sep = "<br/>","<b>Room Type:</b>",room_type,
                                                                                                       "<b>Neighbourhood:</b>",neighbourhood,
                                                                                                       "<b>Price:</b>",price,
                                                                                                       "<b>Minimum Nights:</b>", minimum_nights,
                                                                                                       "<b>Num. of Reviews:</b>",number_of_reviews,
                                                                                                       "<b>Review Rating:</b>",review_scores_rating))
})
  output$histroom <- renderPlot({
    
    ggplot(dfInput(), aes(room_type, ..count..)) + 
      geom_bar(aes(fill = room_type))+
     
      scale_fill_manual(values = c("Entire home/apt"= "#EE3B3B",
                                   "Private room" ="#0000EE",
                                   "Shared room" ="#66CD00"),
                        guide=FALSE)+
      labs(y="Count",x="Room Type")
    
  })
  
  output$medprice <- renderPlot({
    
    ggplot(pricedata(), aes(x=room_type,y=med_price)) + 
      geom_bar(aes(fill = room_type),stat="identity",position='dodge')+
     
      scale_fill_manual(values = c("Entire home/apt"= "#EE3B3B",
                                   "Private room" ="#0000EE",
                                   "Shared room" ="#66CD00"),
                        guide=FALSE)+
      labs(y="Median Price",x="Room Type")
  })  
  
  output$avgrating <- renderPlot({
    
    ggplot(ratingdata(), aes(x=room_type,y=avg_rating)) + 
      geom_bar(aes(fill = room_type),stat="identity",position='dodge')+
     
      scale_fill_manual(values = c("Entire home/apt"= "#EE3B3B",
                                   "Private room" ="#0000EE",
                                   "Shared room" ="#66CD00"),
                        guide=FALSE)+
      labs(y="Avg. Rating Score",x="Room Type")
  }) 
  
  
  ##Code for plotting the graph in second tab
 
  reviewdate<-reactive({
    df <- review %>%
      group_by(date) %>%
      summarise(.,count=n())
    xt <- xts(x = df$count, order.by = as.Date(df$date))
  })
  
  rwd<-reactive({review_txt})
  
  output$dygraph <- renderDygraph({
    dygraph(reviewdate(),ylab = "Num. of Reviews / Day") %>%
      dyOptions(drawGrid = TRUE)%>%
      dySeries("V1", label = "Num. of Reviews")%>%
      dyRangeSelector()%>%
      dyRoller(rollPeriod = 60)
    
  })
  
  ##Bargraphs for listings
  
  listdata <- reactive({
    df <- mel_airbnb %>%
      filter(review_scores_rating>=input$listrating[1],
             review_scores_rating<=input$listrating[2])%>%
      select(neighbourhood,room_type)
  })
  
  listdata2<-reactive({
    df<- mel_airbnb%>%
      filter(review_scores_rating>=input$listrating[1],
             review_scores_rating<=input$listrating[2])%>%
      group_by(neighbourhood,room_type) %>%
      tally  %>%
      group_by(neighbourhood) %>%
      mutate(p=(100*n)/sum(n))%>%
      select(neighbour=neighbourhood,room_type,p)
  })
  output$activelist<-renderGvis({
    if(input$listformat=="Count"){
      df<-table(listdata()$neighbourhood,listdata()$room_type)
      df<-as.data.frame.matrix(df)
      df$neighbour<-rownames(df)}
    if(input$listformat=="Percentage") {
      df <- as.data.frame(with(listdata2(), tapply(p, list(neighbour, room_type) , I)))
      df$neighbour<-rownames(df)
    }
    gvisBarChart(df,"neighbour",c("Entire home/apt","Private room","Shared room"),
                 options=list(colors= "['#EE3B3B', '#0000EE','#66CD00']",
                              legend="bottom",
                              bar="{groupWidth:'500%'}",
                              gvis.editor="Change Graph",
                              width=1000,height=900))
    
  })
  
  
  
  
 
}

