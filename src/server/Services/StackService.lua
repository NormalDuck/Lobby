--!native
local Stack = {}
Stack.__index = Stack
function Stack.new(Size:number)
	local self = setmetatable({},Stack)
	self.stack = {}
	self.size = Size
	self.top = -1
	return self
end

function Stack:Push(Node)
	if #self.stack == self.size then 
		return "Stack Overflow"
	end
	self.top += 1
	self.stack[self.top] = Node
	return self.stack[self.top]
end

function Stack:Pop(Node)
	local PoppedNode = self.stack[self.top]
	if self:IsEmpty() then
		return "Stack Overflow"
	end
	self.stack[self.top] = nil
	self.top -= 1
	return PoppedNode
end

function Stack:Peek(Node)
	return self.stack[self.top]
end

function Stack:IsEmpty()
	return self.top == -1
end

return Stack