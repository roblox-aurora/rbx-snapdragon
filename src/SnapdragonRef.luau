local types = require("./Types")
local refs = setmetatable({} :: { [types.SnapdragonRef]: unknown }, {__mode = "k"})

local SnapdragonRef = {}
SnapdragonRef.__index = SnapdragonRef

function SnapdragonRef.new(current)
	for ref, value in refs do
		if ref.current == current then
			return ref
		end
	end

	local ref = setmetatable({
		current = current
	}, SnapdragonRef)

	refs[ref] = current
	return ref
end

SnapdragonRef.__debug = refs

function SnapdragonRef.toRef(value)
	if typeof(value) == "Instance" then
		print("creating ref from instance")
		return SnapdragonRef.new(value)
	else
		if SnapdragonRef.is(value) then
			print("using snapdragon ref")
			return value
		elseif typeof(value) == "table" and value.current ~= nil then
			print("creating ref from another ref type")
			return SnapdragonRef.new(value.current)
		else
			error("Cannot convert value to snapdragon ref", 2)
		end
	end
end

function SnapdragonRef.__eq(a, b)
	return a.current == b.current
end

function SnapdragonRef.is(ref)
	return typeof(ref) == "table" and getmetatable(ref) == SnapdragonRef
end

return SnapdragonRef :: types.SnapdragonRefType