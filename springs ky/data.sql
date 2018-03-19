/**************************************************************************/

/* Make hexagonal grid */

create table
	ky_springs.hexgrid_5mile
as

select
    /* function requires geometry field and length of side. Notice the conversion to 2.5 miles */
    CDB_HexagonGrid(geom, 2.5*5280)::geometry(polygon, 3089) as geom
from
    ky_springs.state;

/* add unique identifier, which is important for the spatial join! */

alter table
	ky_springs.hexgrid_5mile
add column
	id serial primary key;

  /* Make hexagonal grid */
  /*The GIST stands for Generalized Search Tree */

create index sidx_hexgrid_5mile on ky_springs.hexgrid_5mile using gist (geom);

/**************************************************************************/

/* Then clean up! */
vacuum analyze ky_springs.hexgrid_5mile;

/**************************************************************************/

/* Spatial Join*/
create table
ky_springs.spring_by_5mi_hexagon_table
as
select
ky_springs.hexgrid_5mile.id as id,
count(*) as count -- count() function
from
/* Target layer with enumeration units */
ky_springs.hexgrid_5mile
join
/* Source layer that will be counted/analyzed */
ky_springs.dow_groundwater_springs
on
/* Geometric predicate intersects */
st_intersects(ky_springs.hexgrid_5mile.geom,ky_springs.dow_groundwater_springs.geom)
group by
/* The attribute that aggregates the intersecting points, the county geoid */
ky_springs.hexgrid_5mile.id
order by
count desc;

/**************************************************************************/

/* Not Needed----Convert null values to zero for summary statistics */
/*
update
	ky_springs.spring_by_5mi_hexagon
set
	xxxxxxxx = 0
where
	count = 0;
*/
	/* Attribute Join */

/**************************************************************************/

create table
ky_springs.springs_by_5mi_hexagon
as
select
ky_springs.hexgrid_5mile.id as id,
geom,
count
from
/* Target layer with enumeration units */
ky_springs.hexgrid_5mile, ky_springs.spring_by_5mi_hexagon_table

where

ky_springs.hexgrid_5mile.id =ky_springs.spring_by_5mi_hexagon_table.id;

alter table
ky_springs.springs_by_5mi_hexagon
add primary key(id);
