# Version 0.10.0

Resubmission - Tests have been modified to reduce the amount of compute time on
Windows.

## R CMD check results

* Local:
  * R 4.6.1 (macOS Tahoe 26.5.2, aarch64-apple-darwin23)
    * Status: OK
    * about 3 minutes to run R CMD check
    * about 3 mintues 45 seconds to run R CMD check --as-cran

* GitHub Actions
  * macos-latest (release)
    * Status: OK
    * INFO: 
       installed size is  5.1Mb
       sub-directories of 1Mb or more:
         R   3.2Mb
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

## Additional checks

* `urlchecker::url_check()`
  * Status: OK
  * Result: All URLs are correct.
* `spelling::spell_check_package()`
  * Status: OK
  * Result: No spelling errors found.
