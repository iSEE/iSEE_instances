# Code for generating an instance of iSEE accepting RDS files

Data:
This app launches an "empty" instance of iSEE (>= 1.5.4) that is not preloaded with any data.
Instead, a file upload input allows users to upload an RDS file that must contain an object that inherits from the `SummarizedExperiment` class.

Notes:

* The maximum file upload size limit is set to 1GB.
