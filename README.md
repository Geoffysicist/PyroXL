# PyroXL
Fire Behaviour Analysis Excel VBA Scripts

## PyroXL_AFDRS spreadsheet
The original intent of this spreadsheet was to implement the Australian Fire Danger Rating System models in Excel.  
All AFDRS models are tested against the python scripts that underlie AFDRS.

Requests for additional functionality have resulted in the addition of non-AFDRS models

A rudimentary guide to the VBA user defined functions can be found in the docs/guide directory. The user guides are markdown files so are probably best read using a browser through the github repository: https://github.com/Geoffysicist/PyroXL/tree/main/docs/guide

If you use this code in other projects please acknowledge the author and NSW Rural Fire Service.

## Change log
- 20240311: Added notes to several fields; exposed spread probabilities for mallee and spinifex, exposed some growth curve parameters
- 20240228: Included probability of breach of firebreak using the formula from Wilson, A. A. G. (2011). Width of firebreak that is necessary to stop grass fires: Some field experiments. Canadian Journal of Forest Research. https://doi.org/10.1139/x88-104
- 20240215: Updated heath and spinifex models in line with AFDRS changes (see AFDRS technical guides); updated mallee moisture function in line with Criuz 2015
- 20230109: User version now a macro-enabled template. Buttongrass model added. FFDI and Vesta2 VBA functions are included for use if desired. Time since fire, time since rain and precipitation are now gathered under the weather data. Errors arising from relative references fixed in the Pine model.
 - 22021201: all AFDRS models except buttongrass now implemented. Vesta2 modules written but spread interface not implemented however they are available as formulae.
 - 20220930: added woodlands model. models now implemented include forest, grassland, woodland, heath, pine and mallee
 - Further changes are now embedded in the spreadsheets on the notes page

## DISCLAIMER
This calculator is offered as is without guarantees. While every effort has been made to ensure the calculations are correct, this is not an official product and users should recognise it may ocntain errors.

This calculator should be used with caution. The accuracy of calculations will be impacted by the accuracy of the input data.  Potential sources of error in these calculations could include (but are not limited to): incorrect or invalid weather observations, incorrect or invalid fuel observations, missing or unknown antecedent conditions (e.g. previous rainfall or time since fire).

Calculating the AFDRS Fire Behaviour Index can require highly detailed information about fuel condition, arrangement and load. Users should be aware that small differences in this information can produce significantly different calculations of FBI and care should be taken to ensure that the values used are not only accurate but area also representative of the broader landscape.

Please also be aware that these calculations are not a substitute for official observations of Fire Behaviour Indices calculated by the Bureau of Meteorology.

The calculator is still being developed and tested.  Updated versions of this calculator may be provided at a later date with error corrections or updated functionality. It is the users responsibility to ensure they have the most up-to-date version when using the calculator. If you identify a bug or error in the calculator or its equations please contact the NSW Rural Fire Service’s Predictive Services Team at FBA@rfs.nsw.gov.au

You can find out more information about the AFDRS, FBI and other matters related to this calculator at https://one.rfs.nsw.gov.au/our-organisation/priority-projects/afdrs.

