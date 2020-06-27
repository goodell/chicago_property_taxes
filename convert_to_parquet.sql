-- convert from csv to parquet for efficiency, also remove duplicate rows that are present in the data set
-- adapted from https://www.cloudforecast.io/blog/Athena-to-transform-CSV-to-Parquet/
CREATE TABLE chi_taxes.unique_characteristics
    WITH (
          format = 'PARQUET',
          parquet_compression = 'SNAPPY',
          external_location = 's3://chi-property-tax-info/parquet/unique_characteristics'
    ) AS select distinct * FROM chi_taxes."characteristics"