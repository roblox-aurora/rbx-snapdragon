local Signal = {}
Signal.__index = Signal

function Signal.new(): Signal
	return setmetatable({
		Bindable = Instance.new("BindableEvent");
	}, Signal)
end

export type Signal = {
	Fire: (self: Signal, ...any) -> (),
	Destroy: (self: Signal) -> (),
	Connect: (self: Signal, cb: (...any) -> ()) -> RBXScriptConnection,
	Wait: (self: Signal) -> unknown
}

export type Signal1<T> = {
	Fire: (self: Signal1<T>, v: T) -> (),
	Destroy: (self: Signal1<T>) -> (),
	Connect: (self: Signal1<T>, cb: (v: T) -> ()) -> RBXScriptConnection,
	Wait: (self: Signal1<T>) -> T,
}

export type SignalType = {
	new: () -> Signal,
}

function Signal:Connect(Callback)
	return self.Bindable.Event:Connect(function(GetArgumentStack)
		Callback(GetArgumentStack())
	end)
end

function Signal:Fire(...)
	local Arguments = { ... }
	local n = select("#", ...)

	self.Bindable:Fire(function()
		return unpack(Arguments, 1, n)
	end)
end

function Signal:Wait()
	return self.Bindable.Event:Wait()()
end

function Signal:Destroy()
	self.Bindable:Destroy()
end

return Signal :: SignalType
