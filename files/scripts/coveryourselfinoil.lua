local a="data/entities/misc/effect_oiled.xml"local b=ModTextFileGetContent(a)local c=b:gsub("</Entity>$",function()return[[<LuaComponent script_source_file="data/virtual/copi.CoverYourselfInOil/main.lua" />]].."</Entity>"end)ModTextFileSetContent(a,c)ModTextFileSetContent("data/virtual/copi.CoverYourselfInOil/main.lua",[[local a=EntityGetParent(GetUpdatedEntityID())if GameGetGameEffectCount(a,"WET")>0 then local b=EntityGetFirstComponent(a,"CharacterDataComponent")local c=EntityGetFirstComponent(a,"ControlsComponent")if ComponentGetValue2(c,"mButtonDownDown")then return end;local d,e=ComponentGetValueVector2(b,"mVelocity")ComponentSetValue2(b,"mVelocity",d,math.min(-9,e-9))end]])