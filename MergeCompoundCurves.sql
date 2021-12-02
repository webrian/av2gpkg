insert into kreisboegen ("name", "geom")

values (

'203' , ST_LineToCurve(st_linemerge((select st_union(k.geom) from kreisboegen k where k."name" ilike '201')))
);