#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#base code here taken from https://www.davidsolito.com/post/conditional-drop-down-in-shiny/ 
#look at carolinas email for type sof categories they thinking, assing arbitrariliy, and make a mock version they can see 


#seems like you can just embed R shiny stuff within HTML if you publish it first on the R shiny site 
#https://datasciencegenie.com/how-to-embed-a-shiny-app-on-website/
#sign up for an account, try this, and then tell cora how easy 
library(DT)
library(shiny)
library(shinyWidgets)
#library(googlesheets4)
library(dplyr)
library(rsconnect)
#install.packages('rsconnect')
#install.packages("googlesheets4")
#install.packages("shinyWidgets")
#gs4_deauth()

#setwd("/Users/underriner/Desktop/work/land_use_dashboard/Shiny_app")

#if i put on github, need to mask token codes 
#rsconnect::setAccountInfo(name='ternercenter', 
#  token='F7E0AD0553E675AC3A1294CC15A049FA', secret='o5lzKVaFl10nGpEkSDsQK68Mo6GNtLaXyTWREkKR')


#ideally this will be read in from 
#df <- read.csv(file = 'land_use_data_11_23_22.csv')
#the origional file was an uploaded excel - needed to make my own copy that was native to Google sheets 
#df <- read_sheet("https://docs.google.com/spreadsheets/d/1aR21v_mYrVh0dCaU6fcQD6pdMtfoTHIkqH6UHpBUNUQ/edit#gid=0")

df <-read.csv(file = "https://raw.githubusercontent.com/Terner-Center/California-Housing-and-Land-Use-Laws/main/California%20Housing%20and%20Land%20Use%20Laws%20-%20Updates%20Since%202017_last_updated_11_28_22.csv")

df_sub <- df[c("Bill.No.","Session","Topic","Function")]


shinyApp(
  ui = pageWithSidebar(
    headerPanel("Land Use Dashboard Test"),
    
#    sidebarSearchForm(textId = "searchText", buttonId = "searchButton", 
#                      label = "Search dataset", icon = shiny::icon("search"))
#  ),
    
    sidebarPanel(
      #style = "position:fixed;width:220px;",
      selectizeGroupUI(
        id = "my-filters",
        inline = FALSE,
        params = list(
          var_one = list(inputId = "Session", title = "Select Year", placeholder = 'select'),
          var_two = list(inputId = "Bill.No.", title = "Select Bill Number",placeholder ='select')
          #var_three = list(inputId = "var_three", title = "Select variable 3", placeholder = 'select'),
          #var_four = list(inputId = "var_four", title = "Select variable 4", placeholder = 'select'),
          #var_five = list(inputId = "var_five", title = "Select variable 5", placeholder = 'select')
        )
      
        ),
    downloadButton("downloadData", "Download Current Data"),
    ),
    
    
    mainPanel(
      tableOutput("table")
    )
  ),
  
  server = function(input, output, session) {
    
    res_mod <- callModule(
      module = selectizeGroupServer,
      id = "my-filters",
      data = df_sub,
      vars = c("Session", "Bill.No.")
    )
    
    output$table <- renderTable({
      res_mod()
    })
    output$downloadData <- downloadHandler(
      filename = function() {
        paste("Land_Use_Data_",toString(Sys.Date()), ".csv", sep = "") #Sys.Date() #Add date 
      },
      content = function(file) {
        write.csv(res_mod(), file, row.names = FALSE)
      }
    )
    
    
  },
  
  options = list(height = 500)
)

#deployApp()
