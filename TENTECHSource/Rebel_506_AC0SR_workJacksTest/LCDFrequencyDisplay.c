/*****
  This method uses the LCD display from Chapter 3 of the Purdum-Kidder book to
  display the Rebel receiving frequency. Jack Purdum, W9NMT/8, 9/20/2013
  
  Parameters:
    void
    
  Return value:
    void
*****/

void LCDFrequencyDisplay()
{
  char row1[17] = {'R', 'X', ':', ' '};
  char row2[17] = {'T', 'X', ':', ' '};
  char temp[17];
  char tail[] = {' ', 'M', 'H', 'z', '\0'};
  
  if (bsm == 1) {            // 20 meters
    row1[3] = '1';           // Display row 1
    row1[4] = '4';
    row1[5] = '.';          // Make sure we can treat as a string
    row1[6] = '\0';
    itoa((frequency_tune + IF), temp, 10);
    strcat(row1, &temp[2]);  
    strcat(row1, tail);    
    row2[3] = '1';           // Display row 1
    row2[4] = '4';
    row2[5] = '.';          // Make sure we can treat as a string
    row2[6] = '\0';
    itoa((frequency + IF), temp, 10);
    strcat(row2, &temp[2]);  
    strcat(row2, tail);    
  } else {                   // 40 meters
    row1[4] = '7';           // Display row 1
    row1[5] = '.';
    row1[6] = '\0';          // Make sure we can treat as a string
    itoa((frequency_tune + IF), temp, 10);
    strcat(row1, &temp[1]);  // Ignore the leading '7'
    strcat(row1, tail);    
    row2[4] = '7';           // Display row 2
    row2[5] = '.';
    row2[6] = '\0';          
    itoa((frequency + IF), temp, 10);
    strcat(row2, &temp[1]);  
    strcat(row2, tail);    
  }
  lcd.setCursor(0, 0);
  lcd.print(row1);  
  lcd.setCursor(0, 1);
  lcd.print(row2);
 
}