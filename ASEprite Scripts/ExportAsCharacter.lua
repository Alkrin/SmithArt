if (app.activeSprite == nil) then
  return app.alert("There is no active sprite.  Please select one and try again.");
end

local s = app.activeSprite;

if (#s.frames ~= 12) then
  return app.alert("ERROR: Characters must have exactly 12 frames.");
end

local spriteSheet = Image(s.width * 12, s.height * 8);

--Draw each frame onto the spriteSheet.
local x = 0;
local y = 0;
for i,frame in ipairs(s.frames) do
  print("Drawing frame "..i);
  spriteSheet:drawSprite(s, i, Point(x * s.width,y * s.height));
  x = x + 1;
  if (x >= 3) then 
    x = 0; 
    y = y + 1;
  end
end


local spritePath = "C:\\Users\\Jesse\\Documents\\RMMZ\\Smith\\img\\";
local spriteNameRoot = app.activeSprite.filename:match(".*[/\\](.+)%.aseprite");

spriteSheet:saveAs(spritePath.."characters\\"..spriteNameRoot..".png");

Dialog(spriteNameRoot):label{label="Export Complete"}:button{text="Okay"}:show();
