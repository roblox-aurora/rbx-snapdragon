local function objectAssign<T>(target: T, ...: T): T
	local targets = {...}
	for _, t in pairs(targets) do
		for k ,v in pairs(t) do
			target[k] = v;
		end
	end
	return target
end

return objectAssign