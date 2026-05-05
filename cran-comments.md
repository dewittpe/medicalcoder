# Version 0.8.1

Bug fixes - Imporantly fixing a CRAN check error on two fedora instances.

## R CMD check results

* Local:
  * R 4.6.0 (MacOS arm)
    * Status: OK

* GitHub Actions
  * macos-latest (release)
    * Status: OK
  * windows-latest (release)
    * Status: OK
  * ubuntu-latest (devel)
    * Status: OK
  * ubuntu-latest (release)
    * Status: OK
  * ubuntu-latest (oldrel-1)
    * Status: OK

* rhub
  * Status: OK

* windbuilder
  * Status: OK


# Version 0.8.0

Bug fixes and new features.

## R CMD check results

Status: OK

### platforms:
* local macOS
  - All R versions 3.5.0 through 4.5.2 without suggests
  - All R versions 4.4.0 through 4.5.2 with suggests

* Github Actions:
  * macOS R-4.5.2
  * windows R-4.5.2
  * ubuntu R-4.5.2
  * ubuntu R-devel
  * ubuntu R-4.5.2
* rhub
* winbuilder

## Notes:

On some systems (Windows) there are some possible misspelled words in the
DESCRIPTION file:

    NOTE: possible misspelled words in DESCRIPTION

      Rebull
      Charlson
      Elixhauser
      ICD
      PCCC
      schemas

* "Rebull" is the correct spelling of the family name of one of the package authors.
* "Charlson" is the correct spelling for the Charlson Comorbidities.
* "Elixhauser" is the correct spelling for a Elixhauser Comorbidities.
* "ICD" is the common abbreviation for the International Classification of Diseases.
* "PCCC" is a defined abbreviation for the Pediatric Complex Complex Conditions
  and is commonly used in literature.
* "schemas" is a common plural for schema, preferable to the more formal schemata.
