--- Vox

-- scales
-- DL, last modified 2021-09-12

-- modes
ionian = {0,2,4,5,7,9,11}
dorian = {0,2,3,5,7,9,10}
phrygian = {0,1,3,5,7,8,10}
lydian = {0,2,4,6,7,9,11}
mixolydian = {0,2,4,5,7,9,10}
aeolian = {0,2,3,5,7,8,10}
locrian = {0,1,3,5,6,8,10}

-- other scales
whole = {0,2,4,6,8,10}

-- scale mask function
function mask(scale, degrees)
  local m = {}
  for k, v in ipairs(degrees) do
    m[k] = scale[v]
  end
  return m
end

-- pentatonic scales
penta_maj = mask(ionian, {1,2,3,5,6})
penta_sus = mask(dorian, {1,2,4,5,7})
blues_min = mask(phrygian, {1,3,4,6,7})
blues_maj = mask(mixolydian, {1,2,4,5,6})
penta_min = mask(aeolian, {1,3,4,5,7})
japanese = mask(phrygian, {1,2,4,5,6})
--




-- divisions
divs = {1/32, 1/16, 1/8, 1/4, 1/2, 1, 2, 4, 8, 16, 32}
--





-- initial values
cv = {
  scale = mixolydian,
  octave = 0,
  degree = 1
}
--




-- Vox object
-- DL, last modified 2021-09-13

Vox = {}
function Vox:new(args)
  local o = setmetatable( {}, {__index = Vox} )
  local args = args == nil and {} or args

  o.on, o._on = args.on == nil and true or args.on, true
  o.level, o._level = args.level == nil and 1 or args.level, 1
  o.octave, o._octave = args.octave == nil and 0 or args.octave, 0
  o.degree, o._degree = args.degree == nil and 1 or args.degree, 1
  o.transpose, o._transpose = args.transpose == nil and 0 or args.transpose, 0

  o.scale = args.scale == nil and cv.scale or args.scale
  o.mask = args.mask == nil and nil or args.mask
  o.wrap = args.wrap == nil and false or args.wrap
  o.negharm = args.negharm == nil and false or args.negharm

  o.synth = args.synth == nil and function(note, level) --[[ii.jf.play_note(note / 12, level)]] return note, level end or args.synth

  o.seq = args.seq == nil and {} or args.seq
  o.preset = args.preset == nil and {} or args.preset

  return o
end

function Vox:play(args)
  local args = args == nil and {} or args

  self._on = args.on == nil and self._on or args.on
  self._level = args.level == nil and self._level or args.level
  self._octave = args.octave == nil and self._octave or args.octave
  self._degree = args.degree == nil and self._degree or args.degree
  self._transpose = args.transpose == nil and self._transpose or args.transpose

  self.scale = args.scale == nil and self.scale or args.scale
  self.mask = args.mask == nil and self.mask or args.mask
  self.wrap = args.wrap == nil and self.wrap or args.wrap
  self.negharm = args.negharm == nil and self.negharm or args.negharm

  self.synth = args.synth == nil and self.synth or args.synth

  return self:__on() and self.synth(self:__note(), self:__level())
end

function Vox:__on() return self.on and self._on end
function Vox:__level() return self.level * self._level end
function Vox:__wrap() return self.wrap and 0 or math.floor(self:__degree() / #self.scale) end
function Vox:__octave() return self.octave + self._octave + self:__wrap() end
function Vox:__degree() return (self.degree - 1) + (self._degree - 1) end
function Vox:__transpose() return self.transpose + self._transpose end

function Vox:__val() return self.scale[self:__degree() % #self.scale + 1] end
function Vox:__maskval() return self.scale[selector(self:__val(), self.mask, 1, #self.scale)] end

function Vox:__mask() return self.mask == nil and self:__val() or self:__maskval() end
function Vox:__pos() return self:__mask() + self:__transpose() end
function Vox:__neg() return (7 - self:__pos()) % 12 end

function Vox:__note() return (self.negharm and self:__neg() or self:__pos()) + self:__octave() * 12 end

-- functions for mulitple Vox objects
function _set(objects, property, val)
  for k, v in pairs(objects) do
    v[property] = val
  end
end

function _do(objects, method, args)
  for k, v in pairs(objects) do
    v[method](v, args)
  end
end
--





function clamp(x, min, max)
  return math.min( math.max( min, x ), max )
end

function round(x)
  return x % 1 >= 0.5 and math.ceil(x) or math.floor(x)
end

function linlin(x, in_min, in_max, out_min, out_max)
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function selector(x, data, in_min, in_max, out_min, out_max)
  out_min = out_min or 1
  out_max = out_max or #data
  return data[ clamp( round( linlin( x, in_min, in_max, out_min, out_max ) ), out_min, out_max ) ]
end
