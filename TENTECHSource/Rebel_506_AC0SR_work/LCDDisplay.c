/*****
  This method uses the LCD display from Chapter 3 of the Purdum-Kidder book to
  display the Rebel receiving frequency.
  
  Parameters:
    void
    
  Return value:
    void
*****/

void LCDFrequencyDisplay()
{
  char row1[17];
  char temp[17];
  
  strcpy(row1, "Rec ");
  if (bsm == 1) {            // 20 meters
  } else {                   // 40 meters
    row1[4] = '7';
    row1[5] = '.';
    row1[6] = '\0';
    itoa((frequency_tune + IF), temp, 10);
    strcat(row1, &temp[1]);
    strcat(row1, " Mhz");    
  }
  lcd.setCursor(0, 0);
  lcd.print(row1);  
}