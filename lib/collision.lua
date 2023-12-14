local collision = {}
function collision.checkRectangles(a, b)
	return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

function collision.resolveCollision(rect1, rect2)
	local overlapX = math.min(rect1.x + rect1.w, rect2.x + rect2.w) - math.max(rect1.x, rect2.x)
	local overlapY = math.min(rect1.y + rect1.h, rect2.y + rect2.h) - math.max(rect1.y, rect2.y)

	if overlapX < overlapY then
		if rect1.x < rect2.x then
			rect1.x = rect1.x - overlapX
		else
			rect1.x = rect1.x + overlapX
		end
	else
		if rect1.y < rect2.y then
			rect1.y = rect1.y - overlapY
		else
			rect1.y = rect1.y + overlapY
		end
	end
	return rect1
end
return collision
