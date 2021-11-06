#!/usr/bin/env python3
#
#
#
# Usage: ./Flaechenelement2Area.py ${input_itf} ${input_layer __TOPIC__Flaechenelement} ${output_geopackage} ${output_layer __TOPIC__Flaechenelement_polygon}

import sys
from osgeo import ogr
from osgeo import osr

def main(argv = None):
  if argv is None:
    argv = sys.argv

  # Open Input Interlis datasource
  interlis_driver=ogr.GetDriverByName('Interlis 1')
  srcdb = interlis_driver.Open(sys.argv[1],0)
  # Open the __TOPIC__Flaechenelement_Geometrie layer to read the geometries
  layer = srcdb.GetLayerByName(sys.argv[2] + "_Geometrie")

  # Open output GeoPackage datasource
  gpkg_driver = ogr.GetDriverByName('GPKG')
  gpkgds = gpkg_driver.Open(sys.argv[3],1)

  # Create the spatial reference EPSG:2056 (LV95)
  srs = osr.SpatialReference()
  srs.ImportFromEPSG(2056)

  # Create the layer with geometry type CurvePolygon
  outlayer = gpkgds.CreateLayer(sys.argv[4], srs, ogr.wkbCurvePolygon, ["OVERWRITE=YES"])

  # Add the fields we're interested in
  outlayer.CreateField(ogr.FieldDefn("OBJID", ogr.OFTInteger))
  outlayer.CreateField(ogr.FieldDefn("Flaechenelement_von", ogr.OFTInteger))

  # Create an empty Python dictionary to temporarily store the output features
  # (before we write it finally to the GeoPackage)
  gpkg_features = dict()

  # Loop all input features
  for f in layer:
    
    # The referenced OBJID
    geometrie_von = f['Field02']
    
    # Check if there's already a geometry part of the feature:
    if geometrie_von not in gpkg_features:
      # If not, create a new geometry and save it to the dict
      geom = ogr.Geometry(ogr.wkbCurvePolygon)
      geom.AddGeometry(f.GetGeometryRef())
      gpkg_features[geometrie_von] = geom
    
    else:
      # If there's a feature with this OBJID, add another geometry part (inner polygon ring)
      gpkg_features[geometrie_von].AddGeometry(f.GetGeometryRef())
        
  # Reset the input layer
  layer.ResetReading()
  
  # Open Layer __TOPIC__Flaechenelement from the input Interlis file
  flaechenelement_layer = srcdb.GetLayerByName(sys.argv[2])
  
  # Loop all Flaechenelement features:
  for f in flaechenelement_layer:
    # Get the OBJID
    objid = f['Field01']
    # Get the flaechenelement_von attribute
    flaechenelement_von = f['Field02']
    
    # Create a new output feature
    feature = ogr.Feature(outlayer.GetLayerDefn())
    # Set the attributes
    feature.SetField("OBJID", objid)
    feature.SetField("Flaechenelement_von", flaechenelement_von)
    
    # Get the geometry (with inner rings) from the dict
    feature.SetGeometry(gpkg_features[objid])
    
    # Save feature to layer
    outlayer.CreateFeature(feature)
    
    feature = None

  gpkgds = None

if __name__ == "__main__":
  sys.exit(main())
    

