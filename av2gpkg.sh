#!/bin/sh


# Input OGR virtual format file, see OGR documentation
input_itf=0942.itf
input_vrt=DM01AVCH24LV95D.vrt

# Output GeoPackage
output_gpkg=0942.gpkg

rm -rf ${output_gpkg}*

# Topic Liegenschaften
/usr/bin/ogr2ogr -q -f GPKG ${output_gpkg} ${input_vrt} Liegenschaften_Liegenschaft
/usr/bin/ogr2ogr -f GPKG -append -nlt COMPOUNDCURVE ${output_gpkg} ${input_vrt} Liegenschaften_Liegenschaft_Geometrie
/usr/bin/qgis_process run ./Boundary2Area.model3 -- Centroids="${output_gpkg}|layername=Liegenschaften_Liegenschaft" Boundary_Geometrie="${output_gpkg}|layername=Liegenschaften_Liegenschaft_Geometrie" model:createareawithattributes:Area="ogr:dbname=${output_gpkg} table=Liegenschaften_Liegenschaft_Area (geom)"
/usr/bin/ogr2ogr -f GPKG -append ${output_gpkg} ${input_vrt} Liegenschaften_GrundstueckPos

# Topic Bodenbedeckung
/usr/bin/ogr2ogr -f GPKG -append ${output_gpkg} ${input_vrt} Bodenbedeckung_BoFlaeche
/usr/bin/ogr2ogr -f GPKG -append -nlt COMPOUNDCURVE ${output_gpkg} ${input_vrt} Bodenbedeckung_BoFlaeche_Geometrie
qgis_process run ./Boundary2Area.model3 -- Centroids="${output_gpkg}|layername=Bodenbedeckung_BoFlaeche" Boundary_Geometrie="${output_gpkg}|layername=Bodenbedeckung_BoFlaeche_Geometrie" model:createareawithattributes:Area="ogr:dbname=${output_gpkg} table=Bodenbedeckung_BoFlaeche_Area (geom)"

# Topic Einzelobjekte
# Kopiere Tabelle Einzelobjekt
/usr/bin/ogr2ogr -f GPKG -append ${output_gpkg} ${input_vrt} Einzelobjekte_Einzelobjekt
/usr/bin/ogr2ogr -f GPKG -append ${output_gpkg} ${input_vrt} Einzelobjekte_Punktelement
/usr/bin/ogr2ogr -f GPKG -append -nlt COMPOUNDCURVE ${output_gpkg} ${input_vrt} Einzelobjekte_Linienelement
./Flaechenelement2Area.py ${input_itf} Einzelobjekte__Flaechenelement ${output_gpkg} Einzelobjekte_Flaechenelement_Area
