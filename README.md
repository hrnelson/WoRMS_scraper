# WoRMS_scraper
*Get species list from WoRMS website*

**Authors:** Nelson, H. R.

**Description:** This repository provides code to harvest a list of species, given some specific higher order classification taxa (e.g. genus, family, order, class, etc.) from the [WoRMS](http://www.marinespecies.org/) website.

**Contents:** Two R script files, two output files, a .gitignore, and a README.md file.

**Scripts:** 
* WoRMS_scraper.R: This script is used to import species from the WoRMS website and create a csv file (taxa.csv)
* WoRMS_summary.R: This script imports taxa.csv and summarizes some basic information about the species

**Output:**
* taxa.csv: This is example output of a list of species produced by WoRMS_scraper.R for [Ascidiacea (AphiaID #1839)](http://www.marinespecies.org/aphia.php?p=taxdetails&id=1839)
* genera.csv: This is example output of a list of genera produced by WoRMS_summary.R
