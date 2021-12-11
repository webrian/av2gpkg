@echo off

REM Input OGR virtual format file, see OGR documentation
SET input_itf=av.itf
SET input_vrt=av.vrt

REM Output GeoPackage
SET output_gpkg=av.gpkg

del -rf %output_gpkg%

REM Topic Liegenschaften
ogr2ogr -q -f GPKG %output_gpkg% %input_vrt% Liegenschaften_Liegenschaft
ogr2ogr -f GPKG -append -nlt COMPOUNDCURVE %output_gpkg% %input_vrt% Liegenschaften_Liegenschaft_Geometrie
REM qgis_process-qgis.bat run ./Boundary2Area.model3 -- Centroids="%output_gpkg%|layername=Liegenschaften_Liegenschaft" Boundary_Geometrie="%output_gpkg%|layername=Liegenschaften_Liegenschaft_Geometrie" model:createareawithattributes:Area="ogr:dbname=%output_gpkg% table=Liegenschaften_Liegenschaft_Area (geom)"
%OSGEO4W_ROOT%\apps\qgis\bin\qgis_process.exe run ./Boundary2Area.model3 -- Centroids="%output_gpkg%|layername=Liegenschaften_Liegenschaft" Boundary_Geometrie="%output_gpkg%|layername=Liegenschaften_Liegenschaft_Geometrie" model:createareawithattributes:Area="ogr:dbname=%output_gpkg% table=Liegenschaften_Liegenschaft_Area (geom)"
ogr2ogr -f GPKG -append %output_gpkg% %input_vrt% Liegenschaften_GrundstueckPos

REM Topic Bodenbedeckung
ogr2ogr -f GPKG -append %output_gpkg% %input_vrt% Bodenbedeckung_BoFlaeche
ogr2ogr -f GPKG -append -nlt COMPOUNDCURVE %output_gpkg% %input_vrt% Bodenbedeckung_BoFlaeche_Geometrie
REM qgis_process-qgis.bat run ./Boundary2Area.model3 -- Centroids="%output_gpkg%|layername=Bodenbedeckung_BoFlaeche" Boundary_Geometrie="%output_gpkg%|layername=Bodenbedeckung_BoFlaeche_Geometrie" model:createareawithattributes:Area="ogr:dbname=%output_gpkg% table=Bodenbedeckung_BoFlaeche_Area (geom)"
%OSGEO4W_ROOT%\apps\qgis\bin\qgis_process.exe run ./Boundary2Area.model3 -- Centroids="%output_gpkg%|layername=Bodenbedeckung_BoFlaeche" Boundary_Geometrie="%output_gpkg%|layername=Bodenbedeckung_BoFlaeche_Geometrie" model:createareawithattributes:Area="ogr:dbname=%output_gpkg% table=Bodenbedeckung_BoFlaeche_Area (geom)"

REM Topic Einzelobjekte
REM Kopiere Tabelle Einzelobjekt
ogr2ogr -f GPKG -append %output_gpkg% %input_vrt% Einzelobjekte_Einzelobjekt
ogr2ogr -f GPKG -append %output_gpkg% %input_vrt% Einzelobjekte_Punktelement
ogr2ogr -f GPKG -append -nlt COMPOUNDCURVE %output_gpkg% %input_vrt% Einzelobjekte_Linienelement
python3 Flaechenelement2Area.py %input_itf% Einzelobjekte__Flaechenelement %output_gpkg% Einzelobjekte_Flaechenelement_Area

REM Topic Nomenklatur
ogr2ogr -f GPKG -append %output_gpkg% %input_vrt% Nomenklatur_FlurnamePos