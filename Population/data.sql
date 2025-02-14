/* *************************************************************** */
      create table
  	module_04.kentucky_pop_census_block
  as
  select
  	module_04.bluegrass_census_block.id,
  	geom,
  	geoid10,
  	awater10*(3.281*3.281) as water_sq_ft,
  	(aland10+awater10)*(3.281*3.281) as total_area,
  	((aland10*3.281*3.281))/(5280*5280) as land_sq_mi,
  	--st_area(geom) as area_sq_feet,
  	module_04.census_blocks_2010_housing_population.pop10,
  	module_04.census_blocks_2010_housing_population.housing10,
  	(module_04.census_blocks_2010_housing_population.pop10)/(((aland10*(3.281*3.281)))/(5280*5280)) as pop_per_sq_mi
  from
  	module_04.bluegrass_census_block
  left join
  	module_04.census_blocks_2010_housing_population
  on
  	geoid10=blockid10
  where
  	aland10>0
  order by
  	pop_per_sq_mi desc;
  alter table
  	module_04.kentucky_pop_census_block
  add primary key(id);

  /* Nice work! Another example: */

select
	pop10,
	aland10,
	pop10/((aland10/1e+6))::numeric as pop_per_sq_km, -- 1e+6 = 1,000,000 sq m in sq km
	pop10/((aland10/2.59e+6))::numeric as pop_per_sq_mi, -- 2.59e+6 = 2,590,000 sq m in sq mi
	geom,
	id
from
	bg.census_blocks
where
	aland10 > 0
order by
	pop_per_sq_mi
desc;
