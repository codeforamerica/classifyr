# Data Classification

![][diagram]

## Process

Once a dataset has been created and mapped, classification on the different call
types can begin. You can find datasets to be classified by clicking
"Classification" on the left hand navigation pane.

![][navigation-classification]

The classification home screen will display all datasets that can be classified,
including those that have already been completed. Any datasets that have not
been completed can be classified by the current user assuming they are authorized
to do so and they have not yet classified all of the values for that dataset.

![][classification-home]

Selecting one of the data sets available to be classified, you will be taken to
the screen to classify the first call type in the list. The top portion of this
page will show some useful information about the value you are about to
classify:

1. The name of the dataset
2. The value being classified
3. Instructions for the classification process
4. A set of example records with that value (default: 5)

_Note: If you are the first user to classify a value, it may take a minute for
the page to load while the examples are pulled from the source document._

![][classification-value]

Below the example records you will find the interface for mapping this value to a
common one. Here you can search for a standardized value that can map to the
local one. This portion of the interface provides the following:

1. Full list of standardized codes. This can be useful if you wish to browse the
   complete set before choosing an option.
2. Search box. This interfaces uses fuzzy string matching against the code, its
   title, and description.
3. Unable to map selection. Use this when there is no code from the standard
   that maps to the local value.
4. Search results. These will populate automatically as you type in the search
   box.
5. Code select button. Use this to select the standard code to map to this
   value.

![][classification-search]

After selecting the appropriate code from the standard, you will be presented
with a summary before proceeding. This will ask you to confirm your selection and
specify a confidence rating. If you select any option other than "Very confident"
you will be asked to optionally describe why you feel this way. Although not
required, this information can help determine where the gaps are in the
standard.

_Note that if you select that a value can not be mapped there is no confirmation
step._

![][classification-confirm]

After confirming the application will give you the option to classify the next
value from the dataset. If the current user has classified all of the values for
the dataset, they will be redirected back to the classification home screen.

![][classification-success]

## Configuration

There are no configuration options for data classification.

## Notes

* Minimum classification, minimum confidence rating, and example count are
  currently set by the [UniqueValue][unique-value] model.
* The current logic does not allow a value to be classified more than the
  minimum number of times, even if the minimum confidence level has not been
  reached.
* Changing any of these values would have global consequences and all existing
  records would need to be reevaluated.

[diagram]: https://lucid.app/publicSegments/view/a1ba5d84-9ca8-427c-bc80-1f84f87d96b6/image.png
[navigation-classification]: assets/navigation-classification.png
[classification-home]: assets/classidication-home.png
[classification-value]: assets/classification-value.png
[classification-search]: assets/classification-search.png
[classification-confirm]: assets/classification-confirm.png
[classification-success]: assets/classification-success.png
[unique-value]: ../app/models/unique_value.rb
