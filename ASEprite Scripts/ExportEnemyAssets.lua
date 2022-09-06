local pc = app.pixelColor;

local brightGreen = pc.rgba(0, 255, 0);
local darkGreen = pc.rgba(0, 205, 0);

local brightRed = pc.rgba(255, 0, 0);
local darkRed = pc.rgba(44, 0, 0);

local brightYellow = pc.rgba(255, 255, 0);
local darkYellow = pc.rgba(145, 145, 0);

local brightBlue = pc.rgba(0, 255, 255);
local darkBlue = pc.rgba(0, 204, 204);

local brightPurple = pc.rgba(187, 0, 255);
local darkPurple = pc.rgba(104, 0, 141);

function cloneSprite(osprite, brightEyeColor, darkEyeColor)
  local s = Sprite(osprite);

  --Find the Eyes layer.
  local eyes;
  for i, layer in ipairs(s.layers) do
    if (layer.name == "Eyes" or layer.name == "eyes") then
      eyes = layer;
      break;
    end
  end

  if (eyes) then
    for c, cel in ipairs(eyes.cels) do
      if (cel.image) then
	local image = cel.image;
        --Iterate all pixels in the image.  Replace as necessary.
        for it in image:pixels() do
          local pixelValue = it() -- get pixel
          if (pixelValue == brightGreen) then
            it(brightEyeColor);
          elseif (pixelValue == darkGreen) then
            it(darkEyeColor);
          end
        end
      end
    end
  end

  return s;
end

function cloneSpriteWithRedEyes(osprite)
  return cloneSprite(osprite, brightRed, darkRed);
end

function cloneSpriteWithYellowEyes(osprite)
  return cloneSprite(osprite, brightYellow, darkYellow);
end

function cloneSpriteWithBlueEyes(osprite)
  return cloneSprite(osprite, brightBlue, darkBlue);
end

function cloneSpriteWithPurpleEyes(osprite)
  return cloneSprite(osprite, brightPurple, darkPurple);
end

if (app.activeSprite == nil) then
  return app.alert("There is no active sprite.  Please select one and try again.");
end

local s = app.activeSprite;

--Must have all four direction tags.
local downTag = nil;
local leftTag = nil;
local rightTag = nil;
local upTag = nil;

--Each tag must have three frames.
local hasCorrectFrameCount = true;

for i = 1,#s.tags do
  local t = s.tags[i];
  if (t.name == "Down") then 
   downTag = t;
   hasCorrectFrameCount = hasCorrectFrameCount and (t.frames == 3);
  elseif (t.name == "Left") then
    leftTag = t;
    hasCorrectFrameCount = hasCorrectFrameCount and (t.frames == 3);
  elseif (t.name == "Right") then
    rightTag = t;
    hasCorrectFrameCount = hasCorrectFrameCount and (t.frames == 3);
  elseif (t.name == "Up") then
    upTag = t;
    hasCorrectFrameCount = hasCorrectFrameCount and (t.frames == 3);
  end
end

if (downTag == nil) then
  return app.alert("ERROR: This sprite has no 'Down' tag");
elseif (leftTag == nil) then
  return app.alert("ERROR: This sprite has no 'Left' tag");
elseif (rightTag == nil) then
  return app.alert("ERROR: This sprite has no 'Right' tag");
elseif (upTag == nil) then
  return app.alert("ERROR: This sprite has no 'Up' tag");
elseif (hasCorrectFrameCount == false) then
  return app.alert("ERROR: The 'Up', 'Down', 'Left', and 'Right' tags must have exactly three frames each.");
end

local spriteSheet = Image(s.width * 12, s.height * 8);

--Clone the original sprite so we don't muck it up.
local coloredSprites = { s, cloneSpriteWithRedEyes(s), cloneSpriteWithYellowEyes(s), cloneSpriteWithBlueEyes(s), cloneSpriteWithPurpleEyes(s) };

--Draw each sprite onto the spriteSheet.
for i = 1,#coloredSprites do
  local csprite = coloredSprites[i];
  for j = 1,#csprite.tags do
    local t = csprite.tags[j];
    local destY = -1;
    if (t.name == "Down") then 
      destY = 0;
    elseif (t.name == "Left") then
      destY = s.height;
    elseif (t.name == "Right") then
      destY = 2 * s.height;
    elseif (t.name == "Up") then
      destY = 3 * s.height;
    end
    if (destY > -1 and i > 4) then
      destY = destY + 4 * s.height;
    end

    if (destY > -1) then
      local firstX = (i - 1) * 3 * s.width;
      if (i > 4) then
        firstX = firstX - (4 * 3 * s.width);
      end
      spriteSheet:drawSprite(csprite, t.fromFrame.frameNumber, Point(firstX, destY));
      spriteSheet:drawSprite(csprite, t.fromFrame.frameNumber + 1, Point(firstX + s.width, destY));
      spriteSheet:drawSprite(csprite, t.fromFrame.frameNumber + 2, Point(firstX + s.width * 2, destY));
    end
  end
end

local spritePath = "C:\\Users\\Jesse\\Documents\\RMMZ\\Smith\\img\\";
local spriteNameRoot = app.activeSprite.filename:match(".*[/\\](.+)%.aseprite");

spriteSheet:saveAs(spritePath.."characters\\"..spriteNameRoot.."Small.png");
spriteSheet:resize(spriteSheet.width * 2, spriteSheet.height * 2);
spriteSheet:saveAs(spritePath.."characters\\"..spriteNameRoot.."Large.png");

function exportCombatImages(cframe, csprite, cname)
  local image = Image(s.width, s.height);
  image:drawSprite(csprite, cframe, Point(0,0));
  image:resize(s.width * 3, s.height * 3);
  image:saveAs(spritePath.."sv_enemies\\"..spriteNameRoot..cname.."Small.png");
  image:resize(s.width * 6, s.height * 6);
  image:saveAs(spritePath.."sv_enemies\\"..spriteNameRoot..cname.."Large.png");
end

--Find the Combat tag, if any.
for i = 1,#s.tags do
  local t = s.tags[i];
  if (t.name == "Combat") then
    --Generate RMMZ 'sv_enemy' images (Small, Large)
    exportCombatImages(t.fromFrame.frameNumber, coloredSprites[1], "Green");
    exportCombatImages(t.fromFrame.frameNumber, coloredSprites[2], "Red");
    exportCombatImages(t.fromFrame.frameNumber, coloredSprites[3], "Yellow");
    exportCombatImages(t.fromFrame.frameNumber, coloredSprites[4], "Blue");
    exportCombatImages(t.fromFrame.frameNumber, coloredSprites[5], "Purple");

    break;
  end
end


--Clean up.
for i = 2,#coloredSprites do
  coloredSprites[i]:close();
end

Dialog(spriteNameRoot):label{label="Export Complete"}:button{text="Okay"}:show();
