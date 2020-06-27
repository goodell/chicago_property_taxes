Exploration kicked off by Steve Vance's Twitter question:
https://twitter.com/stevevance/status/1275152464635985922

Using `-` in the db name caused problems for Athena, so converted to `_`.

Getting the CSV parsers in Glue+Athena to be happy and agree was also
problematic.  Converted schema to use all `string` and switched to
`org.apache.hadoop.hive.serde2.OpenCSVSerde`, but that was all pretty fiddly.
Also switched to using the headers from the Socrata API instead of the pretty
human names:

```
$ curl --silent 'https://datacatalog.cookcountyil.gov/resource/bcnq-qi2z.csv?$limit=1' > nice_headers.csv
## then take the first line and replace the basic CSV export's header with that

## could script up a slicker approach with:
$ curl --silent https://datacatalog.cookcountyil.gov/views/bcnq-qi2z.json > socrata_metadata.json
$ cat socrata_metadata.json | jq -Sc '.columns[] | {description, fieldName, name}'
$ cat socrata_metadata.json | jq -Sc '.columns[] | {description, fieldName, name}' | sed -e 's/\\n/\\\\n/g' | recs totable -k fieldName,name,description > schema.txt
```

Raw data set seems to contain numerous 100% duplicate rows, removing them seems
to improve overall usefulness of the data, so I did that in the
`unique_characteristics` table.

Unique-ifying and converting to parquet really seems to help with query speed,
data scanned, and overall storage size:

```
$ aws s3 ls s3://chi-property-tax-info/raw_csv/characteristics/ | awk '{print $3}' | perl -n -e '$total += $_; END { print "$total\n"; }'
634008133

$ aws s3 ls s3://chi-property-tax-info/parquet/unique_characteristics/ | awk '{print $3}' | perl -n -e '$total += $_; END { print "$total\n"; }'
202767784
```

Might be nice to put this data set up on the open data registry at some point
as a Requester Pays format and some instructions on querying with Athena:
https://github.com/awslabs/open-data-registry/
