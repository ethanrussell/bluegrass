/*create streams only in the region*/
create table
	ky_springs.springs_bluegrass
as
select
*
from
ky_springs.dow_groundwater_springs

where
"county"='Woodford'
or "county"='Scott'
or "county"='Mercer'
or "county"='Madison'
or "county"='Jessamine'
or "county"='Garrard'
or "county"='Franklin'
or "county"='Fayette'
or "county"='Clark'
or "county"='Bourbon'
or "county"='Anderson';
alter table
  ky_springs.springs_bluegrass
add primary key (id);  -- end second statement

/* Nice work getting just those counties! */

select
	*
from
	ky_springs.dow_groundwater_springs
where
"county" in ('Woodford','Scott','Mercer','Madison','Jessamine','Garrard','Franklin','Fayette','Clark','Bourbon','Anderson');

-- another way to query out counties

/**************************************************************************/

/* Make hexagonal grid */

create table
	ky_springs.hexgrid_halfmile
as

select
    /* function requires geometry field and length of side. Notice the conversion to 2.5 miles */
    CDB_HexagonGrid(geom, 1.25*5280)::geometry(polygon, 3089) as geom
from
    ky_springs.bluegrass_region;

/* add unique identifier, which is important for the spatial join! */

alter table
	ky_springs.hexgrid_halfmile
add column
	id serial primary key;

  /* Make hexagonal grid */
  /*The GIST stands for Generalized Search Tree */

create index sidx_hexgrid_halfmile on ky_springs.hexgrid_halfmile using gist (geom);

/**************************************************************************/

/* Then clean up! */
vacuum analyze ky_springs.hexgrid_halfmile;

/**************************************************************************/

/* Spatial Join*/
create table
ky_springs.spring_by_halfmi_hexagon_table
as
select
ky_springs.hexgrid_halfmile.id as id,
count(*) as count -- count() function
from
/* Target layer with enumeration units */
ky_springs.hexgrid_halfmile
join
/* Source layer that will be counted/analyzed */
ky_springs.springs_bluegrass
on
/* Geometric predicate intersects */
st_intersects(ky_springs.hexgrid_halfmile.geom,ky_springs.springs_bluegrass.geom)
group by
/* The attribute that aggregates the intersecting points, the county geoid */
ky_springs.hexgrid_halfmile.id
order by
count desc;

/**************************************************************************/

create table
ky_springs.springs_by_halfmi_hexagon
as
select
ky_springs.hexgrid_halfmile.id as id,
geom,
count
from
/* Target layer with enumeration units */
ky_springs.hexgrid_halfmile, ky_springs.spring_by_halfmi_hexagon_table

where

ky_springs.hexgrid_halfmile.id =ky_springs.spring_by_halfmi_hexagon_table.id;

alter table
ky_springs.springs_by_halfmi_hexagon
add primary key(id);

/**************************************************************************/
