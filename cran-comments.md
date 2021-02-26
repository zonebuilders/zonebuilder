I have used \donttest{} to stop examples that took too long from causing issues on CRAN submission.

Following feedback I have added documentation on the type of objects that different functions return.

The function on.exit() was used to ensure no graphical parameters were changed by calling plot functions.

We are grateful for the feedback.

## Test environments

* local R installation, R 4.0.3
* Ubuntu and Mac via GitHub Actions, R 4.0.3
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
