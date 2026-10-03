# medicalcoder tests

There are several different groups of tests each controlled by it's own runner.

1. cran-attached: these tests are expected to run on CRAN and have the
   medicalcoder namespace loaded and attached. The internal data-frame helper
   tests are in this group so coverage tools record execution of the helpers.

2. cran-unattached: these tests are expected to run on CRAN and have the
   medicalcoder namespace loaded but not attached.  These are tests focused on
   the internal workings of the package, not end user facing elements.

3. extended-attached: these are tests which are not run on CRAN and expect the
   medicalcoder namespace to be loaded and attached.

Each runner sources a test script in its own environment so that objects created
by one test do not leak into the next. A test that cannot run because an
optional dependency is unavailable should call `skip_test("reason")`; the
runner records that test as skipped and continues. Individual `test-*.R`
scripts must not call `quit()`, because they are sourced by a group runner and
that would terminate the entire group. The extended group runner is itself an
R CMD check entry point and exits successfully when extended tests are disabled.
