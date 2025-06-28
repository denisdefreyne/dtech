local dtech                 = {}

dtech.Object                = require('dtech.vendor.classic')

dtech.components            = {}
dtech.components.Bounds     = require('dtech.components.bounds')
dtech.components.Clickable  = require('dtech.components.clickable')
dtech.components.Color      = require('dtech.components.color')
dtech.components.Draggable  = require('dtech.components.draggable')
dtech.components.DropTarget = require('dtech.components.drop_target')
dtech.components.Hoverable  = require('dtech.components.hoverable')
dtech.components.Size       = require('dtech.components.size')
dtech.components.Transform  = require('dtech.components.transform')
dtech.components.ZStatic    = require('dtech.components.z_static')
dtech.components.ZDynamic   = require('dtech.components.z_dynamic')

dtech.drawables             = {}
dtech.drawables.Rectangle   = require('dtech.drawables.rectangle')
dtech.drawables.Polygon     = require('dtech.drawables.polygon')

dtech.Easing                = require('dtech.easing')
dtech.Event                 = require('dtech.event')
dtech.NineSlice             = require('dtech.nine_slice')
dtech.NineSliceInstance     = require('dtech.nine_slice_instance')
dtech.Node                  = require('dtech.node')
dtech.Scene                 = require('dtech.scene')
dtech.SceneManager          = require('dtech.scene_manager')
dtech.TimerSet              = require('dtech.timer_set')
dtech.TweenSet              = require('dtech.tween_set')
dtech.Alignment             = require('dtech.alignment')
dtech.Sizing                = require('dtech.sizing')
dtech.Shaders               = require('dtech.shaders')
dtech.Layout                = require('dtech.layout')

return dtech
