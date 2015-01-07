import bpy
from bpy.props import *
from bpy_extras.io_utils import ExportHelper
import struct

def des_convert_model( context, path ):
    f = open( path, "wb" )
    object = context.object.data
    vcount = struct.pack( "@i", len( object.polygons ) * len( object.polygons[0].vertices ) )
    f.write( vcount )
    for p in object.polygons:
        for v in p.vertices:
            vert = object.vertices[v]
            vert = struct.pack( "@fff", vert.co.x, vert.co.y, vert.co.z )
            f.write( vert )
    for p in object.polygons:
        norm = struct.pack( "@fff", p.normal.x, p.normal.y, p.normal.z )
        for i in [0, 1, 2]:
            f.write( norm )
    f.close()

def des_convert_collision_model( context, path ):
    f = open( path, "wb" )
    object = context.object.data
    vcount = struct.pack( "@i", len( object.vertices ) )
    icount = struct.pack( "@i", len( object.polygons ) * len( object.polygons[0].vertices ) )
    f.write( vcount )
    f.write( icount )
    for v in object.vertices:
        vert = struct.pack( "@fff", v.co.x, v.co.y, v.co.z )
        f.write( vert )
    for p in object.polygons:
        for i in p.vertices:
            index = struct.pack( "@i", i );
            f.write( index )
    f.close()
    
class DesExportModelDialog(bpy.types.Operator, ExportHelper):
    bl_idname = "des.model"
    bl_description = 'Convert to des format'
    bl_label = "Convert to des format"
    bl_space_type = "PROPERTIES"
    bl_region_type = "WINDOW"

    filename_ext = ".des"
    filter_glob = StringProperty(default="*.des", options={'HIDDEN'})

    def execute(self, context):
        des_convert_model( context, self.properties.filepath )
        return {'FINISHED'}

    def invoke(self, context, event):
        context.window_manager.fileselect_add(self)
        return {'RUNNING_MODAL'}
    
class DesExportCollisionModelDialog(bpy.types.Operator, ExportHelper):
    bl_idname = "des.model_collision"
    bl_description = 'Convert to des format'
    bl_label = "Convert to des format"
    bl_space_type = "PROPERTIES"
    bl_region_type = "WINDOW"

    filename_ext = ".des_collision"
    filter_glob = StringProperty(default="*.des_collision", options={'HIDDEN'})

    def execute(self, context):
        des_convert_collision_model( context, self.properties.filepath )
        return {'FINISHED'}

    def invoke(self, context, event):
        context.window_manager.fileselect_add(self)
        return {'RUNNING_MODAL'}

class DesConverterPanel(bpy.types.Panel):
    bl_label = "Des converter"
    bl_idname = "des.converterpanel"
    bl_space_type = "PROPERTIES"
    bl_region_type = "WINDOW"
    bl_context = "object"
    
    def draw( self, context ):
        layout = self.layout
        
        layout.operator( DesExportModelDialog.bl_idname, text = "Convert to DES model" )
        layout.operator( DesExportCollisionModelDialog.bl_idname, text = "Convert to DES collision model" )

bpy.utils.register_module( __name__ )