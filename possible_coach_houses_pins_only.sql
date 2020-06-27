-- references:
-- https://prodassets.cookcountyassessor.com/s3fs-public/form_documents/classcode.pdf
-- https://datacatalog.cookcountyil.gov/Property-Taxation/Cook-County-Assessor-s-Residential-Property-Charac/bcnq-qi2z
-- https://twitter.com/stevevance/status/1275152464635985922

with repeated_pins as
(
    select distinct tax_year, pin, bldg_sf, count(*) as num_sharing_pin 
	from chi_taxes."characteristics" c
	where tax_year = '2019'
		and class like '2%'
		-- 295 is "Individually-owned townhome or row house up to 62 years of age", seems to not be what we want
		-- example: https://www.cookcountyassessor.com/pin/01011110100000
		and class != '295'
	group by tax_year, pin, bldg_sf
	having count(*) > 1
	order by pin, tax_year
)

-- select count(*)
select distinct pin
from repeated_pins
order by pin