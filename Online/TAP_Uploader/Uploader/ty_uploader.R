ty_uploader <- function(epoch,vmac) {
  
  library(redcapAPI)
  library(WordR)
  library(officer)
  library(Hmisc)
  library(tidyverse)
  
  edc <- redcapConnection(url = "https://redcap.vanderbilt.edu/api/",
                          token = "A2F023358C81C065E1D98575795DCD5B", conn, project = 135160)
  pdb <- redcapConnection(url = "https://redcap.vanderbilt.edu/api/",
                          token = "0E16F65FB0A51C570781384D91AA1A78", conn, project = 137402)
  pdb_datas <- exportReports(pdb, 270431)
  edc_datas <- exportReports(edc, 280483)
  pdb_datas <- pdb_datas[which(as.integer(as.factor(pdb_datas[,"redcap_event_name"]))== epoch),]
  
  
  i <- which(pdb_datas["vmac_id"]==as.integer(vmac))
  
  pdb_data <- pdb_datas[i,]
  edc_data <- edc_datas[which(edc_datas["vmac_id"]==as.integer(vmac)),]
  
  events <- c("enrollmentbaseline_arm_1","18month_followup_arm_1","3year_followup_arm_1","5year_followup_arm_1","7year_followup_arm_1")
  
  e <- epoch
  
  #map_id <- as.character(pdb_data$map_id)
  #if (nchar(map_id)==1) {input <- paste0("00",map_id)} else if (nchar(map_id)==2) {input <- paste0("0",map_id)} else {input <- map_id}
  #if (nchar(map_id)==1) {input <- paste0("00",map_id)} else if (nchar(map_id)==2) {input <- paste0("0",map_id)} else {input <- map_id}
  vmac_id <- as.character(pdb_data$vmac_id)
  if (nchar(vmac_id)==1) {record <- paste0("0000",vmac_id)} else if (nchar(vmac_id)==2) {record <- paste0("000",vmac_id)} else if (nchar(vmac_id)==3) {record <- paste0("00",vmac_id)} else if (nchar(vmac_id)==4) {record <- paste0("0",vmac_id)} else {record <- vmac_id}
  input <- record
  last_name <<- pdb_data$last_name
  salutation <<- as.character(pdb_data$salutation)
  
  epoch_conv <- c("enrollment","18 month","3 year","5 year","7 year","9 year","11 year","13 year")
  epoch <<- epoch_conv[e]
  epoch_next <<- epoch_conv[e+1]
  ep_conv <- c("base","1yr","2yr","3yr","4yr")
  ep_next <- ep_conv[e+1]
  ep <- ep_conv[e]
  date_next <- paste0("visit_estimate_",ep_next,"_date")
  date_ty <<- format(as.Date(pdb_data[1, date_next]), "%B %Y")
  
  if (e==1){
    elig_out <- edc_data$elig_outcome
    if (is.na(elig_out)) {elig_out <- "Yes"}
    #enroll_stat <- edc_data$enrollment_status
    
    if (elig_out=="Yes") {
      ef <<- paste0("We look forward to seeing you in ",date_ty," for your next follow up visit!")
      elig <<- "You are now part of a valuable research study that will help middle aged and older adults at risk for memory loss. Your participation will help contribute to research understanding brain health. Thank you for your contribution to this important project. Our efforts would not be possible without your generous help."
    } else {
      ef <<- ""
      elig <<- "Even though it was determined that you are not eligible to participate in the Tennessee Alzheimer's Project, we appreciate you donating your time to our research efforts. Thank you for your contribution to this important project. Our efforts would not be possible without your generous help and time."
    }
    
    path_in <- "/srv/shiny-server/resources/Templates/Thank You/TAP Thank You Template_e.docx"
  } else {
    path_in <- "/srv/shiny-server/resources/Templates/Thank You/TAP Thank You Template.docx"
    
    fu <<- "To date, your participation has helped generate more than 130 scientific publications and conference presentations, and it has provided significant teaching opportunities for more than 40 investigators and clinicians-in-training."
  }
  
  output <- paste0("/app/Output/TAP_",input,"_",ep,"_ty_letter.docx")
  renderInlineCode(path_in, output)
  
  importFiles(rcon = pdb, file = output, record = record, field = "card_thank_letter", event = events[e],
              overwrite = TRUE, repeat_instance = 1)
}
  
#}
