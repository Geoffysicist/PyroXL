# PyroXL
Fire Behaviour Analysis Excel VBA Scripts

## PyroXL_AFDRS spreadsheet
Implements the Australian Fire Danger Rating System models in Excel.  
All models tested against the python scripts that underlie AFDRS.

User versions have a date stamp subscript (eg. PyroXL_AFDRS_20220921) and are locked to prevent corruption by the user. Light coloured cells are for user input.

Test and development versions have no subscript, are unlocked and include test tabs. Note the development versions have automatic calculation turned of so worksheets must be calculated manually.

A rudimentary guide to the VBA user defined functions can be found in the docs/guide directory. The user guides are markdown files so are probably best read using a browser through the github repository: https://github.com/Geoffysicist/PyroXL/tree/main/docs/guide

If you use this code in other projects please acknowledge the author and NSW Rural Fire Service.

## Change log
 - 20220930: added woodlands model. models now implemented include forest, grassland, woodland, heath, pine and mallee

## DISCLAIMER
This calculator should be used with caution. The accuracy of calculations will be impacted by the accuracy of the input data.  Potential sources of error in these calculations could include (but are not limited to): incorrect or invalid weather observations, incorrect or invalid fuel observations, missing or unknown antecedent conditions (e.g. previous rainfall or time since fire).

Calculating the AFDRS Fire Behaviour Index can require highly detailed information about fuel condition, arrangement and load. Users should be aware that small differences in this information can produce significantly different calculations of FBI and care should be taken to ensure that the values used are not only accurate but area also representative of the broader landscape.

Please also be aware that these calculations are not a substitute for official observations of Fire Behaviour Indices calculated by the Bureau of Meteorology.

The calculator is still being developed and tested.  Updated versions of this calculator may be provided at a later date with error corrections or updated functionality. It is the users responsibility to ensure they have the most up-to-date version when using the calculator. If you identify a bug or error in the calculator or its equations please contact the NSW Rural Fire Service’s Predictive Services Team at FBA@rfs.nsw.gov.au

You can find out more information about the AFDRS, FBI and other matters related to this calculator at https://one.rfs.nsw.gov.au/our-organisation/priority-projects/afdrs.

