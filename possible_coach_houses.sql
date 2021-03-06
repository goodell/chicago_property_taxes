-- references:
-- https://prodassets.cookcountyassessor.com/s3fs-public/form_documents/classcode.pdf
-- https://datacatalog.cookcountyil.gov/Property-Taxation/Cook-County-Assessor-s-Residential-Property-Charac/bcnq-qi2z
-- https://twitter.com/stevevance/status/1275152464635985922

-- example PIN that seems to have a coach house (from Google Maps satellite and street view):
-- https://www.cookcountyassessor.com/pin/19181230650000
--
-- very small differences appear to be typos/errors
-- e.g., https://www.cookcountyassessor.com/pin/19034090090000 has rows with bldg_sf={1225,1226}
--
-- TODO should there be any filter on the high end, e.g. for https://www.cookcountyassessor.com/pin/01131010080000 ?

with
unique_pin_sf as
(
    select distinct tax_year, pin, bldg_sf
    from chi_taxes.unique_characteristics
    where tax_year = '2019'
        and class like '2%'
        -- excluded property classes:
        -- 211 is "Apartment building with 2 to 6 units, any age"
        --
        -- 212 is "Mixed-use commercial/residential building with apartment and commercial area
        -- totaling 6 units or less with a square foot area less than 20,000 square feet, any age"
        --
        -- 295 is "Individually-owned townhome or row house up to 62 years of age"
        -- example: https://www.cookcountyassessor.com/pin/01011110100000
        and class not in ('211','212','295')
        and bldg_sf != ''
),
repeated_pins as
(
    select
        tax_year
        , pin
        , min(cast(bldg_sf as bigint)) as min_bldg_sf
        , max(cast(bldg_sf as bigint)) as max_bldg_sf
        , round(1.0 * max(cast(bldg_sf as bigint)) / min(cast(bldg_sf as bigint)), 4) as bldg_sf_ratio
        , count(*) as num_sharing_pin
    from unique_pin_sf
    group by tax_year, pin
    -- count=1 have only a single bldg_sf value for the PIN
    -- count > 2 seem to be apartments and row houses without specifically being classed as such (e.g., 17293090540000)
    having count(*) = 2
    order by pin, tax_year
)

-- dump possible coach house PINs, together with min/max/ratio info
select *
from repeated_pins
order by bldg_sf_ratio

/*
-- a join to emit all (previously deduped) rows+columns for possible coach house PINs
select uc.pin, uc.bldg_sf, uc.class, uc.multi_code, uc.multi_ind, uc.multi_family_ind, uc.*
from chi_taxes.unique_characteristics uc
inner join repeated_pins
on uc.pin = repeated_pins.pin
    and uc.tax_year = repeated_pins.tax_year
    and uc.bldg_sf = repeated_pins.min_bldg_sf
order by uc.pin
*/
