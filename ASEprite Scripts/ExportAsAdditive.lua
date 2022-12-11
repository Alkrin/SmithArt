if (app.activeSprite == nil) then
  return app.alert("There is no active sprite.  Please select one and try again.");
end

local s = app.activeSprite;

if (#s.frames ~= 1) then
  return app.alert("ERROR: Additives must have exactly 1 frame.");
end

if (#s.layers ~= 3) then
  return app.alert("ERROR: Additives must have exactly 3 layers.");
end

local background;
local foreground;
local outline;
for i, layer in ipairs(s.layers) do
  if (layer.name == "Background" or layer.name == "background") then
    background = layer;
  elseif (layer.name == "Foreground" or layer.name == "foreground") then
    foreground = layer;
  elseif (layer.name == "Outline" or layer.name == "outline") then
    outline = layer;
  end
end

if (background == nil or foreground == nil or outline == nil) then
  return app.alert("ERROR: Additives must have a Background, Foreground, and Outline layer.");
end

local spritePath = "C:\\Users\\Jesse\\Documents\\RMMZ\\Smith\\img\\smith\\additives\\";
local spriteNameRoot = app.activeSprite.filename:match(".*[/\\](.+)%.aseprite");

--Save each layer out as its own file.
background.isVisible = true; foreground.isVisible = false; outline.isVisible = false;
s:saveCopyAs(spritePath..spriteNameRoot.."Background.png");

background.isVisible = false; foreground.isVisible = true; outline.isVisible = false;
s:saveCopyAs(spritePath..spriteNameRoot.."Foreground.png");

background.isVisible = false; foreground.isVisible = false; outline.isVisible = true;
s:saveCopyAs(spritePath..spriteNameRoot.."Outline.png");

background.isVisible = true; foreground.isVisible = true; outline.isVisible = true;

Dialog(spriteNameRoot):label{label="Export Complete"}:button{text="Okay"}:show();
