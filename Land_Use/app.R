#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#this is the latest and correct version 

library(shiny)
library(dplyr)
library(rsconnect)
library(tidyr)

df <- read.csv(file = "https://raw.githubusercontent.com/Terner-Center/California-Housing-and-Land-Use-Laws/main/Latest_land_use_data.csv",check.names=FALSE)
df <- df[c("Bill No.","Session","Bill Section",'Tags (No Code Ranges)',"Function","URL to Bill Text")]

#df$Section <- gsub('§ ', ' ', df$Section)
  
names(df)[names(df) == 'Function'] <- 'Bill Focus'
names(df)[names(df) == 'Tags (No Code Ranges)'] <- 'Topics'
names(df)[names(df) == 'Link to Bill Text'] <- 'URL to Bill Text'
dataframe <- df[c("Bill No.","Session","Bill Section",'Topics',"Bill Focus","URL to Bill Text")]

dataframe$Session <- factor(dataframe$Session)
dataframe$`Bill No.` <- factor(dataframe$`Bill No.`)
dataframe$`Bill Section` <- factor(dataframe$`Bill Section`)
dataframe$Topics <- factor(dataframe$Topics)

#dataframe <- dataframe %>% mutate(clickme = '<a href="#" 
#                    onmousedown="event.preventDefault(); event.stopPropagation(); alert(event); return false;";
#                    >CLICKME</a>')


dataframe$`URL to Bill Text` <- paste0("<a href='",dataframe$`URL to Bill Text`,"' target='_blank'>","Bill Text","</a>")


# Define UI
ui <- fluidPage(
  downloadButton("download_data", "Download full dataset as CSV"),
 DT::dataTableOutput("data"),
)

# Define server logic
server <- function(input, output) {
  # Filter dataframe based on search input and selected columns
  filtered_data <- reactive({
    if (length(input$columns) == 0) {
      # If no columns are selected, return the full dataframe
      return(dataframe)
    } else {
      # If columns are selected, filter the dataframe
      dataframe %>%
        filter_at(vars(input$columns), any_vars(grepl(input$search, ., ignore.case = TRUE)))
    }
  })


  
  # Render dataframe in DT
  output$data <- DT::renderDataTable({
    DT::datatable(filtered_data(), filter = "top", escape = FALSE, rownames = FALSE)
  })

    
  # Write filtered data to CSV file when download button is clicked
  output$download_data <- downloadHandler(
    filename = paste("Land_Use_Data_",toString(Sys.Date()), ".csv", sep = ""),
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

# Initialize reactive values
shinyServer(function(input, output, session) {
  reactiveValuesToList(session)$search <- ""
})

# Run the Shiny app
shinyApp(ui = ui, server = server)