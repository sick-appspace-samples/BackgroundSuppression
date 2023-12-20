
--Start of Global Scope---------------------------------------------------------

-- A point must have this minimum distance to background to become a foreground point
local THRESHOLD = 150.0

-- The first N scans are background
local BACKGROUND_COUNTER = 75

-- counter of input scans
local scanCounter = 0

-- Create a viewer instance
viewer = View.create()

-- Create the scan decorations
local scanDecorationForeground = View.ScanDecoration.create()
scanDecorationForeground:setPointSize(4)
scanDecorationForeground:setColor(255, 0, 0)

local scanDecorationBackground = View.ScanDecoration.create()
scanDecorationBackground:setPointSize(4)
scanDecorationBackground:setColor(68, 68, 68)

local scanDecoration = View.ScanDecoration.create()
scanDecoration:setPointSize(4)
scanDecoration:setColor(0, 0, 255)

-- Create all filters
local echoFilter = Scan.EchoFilter.create()
echoFilter:setType("FIRST")

local edgeHitFilter = Scan.EdgeHitFilter.create()
edgeHitFilter:setMaxDistNeighbor(100)
edgeHitFilter:setEnabled(false)

-- Remove finite distance with surrounding zeros
local particleFilter = Scan.ParticleFilter.create()
particleFilter:setThreshold(5000)
particleFilter:setEnabled( true)

-- Median 2D
local medianFilter = Scan.MedianFilter.create()
medianFilter:setEchoNumber(0)
medianFilter:setType("2D")
medianFilter:setWidth(3)
medianFilter:setEnabled(true)

-- Create provider. Providing starts automatically with the register call
-- which is found below the callback function
provider = Scan.Provider.File.create()
provider:setFile("resources/main.xml")
-- Set the DataSet of the recorded data which should be used
provider:setDataSetID(1)
provider:setDelayMs(100)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

---Is called for each new PolarScan
---@param scan Scan
function handleNewScan(scan)
  local startTime = DateTime.getTimestamp()

  local scan2 = echoFilter:filter(scan)
  local scan3 = edgeHitFilter:filter(scan2)
  local scan4 = particleFilter:filter(scan3)

  if ( scan4 ~= nil ) then
    local scan5 = medianFilter:filter(scan4)
    if ( scan5 ~= nil ) then

      scanCounter = scanCounter + 1

      local beamCount = scan5:getBeamCount()
      local echoCount = scan5:getEchoCount()

      local foregroundCount = 0

      if  scanCounter < BACKGROUND_COUNTER then
        -- save as reference/background scan for view
        backgroundScan = scan5:clone()
        -- as profile for the calculation
        backgroundContour = scan5:toProfile("DISTANCE")
        print(string.format("%s: Scan %s", DateTime.getTime(), "Background"))
      else
        -- get distance channel of scan
        local currentProfile = scan5:toProfile("DISTANCE")
        -- calculate difference of current contour and reference
        local difference = Profile.subtract(backgroundContour, currentProfile)
        -- inside points = 1, outside points = 0
        difference = Profile.binarize(difference, THRESHOLD, 10000, 1)
        -- count inside points
        foregroundCount = Profile.getSum(difference)
        -- let the inside points survive
        local backgroundSupressed = Profile.multiply(difference, currentProfile)
        -- copy the result back to the scan for later visualization
        Scan.importFromProfile(scan5, backgroundSupressed)
      end

      -- Showing scans on the ScanViewer
      if nil ~= viewer then
        viewer:clear()
        viewer:addScan(backgroundScan, scanDecorationBackground)
        viewer:addScan(scan5, scanDecorationForeground)
        viewer:present()
      end

      local deltaTime = DateTime.getTimestamp() - startTime
      if scanCounter % 15 == 1 then
        print(string.format("%s: Scan %8d (%d, %d, %d ms): Foreground Points = %4d ", DateTime.getTime(),
              scanCounter, beamCount, echoCount, deltaTime, foregroundCount))
      end
    end
  end
end
-- Register callback function to "OnNewScan" event.
-- This call also starts the playback of scans
Scan.Provider.File.register(provider, "OnNewScan", handleNewScan)

--End of Function and Event Scope------------------------------------------------
