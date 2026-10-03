# Version 0.10.0

Resubmission after the previous submission was rejected because the overall
build and check time exceeded 10 minutes, mainly due to the tests. The test
pipeline was reorganized to load the package once per test group, and the
longer-running tests are now run only by the extended test target locally. In
the latest Windows run, the CRAN test suite completed in under 2 minutes.

One check on GitHub shows a size issue for the package.  This is only seen in
this once case and likely is resolved by using a more aggressive compression
algorithm.

## R CMD check results

* Local:
  * R 4.6.1 (macOS Tahoe 26.5.2, aarch64-apple-darwin23)
    * Status: OK
    * about 2.0 minutes to run R CMD check
    * about 2.5 minutes to run R CMD check --as-cran

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

* win-builder
  * Status: OK

## Additional checks

* `urlchecker::url_check()`
  * Status: OK
  * Result: All URLs are correct.
* `spelling::spell_check_package()`
  * Status: OK
  * Result: No spelling errors found.
